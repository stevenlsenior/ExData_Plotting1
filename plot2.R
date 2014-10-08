## Install packages
install.packages(c("dplyr", "sqldf", "lubridate"))
library(dplyr)
library(sqldf)
library(lubridate)

## Download data, if not already present
if(!file.exists("household_power_consumption.txt")){
	fileURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
	download.file(fileURL, destfile = "household_power_consumption.zip", method  = "curl")
	unzip(zipfile = "household_power_consumption.zip")
}

## Read only data for dates 1/2/2007 and 2/2/2007 using read.csv.sql
data <- read.csv.sql("household_power_consumption.txt", 
			   sql = "SELECT * from file WHERE Date IN ('1/2/2007', '2/2/2007')", 
			   sep = ";", 
			   header = TRUE)

data <- as.tbl(data)		## Enables use of dplyr manipulation functions

## Combine Date and Time variables into DateTime and drop separate Date and Time variables
DateTime <- as.POSIXct(paste(data$Date, data$Time), format = "%d/%m/%Y %H:%M:%S")
data <- data %>% 
	mutate(DateTime = DateTime) %>%
	select(-Date, -Time, DateTime, Global_active_power, Global_reactive_power, 
		 Voltage, Global_intensity, Sub_metering_1, Sub_metering_2, Sub_metering_3)

## Plot histogram of global active power to an PNG file

png(filename = "plot2.png", height = 480, width = 480) ## Open file device, set height and width

with(data, plot(
	x = DateTime,
	y = Global_active_power,
	type = "l",
	main = "",
	ylab = "Global Active Power (kilowatts)",
	xlab = "")
)
     
dev.off() ## Close file device

