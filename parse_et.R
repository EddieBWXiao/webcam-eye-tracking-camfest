parse_et<-function(fname){
  #shameless wrapper function
  parse_et_single(fname,1)
  parse_et_single(fname,2)
}
parse_et_single<-function(fname, trial_idx){
  # Bowen Xiao (Eddie) 2025, for CamFest demo visuals
  # fname: path to the .json file saved
  # trial_idx: which eye-tracking trial to visualise; 1 & 2 for CamFest
  
  # Load required libraries
  library(jsonlite)
  library(ggplot2)
  library(jpeg)
  
  # Load the JSON file
  #fname <- 'testing_TRCN.json'
  raw_text <- readChar(fname, file.info(fname)$size)
  raw <- fromJSON(raw_text)
  
  # select the eye-tracking trials
  has_webgazer_data <- !sapply(raw$webgazer_data, is.null) # CHANGE: add trial labels
  if(!is.null(raw$phase)){
    # sorry this is a silly compatibility stuff with old version that had no phase col
    dET <- raw[has_webgazer_data & raw$phase!="CirclesCheck",]
  }else{
    dET <- raw[has_webgazer_data,]
  }
  dtrial <- dET[trial_idx,]  # Get the second eye tracking trial
  
  # Extract x-y coordinates from eye tracking data
  et_data<-list()
  et_data$x <- dtrial$webgazer_data[[1]]$x
  et_data$y <- dtrial$webgazer_data[[1]]$y
  
  # Extract target information
  the_target <- dtrial$webgazer_targets$`#the_view_img`
  
  # Get rectangle coordinates
  rect_x <- the_target$left
  rect_y <- the_target$top
  rect_width <- the_target$width
  rect_height <- the_target$height
  
  # Read the image
  img <- readJPEG("unexpected-visitors-compressed.jpg")
  
  # Get image dimensions
  img_height <- dim(img)[1]
  img_width <- dim(img)[2]
  
  # For the plot with overlay:
  print("Generating image...")
  overlay_alpha = 0.6
  par(mar = c(0, 0, 0, 0))  # Remove margins
  # new empty plot with the coordinates from rect_*
  plot(1, type = "n", xlim = c(rect_x, rect_x + rect_width), 
       ylim = c(rect_y + rect_height, rect_y),  # Note: y-axis is flipped in R
       xlab = "", ylab = "", axes = FALSE)
  
  # Add the image as a background
  rasterImage(img, rect_x, rect_y, rect_x + rect_width, rect_y + rect_height)
  
  # Overlay the points and lines
  # First the lines connecting the points
  lines(et_data$x, et_data$y, col = rgb(1, 0, 0, overlay_alpha), lwd = 2)
  
  # Then the points themselves
  points(et_data$x, et_data$y, col = rgb(1, 0, 0, overlay_alpha), pch = 1, cex = 1.2)  
  
  # ====== save the image =======
  # Create output filename by replacing .json with .jpg and adding trial_idx suffix
  print("Saving image...")
  output_filename <- gsub("\\.json$", paste0("_trial", trial_idx, ".png"), fname)
  
  # Save the plot as a PNG file
  dev.copy(png, filename = output_filename, width = rect_width/1.8, height = rect_height/1.8)
  dev.off()
}