Calculation: short ATR ratio = ATR(high, low, close, ATR lookback) / SMA(ATR(high, low, close, ATR lookback), short ATR average lookback)
Calculation: long ATR ratio = ATR(high, low, close, ATR lookback) / SMA(ATR(high, low, close, ATR lookback), long ATR average lookback)
Calculation: stop distance = ATR(high, low, close, ATR lookback) * (IF short ATR ratio < low-vol ratio threshold THEN low-vol stop multiplier ELSE IF short ATR ratio > high-vol ratio threshold THEN high-vol stop multiplier ELSE medium-vol stop multiplier)
Calculation: last pivot high = most recent confirmed pivot high(high, pivot lookback)
Calculation: last pivot low = most recent confirmed pivot low(low, pivot lookback)
Calculation: bull structure = last pivot high > previous confirmed pivot high OR last pivot low > previous confirmed pivot low
Calculation: bear structure = last pivot high < previous confirmed pivot high OR last pivot low < previous confirmed pivot low
Calculation: OBV slope = LinReg(OBV(close, volume), OBV slope lookback, 0) - LinReg(OBV(close, volume), OBV slope lookback, 1)
Calculation: bull score = structure weight * [bull structure AND close > last pivot low] + volume weight * [OBV slope > 0] + momentum weight * ([close > KAMA(close, KAMA lookback, KAMA fast lookback, KAMA slow lookback)] + [RSI(close, RSI lookback) > RSI midline] + [Williams %R(high, low, close, WPR lookback) > upper WPR threshold]) / 3 + liquidity weight * [low < last pivot low AND close > last pivot low] + volatility weight * [long ATR ratio > lower volatility band AND long ATR ratio < upper volatility band] + efficiency weight * [Efficiency Ratio(close, efficiency lookback) >= min efficiency]
Calculation: bear score = structure weight * [bear structure AND close < last pivot high] + volume weight * [OBV slope < 0] + momentum weight * ([close < KAMA(close, KAMA lookback, KAMA fast lookback, KAMA slow lookback)] + [RSI(close, RSI lookback) < RSI midline] + [Williams %R(high, low, close, WPR lookback) < lower WPR threshold]) / 3 + liquidity weight * [high > last pivot high AND close < last pivot high] + volatility weight * [long ATR ratio > lower volatility band AND long ATR ratio < upper volatility band] + efficiency weight * [Efficiency Ratio(close, efficiency lookback) >= min efficiency]
Calculation: long entry state = ADX(high, low, close, ADX lookback) > ADX threshold AND close > EMA(close, regime EMA lookback) AND close > VWMA(close, volume, VWMA lookback) AND HMA(close, fast HMA lookback) > HMA(close, slow HMA lookback) AND close > EMA(close, trend EMA lookback, T1, last completed bar) AND bull score >= min score AND bull score - bear score >= min lead
Calculation: short entry state = ADX(high, low, close, ADX lookback) > ADX threshold AND close < EMA(close, regime EMA lookback) AND close < VWMA(close, volume, VWMA lookback) AND HMA(close, fast HMA lookback) < HMA(close, slow HMA lookback) AND close < EMA(close, trend EMA lookback, T1, last completed bar) AND bear score >= min score AND bear score - bull score >= min lead
Calculation: long TP1 price = entry price + stop distance at entry bar * TP1 multiple
Calculation: short TP1 price = entry price - stop distance at entry bar * TP1 multiple
Calculation: long trailing stop = MAX(highest of (close - stop distance) from entry bar through current bar, IF high >= long TP1 price on an earlier bar since entry THEN entry price ELSE negative infinity)
Calculation: short trailing stop = MIN(lowest of (close + stop distance) from entry bar through current bar, IF low <= short TP1 price on an earlier bar since entry THEN entry price ELSE positive infinity)
Long: (long entry state AND NOT long entry state[1]) OR (long entry state AND flat AND bull score >= min score + conviction offset)
Short: (short entry state AND NOT short entry state[1]) OR (short entry state AND flat AND bear score >= min score + conviction offset)
Exit: long, low <= long trailing stop[1]
Exit: long, high >= long TP1 price
Exit: long, high >= entry price + stop distance at entry bar * TP2 multiple
Exit: long, bars since entry >= max holding bars
Exit: short, high >= short trailing stop[1]
Exit: short, low <= short TP1 price
Exit: short, low <= entry price - stop distance at entry bar * TP2 multiple
Exit: short, bars since entry >= max holding bars