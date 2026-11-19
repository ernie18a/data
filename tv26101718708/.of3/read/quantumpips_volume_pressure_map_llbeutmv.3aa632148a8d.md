Calculation: candle range = max(high - low, minimum tick)
Calculation: close position = (close - low) / candle range
Calculation: upper wick = high - max(open, close)
Calculation: lower wick = min(open, close) - low
Calculation: candle body fraction = abs(close - open) / candle range
Calculation: volume ratio = IF SMA(volume, volume baseline lookback) != 0 THEN volume / SMA(volume, volume baseline lookback) ELSE 0
Calculation: high-volume condition = volume ratio >= high-volume multiplier
Calculation: extreme-volume condition = volume ratio >= extreme-volume multiplier
Calculation: adjusted pressure = volume * ((close position - pressure midpoint) * pressure scale) + volume * ((lower wick - upper wick) / candle range * pressure wick coefficient)
Calculation: smoothed pressure = EMA(adjusted pressure, pressure smoothing lookback)
Calculation: compressed structure = (Highest(high, structure lookback) - Lowest(low, structure lookback)) / max(ATR(ATR lookback) * structure lookback, minimum tick) <= compression threshold
Calculation: accumulation score = (IF high-volume condition THEN base score weight ELSE 0) + (IF compressed structure THEN base score weight ELSE 0) + (IF smoothed pressure > 0 THEN base score weight ELSE 0) + (IF close position >= accumulation close-position threshold THEN bonus score weight ELSE 0) + (IF lower wick > upper wick THEN bonus score weight ELSE 0)
Calculation: distribution score = (IF high-volume condition THEN base score weight ELSE 0) + (IF compressed structure THEN base score weight ELSE 0) + (IF smoothed pressure < 0 THEN base score weight ELSE 0) + (IF close position <= distribution close-position threshold THEN bonus score weight ELSE 0) + (IF upper wick > lower wick THEN bonus score weight ELSE 0)
Calculation: accumulation signal = high-volume condition AND accumulation score >= score threshold
Calculation: distribution signal = high-volume condition AND distribution score >= score threshold
Calculation: bullish imbalance signal = extreme-volume condition AND close > open AND close position >= bullish imbalance close-position threshold
Calculation: bearish imbalance signal = extreme-volume condition AND close < open AND close position <= bearish imbalance close-position threshold
Calculation: absorption base = high-volume condition AND candle body fraction <= absorption maximum body fraction
Calculation: bullish absorption signal = absorption base AND lower wick > upper wick * absorption wick ratio
Calculation: bearish absorption signal = absorption base AND upper wick > lower wick * absorption wick ratio
Calculation: cumulative pressure = cumulative sum(adjusted pressure)
Calculation: CVD signal = EMA(cumulative pressure, volume baseline lookback)
Long: accumulation signal
Short: distribution signal
Long: bullish imbalance signal
Short: bearish imbalance signal
Long: bullish absorption signal
Short: bearish absorption signal
Long: smoothed pressure >= 0
Short: smoothed pressure < 0
Long: cumulative pressure > CVD signal
Short: cumulative pressure <= CVD signal
Long: NOT accumulation signal AND NOT distribution signal AND NOT bullish imbalance signal AND NOT bearish imbalance signal AND NOT bullish absorption signal AND NOT bearish absorption signal AND close > open
Short: NOT accumulation signal AND NOT distribution signal AND NOT bullish imbalance signal AND NOT bearish imbalance signal AND NOT bullish absorption signal AND NOT bearish absorption signal AND close < open