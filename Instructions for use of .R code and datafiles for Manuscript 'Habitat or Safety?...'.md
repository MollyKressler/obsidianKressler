
Instructions for using the code and data files associated with the manuscript *'Habitat or safety? Drivers and management implications of juvenile lemon shark space use in mangrove nursery'*** .

Molly M Kressler
8 March 2023 

---

**This document illustrates the workflow for the analyses in the aforementioned manuscript.** 

There are **7 .R files** which perform the analyses. There are *two support .R files* which include the code to run supplementary analyses, e.g. a sensitivity anlysis for setting a threshold to classify 'ghost' detections. 

The 7 .R files were written in Sublime Text, on a MacBook, using R version 4.2.0, and can be opened in R or R-Studio, or an alternative text editor, e.g. Visual Studio. 

The accompanying **data** for the analyses can be found in the folder '**data**'. For a description of the datasets please see the section in this document called 'Data Sets Described for Manuscript 'Habitat or safety? Drivers and management implications of juvenile lemon shark space use in mangrove nursery'. 

All the analyses can be performed using the six provided datasets if the code flow is followed through in its entirety. 

---

## R Code Files 

#R #files #code #analysis #dataprep 

Manuscript 'Habitat or safety? Drivers and management implications of juvenile lemon shark space use in mangrove nursery'

**1.*** 'detectiondata_KresslerTrevailetal_inprep.R' 
**2.** 


---

## Data Sets 

Manuscript 'Habitat or safety? Drivers and management implications of juvenile lemon shark space use in mangrove nursery'

#data #modelling #analysis

**All analyses and outcomes can be conducted and/or produced from these starting six data sets.**
The data sets will be described in no particular order. They can be found in the folder 'data' on the manuscript repo. [remember to put in the link here]

- Detection data, collected and provided by Evan Byrnes: ![[EB2020e_noaccel_manuscript.csv]]![[EB2019e_noaccel_manuscript 1.csv]]
	- Acoustic telemetry data 
	- 2019 - 2020
- Habitat data, collected by Drone Adventures in partnerhsip with Save Our Seas Foundation and the Bimini Biological Field Station Foundation: 
	- provded as a shapefile, ESRI
	- open using the 'sf' package in R
	- Habitat is classified in vectors
- Center point of the cental mangrove forest int he North Bimini estuary
	- provided as a shapefile, KML
	- open using the 'sf' package in R
- Bounding box which extends beyodn the habitat data coverage, 'bigger box'
	- provided as a shapefile, ESRI
	- open using the 'sf' package in R
- Tidal data 
	- downloaded from the USA National Oceanographic and Atmospheric Association public website. 
	- collated into years, 2019 & 2020
- Bimini land countours
	-  provided as a shapefile, ESRI
	- open using the 'sf' package in R

{'r'} 
testing<-testing
{'r'}



---

### Any issues? 

Please contact the corresponding author on the manuscript, Molly M Kressler at m.kressler@exeter.ac.uk. 

