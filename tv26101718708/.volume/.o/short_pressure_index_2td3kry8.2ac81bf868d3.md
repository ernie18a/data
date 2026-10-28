Calculation: Volume pressure = bearish volume divided by total volume over a rolling window, expressed as a percentage; include only bars whose volume is at least the average volume times either the above-average or climax multiplier. A bearish bar has close < open. If qualifying volume totals zero, use 50%. For stocks with short-volume data, use reported short volume / total volume instead.
Calculation: MA-deviation pressure = normalize((moving average − close) / ATR) to 0–100 using the rolling normalization window; the moving average may be SMA, EMA, RMA, or WMA, and ATR is an RMA of true range.
Calculation: Momentum pressure = percentage of bars closing below their open in the momentum lookback.
Calculation: Short Pressure Index (SPI) = EMA of the equal-weighted average of volume pressure, MA-deviation pressure, and momentum pressure.
Calculation: Signal line = EMA of SPI, using a longer lookback than the EMA that smooths SPI.
Long: SPI ≤ low threshold OR (SPI < signal line AND previous SPI ≥ previous signal line)
Short: SPI ≥ high threshold OR (SPI > signal line AND previous SPI ≤ previous signal line)