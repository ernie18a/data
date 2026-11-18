Calculation: Current-bar open = open of the still-forming bar of the selected calculation timeframe
Calculation: Current-bar low = low of the still-forming bar of the selected calculation timeframe
Calculation: Current-bar high = high of the still-forming bar of the selected calculation timeframe
Long: Bid > current-bar open AND current-bar open minus current-bar low > distance-threshold parameter in points AND total open order count < order-count-limit parameter AND current hour < entry-hour cutoff parameter
Short: Ask < current-bar open AND current-bar high minus current-bar open > distance-threshold parameter in points AND total open order count < order-count-limit parameter AND current hour < entry-hour cutoff parameter
Exit: long, current hour > market-close-hour parameter minus exit-offset parameter
Exit: short, current hour > market-close-hour parameter minus exit-offset parameter