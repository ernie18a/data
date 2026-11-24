Calculation: Normalized EMA slope(lookback) = change(EMA(close, lookback)) / ATR(ATR lookback)
Calculation: Scale alignment = (sign(normalized EMA slope(shorter scale lookback)) + sign(normalized EMA slope(intermediate scale lookback)) + sign(normalized EMA slope(longer scale lookback))) / 3
Calculation: Scale vote = scale alignment * clamp((abs(normalized EMA slope(shorter scale lookback)) + abs(normalized EMA slope(intermediate scale lookback)) + abs(normalized EMA slope(longer scale lookback))) / 3, 0, 1)
Calculation: Positive CUSUM candidate = max(0, prior positive CUSUM state + z-score(change(log(close)), CUSUM baseline lookback) - CUSUM drift parameter)
Calculation: Negative CUSUM candidate = min(0, prior negative CUSUM state + z-score(change(log(close)), CUSUM baseline lookback) + CUSUM drift parameter)
Calculation: Positive CUSUM state = 0 if the positive CUSUM candidate exceeds the CUSUM detection threshold; otherwise the positive CUSUM candidate; initial state is 0
Calculation: Negative CUSUM state = 0 if the negative CUSUM candidate is below the negative CUSUM detection threshold; otherwise the negative CUSUM candidate; initial state is 0
Calculation: CUSUM vote = 1 if the positive CUSUM candidate exceeds the CUSUM detection threshold, otherwise -1 if the negative CUSUM candidate is below the negative CUSUM detection threshold, otherwise the prior CUSUM vote multiplied by the CUSUM memory decay parameter; clamp to [-1, 1]
Calculation: Conformal in-distribution score and anomaly direction = predict close as prior close + SMA(change(close), prediction drift lookback); append the absolute prediction residual to a rolling buffer capped at the calibration window; when the buffer has at least the minimum calibration observations, radius is the sorted buffer value at index floor((1 - miscoverage parameter) * (buffer size - 1)), otherwise radius is unavailable; ratio is 0 if radius is unavailable or 0, otherwise absolute residual / radius; score is clamp(2 - ratio, 0, 1); anomaly direction is sign(prediction residual) if ratio > 1, otherwise 0
Calculation: Conformal anomaly vote = conformal anomaly direction * conformal gate-strength parameter * anomaly vote fraction
Calculation: Momentum vote = clamp(momentum vote scale parameter * (EMA(RSI(close, momentum lookback), momentum smoothing lookback) - 50) / 50, -1, 1)
Calculation: Weighted raw vote = (scale vote * scale vote weight + CUSUM vote * CUSUM vote weight + momentum vote * momentum vote weight + conformal anomaly vote) / (scale vote weight + CUSUM vote weight + momentum vote weight + conformal gate-strength parameter * anomaly vote fraction), or 0 if the denominator is 0
Calculation: Gate multiplier = clamp(conformal in-distribution score, conformal score floor, 1) * clamp(entropy base factor + entropy predictability factor * (1 - normalized permutation entropy(close, entropy lookback, embedding dimension)), entropy multiplier floor, 1); multiply by the entropy-closed factor when normalized permutation entropy exceeds the chaos threshold
Calculation: Net consensus vote = clamp(weighted raw vote * (consensus base factor + entropy gate-strength parameter * consensus scaling factor) * gate multiplier, -1, 1)
Calculation: Agreement count = the number of nonzero signs among the scale vote, CUSUM vote, momentum vote, and conformal anomaly vote that match sign(net consensus vote), plus 1 if scale alignment is nonzero and its sign matches sign(net consensus vote)
Calculation: Higher-timeframe trend = sign(EMA(close, shorter HTF lookback, T1 current bar, sampled on chart bars with lookahead off) - EMA(close, longer HTF lookback, T1 current bar, sampled on chart bars with lookahead off)); the current T1 bar is used while it is still forming
Long: net consensus vote >= consensus threshold AND agreement count >= minimum agreeing mechanisms AND normalized permutation entropy(close, entropy lookback, embedding dimension) <= chaos threshold AND (higher-timeframe confirmation is disabled OR higher-timeframe trend >= 0) AND cooldown bars since the last long or short consensus signal >= cooldown length
Short: net consensus vote <= -consensus threshold AND agreement count >= minimum agreeing mechanisms AND normalized permutation entropy(close, entropy lookback, embedding dimension) <= chaos threshold AND (higher-timeframe confirmation is disabled OR higher-timeframe trend <= 0) AND cooldown bars since the last long or short consensus signal >= cooldown length
Long: positive CUSUM candidate > CUSUM detection threshold
Short: negative CUSUM candidate < -CUSUM detection threshold
Long: scale vote > 0
Short: scale vote < 0
Long: CUSUM vote > 0
Short: CUSUM vote < 0
Long: momentum vote > 0
Short: momentum vote < 0
Long: higher-timeframe trend > 0
Short: higher-timeframe trend < 0
Long: net consensus vote > 0
Short: net consensus vote < 0
Long: EMA(close, longer scale lookback) > EMA(close, longer scale lookback)[1]
Short: EMA(close, longer scale lookback) <= EMA(close, longer scale lookback)[1]
Long: EMA(close, intermediate scale lookback) > EMA(close, intermediate scale lookback)[1]
Short: EMA(close, intermediate scale lookback) <= EMA(close, intermediate scale lookback)[1]
Long: net consensus vote > conviction-background threshold
Short: net consensus vote < -conviction-background threshold
Long: net consensus vote > consensus threshold * bar-color fraction
Short: net consensus vote < -consensus threshold * bar-color fraction