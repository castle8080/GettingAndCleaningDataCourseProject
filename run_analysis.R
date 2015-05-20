library(utils)

#
# Runs analysis on mobile data samples.
#
runMobileDataAnalysis <- function(
    rawDataUrl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
    dataDir    = ".")
{
    dataSetDir     <- file.path(dataDir, "UCI HAR Dataset")
    rawDataFile    <- file.path(dataDir, "raw_data.zip")
    subsetNames    <- c("train", "test")
    activityLookup <- NULL
    
    #
    # Downloads and unzips the raw data if it is not present.
    #
    initializeRawData <- function() {
        if (!file.exists(dataSetDir)) {
            if (!file.exists(rawDataFile)) {
                print(paste0(c("Downloading: ", rawDataUrl)))


                # For non windows or if windows has a version of curl on the path. 
                # download.file(rawDataUrl, destfile=rawDataFile, method="curl", extra = c("--insecure"))

		# For windows: setInternet2 will use a different implementation for 
		#              opening URLs that supports https.
		setInternet2(TRUE)
                download.file(rawDataUrl, destfile=rawDataFile)

            }
            print("Unzipping data")
            unzip(rawDataFile, exdir = dataDir)
        }
    }
    
    #
    # Gets the file name for a logical data set name in a given subset.
    # A subset such as "train" or "test".
    #
    rawDataFileName <- function(dataSetName, subSet) {
        file.path(dataSetDir, subSet, paste0(dataSetName, "_", subSet, ".txt"))
    }
    
    #
    # Returns the column names in the main dataset (x).
    # The column names are cleaned up by exchaning non alphanumeric
    # character sequences for _.  Leading and trailing _'s are removed
    # as a second pass.
    #
    # Example: 'fBodyAccJerk-meanFreq()-X' becomes 'fBodyAccJerk_meanFreq_X
    #
    getFeatureNames <- function() {
        features <- read.table(file.path(dataSetDir, "features.txt"))
        sapply(features[,2], function(colName) { 
            gsub("(^_+|_+$)", "", gsub("[^a-zA-Z0-9]+", "_", colName))
        })
    }
    
    #
    # Get the activity name for an activity id.
    #
    getActivityName <- function(activityId) {
        if (is.null(activityLookup)) {
            activityLookup <<- read.table(file.path(dataSetDir, "activity_labels.txt"))    
        }
        activityLookup[activityId, 2]
    }
    
    #
    # Loads the detailed data from the raw data.
    #
    # 1) Training and test data is merged.
    # 2) Activity descriptions, subject ids, and data subset names are added.
    # 3) Data columns are filtered out that aren't related to standard deviation
    #    or a mean.
    #
    loadDetailData <- function() {
        measurements <- NULL
        subjects     <- NULL
        activities   <- NULL
        
        #
        # Load the raw data into the various variables from all subsets.
        #
        loadRawData <- function() {
            colNames <- getFeatureNames()
            
            for (subsetName in subsetNames) {
                measurementData <- read.table(rawDataFileName("X", subsetName), col.names = colNames)
                subjectData     <- read.table(rawDataFileName("subject", subsetName))
                activityData    <- read.table(rawDataFileName("y", subsetName))
                
                measurements <<- rbind(measurements, measurementData)
                subjects     <<- rbind(subjects, subjectData)
                activities   <<- rbind(activities, activityData)
            }
        }
        
        #
        # Get the activity descriptions for the detail data.
        #
        getActivityDescriptions <- function() {
            sapply(activities[,1], getActivityName)
        }
        
        #
        # Get the subjects for the detail data.
        #
        getSubjects <- function() {
            subjects[,1]
        }
        
        #
        # Gets the measurements related to standard deviations and means
        # from the detailed data set.
        #
        getStddevAndMeanMeasurements <- function() {
            colNames <- names(measurements)
            colNames <- colNames[grep("_(std|mean)(_|$)", colNames)]
            m <- measurements[,colNames]
            
        }
        
        #
        # Get the detailed data for stddevs and means with the subject and
        # activity.
        #
        getDetailData <- function() {
            loadRawData()
            cbind(
                subject  = getSubjects(),
                activity = getActivityDescriptions(),
                getStddevAndMeanMeasurements()
            )
        }
        
        getDetailData()
    }
    
    #
    # Groups the detailed data by subject and activty and returns 1
    # row per distince subject and activity.  The measurements will be
    # averaged for the measurement columns.
    #
    computedGroupedAverages <- function(detailData) {
        
        # Measurements start in the 3rd column
        measurementStartIndex <- 3
        
        # Split the data into groups based on the subject and activity
        getGroupedDetailData <- function(detailData) {
            split(detailData, list(detailData$subject, detailData$activity))
        }
        
        # Gets a data frame for the averages of all the measurements columns
        # where 1 row is generated for each group.
        getMeasurementAverages <- function(detailDataGroups) {
            colLength <- dim(detailDataGroups[[1]])[[2]]
            
            averages <- sapply(detailDataGroups, function(detailDataGroup) {
                colMeans(detailDataGroup[measurementStartIndex:colLength])
            })
            
            # The data needs to be transposed before returning it.
            as.data.frame(t(averages))
        }
        
        getSubjects <- function(detailDataGroups) {
            sapply(detailDataGroups, function(detailDataGroup) {
                detailDataGroup[1,1]
            })
        }
        
        getActivities <- function(detailDataGroups) {
            sapply(detailDataGroups, function(detailDataGroup) {
                detailDataGroup[1,2]
            })
        }
        
        getGroupedAverages <- function() {
            groupedData <- getGroupedDetailData(detailData)
            
            averages <- cbind(
                subject = getSubjects(groupedData),
                activity = getActivities(groupedData),
                getMeasurementAverages(groupedData)
            )
            
            # Reset row names to be numeric
            rownames(averages) <- 1:dim(averages)[[1]]
            
            averages
        }
        
        getGroupedAverages()
    }
    
    saveTable <- function(name, dataTable) {
        fileName <- file.path(dataDir, paste0(name, ".txt"))
        print(paste0("Writing to: ", fileName))
        write.table(dataTable, file = fileName, row.names=FALSE)
    }
    
    #
    # Run the anaylysis.
    #
    run <- function() {
        print("Initializing raw data.")
        initializeRawData()
        
        print("Loading detailed data.")
        detailData <- loadDetailData()
        
        print("Computing averages.")
        averages <- computedGroupedAverages(detailData)
        
        print("Saving data sets.")
        saveTable("detailedMobileData", detailData)
        saveTable("mobileAverageDataBySubjectActivity", averages)
    }
    
    run()
}

runMobileDataAnalysis()
