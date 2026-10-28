Calculation: Relative volume = volume / moving average of volume over its baseline lookback
Calculation: Close-location flow = (2 × close − high − low) / bar range × volume × (1 + absolute close-location value) × (relative-volume boost if volume exceeds its baseline average, otherwise 1)
Calculation: Pressure Z-score = Z-score of cumulative close-location flow minus its smoothed value; smooth with the selected flow smoother and flow lookback
Calculation: Effort Z-score = Z-score of the smoothed (close-location value × relative volume); smooth with EMA and effort lookback
Calculation: Volume sigma Z-score = Z-score of the square root of the EMA of squared log(volume / previous-bar volume) changes; use the volume-sigma lookback
Calculation: Momentum bias = (14-period RSI of close − 50) / 10
Calculation: Efficiency bias = (close − close from the efficiency lookback bars ago) / sum of absolute close changes over that lookback
Calculation: VWAP bias = (close − session VWAP of typical price) / ATR
Calculation: Composite pressure = 0.34 × pressure Z-score + 0.18 × effort Z-score + 0.16 × volume sigma Z-score + 0.14 × momentum bias + 0.10 × efficiency bias + 0.08 × VWAP bias
Calculation: Signal line = EMA of composite pressure over the signal lookback
Calculation: Pressure spread = composite pressure − signal line
Calculation: Pressure envelope = EMA of composite pressure ± standard deviation of composite pressure × envelope multiplier; use the envelope lookback
Calculation: Trend EMAs = EMA of close at a shorter fast lookback and a longer slow lookback
Calculation: Bull trend = fast trend EMA ≥ slow trend EMA AND close ≥ slow trend EMA
Calculation: Bear trend = fast trend EMA < slow trend EMA AND close < slow trend EMA
Calculation: Bullish divergence = at a confirmed composite-pressure pivot low, its value is higher than the previous composite-pressure pivot low within the divergence scan, while the corresponding price low is lower
Calculation: Bearish divergence = at a confirmed composite-pressure pivot high, its value is lower than the previous composite-pressure pivot high within the divergence scan, while the corresponding price high is higher
Calculation: Auction skew = (pressure Z-score + effort Z-score + VWAP bias) / 3
Long: current bar is confirmed AND ((composite pressure > 0 AND pressure spread > minimum spread AND pressure Z-score > 0 AND effort Z-score > 0 AND (trend gate disabled OR bull trend) AND (VWAP gate disabled OR close ≥ session VWAP) AND composite pressure > upper pressure envelope) OR (pressure Z-score > 0 AND effort Z-score < 0 AND composite pressure > 0 AND pressure spread < 0) OR (composite pressure > EMA of composite pressure over the envelope lookback AND pressure spread > 0 AND auction skew > 0) OR bullish divergence)
Short: current bar is confirmed AND ((composite pressure < 0 AND pressure spread < −minimum spread AND pressure Z-score < 0 AND effort Z-score < 0 AND (trend gate disabled OR bear trend) AND (VWAP gate disabled OR close < session VWAP) AND composite pressure < lower pressure envelope) OR (pressure Z-score < 0 AND effort Z-score > 0 AND composite pressure < 0 AND pressure spread > 0) OR (composite pressure < EMA of composite pressure over the envelope lookback AND pressure spread < 0 AND auction skew < 0) OR bearish divergence)