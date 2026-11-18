Calculation: current_htf_close = close of the higher-timeframe bar containing the current bar, still forming
Calculation: prev_htf_close = close of the last completed higher-timeframe bar before the bar containing the current bar
Long: current_htf_close > prev_htf_close
Short: current_htf_close <= prev_htf_close
Exit: Long, current_htf_close <= prev_htf_close
Exit: Short, current_htf_close > prev_htf_close