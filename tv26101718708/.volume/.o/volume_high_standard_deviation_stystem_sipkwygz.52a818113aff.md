Calculation: Adjusted volume = volume, except zero volume uses the last nonzero volume; when adjusted volume is at or below the prior volume upper limit, use the prior adjusted volume.
Calculation: Volume upper limit = simple moving average of adjusted volume + 2 × factor × standard deviation of adjusted volume, using the same lookback for both.
Calculation: Short-term moving average = simple moving average of close using half the lookback used for the volume average and standard deviation.
Long: Short-term moving average > its prior-bar value AND volume < volume upper limit AND position side is not long
Short: Short-term moving average < its prior-bar value AND volume < volume upper limit AND position side is not short
Exit: Long, short-term moving average < its prior-bar value OR (close > prior-bar close AND volume > volume upper limit)
Exit: Short, short-term moving average > its prior-bar value OR (close < prior-bar close AND volume > volume upper limit)