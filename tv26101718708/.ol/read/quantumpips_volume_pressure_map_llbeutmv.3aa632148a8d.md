Calculation: Relative volume = volume / longer-lookback simple moving average of volume
Calculation: High volume = relative volume >= high-volume threshold
Calculation: Extreme volume = relative volume >= extreme-volume threshold, where extreme-volume threshold is greater than the high-volume threshold
Calculation: Close position = (close - low) / (high - low)
Calculation: Upper wick = high - max(open, close)
Calculation: Lower wick = min(open, close) - low
Calculation: Smoothed pressure = shorter-lookback exponential moving average of volume × (2 × close position - 1 + 0.30 × (lower wick - upper wick) / (high - low))
Calculation: Compression ratio = (highest high - lowest low over the structure lookback) / (ATR × structure lookback)
Calculation: Compressed = compression ratio <= compression threshold
Calculation: Accumulation score = 1 point each for high volume, compressed, and smoothed pressure > 0; 0.5 point each for close position >= 0.60 and lower wick > upper wick
Calculation: Distribution score = 1 point each for high volume, compressed, and smoothed pressure < 0; 0.5 point each for close position <= 0.40 and upper wick > lower wick
Calculation: Body percentage = abs(close - open) / (high - low)
Long: High volume AND accumulation score >= accumulation threshold
Long: Extreme volume AND close > open AND close position >= 0.70
Long: High volume AND body percentage <= absorption-body threshold AND lower wick > 2 × upper wick
Short: High volume AND distribution score >= distribution threshold
Short: Extreme volume AND close < open AND close position <= 0.30
Short: High volume AND body percentage <= absorption-body threshold AND upper wick > 2 × lower wick