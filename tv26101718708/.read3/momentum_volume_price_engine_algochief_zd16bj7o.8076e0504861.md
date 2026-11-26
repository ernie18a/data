Calculation: Up-close count = number of bars in the shared lookback with close > the preceding bar's close
Calculation: Down-close count = number of bars in the shared lookback with close < the preceding bar's close
Calculation: Volume change (%) = if SMA(volume, baseline volume lookback) > 0 then 100 * (SMA(volume, shared lookback) - SMA(volume, baseline volume lookback)) / SMA(volume, baseline volume lookback) else 0
Calculation: Price change (%) = if close[shared lookback] > 0 then 100 * (close - close[shared lookback]) / close[shared lookback] else 0
Calculation: Bullish MVP = up-close count >= minimum directional bars AND volume change (%) >= volume surge threshold AND price change (%) >= price change threshold
Calculation: Bearish MVP = down-close count >= minimum directional bars AND volume change (%) >= volume surge threshold AND price change (%) <= -price change threshold
Long: Bullish MVP
Long: Bullish MVP AND NOT Bullish MVP on the previous chart bar
Short: Bearish MVP
Short: Bearish MVP AND NOT Bearish MVP on the previous chart bar
Exit: long, low <= entry price - ATR(ATR lookback) on the entry bar * stop-loss multiple
Exit: short, high >= entry price + ATR(ATR lookback) on the entry bar * stop-loss multiple