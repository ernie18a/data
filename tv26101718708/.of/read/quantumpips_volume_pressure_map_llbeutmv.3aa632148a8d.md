Calculation: Candle range = max(high - low, minimum price increment); body fraction = abs(close - open) / candle range; upper wick = high - max(open, close); lower wick = min(open, close) - low; close position = (close - low) / candle range.
Calculation: Volume ratio = volume / SMA(volume), or zero when the SMA is zero. High volume means volume ratio >= high-volume threshold; extreme volume means volume ratio >= extreme-volume threshold, where the extreme threshold is higher.
Calculation: Adjusted pressure = volume * (2 * (close position - 0.5) + 0.3 * (lower wick - upper wick) / candle range). Smoothed pressure = EMA(adjusted pressure). Cumulative pressure = cumulative sum of adjusted pressure; its signal = EMA(cumulative pressure) using the volume baseline lookback.
Calculation: Compression ratio = (highest high - lowest low over the structure lookback) / max(ATR * structure lookback, minimum price increment). Compression means compression ratio <= compression threshold.
Calculation: Accumulation score = 1 for high volume + 1 for compression + 1 for smoothed pressure > 0 + 0.5 for close position >= 0.60 + 0.5 for lower wick > upper wick; each unmet condition contributes zero.
Calculation: Distribution score = 1 for high volume + 1 for compression + 1 for smoothed pressure < 0 + 0.5 for close position <= 0.40 + 0.5 for upper wick > lower wick; each unmet condition contributes zero.
Calculation: Accumulation = high volume AND accumulation score >= 3. Distribution = high volume AND distribution score >= 3.
Calculation: Bullish imbalance = extreme volume AND close > open AND close position >= 0.70. Bearish imbalance = extreme volume AND close < open AND close position <= 0.30.
Calculation: Bullish absorption = high volume AND body fraction <= absorption threshold AND lower wick > 2 * upper wick. Bearish absorption = high volume AND body fraction <= absorption threshold AND upper wick > 2 * lower wick.
Long: Accumulation OR bullish imbalance OR bullish absorption.
Short: Distribution OR bearish imbalance OR bearish absorption.
Long: Close > open AND accumulation = false AND distribution = false AND bullish imbalance = false AND bearish imbalance = false AND bullish absorption = false AND bearish absorption = false.
Short: Close < open AND accumulation = false AND distribution = false AND bullish imbalance = false AND bearish imbalance = false AND bullish absorption = false AND bearish absorption = false.
Long: Smoothed pressure >= 0.
Short: Smoothed pressure < 0.
Long: Cumulative pressure > its signal.
Short: Cumulative pressure <= its signal.