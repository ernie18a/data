Calculation: prior_close = close of the last completed bar of the reference timeframe
Calculation: current_close = close of the reference-timeframe bar still forming
Long: prior_close < current_close
Short: prior_close >= current_close
Exit: long, prior_close >= current_close
Exit: short, prior_close < current_close