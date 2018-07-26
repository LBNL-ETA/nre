#-------------------------------------------------------------------------------
# nre (version 1.0.0)
# Samir Touzani, PhD
#-------------------------------------------------------------------------------


#' Calculate dissimilarity metric
#'
#' \code{dissim_calc} This function calculate CORT dissimilarity metric for 
#' each day of the energy use time series
#'
#'
#' @param post_Data A dataframe that contains actual post energy use time series
#' @param predicted_post_Data A dataframe that contains predicted post energy use time series
#' @return A one column matrix where the value in each row is 
#' the dissimilarity metric of a day.
#'
#' @export


dissim_calc <- function(post_Data,predicted_post_Data){
  N_days <- dim(post_Data)[1]
  dissim_tab <- matrix(nrow = N_days,nc=1)
  for(i in 1:N_days){
    dissim_tab[i,] <- TSclust::diss.CORT(as.numeric(post_Data[i,]),
                                         as.numeric(predicted_post_Data[i,]),
                                         k=1,
                                         deltamethod="Euclid")
  }
  return(dissim_tab)
}


#' Detect potential Non-Routine Events
#'
#' \code{nre_detect} This function uses a statistical change point algorithm 
#' (i.e., \code{cpt.meanvar} function from "changepoint" package) to detect 
#' potential non-routine events
#'
#'
#' @param post_Data A dataframe that contains the actual post energy use time series
#' @param predicted_post_Data A dataframe that contains the predicted post energy use time series
#' @return a nre_detect object, which is a list with the following components:
#' \describe{
#'   \item{dissim_tab}{A dataframe that correspond to the computed daily dissimilarities}
#'   \item{cpt_res}{An object of S4 class "cpt" (refer to changepoint package 
#' documentation for more information)}
#'   \item{nre_dates}{A vector containing character string that corresponds to 
#' potential non-routine events dates}
#' } 
#'
#' @export


nre_detect <- function(post_Data,predicted_post_Data){
  post_Data_d <- daily_tab(post_Data) #reshape Data
  post_Data_d_0 <- dplyr::select(post_Data_d,-date,-wday)
  post_Data_d_0 <- as.data.frame(t(apply(post_Data_d_0,1,zoo::na.locf)))
  predicted_post_Data_d <- daily_tab(predicted_post_Data) #reshape Data
  predicted_post_Data_d_0 <- dplyr::select(predicted_post_Data_d,-date,-wday)
  predicted_post_Data_d_0 <- as.data.frame(t(apply(predicted_post_Data_d_0,1,zoo::na.locf)))
  dissim_tab <- dissim_calc(post_Data_d_0,predicted_post_Data_d_0)
  cpt_res <- changepoint::cpt.meanvar(dissim_tab[,1],
                                      method="PELT",
                                      penalty="MBIC", 
                                      minseglen = 2)
  Cp_new <- Cp_filter(cpt_res@cpts,dissim_tab)
  nre_dates <- post_Data_d$date[Cp_new]
  dissim_tab <- as.data.frame(dissim_tab)
  dissim_tab <- cbind(post_Data_d$date,dissim_tab)
  names(dissim_tab)<- c("date","dissimilarity")
  return(list(dissim_tab = dissim_tab,
              cpt_res = cpt_res,
              nre_dates = nre_dates))
}


# # Indices of non-routine events


# nre_idx <- function(Data, nre_dates){
#     n_dates <- dim(nre_dates)[1]
#     idx_nre <- NULL
#     for (i in 1:n_dates){
#         idx_nre <- c(idx_nre,
#                      which(dts >= nre_dates$start[i] & dts <= nre_dates$end[i]))
#     }
#     retrurn(idx_nre)
# }