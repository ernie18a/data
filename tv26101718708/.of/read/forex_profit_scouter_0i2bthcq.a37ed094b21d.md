Calculation: Previous daily range = high and low of the last completed daily bar.
Calculation: Previous 4-hour range = high and low of the last completed 4-hour bar, or of the last completed New York 4-hour block.
Calculation: Previous hourly range = high and low of the last completed hourly bar.
Calculation: 8–9 AM range = high and low of chart bars during the New York 8–9 AM window, fixed after that window ends.
Calculation: Opening range = high and low of chart bars during the configured opening window, fixed after that window ends.
Calculation: Sweep extreme = the lowest low below the range low for a long setup, or highest high above the range high for a short setup; a sweep deeper than the configured fraction of the range invalidates that setup.
Calculation: CISD level = the open of the bearish candle run containing the deepest low sweep, or the bullish candle run containing the deepest high sweep.
Calculation: CRT stop distance = greater of the distance from entry to beyond the sweep extreme by a buffer and the minimum stop distance; skip if greater than the maximum stop distance.
Calculation: ORB stop distance = greater of the distance from entry to the opening-range midpoint and the minimum stop distance; skip if greater than the maximum stop distance.
Calculation: CRT targets = range midpoint (TP1), opposite range boundary (TP2), and an extension beyond that boundary (TP3); if TP1 is too close, use the opposite boundary as TP1 and extend later targets, or skip, according to the configured rule.
Calculation: ORB targets = entry plus or minus the stop distance times the configured first, second, and third reward multiples, in the position direction.
Calculation: Trend ribbon = chart-timeframe EMAs with short-to-long lookbacks; bullish when the shortest EMA is above the longest, bearish otherwise.
Calculation: Regime direction = on the configured higher timeframe, ADX and the short-, medium-, and long-lookback EMA ordering, all from the last completed bar; bullish/bearish only when ADX meets its threshold and the EMA ordering agrees. In ribbon mode, use the chart-timeframe trend ribbon direction.
Calculation: Extreme volatility = chart-timeframe ATR exceeds its longer-lookback average times the configured multiplier.
Long: (CRT sweep low and reclaim under the selected confirmation mode OR close above the completed opening-range high) AND weekday during the trading session AND outside the news block AND confirmed chart bar AND no open position AND daily trade and loss limits not reached AND selected setup is allowed by the regime filter AND no spike candle AND not extreme volatility AND valid stop and position size AND sufficient reward room AND not past the CRT midpoint AND, if enabled, close at or below the previous daily range midpoint.
Short: (CRT sweep high and reclaim under the selected confirmation mode OR close below the completed opening-range low) AND weekday during the trading session AND outside the news block AND confirmed chart bar AND no open position AND daily trade and loss limits not reached AND selected setup is allowed by the regime filter AND no spike candle AND not extreme volatility AND valid stop and position size AND sufficient reward room AND not past the CRT midpoint AND, if enabled, close at or above the previous daily range midpoint.
Exit: Long, low <= current stop.
Exit: Short, high >= current stop.
Exit: Long, high >= TP1 (close one third).
Exit: Short, low <= TP1 (close one third).
Exit: Long, high >= TP2 (close one third).
Exit: Short, low <= TP2 (close one third).
Exit: Long, high >= TP3.
Exit: Short, low <= TP3.
Exit: Long or short, New York time reaches the configured flat time or a new daily bar begins.