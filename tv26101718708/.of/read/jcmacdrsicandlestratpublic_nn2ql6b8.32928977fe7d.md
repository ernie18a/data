Calculation: Current-timeframe RSI = Wilder RSI of close using a lookback; bullish RSI cross = prior RSI < lower threshold AND current RSI > lower threshold; bearish RSI cross = prior RSI > upper threshold AND current RSI < upper threshold
Calculation: Candle body filter = abs(open − close) / max(high, low) × 10000 > minimum body-size factor
Calculation: Bullish pin bar = body filter AND open and close > low + (high − low) × pin-bar range percentage AND neither reversal pin-bar condition holds
Calculation: Bearish pin bar = body filter AND open and close < high − (high − low) × pin-bar range percentage AND neither reversal pin-bar condition holds
Calculation: Bullish reversal pin bar condition = open and close > high − (high − low) × (1 − reversal-pin-bar range percentage) AND low ≤ lowest low over the reversal-pin-bar lookback
Calculation: Bearish reversal pin bar condition = open and close < high − (high − low) × reversal-pin-bar range percentage AND high ≥ highest high over the reversal-pin-bar lookback
Calculation: Dark cloud cover = body filter AND prior candle bullish with body/range ≥ 0.7 AND current candle bearish with body/range ≥ 0.7 AND current open ≥ prior close AND current close > prior open AND current close < prior body midpoint
Calculation: Piercing line = body filter AND prior candle bearish with body/range ≥ 0.7 AND current candle bullish with body/range ≥ 0.7 AND current open ≤ prior close AND current close < prior open AND current close > prior body midpoint
Calculation: Bearish harami = body filter AND prior candle bullish AND current candle bearish AND current open > prior close AND current low ≥ prior open AND current body smaller than prior body AND current range inside prior range AND dark cloud cover is false
Calculation: Bullish harami = body filter AND prior candle bearish AND current candle bullish AND current close ≤ prior open AND current high ≤ prior open AND current body smaller than prior body AND current range inside prior range AND piercing line is false
Calculation: Bearish engulfing = body filter AND prior candle bullish AND current candle bearish AND current close ≤ prior low AND current open ≥ prior close
Calculation: Bullish engulfing = body filter AND prior candle bearish AND current candle bullish AND current close ≥ prior high AND current open ≤ prior close
Calculation: Top fractal level = most recent high[2] where high[2] > high[1], high, high[3], and high[4]
Calculation: Bottom fractal level = most recent low[2] where low[2] < low[1], low, low[3], and low[4]
Calculation: Bullish fractal cross = body filter AND close crosses above top fractal level AND bullish engulfing is false AND bullish harami is false AND close < high − (high − low) × shaved-bar percentage
Calculation: Bearish fractal cross = body filter AND close crosses below bottom fractal level AND bearish engulfing is false AND bearish harami is false AND close > low + (high − low) × shaved-bar percentage
Long: current-timeframe RSI bullish cross OR bullish pin bar OR piercing line OR bullish harami OR bullish engulfing OR bullish fractal cross
Short: current-timeframe RSI bearish cross OR bearish pin bar OR dark cloud cover OR bearish harami OR bearish engulfing OR bearish fractal cross
Exit: Long, bearish pin bar OR high ≥ entry price + take-profit distance OR low ≤ entry price − stop-loss distance OR long trailing stop is triggered
Exit: Short, bullish pin bar OR low ≤ entry price − take-profit distance OR high ≥ entry price + stop-loss distance OR short trailing stop is triggered