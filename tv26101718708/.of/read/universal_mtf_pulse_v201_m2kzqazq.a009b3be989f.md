Calculation: Momentum = (close − close a lookback number of bars earlier) / ATR, calculated only when ATR > 0.
Calculation: Relative volume = bar volume / mean volume of the preceding volume-lookback bars, excluding the current bar; valid only when all volumes are nonnegative and the mean is positive.
Calculation: Busy = relative volume is valid AND relative volume >= busy-volume threshold AND abs(close − open) / ATR < body threshold.
Calculation: Source readings = calculations on the chart timeframe or on a higher or lower timeframe, using the last completed source bar at each chart close; lower-timeframe readings use the last completed intrabar.
Long: Source close > source EMA AND source EMA > its value a trend-lookback number of source bars earlier AND at least EMA-length + trend-lookback source bars exist.
Short: Source close < source EMA AND source EMA < its value a trend-lookback number of source bars earlier AND at least EMA-length + trend-lookback source bars exist.
Long: Source momentum > 0.
Short: Source momentum < 0.
Long: Chart momentum >= flat-band threshold AND previous chart momentum <= 0.
Short: Chart momentum <= −flat-band threshold AND previous chart momentum >= 0.
Long: Source momentum >= strong-momentum threshold AND relative volume >= strong-volume threshold AND Busy = false AND source trend is valid.
Short: Source momentum <= −strong-momentum threshold AND relative volume >= strong-volume threshold AND Busy = false AND source trend is valid.
Short: Source close > source EMA AND source EMA > its value a trend-lookback number of source bars earlier AND source momentum < 0 AND Busy = false AND (relative volume is invalid OR abs(source momentum) < strong-momentum threshold OR relative volume < strong-volume threshold).
Long: Source close < source EMA AND source EMA < its value a trend-lookback number of source bars earlier AND source momentum > 0 AND Busy = false AND (relative volume is invalid OR abs(source momentum) < strong-momentum threshold OR relative volume < strong-volume threshold).