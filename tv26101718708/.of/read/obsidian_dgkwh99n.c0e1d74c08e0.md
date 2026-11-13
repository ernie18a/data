Calculation: TEMA(src,n) = 3*EMA1 - 3*EMA2 + EMA3, where EMA1 = EMA(src,n), EMA2 = EMA of EMA1, EMA3 = EMA of EMA2
Calculation: compTEMA = average of TEMA(close,n) over six lengths spanning short to long
Calculation: accelZ = z-score (vs its rolling SMA and rolling stdev) of accel, where accel = change of vel and vel = change of compTEMA
Calculation: multiADX = (2*ADX(short length) + ADX(longer length))/3, DI length equals ADX smoothing length for each
Calculation: rsiStackBull = RSI(close) > 50 for all three lengths (short, medium, long)
Calculation: rsiSlope = RSI(medium length) - RSI(medium length) one bar ago
Calculation: volSpike = rolling z-score of volume > a threshold
Calculation: score = clamp(0..100) of sum of: 20 if close > compTEMA; 20 if rsiStackBull; 20 if volSpike; 20*min(multiADX/ADXnorm,1); clamp(5*accelZ, -20, 20)
Calculation: POC = over a lookback window, split [lowest low, highest high] into equal-width bins, sum volume of each bar by the bin containing its close (bin range is low-inclusive, high-exclusive), POC = midpoint of the bin with the largest volume (first bin wins ties)
Calculation: VAH = POC + stdev(close, valueLength); VAL = POC - stdev(close, valueLength)
Calculation: POCdrift = POC - POC n bars ago
Calculation: liquidityHigh/liquidityLow = most recent confirmed pivot high/low (same bars on left and right)
Calculation: avgRange = SMA(high - low)
Long: score > scoreThreshold AND multiADX >= squeezeThreshold AND rsiSlope > 0
Short: score > scoreThreshold AND multiADX >= squeezeThreshold AND rsiSlope < 0
Long: compTEMA crosses above POC AND multiADX > trendThreshold
Short: compTEMA crosses below POC AND multiADX > trendThreshold
Long: POCdrift > 0 AND abs(POCdrift) > small price threshold AND compTEMA > POC AND close > VAH AND previous close <= VAH
Short: POCdrift < 0 AND abs(POCdrift) > small price threshold AND compTEMA < POC AND close < VAL AND previous close >= VAL
Long: low < liquidityLow AND close > liquidityLow AND (high - low) > avgRange
Short: high > liquidityHigh AND close < liquidityHigh AND (high - low) > avgRange