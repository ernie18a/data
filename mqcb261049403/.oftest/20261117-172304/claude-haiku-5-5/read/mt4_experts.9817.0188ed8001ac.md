Calculation: higher_tf_close = close of the last completed bar of the higher timeframe
Calculation: higher_tf_open = open of the last completed bar of the higher timeframe
Long: higher_tf_close > higher_tf_open AND hour of datetime < entry_hour_threshold AND position side is flat
Short: higher_tf_close < higher_tf_open AND hour of datetime < entry_hour_threshold AND position side is flat
Exit: long, hour of datetime > exit_hour_threshold
Exit: short, hour of datetime > exit_hour_threshold