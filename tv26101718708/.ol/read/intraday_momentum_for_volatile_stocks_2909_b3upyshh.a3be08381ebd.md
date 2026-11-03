Long: High >= current daily open × (1 + momentum threshold) AND cumulative volume so far in the current day >= the 20-day average volume from the previous completed daily bar AND time <= 15:00 AND daily index close > its SMA over a longer lookback AND MFI > 50 AND flat
Calculation: Daily index close = close of the higher-timeframe daily bar, using the forming bar in realtime and the last completed bar on historical bars
Calculation: Daily index SMA = simple moving average of the daily index close series over a longer lookback, calculated on chart-timeframe bars
Calculation: Long trailing stop = running maximum since entry of (bar high − ATR × stop multiplier)
Calculation: Long profit target = entry price + ATR × target multiplier, set on the first bar in the position
Exit: Long, close < long trailing stop OR close >= long profit target