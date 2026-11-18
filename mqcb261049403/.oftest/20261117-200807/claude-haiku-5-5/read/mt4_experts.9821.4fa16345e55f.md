Long: close > open of the bar still forming on range timeframe AND (open of the bar still forming on range timeframe - low of the bar still forming on range timeframe) > min_range AND position side is flat AND hour of datetime < max_entry_hour
Short: close < open of the bar still forming on range timeframe AND (high of the bar still forming on range timeframe - open of the bar still forming on range timeframe) > min_range AND position side is flat AND hour of datetime < max_entry_hour
Exit: long, hour of datetime >= close_hour
Exit: short, hour of datetime >= close_hour