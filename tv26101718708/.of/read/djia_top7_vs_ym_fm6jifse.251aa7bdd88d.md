Long: close > session VWAP
Short: close <= session VWAP
Long: close > previous session's final VWAP
Short: close <= previous session's final VWAP
Long: close > reference price, where reference price is either the current session open or the previous session close
Short: close < reference price, where reference price is either the current session open or the previous session close
Long: (close - session open) / session open >= threshold AND session open > 0 AND previous session close > 0
Short: (close - session open) / session open <= -threshold AND session open > 0 AND previous session close > 0