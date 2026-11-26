Calculation: Smoothed Candles OHLC = Smoothed Candles(open, high, low, close)
Long: smoothed candle open < smoothed candle close
Short: smoothed candle open >= smoothed candle close
Long: On chart bars, close > Smoothed Candles high(T1, last completed bar) + breakout offset AND bar index = signal-bar parameter AND buy permission is enabled
Short: On chart bars, close < Smoothed Candles low(T1, last completed bar) - breakout offset AND bar index = signal-bar parameter AND sell permission is enabled
Exit: long, On chart bars, close < Smoothed Candles low(T1, last completed bar) - breakout offset AND long-close permission is enabled
Exit: short, On chart bars, close > Smoothed Candles high(T1, last completed bar) + breakout offset AND short-close permission is enabled