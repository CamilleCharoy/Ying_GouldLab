/*
 * Macro template to process multiple images in a folder
 * Camille Charoy, Crick Calm, July 2021
 * plugins needed: Stardist, CSBDeep, ResultsToExcel
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix
#@ String (label = "Output File Name", value="*.xlsx") outfile

processFolder(input);
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i], i);
	}
}

function processFile(input, output, file, i) {
	open(input+File.separator+file);

	// 1.Rotate image if necessary and create a 200um wide area
	Dialog.createNonBlocking("Adjust Selection");
	Dialog.addMessage("Rotate image if nececary then click OK\n\n   (in Image > Transform > Rotate...)");
	Dialog.show();

	getPixelSize(unit, pixelWidth, pixelHeight);
	width = 200 / pixelWidth;
	makeRectangle(0, 400, width, 2000);

	Dialog.createNonBlocking("Adjust Selection");
	Dialog.addMessage("Adjust selection area then click OK");
	Dialog.show();

	all = getImageID();
	run("Duplicate...", "duplicate channels=1-4");
	stainings = getImageID();
	selectImage(all);
	run("Duplicate...", "duplicate channels=1");
	dapi = getTitle();

	// 2.Image segmentation using stardist
	selectImage(dapi);
	run("Median...", "radius=2");
	run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'"+dapi+"', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'99.60000000000001', 'probThresh':'0.35000000000000003', 'nmsThresh':'0.2', 'outputType':'ROI Manager', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
	roiManager("Show All");

	selectImage(stainings);
	run("Set Measurements...", "area mean center stack redirect=None decimal=3");
	run("Subtract Background...", "rolling=30");
	Stack.setChannel(3);
	roiManager("Deselect");
	roiManager("Measure");
	Stack.setChannel(4);
	roiManager("Measure");
	
	// 3.Export measurements to Excel
	run("Read and Write Excel", "file=["+output+File.separator+ outfile+"] sheet=Sheet"+i+"");
	run("Clear Results");
	roiManager("Delete");
	run("Close All");
}

