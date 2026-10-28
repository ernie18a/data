Calculation: Fast EMA = EMA of close with a shorter lookback than the slow EMA
Calculation: Slow EMA = EMA of close with a longer lookback than the fast EMA
Calculation: Breakout direction = 1 when close > the prior bar’s highest high over the breakout lookback; −1 when close < the prior bar’s lowest low over that lookback; otherwise retain the previous direction
Calculation: RSI reversal direction = 1 when prior RSI < oversold level and current RSI ≥ oversold level; −1 when prior RSI > overbought level and current RSI ≤ overbought level; otherwise retain the previous direction
Calculation: Bollinger fade direction = 1 when close < lower Bollinger Band; −1 when close > upper Bollinger Band; otherwise retain the previous direction
Calculation: Raw direction = the selected built-in signal’s direction: 1 or −1 according to fast EMA vs. slow EMA; MACD line vs. signal line; Supertrend direction; RSI vs. 50; RSI reversal direction; smoothed stochastic %K vs. smoothed %D; breakout direction; close vs. VWAP; Bollinger fade direction; or a deterministic hash of bar index > 0.5 (1, otherwise −1). Ties for comparisons produce 0.
Long: Raw direction = 1 AND prior raw direction ≠ 1 AND bars since the prior fire ≥ the minimum gap
Short: Raw direction = −1 AND prior raw direction ≠ −1 AND bars since the prior fire ≥ the minimum gap