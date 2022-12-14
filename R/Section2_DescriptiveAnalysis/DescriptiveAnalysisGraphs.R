#Using mortality to predict incidence for rare and lethal cancers
#in very small areas. Biometrical Journal (2022)
# Author: Jaione Etxeberria 
# This code is developed in R-4.2.1 version

#rm(list=ls())
#setwd(".../Section2_DescriptiveAnalysis")
######################################################################
##### FIGURE 1: Map of regions in Navarre and Basque Country
library(classInt)
library(RColorBrewer)
library(sf)
library(tmap)
library(viridis)
library(ggplot2)
library(ggrepel)

##### FIGURE 1: Map of regions in Navarre and Basque Country
carto <- st_read('carto/carto.shp')
carto$ID <- as.character(seq(1,nrow(carto)))
carto$regions <- factor(c("1-Gran Bilbao", "2-North Biscay", "3-South Biscay", "4-West Gipuzkoa", "5-East Gipuzkoa",
                       "6-Donostia-Bajo Bidasoa", "7-Alava", "8-Mid Navarra", "9-Navarra South", "10-Navarra North", "11-Pamplona"),
              levels=c("1-Gran Bilbao", "2-North Biscay", "3-South Biscay", "4-West Gipuzkoa", "5-East Gipuzkoa",
                       "6-Donostia-Bajo Bidasoa", "7-Alava", "8-Mid Navarra", "9-Navarra South", "10-Navarra North", "11-Pamplona"))

colcode <- c("#9E0142", "#D53E4F", "#F46D43", "#FDAE61", "#FEE08B", "#FFFFBF", "#E6F598", "#ABDDA4", "#66C2A5","#3288BD", "#5E4FA2")

pos.x <- pos.y <- rep(0,nrow(carto))
pos.x[3] <- 1
pos.y[4] <- 0.25
pos.y[7] <- 0.25
pos.y[9] <- 0.25

fig1 <- tm_shape(carto) + 
  tm_polygons(col="regions", palette=colcode, title="", legend.show=T) + 
  tm_layout(main.title="Regions in Navarre and Basque Country",
            main.title.size=1.5, main.title.position="center",
            legend.outside=T, legend.outside.position="right",
            frame=FALSE) + 
  tm_shape(carto) + 
  tm_text("ID", size=1, fontface="bold", xmod=pos.x, ymod=pos.y)
 tmap_save(fig1,paste0("Fig1.pdf"))
           
           
######################################################################
##### FIGURE 2:Age and gender specific incidence and mortality rates per 100.000


DBrain <- read.table(file="DBrainNA.txt")

Brain <- data.frame(aggregate(DBrain[,c(5,6)],list(sex=DBrain$sex,outcome=DBrain$outcome,age=DBrain$age),sum, na.rm = TRUE))
Brain$rate <- Brain$cases/Brain$pop*10^5
a <- max(Brain$rate)
xm <- Brain[Brain$outcome=="Incidence" & Brain$sex==1,]$rate
ym <- Brain[Brain$outcome=="Mortality"& Brain$sex==1,]$rate

x <- Brain[Brain$outcome=="Incidence" & Brain$sex==2,]$rate
y <- Brain[Brain$outcome=="Mortality"& Brain$sex==2,]$rate

agelabels <- c("0-4","5-9","10-14","15-19","20-24","25-29","30-34","35-39","40-44",
               "45-49","50-54","55-59","60-64","65-69","70-74","75-79","80-84","85+")
cexes <- 1.5

## Create and save the Figure 2 
pdf(file="Fig2.pdf",width=10,height = 5)

plot(1:18,x,type="n",ylim=c(0,a), col="blue", pch=16 ,cex.main=cexes ,lwd="2", 
     cex.lab=cexes, cex.axis=cexes, cex=1.3 , xlab="" ,ylab="", xaxt='n', 
     main=paste("Age and gender-specific incidence and mortality rates per 100.000"),xlog=TRUE)
axis(1, at=1:18, labels=agelabels,cex.lab=cexes,cex.axis=cexes)



#### Males/Incidence
lines(1:18,xm, pch=16,lwd=2,col="blue")
#### Males/Mortality
lines(1:18,ym, pch=16,lwd=2,lty=2, col="blue")
#### Females./Incidence
lines(1:18,x, pch=16,lwd=2,col="red")
#### Females./Mortality
lines(1:18,y, pch=16,lwd=2,lty=2, col="red")

labgender <- c("Incidence males","Mortality males","Incidence females","Mortality females")

legend("topleft",legend=labgender,col=rep(c("blue","red"),each=2),bty="n", lwd=2, lty=rep(c(1,2),2), cex=1)

dev.off()
######################################################################
##### FIGURE 3: Crude incidence and mortality rates trends by gender

BrainP <- data.frame(aggregate(DBrain[,c(5,6)],list(sex=DBrain$sex,outcome=DBrain$outcome,period=DBrain$period),sum, na.rm = TRUE))
BrainP$rate=BrainP$cases/BrainP$pop*10^5
cexes <- 1.8
years <- unique(BrainP$period)
yearslab <- c("1989-1990","1991-1992","1993-1994","1995-1996","1997-1998","1999-2000","2001-2002","2003-2004","2005-2006","2007-2008")

l <- length(years)
labgender=c("Incidence males","Mortality males","Incidence females","Mortality females")

spim <- BrainP[BrainP$sex==1 &  BrainP$outcome=="Incidence",]$rate
spif <- BrainP[BrainP$sex==2 &   BrainP$outcome=="Incidence",]$rate

spmm <- BrainP[BrainP$sex==1 &  BrainP$outcome=="Mortality",]$rate
spmf <- BrainP[BrainP$sex==2 &   BrainP$outcome=="Mortality",]$rate

pdf(file="Fig3.pdf",width=14,height = 7)

plot(years,spim,type="n",ylim=c(0,30), col="blue", pch=16 ,cex.main=cexes ,lwd="2", 
     cex.lab=cexes, cex.axis=cexes, cex=1.3 , xlab="" ,ylab="", xaxt='n', 
     main=paste("Gender-specific incidence and mortality rate trends per 100.000"),xlog=TRUE)

axis(1, at=years, labels=yearslab,cex.lab=cexes,cex.axis=cexes)

#### Males/Incidence
lines(years[1:(l-2)],spim[1:(l-2)], pch=16,lwd=2,col="blue")
#### Males/Mortality
lines(years[1:l],spmm[1:l], pch=16,lwd=2,lty=2, col="blue")
#### Females/Incidence
lines(years[1:(l-2)],spif[1:(l-2)], pch=16,lwd=2,col="red")
#### Females/Mortality
lines(years[1:l],spmf[1:l], pch=16,lwd=2,lty=2,col="red")

abline(v=years[l-2],lty=2)
legend("bottom", horiz=T, legend=labgender,col=rep(c("blue","red"),each=2), 
       bty="n", lwd=2, lty=rep(c(1,2),2), cex=1.5)
dev.off()


######################################################################
##### FIGURE 4 (UPPER SIDE): Crude Incidence and mortality rates for the whole period in Navarre and Basque Country

carto <- st_read('carto/carto.shp')
carto$region <- c("Gran Bilbao", "North Biscay", "South Biscay", "West Gipuzkoa", "East Gipuzkoa", "Donostia-Bajo Bidasoa", "Alava", "Mid Navarra", "Navarra South", "Navarra North", "Pamplona")

n <- length(unique(DBrain$age))
m <- length(unique(DBrain$sex))
s <- length(unique(DBrain$region))
rate <- matrix(0,s,1)
comarc <- carto$region

data <- DBrain[DBrain$outcome=="Incidence",]
for(i in 1:s){
  r=apply(subset(data, (region == i), select = c(cases, pop)),2,sum,na.rm=TRUE)
  rate[i] <- r[1]/r[2]*10^5
  }

regionInci <- data.frame(comarc,round(rate,3))
colnames(regionInci) <- c("region","crude_rate")
regionInci

data <- DBrain[DBrain$outcome=="Mortality",]
for(i in 1:s){
  r=apply(subset(data, (region == i), select = c(cases, pop)),2,sum,na.rm=TRUE)
  rate[i] <- r[1]/r[2]*10^5
  }
regionMort <- data.frame(comarc,round(rate,3))
colnames(regionMort) <- c("region","crude_rate")
regionMort

carto$CIR <- regionInci$crude_rate
carto$CMR <- regionMort$crude_rate
a <- floor(min(carto$CIR,carto$CMR))
b <- ceiling(max(carto$CIR,carto$CMR))

my.palette <- rev(viridis(12))
breaks <- seq(a,b,length.out = 12)

fig4_1 <- tm_shape(carto) + 
  tm_polygons(col=c("CIR","CMR"), breaks=breaks, palette=my.palette,
              labels=levels(cut(a:b, breaks=breaks)),
              title="", legend.show=T, legend.is.portrait=F) + 
  tm_layout(main.title="Crude incidence and mortality rates for the whole period in Navarre and Basque Country",
            main.title.size=0.8, main.title.position="center",
            legend.outside.position="bottom",
            legend.position = c(0.10, 0.25), 
            legend.text.size=0.83,
            legend.outside=TRUE,
            panel.labels = c("Crude incidence rates", "Crude mortality rates"),
            panel.label.bg.color="#1E9B8AFF") +
  tm_facets(nrow=1, ncol=2)
tmap_save(fig4_1,paste0("Fig4_1.pdf"))

######################################################################
##### FIGURE 4 (BOTTOM SIDE): Scatter plot of incidence and mortality rates by region



datacor <- data.frame(regionInci,regionMort)
nbaplot <- ggplot(datacor, aes(x= crude_rate, y = crude_rate.1)) + 
           geom_point(color = "grey", size = 5) + 
           labs(x = "Incidence rates",y="Mortality rates",title = "Scatter plot of incidence and mortality rates by region")

fig4_2 <- nbaplot + 
  geom_label_repel(aes(label = region),
                   box.padding   = 0.35, 
                   point.padding = 0.5,
                   segment.color = 'grey50') +
  theme_classic() + theme( plot.title = element_text( size=13, face="bold"))

pdf("Fig4_2.pdf",width = 10,height=7)
print(fig4_2)
dev.off()



