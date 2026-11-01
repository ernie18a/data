Calculation: Raw delta = choose one method: OHLC: if high = low, volume when close >= open, otherwise -volume; otherwise volume * ((close - low) - (high - close)) / (high - low). Close/open: volume when close >= open, otherwise -volume. Wick: if high = low, volume when close >= open, otherwise -volume; otherwise let buy pressure = min(open, close) - low + (abs(close - open) when close >= open, otherwise 0), and sell pressure = high - max(open, close) + (abs(close - open) when close < open, otherwise 0); return volume * (buy pressure - sell pressure) / (buy pressure + sell pressure), or 0 if the denominator is 0.
Calculation: Delta = raw delta or its EMA, using the selected smoothing setting.
Calculation: Cumulative delta = sum of delta since initialization or since the latest selected daily or weekly reset, including the current bar.
Calculation: Buy volume = for the OHLC method, volume * (close - low) / (high - low), or volume when high = low and close >= open, otherwise 0 when high = low; for the close/open method, volume when close >= open, otherwise 0; for the wick method, volume / 2. Sell volume = volume - buy volume.
Calculation: Buy percentage = 100 * buy volume / volume, or 50 when volume = 0. Imbalance ratio = buy volume / sell volume, or 99 when sell volume <= 0.
Calculation: Delta percentage = 100 * delta / volume, or 0 when volume = 0. Volume ratio = volume / SMA(volume), or 1 when the SMA is 0. Aggression index = delta percentage * volume ratio.
Calculation: Close position = 100 * (close - low) / (high - low), or 50 when high = low. Weighted delta score = 0.4 * delta percentage + 9 * (volume ratio - 1) + 0.3 * (close position - 50).
Calculation: Daily delta = sum of delta since the start of the current day, including the current bar.
Calculation: Bias score = sign of cumulative delta change over a lookback + sign of the same change again + sign of delta when close and delta have matching nonzero directions, otherwise 0 + 1 when imbalance ratio exceeds its buy threshold, -1 when below its sell threshold, otherwise 0 + sign of daily delta.
Calculation: Normalized cumulative delta and its EMA = midpoint of the rolling highest high and lowest low plus the respective value multiplied by 0.3 times that rolling price range divided by the rolling maximum absolute cumulative delta; use multiplier 1 when that maximum is 0. Use the same rolling window and multiplier for both values.
Calculation: Confirmed divergence = a price pivot and cumulative delta pivot of the same type confirmed on the current bar using equal left and right lookbacks, compared separately with the most recently confirmed prior price pivot and prior cumulative delta pivot of that type; the two prior pivots need not have occurred together. Evaluate on the confirmation bar.
Long: Confirmed low divergence AND price pivot low < prior price pivot low AND cumulative delta pivot low > prior cumulative delta pivot low.
Short: Confirmed high divergence AND price pivot high > prior price pivot high AND cumulative delta pivot high < prior cumulative delta pivot high.
Long: Volume >= volume SMA * high-volume multiplier AND abs(delta percentage) < absorption threshold AND close > open.
Short: Volume >= volume SMA * high-volume multiplier AND abs(delta percentage) < absorption threshold AND close < open.
Short: Volume >= volume SMA * high-volume multiplier AND abs(delta percentage) < absorption threshold AND close > open.
Long: Volume >= volume SMA * high-volume multiplier AND abs(delta percentage) < absorption threshold AND close <= open.
Long: Volume >= volume SMA * climax multiplier AND abs(delta percentage) > climax threshold AND delta > 0.
Short: Volume >= volume SMA * climax multiplier AND abs(delta percentage) > climax threshold AND delta < 0.
Long: Volume >= volume SMA * high-volume multiplier AND delta > 0.
Short: Volume >= volume SMA * high-volume multiplier AND delta < 0.
Long: Delta >= 0.
Short: Delta < 0.
Long: Cumulative delta >= 0.
Short: Cumulative delta < 0.
Long: Daily delta >= 0.
Short: Daily delta < 0.
Long: Rolling sum of delta >= 0.
Short: Rolling sum of delta < 0.
Long: Delta > 0 for at least one consecutive bar.
Short: Delta < 0 for at least one consecutive bar.
Long: Imbalance ratio > buy threshold.
Short: Imbalance ratio < sell threshold.
Long: Buy percentage > upper pressure threshold.
Short: Buy percentage < lower pressure threshold.
Long: Aggression index > positive threshold.
Short: Aggression index < negative threshold.
Long: Weighted delta score > positive threshold.
Short: Weighted delta score < negative threshold.
Long: Bias score >= positive threshold.
Short: Bias score <= negative threshold.
Long: Cumulative delta > its EMA.
Short: Cumulative delta <= its EMA.
Long: Normalized cumulative delta >= its normalized EMA.
Short: Normalized cumulative delta < its normalized EMA.
Long: Cumulative delta change over the shorter lookback > 0.
Short: Cumulative delta change over the shorter lookback < 0.
Long: Close > short-term close EMA AND short-term close EMA > medium-term close EMA.
Short: Close < short-term close EMA AND short-term close EMA < medium-term close EMA.
Long: Close position > upper position threshold.
Short: Close position < lower position threshold.