Calculation: bullish alignment = chart-bar Supertrend direction(default multiplier, default ATR lookback) is bullish AND Supertrend direction(additional multiplier, additional ATR lookback, T1 bars, last completed bar, carried onto chart bars) is bullish
Calculation: bearish alignment = chart-bar Supertrend direction(default multiplier, default ATR lookback) is bearish AND Supertrend direction(additional multiplier, additional ATR lookback, T1 bars, last completed bar, carried onto chart bars) is bearish
Long: bullish alignment AND NOT bullish alignment[1] AND (VWAP filter is off OR close > VWAP)
Short: bearish alignment AND NOT bearish alignment[1] AND (VWAP filter is off OR close < VWAP)
Exit: long, bullish alignment[1] AND NOT bullish alignment
Exit: short, bearish alignment[1] AND NOT bearish alignment