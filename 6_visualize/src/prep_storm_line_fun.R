prep_storm_line_fun <- function(storm_points_sf, DateTime, storm_line_cfg, timesteps){
  this_DateTime <- as.POSIXct(DateTime, tz = "UTC")
  colfunc <- colorRampPalette(c(storm_line_cfg$light_col, storm_line_cfg$dark_col))
  plot_fun <- if(is.null(storm_points_sf)) {
    function() {} # storms are optional
  } else {

    before_this_dot <- filter(storm_points_sf, DateTime <= this_DateTime)
    last_storm_pt_date <- tail(before_this_dot, 1) %>% pull(DateTime)

    tail_lengths <- seq(storm_line_cfg$tail_length, storm_line_cfg$fade_i, by = -storm_line_cfg$fade_i)
    cols <- colfunc(length(tail_lengths))

    # If we are past the storm dates, just show the line as very faint
    # If it is the very last frame, force the line to be the faint shade at the end
    if(this_DateTime > last_storm_pt_date | this_DateTime == tail(timesteps, 1)) {
      tail_lengths <- c()
      cols <- c()
    }

    # Keep a faint line to show where the hurricane has been
    tail_lengths <- c(nrow(before_this_dot), tail_lengths)
    cols <- c("grey80", cols)

    function(){
      for(i in 1:length(tail_lengths)) {
        # Plot each fading section individually
        # For the last one, use the last row in the data
        n_start <- nrow(before_this_dot) - tail_lengths[i]
        n_end <- nrow(before_this_dot) - ifelse(i==length(tail_lengths), 0, tail_lengths[i+1])

        # For the initial ones where tail_lengths may be > nrow
        if(n_start < 1) { n_start <- 1 }
        if(n_end < 1) { n_end <- nrow(before_this_dot) }

        plot(st_geometry(slice(before_this_dot, n_start:n_end)), add=TRUE,
             col=cols[i], type = 'l', lty="dotted", lwd = 2)
      }
    }
  }
  return(plot_fun)
}
