Calculation: Adaptive overbought threshold = 50 + overbought multiplier × base factor × max(selected overbought volatility percentage ÷ 5, 0.5), where selected overbought volatility percentage is either ATR ÷ close × 100 or absolute(close − VWAP) ÷ close × 100
Calculation: Adaptive oversold threshold = 50 − oversold multiplier × base factor × max(selected oversold volatility percentage ÷ 5, 0.5), where selected oversold volatility percentage is either ATR ÷ close × 100 or absolute(close − VWAP) ÷ close × 100
Calculation: Long stop = entry price × (1 − stop percentage ÷ 100)
Calculation: Long target = entry price × (1 + stop percentage × reward-risk multiple ÷ 100)
Calculation: Short stop = entry price × (1 + stop percentage ÷ 100)
Calculation: Short target = entry price × (1 − stop percentage × reward-risk multiple ÷ 100)
Long: RSI crosses above adaptive oversold threshold AND position is flat
Short: RSI crosses below adaptive overbought threshold AND position is flat
Exit: Long, RSI crosses below 50 OR RSI crosses above adaptive overbought threshold OR low ≤ long stop OR high ≥ long target
Exit: Short, RSI crosses above 50 OR RSI crosses below adaptive oversold threshold OR high ≥ short stop OR low ≤ short target