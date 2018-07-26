#-------------------------------------------------------------------------------
# nre (version 1.0.0)
# Samir Touzani, PhD
#-------------------------------------------------------------------------------


#' Convert interval data into daily data
#'
#' \code{convert_to_day} This function convert interval data into daily data
#'
#'
#' @param Data A dataframe that contains interval data
#' @param kWh A logical if TRUE it means that the interval data are in kWh. If FALSE
#' it means that the data are in kW.
#' @param thresh a minimal number of hours per day to compute the daily kWh/kW.
#' @return A dataframe with daily interval data
#'
#' @export

convert_to_daily <- function(Data,kWh = TRUE, thresh = 22){ 
  Data <- time_var(Data)
  dates <- unique(Data$date)
  N_days <- length(dates)
  Data_daily <-as.data.frame(matrix(nr=N_days, nc=6))
  names(Data_daily)<- c("date","eload","Temp","wday")
  Data_daily$date <- dates
  for(k in 1:N_days){
    k_day <- dates[k]
    idx_k_day <- which(Data$date == k_day)
    if(length(idx_k_day)>=thresh){
      if (kWh){
        Data_daily$eload[k] <- sum(Data$eload[idx_k_day])
      }
      else{Data_daily$eload[k] <- mean(Data$eload[idx_k_day])}
      Data_daily$Temp[k] <- mean(Data$Temp[idx_k_day])
      Data_daily$wday[k] <- unique(Data$wday[idx_k_day])[1]
    }
  }
  return(Data_daily)
}


# Extract features from time stamps
#' @export

time_var <- function(Data){
  Data$dts <- as.POSIXct(strptime(Data$time, format = "%m/%d/%y %H:%M"))
  Data$wday <- as.POSIXlt(Data$dts)$wday
  Data$date <- lubridate::date(Data$dts)
  Data$hour <- lubridate::hour(Data$dts) +1
  Data$tod <- Data$hour + lubridate::minute(Data$dts)/60
  Data <- Data[complete.cases(Data),]
  return(Data)
}


#' @export

daily_tab <- function(Data){
  Data <- time_var(Data)
  Data <- dplyr::select(Data,date,tod,wday,eload)
  Data <- tidyr::spread(Data,tod,eload)
  return(Data)
}


#' @export
Cp_filter <- function(Cp,dist_ts){
  Cp_new <- Cp[1:(length(Cp)-1)]
  diff_Cp <- diff(Cp)
  idx_2 <- which(diff_Cp==2)
  if(length(idx_2)!=0){
    for(i in 1:length(idx_2)){
      idx_Cp <- Cp[idx_2[i]]
      test_i <- which(max(c(dist_ts[idx_Cp],dist_ts[idx_Cp+1],dist_ts[idx_Cp+2]))==c(dist_ts[idx_Cp],dist_ts[idx_Cp+1],dist_ts[idx_Cp+2]))
      if(test_i == 1){
        Cp_new[idx_2[i]] <- idx_Cp
        Cp_new[idx_2[i]+1] <- idx_Cp
      }
      if(test_i == 2){
        Cp_new[idx_2[i]] <- idx_Cp+1
        Cp_new[idx_2[i]+1] <- idx_Cp+1
      }
      if(test_i == 3){
        Cp_new[idx_2[i]] <- idx_Cp+2
        Cp_new[idx_2[i]+1] <- idx_Cp+2
      }
    }
  }
  idx_3 <- which(diff_Cp==3)
  if(length(idx_3)!=0){
    for(i in 1:length(idx_3)){
      idx_Cp <- Cp[idx_3[i]]
      test_i <- which(max(c(dist_ts[idx_Cp],dist_ts[idx_Cp+1],dist_ts[idx_Cp+2],dist_ts[idx_Cp+3]))==c(dist_ts[idx_Cp],dist_ts[idx_Cp+1],dist_ts[idx_Cp+2],dist_ts[idx_Cp+3]))
      if(test_i == 1){
        Cp_new[idx_3[i]] <- idx_Cp
        Cp_new[idx_3[i]+1] <- idx_Cp
      }
      if(test_i == 2){
        Cp_new[idx_3[i]] <- idx_Cp+1
        Cp_new[idx_3[i]+1] <- idx_Cp+1
      }
      if(test_i == 3){
        Cp_new[idx_3[i]] <- idx_Cp+2
        Cp_new[idx_3[i]+1] <- idx_Cp+2
      }
      if(test_i == 4){
        Cp_new[idx_3[i]] <- idx_Cp+3
        Cp_new[idx_3[i]+1] <- idx_Cp+3
      }
    }
  }
  return(unique(Cp_new))
}