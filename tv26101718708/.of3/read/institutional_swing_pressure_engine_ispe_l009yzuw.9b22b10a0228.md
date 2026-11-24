Calculation: Compression score = weighted sum of 100 − PercentRank(ATR(close, high, low, ATR lookback) / close, adaptive lookback), 100 − PercentRank(Bollinger Band width(close, compression lookback, Bollinger multiplier) / SMA(close, compression lookback), adaptive lookback), 100 − PercentRank((highest(high, compression lookback) − lowest(low, compression lookback)) / close, adaptive lookback), 100 − PercentRank(standard deviation of log(close / close[1]) over compression lookback, adaptive lookback), 100 − PercentRank(EMA(abs(close − open) / max(high − low, minimum tick), body lookback), adaptive lookback), and 100 when the Bollinger Bands are inside the Keltner Channel, otherwise 0
Calculation: Accumulation score = weighted sum of PercentRank(EMA(close location × relative volume, flow lookback), adaptive lookback), PercentRank(OBV linear-regression slope over flow lookback divided by average volume, adaptive lookback), PercentRank(max(normalized close change, 0) × relative volume, adaptive lookback), PercentRank(bullish absorption, adaptive lookback), and PercentRank(up-volume share, adaptive lookback)
Calculation: Distribution score = weighted sum of 100 − PercentRank(EMA(close location × relative volume, flow lookback), adaptive lookback), 100 − PercentRank(OBV linear-regression slope over flow lookback divided by average volume, adaptive lookback), PercentRank(max(−normalized close change, 0) × relative volume, adaptive lookback), PercentRank(bearish absorption, adaptive lookback), and PercentRank(down-volume share, adaptive lookback)
Calculation: Relative strength score = weighted sum of PercentRank(ROC(close / benchmark close, shorter relative-strength lookback), adaptive lookback), optional PercentRank(ROC(close / sector benchmark close, shorter relative-strength lookback), adaptive lookback) or a neutral score, PercentRank(mean asset-minus-benchmark return when benchmark return is negative, relative-strength lookback, adaptive lookback), PercentRank(mean asset-minus-benchmark return when benchmark return is positive, relative-strength lookback, adaptive lookback), and PercentRank(EMA(asset return − beta × benchmark return, beta-alpha lookback), adaptive lookback), where beta is correlation(asset return, benchmark return, relative-strength lookback) × standard deviation(asset return, relative-strength lookback) / standard deviation(benchmark return, relative-strength lookback)
Calculation: Relative weakness score = 100 − relative strength score
Calculation: Resistance = highest(high[1], resistance lookback); support = lowest(low[1], resistance lookback)
Calculation: Resistance pressure = clamp(100 − (resistance − close) / ATR × resistance-distance factor); support pressure = clamp(100 − (close − support) / ATR × support-distance factor)
Calculation: Bullish structure score = weighted sum of resistance pressure, EMA alignment score (close above short EMA, short EMA above medium EMA, medium EMA above long EMA, and close above long EMA), PercentRank(slope of low linear regression over structure lookback divided by ATR, adaptive lookback), bullish trend efficiency, and seller-rejection exhaustion
Calculation: Bearish structure score = weighted sum of support pressure, EMA alignment score (close below short EMA, short EMA below medium EMA, medium EMA below long EMA, and close below long EMA), PercentRank(negative slope of high linear regression over structure lookback divided by ATR, adaptive lookback), bearish trend efficiency, and buyer-rejection exhaustion
Calculation: Higher-timeframe trend score = bull count minus bear count across close versus short EMA, short versus medium EMA, medium versus long EMA, and close versus long EMA, using the last completed bar of that timeframe; evaluate on T1 or T2 bars and carry the result onto chart bars
Calculation: Bullish multi-timeframe score = clamp((weighted sum of T1 and T2 higher-timeframe trend scores + 1) × 50); bearish multi-timeframe score = 100 − bullish multi-timeframe score
Calculation: Bull pressure = clamp(weighted sum of compression score, accumulation score, relative strength score, bullish structure score, and bullish multi-timeframe score)
Calculation: Bear pressure = clamp(weighted sum of compression score, distribution score, relative weakness score, bearish structure score, and bearish multi-timeframe score)
Calculation: Bull impulse = PercentRank(max(normalized close change, 0) × relative volume × max(close location, 0), adaptive lookback)
Calculation: Bear impulse = PercentRank(max(−normalized close change, 0) × relative volume × max(−close location, 0), adaptive lookback)
Calculation: Bull expansion = clamp(weighted sum of bull pressure, bull impulse, and resistance pressure); bear expansion = clamp(weighted sum of bear pressure, bear impulse, and support pressure)
Calculation: Confirmed bull breakout = confirmed bar, close crosses above resistance, and bull pressure > bear pressure; confirmed bear breakout = confirmed bar, close crosses below support, and bear pressure > bull pressure
Calculation: Bull breakout failure = a confirmed bull breakout occurred within the failure lookback and close is below its breakout level; bear breakout failure = a confirmed bear breakout occurred within the failure lookback and close is above its breakout level
Calculation: Bull pressure divergence = confirmed bar, abs(close − close[divergence lookback]) / ATR < price-compression threshold, bull pressure − bull pressure[divergence lookback] > pressure-change threshold, accumulation score > flow threshold, and bull pressure > bear pressure; bear pressure divergence is the inverse using bear pressure and distribution score
Calculation: Bull exhaustion = a bull breakout occurred within the recent-breakout lookback, RSI(close, RSI lookback) > upper RSI threshold, and bull pressure is falling over the pressure-fall lookback; bear exhaustion = a bear breakout occurred within the recent-breakout lookback, RSI(close, RSI lookback) < lower RSI threshold, and bear pressure is falling over the pressure-fall lookback
Long: bull pressure > bear pressure
Short: bear pressure >= bull pressure
Long: confirmed bar and bull pressure >= pressure threshold and bull pressure > bear pressure and compression score >= pressurized compression threshold
Short: confirmed bar and bear pressure >= pressure threshold and bear pressure > bull pressure and compression score >= pressurized compression threshold
Long: confirmed bull breakout
Short: confirmed bear breakout
Long: confirmed bar and normalized price movement over divergence lookback < price-compression threshold and bull pressure change over divergence lookback > pressure-change threshold and accumulation score > flow threshold and bull pressure > bear pressure
Short: confirmed bar and normalized price movement over divergence lookback < price-compression threshold and bear pressure change over divergence lookback > pressure-change threshold and distribution score > flow threshold and bear pressure > bull pressure
Long: bull pressure divergence and not bull pressure divergence[1]
Short: bear pressure divergence and not bear pressure divergence[1]
Long: bear breakout failure
Short: bull breakout failure
Long: bear breakout failure and not bear breakout failure[1]
Short: bull breakout failure and not bull breakout failure[1]
Exit: long, bull exhaustion
Exit: short, bear exhaustion
Long: bull expansion >= extreme pressure threshold and bull pressure > bear pressure
Short: bear expansion >= extreme pressure threshold and bear pressure >= bull pressure
Long: compression score >= pressurized-state threshold and max(bull pressure, bear pressure) >= pressure threshold and bull pressure > bear pressure
Short: compression score >= pressurized-state threshold and max(bull pressure, bear pressure) >= pressure threshold and bear pressure >= bull pressure
Long: accumulation score >= accumulation threshold and bull pressure > bear pressure
Short: distribution score >= distribution threshold and bear pressure >= bull pressure