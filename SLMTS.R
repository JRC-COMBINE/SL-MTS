computeSL = function(mts_data_list, num_trends = 3, rolling_window_size = 18, bin_size = 30, num_cores = 3){

  library("MARSS")
  library("parallel")
  library("pracma")
  
  
  r_it <- c("diagonal and equal")
  cntl_list <- list(minit = 10, maxit= 20)
  model_list <- list(m=num_trends, R=r_it)
  k <- (rolling_window_size*60/bin_size)-1
  
  
  result <- mclapply(mts_data_list, function(mts_data){
    
    num_bin <- nrow(mts_data)
    num_var <- ncol(mts_data)
    
    timeStamps <- seq(from = 1, to = num_bin-k)
    SL_fit <- vector()
    SL_lwr <- vector()
    SL_upr <- vector()
    
    z_scaled_data <- scale(mts_data)
    
    for(i in (k+1):(num_bin-1)){
      scaled_in <- scale(z_scaled_data[(i-k):i,])
      
      scaled_center <- attr(scaled_in,'scaled:center')
      scaled_scale <- attr(scaled_in,'scaled:scale')
      
      fit <- tryCatch({
        fit <- MARSS(t(scaled_in), model=model_list,z.score=F, form="dfa", silent = T, control = cntl_list)
      },error = function(e){
        fit <- NULL
      })
      
      out_Sample_fit <- vector()
      in_Sample_fit <- vector()
      
      out_Sample_lwr <- vector()
      in_Sample_lwr <- vector() 
      
      out_Sample_upr <- vector()
      in_Sample_upr <- vector() 
      
      if (!is.null(fit)){
        kfasModel <- MARSSkfas( fit, return.kfas.model=T)
        kfasModel <- kfasModel$kfas.model
        par.mat <- coef(fit, type = "matrix") # in sample prediction
        predicted_out <- predict(kfasModel, n.ahead = 1, interval = 'prediction', level = 0.5) # out sample prediction
        predicted_out_fit <- sapply(predicted_out, function(z) z[1])
        predicted_out_lwr <- sapply(predicted_out, function(z) z[2])
        predicted_out_upr <- sapply(predicted_out, function(z) z[3])
        
        predicted_out_fit <- predicted_out_fit*scaled_scale+scaled_center
        predicted_out_lwr <- predicted_out_lwr*scaled_scale+scaled_center
        predicted_out_upr <- predicted_out_upr*scaled_scale+scaled_center
        actual_out <- z_scaled_data[i+1,]
        
        predicted_in <- predict(kfasModel, interval = 'prediction', level=0.95)
        predicted_in_fit <- sapply(predicted_in, function(z) z[,1])
        predicted_in_lwr <- sapply(predicted_in, function(z) z[,2])
        predicted_in_upr <- sapply(predicted_in, function(z) z[,3])
        
        predicted_in_fit<- t(apply(predicted_in_fit,1,function(z) z*scaled_scale+scaled_center))
        predicted_in_lwr<- t(apply(predicted_in_lwr,1,function(z) z*scaled_scale+scaled_center))
        predicted_in_upr<- t(apply(predicted_in_upr,1,function(z) z*scaled_scale+scaled_center))
        
        
        for(j in 1:num_var){
          out_Sample_fit[j] <- (predicted_out_fit[j] - actual_out[j])^2
          in_Sample_fit[j] <- mean((predicted_in_fit[,j] - z_scaled_data[(i-k):i,j])^2,na.rm=T)
          
          
          out_Sample_lwr[j] <- (predicted_out_lwr[j] - actual_out[j])^2
          in_Sample_lwr[j] <- mean((predicted_in_lwr[,j] - z_scaled_data[(i-k):i,j])^2,na.rm=T)
          
          
          out_Sample_upr[j] <- (predicted_out_upr[j] - actual_out[j])^2
          in_Sample_upr[j] <- mean((predicted_in_upr[,j] - z_scaled_data[(i-k):i,j])^2,na.rm=T)
          
        }
        SL_fit[i+1] <- mean(out_Sample_fit - in_Sample_fit)
        SL_lwr[i+1] <- mean(out_Sample_lwr - in_Sample_lwr)
        SL_upr[i+1] <- mean(out_Sample_upr - in_Sample_upr) 
      }
    }
    
    out <- as.data.frame(cbind(mts_data,SL_fit,SL_lwr,SL_upr))
    return(out)
  }, mc.cores = num_cores)
  
  return(result)
}
