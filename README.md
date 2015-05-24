# Getting And Cleaning Data Course Project

This project is for the Coursera class Getting and Cleaning Data.

https://class.coursera.org/getdata-014

The script run_analysis.R in this project will analyze data collected by
subjects wearning smart phones while performing certain activities.

Information about the data collection can be found here:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The raw data that is analyze can be found here:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

## Running Analysis

There is one script run_analysis.R.  To run the script type:

    $ Rscript run_analysis.R

Sample output:

    [1] "Initializing raw data."
    [1] "Loading detailed data."
    [1] "Computing averages."
    [1] "Saving data sets."
    [1] "Writing to: ./detailedMobileData.txt"
    [1] "Writing to: ./mobileAverageDataBySubjectActivity.txt"

### Inputs

The analysis script will download and unzip the raw data if the raw data
directory is not unzipped into the current working directory.  The exepcted
raw data directory is "UCI HAR Dataset".

If you want to run with a fresh raw data set.  Delete the mentioned directory
and run the script again.

### Outputs

2 files will be produced by running the analysis script.

* detailedMobileData.txt - This file contains the merged raw data and is useful for debugging.
* mobileAverageDataBySubjectActivity.txt - This file contains the average measurements for each unique subject and activity.

Descriptions for the columsn in mobileAverageDataBySubjectActivty can be found
in CodeBook.md.

## Logic

The anaylis script performs the following steps:

1. Downloads and unzips the raw data if it is not present.
2. Reads the "test" and "train" data sets for the "subject", "X", and "y" data files.
3. Activity ids are transformed into activity descriptions.
4. The measurement columns from the "x" files are filtered so that only measurements for standard deviations and means are present.
5. The "subject", "y", and the filtered "x" files are all merged into a single table by their corresponding line numbers.
6. This merged dataset is output as "detailedMobileData.txt".
7. The detailed data is broken into groups by subject and activity.
8. The observations for each unique subject and activity are condensed into a single row by taking the average for all measurements for each subject and activity combination.
9. The averaged measurements are output as "mobileAverageDataByubjectActivity.txt".

