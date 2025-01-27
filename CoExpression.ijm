/*
 * Macro template to process multiple images in a folder
 * Camille Charoy, Crick Calm, Jan 2022
 * plugins needed: Stardist, CSBDeep, ResultsToExcel
 */

#@ File (label = "Select folder with tif files", style = "directory") input
#@ File (label = "Select folder to save files into", style = "directory") output
#@ String(value="     ", visibility="MESSAGE") message
#@ Integer (label="Channel for segmentation", min=1, max=4, value=3) myint1
#@ String (label = "Staining channel1", value="") Segm
#@ String(value="     ", visibility="MESSAGE") message
#@ Integer (label="2nd Channel", min=1, max=4, value=3) myint2
#@ String (label = "Staining channel2", value="") Exp
#@ String(value="     ", visibility="MESSAGE") message
#@ String (label = "Name of spreadsheet to create", value="*.xlsx") outfile

suffix = ".tif"

newdir = output+File.separator+"Images_Segmented_on_"+Segm+File.separator
File.makeDirectory(newdir);

processFolder(input);
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i], i);
	}
}

function processFile(input, output, file, i) {
	open(input+File.separator+file);
	// Rotate image if necessary
	Dialog.createNonBlocking("Rotation");
	Dialog.addNumber("Angle :", 0);
	Dialog.show();
	myangle = Dialog.getNumber();
	run("Rotate... ", "angle="+ myangle +" grid=1 interpolation=Bilinear");

	// Create a 200um wide ROI
	getPixelSize(unit, pixelWidth, pixelHeight);
	width = 200 / pixelWidth;
	makeRectangle(0, 400, width, 1500);
	Dialog.createNonBlocking("Adjust Selection");
	Dialog.addMessage("Adjust selection area then click OK");
	Dialog.show();

	// Get height of ROI and lower threshold limit
	run("Set Measurements...", "area mean center bounding display redirect=None decimal=3");
	run("Measure");
	
	// 1st channel
	// Image segmentation using stardist	
	all = getImageID();
	run("Duplicate...", "duplicate channels="+myint1+"");
	rename(Segm);
	Ch1 = getTitle();

	selectImage(Ch1);
	setAutoThreshold("IsoData dark");
	getThreshold(lower, upper);
	n = nResults;
	setResult("Treshold", n-1, getInfo("threshold.method")+" "+Segm);
	setResult("Lower", n-1, lower);

	run("Median...", "radius=2");
	run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'"+Ch1+"', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'99.60000000000001', 'probThresh':'0.35000000000000003', 'nmsThresh':'0.2', 'outputType':'ROI Manager', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
	roiManager("Show All without labels");

	// signal intensity from each detected cell
	roiManager("Deselect");
	roiManager("Measure");
	
	// 2nd channel
	// signal intensity in cells detected with channel1
	selectImage(all);
	run("Duplicate...", "duplicate channels="+myint2+"");
	rename(Exp);
	Ch2 = getTitle();

	selectImage(Ch2);
	setAutoThreshold("IsoData dark");
	getThreshold(lower, upper);
	setResult("Treshold", n, getInfo("threshold.method")+" "+Exp);
	setResult("Lower", n, lower);
	
	run("Median...", "radius=2");
	
	roiManager("Deselect");
	roiManager("Measure");	
	

	// Export measurements to Excel
	run("Read and Write Excel", "file=["+output+File.separator+outfile+"] sheet=Sheet"+i+"");
	run("Clear Results");
	run("From ROI Manager");
	selectImage(Ch1);
	saveAs("Tiff", newdir+File.separator+file+Ch1);
	selectImage(Ch2);
	saveAs("Tiff", newdir+File.separator+file+Ch2);
	roiManager("Delete");	
	run("Close All");
}

showMessage("Done", "All images in the folder have been quantified!!");