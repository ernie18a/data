Calculation: Chart directional indicators = For the first bar, substitute zero for the previous high, low, and close. True range is max(high - low, abs(high - previous close), abs(low - previous close)). Up move is high - previous high; down move is previous low - low. Positive directional movement is max(up move, 0) if up move > down move, otherwise 0; negative directional movement is max(down move, 0) if down move > up move, otherwise 0. For true range and each directional movement, initialize the smoothed value to zero before the first bar and update it as previous smoothed value - previous smoothed value / directional period + current value. DI+ and DI- are 100 times their respective smoothed directional movements divided by smoothed true range, or zero when smoothed true range is zero.
Calculation: Chart ADX = Simple moving average of DX over a smoothing period, where DX is 100 * abs(DI+ - DI-) / (DI+ + DI-), or zero when DI+ + DI- is zero.
Calculation: Other-timeframe directional indicators = Standard Wilder DI+ and DI- calculated on each selected timeframe. For a higher timeframe use the last completed bar; for a lower timeframe use the last completed intrabar within the chart bar; for the chart timeframe use the current chart bar.
Long: Chart DI+ crosses above chart DI-.
Short: Chart DI+ crosses below chart DI-.
Long: Chart DI+ > chart DI-.
Short: Chart DI+ <= chart DI-.
Long: Chart ADX > trend threshold AND chart DI+ > chart DI-.
Short: Chart ADX > trend threshold AND chart DI+ <= chart DI-.
Long: Other-timeframe DI+ > other-timeframe DI-.
Short: Other-timeframe DI+ <= other-timeframe DI-.