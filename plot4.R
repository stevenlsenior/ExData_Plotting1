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

png(filename = "plot3.png", height = 480, width = 480) ## Open file device, set height and width

## Set number of rows and columns

par(mfrow = c(2,2))

## Create first panel

with(data, plot(
	x = DateTime,
	y = Global_active_power,
	type = "l",
	main = "",
	ylab = "Global Active Power (kilowatts)",
	xlab = "")
)

## Create second panel

with(data, plot(
	x = DateTime,
	y = Voltage,
	type = "l",
	xlab = "datetime")
     )

## Create third panel

plot(x = data$DateTime,
     y = data$Sub_metering_1,
     type = "l",
     ylab = "Energy to sub metering",
     xlab = "")
lines(x = data$DateTime, y = data$Sub_metering_2, col = "red")
lines(x = data$DateTime, y = data$Sub_metering_3, col = "blue")
legend("topright", 
	 lty = 1, 
	 col = c("black", "red", "blue"), 
	 legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3")
)

## Create fourth panel

with(data, plot(
	x = DateTime,
	y = Global_reactive_power,
	type = "l",
	xlab = "datetime")
     )

dev.off() ## Close file device