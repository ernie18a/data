Calculation: session minute = minutes from session open to bar close time
Calculation: entry window open = session minute > opening block end AND session minute < closing block start AND IF(session minute <= window 1 end, TRUE, IF(session minute <= window 2 end, window 2 enabled, IF(session minute <= window 3 end, window 3 enabled, IF(session minute <= window 4 end, window 4 enabled, window 5 enabled))))
Calculation: short RSI floor = IF(session minute <= window 1 end, window 1 short RSI floor, IF(session minute <= window 4 end, window 2-4 short RSI floor, window 5 short RSI floor))
Calculation: MACD slope = MACD line(close, MACD fast, MACD slow, MACD signal) - MACD line(close, MACD fast, MACD slow, MACD signal)[slope bars]
Calculation: long marker count = number of true among: EMA(close, shorter lookback) > EMA(close, longer lookback); MACD line(close, MACD fast, MACD slow, MACD signal) < long marker MACD line max; ADX(ADX lookback) > long marker ADX min; MACD slope > 0; MACD signal line(close, MACD fast, MACD slow, MACD signal) > long marker MACD signal min; SMA(RSI(close, rsi lookback), rsi smoothing lookback) > long marker RSI min
Calculation: short marker count = number of true among: EMA(close, shorter lookback) < EMA(close, longer lookback); MACD line(close, MACD fast, MACD slow, MACD signal) > short marker MACD line min; ADX(ADX lookback) > short marker ADX min; MACD slope < 0; MACD signal line(close, MACD fast, MACD slow, MACD signal) < short marker MACD signal max; SMA(RSI(close, rsi lookback), rsi smoothing lookback) < short marker RSI max
Long: EMA(close, shorter lookback) > EMA(close, longer lookback) AND EMA(close, T1 longer lookback, T1, last completed bar, on chart bars) > EMA(close, T1 shorter lookback, T1, last completed bar, on chart bars) AND SMA(RSI(close, rsi lookback), rsi smoothing lookback) < long RSI max AND entry window open AND position side is flat
Long: high = open AND close - low >= pin tail ratio * (open - close) AND open >= close AND (high - low) / high >= target fraction AND position side is not long AND long pin bar enabled
Long: long marker count >= long marker min count
Short: EMA(close, shorter lookback) < EMA(close, longer lookback) AND EMA(close, T1 longer lookback, T1, last completed bar, on chart bars) < EMA(close, T1 shorter lookback, T1, last completed bar, on chart bars) AND SMA(RSI(close, rsi lookback), rsi smoothing lookback) > short RSI floor AND entry window open AND position side is flat
Short: close = low AND high - close >= pin tail ratio * (close - open) AND open <= close AND (high - low) / high >= target fraction AND position side is not short AND short pin bar enabled
Short: short marker count >= short marker min count
Exit: long, close < entry price * (1 - stop fraction)
Exit: long, close >= entry price * (1 + target multiple * target fraction) AND (ADX(ADX lookback) <= exit ADX max OR close < close[momentum bars])
Exit: long, close(T1, last completed bar) < EMA(close, T1 longer lookback, T1, last completed bar, on chart bars) AND (ADX(ADX lookback) <= exit ADX max OR close < close[momentum bars])
Exit: long, session minute = flatten minute
Exit: short, close > entry price * (1 + stop fraction)
Exit: short, close <= entry price * (1 - target multiple * target fraction) AND (ADX(ADX lookback) <= exit ADX max OR close > close[momentum bars])
Exit: short, close(T1, last completed bar) > EMA(close, T1 longer lookback, T1, last completed bar, on chart bars) AND (ADX(ADX lookback) <= exit ADX max OR close > close[momentum bars])
Exit: short, session minute = flatten minute