Long: close > open of forming daily bar AND (open of forming daily bar - low of forming daily bar) > range parameter × point AND position side is flat AND hour of datetime < long hour limit parameter
Short: close < open of forming daily bar AND (high of forming daily bar - open of forming daily bar) > range parameter × point AND position side is flat AND hour of datetime < short hour limit parameter
Exit: long, hour of datetime >= market close hour parameter
Exit: short, hour of datetime >= market close hour parameter