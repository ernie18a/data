Calculation: Session VWAP = cumulative_sum(hlc3 * volume) / cumulative_sum(volume) since the current session began, including the current bar
Long: close > Session VWAP
Short: close < Session VWAP