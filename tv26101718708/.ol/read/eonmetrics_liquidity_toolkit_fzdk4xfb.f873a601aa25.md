Calculation: Swing high/low level = the high/low of a bar higher/lower than the configured number of bars before and after it; confirmed after those later bars complete.
Calculation: Equal high/low pool = an unswept same-side swing level merged with a new confirmed swing when their prices differ by no more than an ATR-scaled tolerance; retain the existing level price.
Calculation: Previous day/week high/low = the high/low of the previous completed daily/weekly bar, using a higher timeframe than the chart timeframe.
Calculation: Average volume = moving average of volume over a configured lookback.
Long: For any unswept sellside swing/equal-low or previous-period low level, low <= level AND close > level AND volume > a configured multiple of average volume.
Short: For any unswept buyside swing/equal-high or previous-period high level, high >= level AND close < level AND volume > a configured multiple of average volume.