## Detection data, adding tidal informaton, assign day or night, and filtering for ghost detections
#### Manuscript: 'Habitat or safety? Drivers and management implications of juvenile lemon shark space use in mangrove nursery', Kressler, Trevail, et al. (in prep)

# unless otherwise noted, code written by Molly M Kressler

	
##################
## Prepare Workspace
##################

## Load packages 

pacman::p_load(tidyverse,sf,lubridate,ggplot2,fuzzyjoin,BiocManager,suncalc)

## Load Data 

# cleaned detection data

	eb19<-read.csv('testing/EB2019e_noaccel_manuscript.csv')%>%dplyr::select(-X) # dataset provided by Evan Byrnes
		{
		eb19$time<-as_datetime(eb19$time,tz='EST') 
		eb19$station<-as.factor(eb19$station)
		eb19$location<-as.factor(eb19$location)
		eb19$PIT<-as.factor(eb19$PIT)
		eb19$transmitter_id<-as.factor(eb19$transmitter_id)
		eb19$acoustic_serial<-as.factor(eb19$acoustic_serial)
		eb19$download<-as.factor(eb19$download)
		eb19$sex<-as.factor(eb19$sex) }
	eb20<-read.csv('testing/EB2020e_noaccel_manuscript.csv')%>%dplyr::select(-X) # dataset provided by Evan Byrnes
		{
		eb20$time<-as_datetime(eb20$time,tz='EST') 
		eb20$station<-as.factor(eb20$station)
		eb20$location<-as.factor(eb20$location)
		eb20$PIT<-as.factor(eb20$PIT)
		eb20$transmitter_id<-as.factor(eb20$transmitter_id)
		eb20$acoustic_serial<-as.factor(eb20$acoustic_serial)
		eb20$download<-as.factor(eb20$download)
		eb20$sex<-as.factor(eb20$sex) }
	eb<-bind_rows(eb19,eb20)

# tidal data 

	tides2019<-read.csv('testing/tides2019.csv') # dataset downloaded from NOAA
	tides2020<-read.csv('testing/tides2020.csv') # dataset downloaded from NOAA
	tall<-bind_rows(tides2019,tides2020)
	tall$Date.Time<-as_datetime(tall$Date.Time,tz="EST")

##################
## Narrow detections to only sharks in size class 60-99cm
##################

# remove sharks that aren't in the 2-3 year old size class: 60-99cm PCL (pre-caudal length)

	eb<-eb%>%filter(pcl>=60,pcl<100)
	summary(eb)

##################
## Assign Tide Phase by time
##################

#create tidephase df - this describes the interval during which the tide phase is peak low or high tide. 18,000 = 2 hours either side of peak time. 

	tidephasesEB<-tall%>%dplyr::select(Date.Time,Prediction,Type) %>%
	 dplyr::rename(Tidepeak_time=Date.Time,Tidepeak_type=Type, Tide_height=Prediction) %>%
	  mutate(Phase_start=Tidepeak_time-dseconds(9000))%>% 
	  mutate(Phase_end=Tidepeak_time+dseconds(9000))

# join the detections (eb) and the tidephase df, and classify whether the deteciton is inside a low or high tide tidephase interval
	eb_withtide<-interval_left_join(eb,tidephasesEB,by=c("time"="Phase_start","time"="Phase_end"))
	
	stopifnot(nrow(eb_withtide)=/=nrow(eb)) # check 

# detections can fall outside the window of peak times, classify these as Tidepeak_type='M'
	eb_withtide<-eb_withtide%>%replace_na(list(Tidepeak_type='M'))
	eb_withtide$Tidepeak_type<-as.factor(eb_withtide$Tidepeak_type)
	summary(eb_withtide)

# get rid of what is now unnescessary 
	eb_withtide<-eb_withtide%>%dplyr::select(-Tidepeak_time,-Phase_end,-Phase_start,-Tide_height)

##################
## Assign Day/Night by time
##################

eb_withtide$day<-as.Date(eb_withtide$time,tz="EST") # a double-check

# create sun stages df usign the suncalc package
	sunEB<-getSunlightTimes(date=eb_withtide$day,lat=25.7491,lon=-79.2564,keep=c('sunrise','sunset'),tz="EST")

# bond the columns of the detections with tide to the sun phases df, and classify whether the detection occurs at night or during the day
	eb_withtide_withsun<-bind_cols(eb_withtide,sunEB)
	data<-eb_withtide_withsun%>%mutate(dorn=case_when(time>=sunrise & time<sunset ~ 'day',.default='night'))
	data$dorn<-as.factor(data$dorn)
	summary(data)

##################
## Filter Ghost Detections
##################

# the bulk/base of this code is provided by Alice Trevail, Liam Langley, Stephen Lang & Luke Ozsanlav-Harris. It identifies whether the difference in time between detections is greater than a threshold value, and then I've added some lines to calculate whether a detection is a 'ghost' or not. 
	#----------------------------------------------#
	## 1. Prepare Data (done in steps above)    ####
	#----------------------------------------------#

	df_diagnostic <- data

	#----------------------------------------------#
	## 2. Define segments using time threshold  ####
	#----------------------------------------------#

	## Here, we segments where gaps in data exceed a time threshold
	## This code will work based on time differences calculated in the main workflow

	#--------------------#
	##USER INPUT START##
	#--------------------#

	# define maximum gap in data using time threshold. 
	x2=48*60*60
	x1=24*60*60
	x05=12*60*60 #
	x025=6*60*60 # 6 hours, selected in the end [for how I settled on 6 hours as the threshold value see R file ' ']
	threshold_time <- as.period(x025, unit = "secs")

	## set units of time difference column (difftime) in the tracking data
	## if working with df_diagnostic, time difference will be in seconds
	units_df_datetime <- "secs"

	# define minimum number of points for valid segment 
	threshold_points <- 2

	#-----------------#
	##USER INPUT END##
	#-----------------#

	options(tibble.width=Inf)

	# add difftime column

	df_diagnostic <-  df_diagnostic %>%group_by(PIT) %>%mutate(difftime = difftime(time, lag(time), units="secs")  )

	# convert the time threshold to the same units as difftime in df_diagnostic
	threshold_units <- as.numeric(as.period(threshold_time, units_df_datetime))
	  
	df_segments <- df_diagnostic %>%
	  group_by(PIT) %>%
	  mutate(segment_start = case_when(row_number()==1 ~ TRUE,
	                                   difftime > threshold_units ~ TRUE),
	         segment_row_number = case_when(segment_start == TRUE ~ cur_group_rows())) %>%
	  fill(segment_row_number) %>%
	  ungroup() %>% group_split(PIT) %>%
	  purrr::map_df(~.x %>% group_by(segment_row_number) %>% mutate(segment_num = cur_group_id())) %>% 
	  ungroup() %>% select(-c(segment_row_number)) %>% 
	  mutate(SegmentID = paste0(PIT, "_", segment_num))

	summary(df_segments)
	head(df_segments,20)
	print(df_segments[490:600,c(1,2,11:12)],n=50)


	## mark a detection as ghost if IT and its LEAD (the next) row == TRUE (based on segment.start col)

	df_segments2<-df_segments%>%group_by(PIT)%>%mutate(ghost=case_when((segment_start==TRUE & lag(segment_start)==TRUE) ~ TRUE,TRUE~FALSE))
	summary(df_segments2)


	ghosts_removed<-df_segments2%>%filter(ghost==FALSE)
	nrow(ghosts_removed)


	#################
	## SAVE DATA, NEW DATASET IDENTIFIED BY GHOSTS REMOVED
	#################

	write.csv(ghosts_removed,'testing/detections_2019to2020_pcl60to99_withMtide_cleaned_GHOSTSREMOVED_dec22.csv')




























