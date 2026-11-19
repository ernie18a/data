Calculation: candle body proportion = if high > low then abs(close - open) / (high - low) else 0
Long: Nasdaq-100 E-mini futures close > open
Short: Nasdaq-100 E-mini futures close < open
Long: Russell 2000 E-mini futures close > open
Short: Russell 2000 E-mini futures close < open
Long: Dow E-mini futures close > open
Short: Dow E-mini futures close < open
Long: Nasdaq-100 E-mini futures close > open AND Russell 2000 E-mini futures close > open AND Dow E-mini futures close > open AND CBOE Volatility Index close < previous close
Short: Nasdaq-100 E-mini futures close < open AND Russell 2000 E-mini futures close < open AND Dow E-mini futures close < open AND CBOE Volatility Index close > previous close
Long: candle body proportion >= P1 AND close > open AND high - close <= (high - low) * P2 AND Nasdaq-100 E-mini futures close > open AND Russell 2000 E-mini futures close > open AND Dow E-mini futures close > open AND CBOE Volatility Index close < previous close
Short: candle body proportion >= P1 AND close < open AND close - low <= (high - low) * P2 AND Nasdaq-100 E-mini futures close < open AND Russell 2000 E-mini futures close < open AND Dow E-mini futures close < open AND CBOE Volatility Index close > previous close