rm(list = ls())
set.seed(12)
# library("RMV2.0")
library("ggplot2")
# library("dplyr")
library("gridExtra")
# library("nre")


### PS_2
setwd("/Users/stouzani/Google\ Drive/BTUS_Projects/MV_Projects/Non_routine_events/")
pre <- read.csv(file="Simu_clean_Data/PS_2_pre.csv")
post <- read.csv(file="Simu_clean_Data/PS_2_post.csv")
gbm_res <- RMV2.0::gbm_baseline(train_Data = pre,
                                pred_Data  = post,
                                variables = c("Temp", "tow","vacation"),
                                ncores=5)

post_Data <- dplyr::select(gbm_res$pred,time,eload,Temp)
y_pred <- gbm_res$prediction
predicted_post_Data <- post_Data
predicted_post_Data$eload <- y_pred

nre_detected <- nre::nre_detect(post_Data,predicted_post_Data)

dissim_tab <- nre_detected$dissim_tab
idx_nre <- which(dissim_tab$date > "2017-06-30" & dissim_tab$date < "2017-08-11")
idx_nre_2 <- which(dissim_tab$date == "2017-02-20" | dissim_tab$date == "2017-01-16")
idx_nre <- c(idx_nre_2,idx_nre)

dissim_tab$diss_nre <- NA
dissim_tab$diss_nre[idx_nre] <- dissim_tab$dissimilarity[idx_nre]

post_d <- nre::convert_to_daily(post)
post_d$eload_nre <- NA
post_d$eload_nre[idx_nre] <- post_d$eload[idx_nre]
post_d$eload_nre2 <- NA
post_d$eload_nre2[idx_nre_2] <- post_d$eload[idx_nre_2]


p1 <- ggplot(data = post_d, aes(x = date, y = eload)) +
  geom_line(color = "#00AFBB", size = 1)+
  geom_line(data = post_d, aes(x = date, y = eload_nre),color = "#F26968", size = 1)+
  geom_point(data = post_d, aes(x = date, y = eload_nre2),color = "#F26968", size = 2.5)+
  geom_vline(xintercept = nre_detected$nre_dates)+
  scale_y_continuous(name="kWh")+
  theme_bw() +
  theme(legend.position="top")+
  ggtitle("PS_2")+
  theme(text = element_text(size=12), axis.text.x = element_text(angle=0, vjust=0.5,size=12),
        axis.text.y = element_text(size=12), legend.text = element_text(size=12),
        plot.title = element_text(hjust = 0.5, face="bold",size=14))


p2 <- ggplot(data = dissim_tab, aes(x = date, y = dissimilarity)) +
  geom_point(color = "#00AFBB", size = 2)+
  geom_point(data = dissim_tab, aes(x = date, y = diss_nre),color = "#F26968", size = 2)+
  geom_vline(xintercept = nre_detected$nre_dates)+
  scale_y_continuous(name="Dissimilarity")+
  theme_bw() +
  theme(legend.position="top")+
  ggtitle("PS_2")+
  theme(text = element_text(size=12), axis.text.x = element_text(angle=0, vjust=0.5,size=12),
        axis.text.y = element_text(size=12), legend.text = element_text(size=12),
        plot.title = element_text(hjust = 0.5, face="bold",size=14))

grid.arrange(p1, p2, nrow = 2)


# NRE Adjustment

dts <- as.POSIXct(strptime(post$time, format = "%m/%d/%y %H:%M"))
idx_nre_0 <- which(dts >= "2017-06-30 00:00:00" & dts <= "2017-08-11 23:00:00")
idx_nre_0 <- c(idx_nre_0,which(dts >= "2017-02-20 00:00:00" & dts <= "2017-02-20 23:00:00"))
idx_nre_0 <- c(idx_nre_0,which(dts >= "2017-01-16 00:00:00" & dts <= "2017-01-16 23:00:00"))

post_nre <- post[idx_nre_0,]
post_train <- post[-idx_nre_0,]
gbm_res2 <- RMV2.0::gbm_baseline(train_Data = post_train,
                                 pred_Data  = post_nre,
                                 variables = c("Temp", "tow","vacation"),ncores=5)

post_adj <- post
post_adj$eload[idx_nre_0] <- gbm_res2$prediction


####  LO_2

pre <- read.csv(file="Simu_clean_Data/LO_2_pre.csv")
post <- read.csv(file="Simu_clean_Data/LO_2_post.csv")
gbm_res <- RMV2.0::gbm_baseline(train_Data = pre,
                                pred_Data  = post,
                                variables = c("Temp", "tow"),
                                ncores=5)

post_Data <- dplyr::select(gbm_res$pred,time,eload,Temp)
y_pred <- gbm_res$prediction
predicted_post_Data <- post_Data
predicted_post_Data$eload <- y_pred

nre_detected <- nre::nre_detect(post_Data,predicted_post_Data)

dissim_tab <- nre_detected$dissim_tab
idx_nre <- which(dissim_tab$date > "2017-06-5" & dissim_tab$date < "2017-08-9")
idx_nre_2 <- which(dissim_tab$date == "2017-02-20" | dissim_tab$date == "2017-01-16")
idx_nre <- c(idx_nre_2,idx_nre)

dissim_tab$diss_nre <- NA
dissim_tab$diss_nre[idx_nre] <- dissim_tab$dissimilarity[idx_nre]

post_d <- nre::convert_to_daily(post)
post_d$eload_nre <- NA
post_d$eload_nre[idx_nre] <- post_d$eload[idx_nre]
post_d$eload_nre2 <- NA
post_d$eload_nre2[idx_nre_2] <- post_d$eload[idx_nre_2]


p1 <- ggplot(data = post_d, aes(x = date, y = eload)) +
  geom_line(color = "#00AFBB", size = 1)+
  geom_line(data = post_d, aes(x = date, y = eload_nre),color = "#F26968", size = 1)+
  geom_point(data = post_d, aes(x = date, y = eload_nre2),color = "#F26968", size = 2.5)+
  geom_vline(xintercept = nre_detected$nre_dates)+
  scale_y_continuous(name="kWh")+
  theme_bw() +
  theme(legend.position="top")+
  ggtitle("LO_2")+
  theme(text = element_text(size=12), axis.text.x = element_text(angle=0, vjust=0.5,size=12),
        axis.text.y = element_text(size=12), legend.text = element_text(size=12),
        plot.title = element_text(hjust = 0.5, face="bold",size=14))


p2 <- ggplot(data = dissim_tab, aes(x = date, y = dissimilarity)) +
  geom_point(color = "#00AFBB", size = 2)+
  geom_point(data = dissim_tab, aes(x = date, y = diss_nre),color = "#F26968", size = 2)+
  geom_vline(xintercept = nre_detected$nre_dates)+
  scale_y_continuous(name="Dissimilarity")+
  theme_bw() +
  theme(legend.position="top")+
  ggtitle("LO_2")+
  theme(text = element_text(size=12), axis.text.x = element_text(angle=0, vjust=0.5,size=12),
        axis.text.y = element_text(size=12), legend.text = element_text(size=12),
        plot.title = element_text(hjust = 0.5, face="bold",size=14))

grid.arrange(p1, p2, nrow = 2)


# NRE Adjustment

dts <- as.POSIXct(strptime(post$time, format = "%m/%d/%y %H:%M"))
idx_nre_0 <- which(dts >= "2017-06-5 00:00:00" & dts <= "2017-08-9 23:00:00")
idx_nre_0 <- c(idx_nre_0,which(dts >= "2017-02-20 00:00:00" & dts <= "2017-02-20 23:00:00"))
idx_nre_0 <- c(idx_nre_0,which(dts >= "2017-01-16 00:00:00" & dts <= "2017-01-16 23:00:00"))

post_nre <- post[idx_nre_0,]
post_train <- post[-idx_nre_0,]
gbm_res2 <- RMV2.0::gbm_baseline(train_Data = post_train,
                                 pred_Data  = post_nre,
                                 variables = c("Temp", "tow"),ncores=5)

post_adj <- post
post_adj$eload[idx_nre_0] <- gbm_res2$prediction

