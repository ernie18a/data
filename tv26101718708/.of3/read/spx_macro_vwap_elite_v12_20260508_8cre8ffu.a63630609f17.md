Calculation: candle body = abs(close - open)
Calculation: candle range = high - low
Calculation: upper wick = high - max(close, open)
Calculation: lower wick = min(close, open) - low
Calculation: valid pattern body = candle body > ATR(ATR lookback) * pattern body threshold
Calculation: bullish pin pattern = valid pattern body AND close > open AND lower wick >= candle body * pin wick/body threshold AND lower wick > upper wick
Calculation: bearish pin pattern = valid pattern body AND close < open AND upper wick >= candle body * pin wick/body threshold AND upper wick > lower wick
Calculation: bullish engulfing pattern = valid pattern body AND close > open AND close[1] < open[1] AND open <= close[1] AND close >= open[1]
Calculation: bearish engulfing pattern = valid pattern body AND close < open AND close[1] > open[1] AND open >= close[1] AND close <= open[1]
Calculation: dark cloud pattern = valid pattern body AND close[1] > open[1] AND abs(close[1] - open[1]) / candle range[1] >= candle body/range threshold AND close < open AND abs(close - open) / candle range >= candle body/range threshold AND open >= close[1] AND close > open[1] AND close < (open[1] + close[1]) / 2
Calculation: piercing line pattern = valid pattern body AND close[1] < open[1] AND abs(open[1] - close[1]) / candle range[1] >= candle body/range threshold AND close > open AND abs(close - open) / candle range >= candle body/range threshold AND open <= close[1] AND close < open[1] AND close > (open[1] + close[1]) / 2
Calculation: bearish harami pattern = valid pattern body AND close[1] > open[1] AND open > close AND open <= close[1] AND low >= open[1] AND open - close < close[1] - open[1] AND high < high[1] AND low > low[1]
Calculation: bullish harami pattern = valid pattern body AND open[1] > close[1] AND close > open AND close <= open[1] AND high <= open[1] AND close - open < open[1] - close[1] AND high < high[1] AND low > low[1]
Calculation: bullish candle pattern set = bullish pin pattern OR bullish engulfing pattern OR piercing line pattern OR bullish harami pattern
Calculation: bearish candle pattern set = bearish pin pattern OR bearish engulfing pattern OR dark cloud pattern OR bearish harami pattern
Calculation: high fractal = the high at the fractal-width bars-ago center is greater than the highs at each matching offset before and after that center, for offsets from one through fractal width
Calculation: low fractal = the low at the fractal-width bars-ago center is less than the lows at each matching offset before and after that center, for offsets from one through fractal width
Calculation: latest confirmed fractal high = the most recent center-bar high satisfying high fractal
Calculation: latest confirmed fractal low = the most recent center-bar low satisfying low fractal
Calculation: bullish fractal break = close crosses above latest confirmed fractal high
Calculation: bearish fractal break = close crosses below latest confirmed fractal low
Long: chart bar is confirmed AND (time filter is off OR chart time is within either New York session window) AND close > VWAP(hlc3) AND (low <= VWAP(hlc3) AND close > open AND candle body > ATR(ATR lookback) * VWAP-body threshold OR close crosses above VWAP(hlc3) AND close > open AND candle body > ATR(ATR lookback) * VWAP-body threshold OR bullish fractal break) AND at least the filter-score minimum of these four checks pass: (trend filter is off OR HMA(close, trend lookback) > its previous value), (volume filter is off OR volume > SMA(volume, volume lookback)), (ATR filter is off OR candle body > ATR(ATR lookback) * ATR-filter body threshold), (macro filter is off OR chart-timeframe macro-series close <= SMA(chart-timeframe macro-series close, macro lookback)) AND (pattern confirmation is off OR bullish candle pattern set OR bullish fractal break) AND (MACD confirmation is off OR MACD histogram(close, fast lookback, slower lookback, signal lookback) > its previous value) AND (momentum confirmation is off OR close > high[1])
Short: chart bar is confirmed AND (time filter is off OR chart time is within either New York session window) AND close < VWAP(hlc3) AND (high >= VWAP(hlc3) AND close < open AND candle body > ATR(ATR lookback) * VWAP-body threshold OR close crosses below VWAP(hlc3) AND close < open AND candle body > ATR(ATR lookback) * VWAP-body threshold OR bearish fractal break) AND at least the filter-score minimum of these four checks pass: (trend filter is off OR HMA(close, trend lookback) < its previous value), (volume filter is off OR volume > SMA(volume, volume lookback)), (ATR filter is off OR candle body > ATR(ATR lookback) * ATR-filter body threshold), (macro filter is off OR chart-timeframe macro-series close > SMA(chart-timeframe macro-series close, macro lookback)) AND (pattern confirmation is off OR bearish candle pattern set OR bearish fractal break) AND (MACD confirmation is off OR MACD histogram(close, fast lookback, slower lookback, signal lookback) < its previous value) AND (momentum confirmation is off OR close < low[1])
Long: bullish candle pattern set OR high fractal
Short: bearish candle pattern set OR low fractal
Long: HMA(close, trend lookback) > its previous value
Short: HMA(close, trend lookback) <= its previous value
Long: macro filter is off OR chart-timeframe macro-series close <= SMA(chart-timeframe macro-series close, macro lookback)
Short: macro filter is on AND chart-timeframe macro-series close > SMA(chart-timeframe macro-series close, macro lookback)