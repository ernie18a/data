Calculation: candle body = ABS(close - open)
Calculation: upper wick = high - MAX(close, open)
Calculation: lower wick = MIN(close, open) - low
Calculation: body percent of range = candle body / (high - low) * 100
Calculation: bullish pin bar = lower wick >= candle body * pin bar wick ratio AND lower wick >= upper wick * opposite wick ratio AND candle body > 0
Calculation: bearish pin bar = upper wick >= candle body * pin bar wick ratio AND upper wick >= lower wick * opposite wick ratio AND candle body > 0
Calculation: bullish engulfing = close[1] <= open[1] AND close > open[1] AND open < close[1] AND candle body >= candle body[1] * (engulfing minimum percent / 100)
Calculation: bearish engulfing = close[1] >= open[1] AND close < open[1] AND open > close[1] AND candle body >= candle body[1] * (engulfing minimum percent / 100)
Calculation: last pivot high = latest confirmed PivotHigh(high, pivot left lookback, pivot right bars)
Calculation: prior pivot high = confirmed PivotHigh value before the last pivot high
Calculation: last pivot low = latest confirmed PivotLow(low, pivot left lookback, pivot right bars)
Calculation: prior pivot low = confirmed PivotLow value before the last pivot low
Calculation: near support = low >= last pivot low * (1 - zone tolerance percent / 100) AND low <= last pivot low * (1 + zone tolerance percent / 100)
Calculation: near resistance = high >= last pivot high * (1 - zone tolerance percent / 100) AND high <= last pivot high * (1 + zone tolerance percent / 100)
Calculation: EMA gap percent = ABS(EMA(close, shorter lookback) - EMA(close, longer lookback)) / EMA(close, longer lookback) * 100
Calculation: volume delta = SUM(volume where close >= open, volume lookback) - SUM(volume where close < open, volume lookback)
Calculation: long stop level = IF pivot levels enabled AND last pivot low at entry bar < entry price THEN last pivot low at entry bar * (1 - SL buffer percent / 100) ELSE entry price - ATR(ATR lookback) at entry bar * ATR stop multiplier
Calculation: long TP1 level = IF pivot levels enabled AND last pivot high at entry bar > entry price THEN last pivot high at entry bar ELSE entry price + ATR(ATR lookback) at entry bar * ATR TP1 multiplier
Calculation: long TP2 level = IF pivot levels enabled AND prior pivot high at entry bar > long TP1 level THEN prior pivot high at entry bar ELSE entry price + ATR(ATR lookback) at entry bar * ATR TP2 multiplier
Calculation: short stop level = IF pivot levels enabled AND last pivot high at entry bar > entry price THEN last pivot high at entry bar * (1 + SL buffer percent / 100) ELSE entry price + ATR(ATR lookback) at entry bar * ATR stop multiplier
Calculation: short TP1 level = IF pivot levels enabled AND last pivot low at entry bar < entry price THEN last pivot low at entry bar ELSE entry price - ATR(ATR lookback) at entry bar * ATR TP1 multiplier
Calculation: short TP2 level = IF pivot levels enabled AND prior pivot low at entry bar < short TP1 level THEN prior pivot low at entry bar ELSE entry price - ATR(ATR lookback) at entry bar * ATR TP2 multiplier
Long: ((near support AND ((pin bar enabled AND bullish pin bar) OR (engulfing enabled AND bullish engulfing))) OR (breakout enabled AND close crosses above last pivot high * (1 + zone tolerance percent / 100))) AND (EMA filter disabled OR (EMA(close, shorter lookback) > EMA(close, longer lookback) AND EMA gap percent >= min EMA gap percent AND close > EMA(close, shorter lookback))) AND (RSI filter disabled OR RSI(close, RSI lookback) < RSI overbought level) AND (VWAP filter disabled OR close > VWAP((high + low + close) / 3)) AND (volume filter disabled OR (volume > volume threshold multiplier * SMA(volume, volume lookback) AND volume delta > 0)) AND (strength filter disabled OR (candle body >= min ATR multiple * ATR(ATR lookback) AND body percent of range >= min body percent AND volume > volume spike multiplier * SMA(volume, volume lookback) AND (confirmation candle disabled OR close[1] > open[1])))
Short: ((near resistance AND ((pin bar enabled AND bearish pin bar) OR (engulfing enabled AND bearish engulfing))) OR (breakout enabled AND close crosses below last pivot low * (1 - zone tolerance percent / 100))) AND (EMA filter disabled OR (EMA(close, shorter lookback) < EMA(close, longer lookback) AND EMA gap percent >= min EMA gap percent AND close < EMA(close, shorter lookback))) AND (RSI filter disabled OR RSI(close, RSI lookback) > RSI oversold level) AND (VWAP filter disabled OR close <= VWAP((high + low + close) / 3)) AND (volume filter disabled OR (volume > volume threshold multiplier * SMA(volume, volume lookback) AND volume delta < 0)) AND (strength filter disabled OR (candle body >= min ATR multiple * ATR(ATR lookback) AND body percent of range >= min body percent AND volume > volume spike multiplier * SMA(volume, volume lookback) AND (confirmation candle disabled OR close[1] < open[1])))
Exit: Long, low <= long stop level
Exit: Long, high >= long TP1 level
Exit: Long, high >= long TP2 level
Exit: Short, high >= short stop level
Exit: Short, low <= short TP1 level
Exit: Short, low <= short TP2 level