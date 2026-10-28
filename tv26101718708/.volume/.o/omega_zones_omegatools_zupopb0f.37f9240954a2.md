Calculation: n = confirmation-window length; confirmed swing high/low uses a left lookback longer than its right lookback n
Calculation: Origin = n bars back if that candle is bearish for a swing low or bullish for a swing high; otherwise n+1 bars back
Calculation: ATR = average true range; average range = moving average of high − low; volume z-score = (volume − moving average(volume)) / max(standard deviation(volume), 1)
Calculation: Prior high/low = highest high / lowest low over the lookback before the origin candle
Calculation: Bullish reclaim = confirmed swing low AND any close from current bar through n−1 bars ago > high[n] AND close[n+1] < open[n+1] AND close − close[Origin] > ATR AND origin range < 1.5 × average range
Calculation: Bearish reclaim = confirmed swing high AND any close from current bar through n−1 bars ago < low[n] AND close[n+1] > open[n+1] AND close − close[Origin] < −ATR AND origin range < 1.5 × average range
Calculation: Tight base = high[n] − low[n] < 0.8 × average range
Calculation: Rally in/out = close[n+1] > close[n+2] > close[n+3] AND each close from current bar through n−1 bars ago > the next bar's close
Calculation: Drop in/out = close[n+1] < close[n+2] < close[n+3] AND each close from current bar through n−1 bars ago < the next bar's close
Calculation: Bullish pause = rally in/out AND candle n bars ago is bearish AND tight base
Calculation: Bearish pause = drop in/out AND candle n bars ago is bullish AND tight base
Calculation: Bullish FVG = low[Origin−1] > high[Origin+1]; bearish FVG = high[Origin−1] < low[Origin+1]
Calculation: High sweep = origin high > prior high AND origin close < prior high; low sweep = origin low < prior low AND origin close > prior low
Calculation: Strength = 1 + points for each true condition: absolute displacement > 2 ATR, absolute displacement > 4 ATR, origin volume z-score > 0, > 1, > 2, > 3, either FVG, either sweep
Long: (Bullish reclaim OR bullish pause) AND NOT (bearish reclaim OR bearish pause) AND close > origin low AND strength ≥ minimum confidence
Short: (Bearish reclaim OR bearish pause) AND NOT (bullish reclaim OR bullish pause) AND close < origin high AND strength ≥ minimum confidence