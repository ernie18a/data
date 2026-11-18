Calculation: reference_close = close of the last completed reference-timeframe bar
Calculation: reference_range = high - low of the last completed reference-timeframe bar
Calculation: upper_breakout_level = reference_close + upper_breakout_factor * reference_range / upper_breakout_divisor
Calculation: lower_breakout_level = reference_close - lower_breakout_factor * reference_range / lower_breakout_divisor
Calculation: upper_short_level = reference_close + upper_short_factor * reference_range / upper_short_divisor
Calculation: lower_long_level = reference_close - lower_long_factor * reference_range / lower_long_divisor
Calculation: upper_target_level = (high / low of the last completed reference-timeframe bar) * reference_close
Calculation: lower_target_level = reference_close - (upper_target_level - reference_close)
Long: high of the current bar > upper_breakout_level
Long: low of the current bar <= lower_long_level
Short: low of the current bar < lower_breakout_level
Short: high of the current bar >= upper_short_level
Exit: long, high of the current bar >= upper_target_level
Exit: short, low of the current bar <= lower_target_level