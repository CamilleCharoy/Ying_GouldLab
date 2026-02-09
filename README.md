# Cell Counting and CoExpression scripts (Gould lab)

FIJI script to segment the number of positive cells in a specific channel in a 200um wide stretch of tissue. It will run through all the .tif files present in a directory and save the channel of interest with a mask of the ROIs of each positive cell identified in a newly created Treated_Images folder. It will create a new Excel speadsheet for each folder analysed and save the size, coordinates and mean fluorescence intensity for every cell segmented in each image.


##     Installation
To use this script you need to have the following FIJI plugins installed as well as the script itself. 

### Plugins: 
    - CSBDeep
    - Stardist
    - ResultsToExcel
 To install the plugins navigate to Help > Update then click on Manage Update Sites. From there check the boxes for CSBDeep, Stardist and ResultToExcel and click Apply and Close, then click Apply Changes. 
 FIJI needs to be closed for the newly installed plugins to be available.  
 
### Script:
The script can be saved in the script folder of the FIJI installation, scripts saved in a folder there will stay visible at the bottom of the Plugins menu.

##     Running the script
The script can be run either by selecting it in the Plugins menu or by dragging and dropping the file in FIJI, from there just click Run and a dialog box will appear.

The code will take some time to run, images will open and close in the background. The code can be run on the cluster or on a worksation.

##     Results
For each folder analysed a new spreadsheet will be created, the measurements for each images will be added in a new tab.
The name of the images analysed is in cell A1 of the tab. The first two lines are showing the height of the area created, the thresholding method used and the value of the lower threshold used for that image.
In each line of the table underneath are the measurements for each cell: cell area, mean fluorescence intensity, cell coordinates and cell dimentions (width and height).

## Data Analysis
The excel file YingCellAndAreaMeasures.xlsm can be used for data wrangling. On openning macro usage need to be enabled.
This macro will help with the counting and the measurement of the area occupied by cells. You can indicate a lower threshold to discard any detection too small to be a healthy cell and an upper treshold to discard any detection too large to be an individual cell.

The macro is defining 10 area of identical size in the cortex, counts the number of positive cells in each area and measure the average nuclei size.


# Cell Counting script
###     Description
Script to segment positive cells and measure the fluorescence intensity of this fluorophore in each segmented cells
###     Dialog box choices
- **Select folder with tif files**: Click browse to choose the folder where the images are
- **Select folder to save files into**: Click browse to choose the folder where the result file will be kept, the script will generate a new folder to save the images in that folder too.   
- **Channel to analyse**: Select the channel to analyse (from 1 to 4)
- **Name of spreadsheet to create**: Give a name to the Excel spreadsheet that will have the results in


# CoExpression script
###      Description
Script to segment positive cells and measure the fluorescence intensity of this fluorophore and of a second one in each segmented cells.
###      Dialog box choices
- **Select folder with tif files**: Click browse to choose the folder where the images are
- **Select folder to save files into**: Click browse to choose the folder where the result file will be kept, the script will generate a new folder to save the images in that folder too.   
- **Channel for segmentation**: Select the channel to use for the segmentation (from 1 to 4)
- **Staining Channel1**: name of the staining used for segmentation
- **2nd Channel**: Select the second channel to analyse (from 1 to 4)
- **Staining Channel2**: name of the staining used
- **Name of spreadsheet to create**: Give a name to the Excel spreadsheet that will have the results in


## Data Analysis
The excel file YingCoExpressionCounterV1.xlsm can be used for data wrangling. On openning macro usage need to be enabled.
This macro will help with the counting and the measurement of the area occupied by cells. You can indicate a lower threshold to discard any detection too small to be a healthy cell and an upper treshold to discard any detection too large to be an individual cell.

The macro is defining 10 area of identical size in the cortex, counts the number of positive cells in each area, measure the average area of positive nucleus stain and counts the number of co-expressing cells in each area.


# For Method section
A 200um wide area of interest was selected and thresholded (IsoData dark), a median filter (radius 2) was applied before positive cells were segmented with StarDist (cite paper below). Cell position, size and mean fluorescent intensities was exported to Excel for further analysis.


Schmidt, U., Weigert, M., Broaddus, C., & Myers, G. (2018). Cell Detection with Star-Convex Polygons. In Lecture Notes in Computer Science (pp. 265–273). Springer International Publishing. doi:10.1007/978-3-030-00934-2_30
