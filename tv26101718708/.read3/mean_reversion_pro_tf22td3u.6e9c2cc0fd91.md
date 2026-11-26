Calculation: THR(i) = points ladder(i) if threshold mode = M1; multiplier ladder(i) * ATR(atr lookback) if threshold mode = M2; multiplier ladder(i) * STDEV(close, max(ma lookback, minimum stdev lookback)) if threshold mode = M3
Calculation: LONG_EVENT(i) = (LONG_EVENT(i)[1] AND NOT (LONG_RETURN(i) OR bars since entry >= event timeout)) OR (NOT LONG_EVENT(i)[1] AND MA(close, ma lookback) - close >= THR(i))
Calculation: LONG_RETURN(i) = LONG_EVENT(i)[1] AND close >= MA(close, ma lookback)
Calculation: LONG_MAE(i) = max(LONG_MAE(i)[1], entry price - close) if LONG_EVENT(i)[1], else 0
Calculation: LONG_MFE(i) = max(LONG_MFE(i)[1], close - entry price) if LONG_EVENT(i)[1], else 0
Calculation: LONG_OCC(i) = count of bars so far where LONG_EVENT(i) AND NOT LONG_EVENT(i)[1]
Calculation: LONG_RET(i) = count of bars so far where LONG_RETURN(i)
Calculation: LONG_SMAE(i) = sum of LONG_MAE(i) over bars so far where LONG_RETURN(i)
Calculation: LONG_SMFE(i) = sum of LONG_MFE(i) over bars so far where LONG_RETURN(i)
Calculation: LONG_EXP(i) = LONG_SMFE(i) / LONG_OCC(i) - (1 - LONG_RET(i) / LONG_OCC(i)) * LONG_SMAE(i) / LONG_OCC(i)
Calculation: LONG_OPT = lowest i with maximum LONG_EXP(i) among i where LONG_OCC(i) >= minimum occurrences AND LONG_RET(i) / LONG_OCC(i) >= minimum win-rate AND LONG_EXP(i) > minimum expectancy; undefined if no i qualifies
Calculation: LONG_SIGNAL = bars so far >= minimum history bars AND LONG_OPT is defined AND (NOT volume filter OR volume > SMA(volume, volume lookback)) AND (NOT session filter OR time(T1, session window, session time zone) of forming bar is defined) AND (NOT ATR filter OR ATR(atr lookback) >= minimum ATR) AND (NOT trend filter OR EMA(close, trend lookback) - EMA(close, trend lookback)[trend slope lookback] >= -slope tolerance * EMA(close, trend lookback)) AND MA(close, ma lookback) - close >= THR(LONG_OPT)
Calculation: SHORT_EVENT(i) = (SHORT_EVENT(i)[1] AND NOT (SHORT_RETURN(i) OR bars since entry >= event timeout)) OR (NOT SHORT_EVENT(i)[1] AND close - MA(close, ma lookback) >= THR(i))
Calculation: SHORT_RETURN(i) = SHORT_EVENT(i)[1] AND close <= MA(close, ma lookback)
Calculation: SHORT_MAE(i) = max(SHORT_MAE(i)[1], close - entry price) if SHORT_EVENT(i)[1], else 0
Calculation: SHORT_MFE(i) = max(SHORT_MFE(i)[1], entry price - close) if SHORT_EVENT(i)[1], else 0
Calculation: SHORT_OCC(i) = count of bars so far where SHORT_EVENT(i) AND NOT SHORT_EVENT(i)[1]
Calculation: SHORT_RET(i) = count of bars so far where SHORT_RETURN(i)
Calculation: SHORT_SMAE(i) = sum of SHORT_MAE(i) over bars so far where SHORT_RETURN(i)
Calculation: SHORT_SMFE(i) = sum of SHORT_MFE(i) over bars so far where SHORT_RETURN(i)
Calculation: SHORT_EXP(i) = SHORT_SMFE(i) / SHORT_OCC(i) - (1 - SHORT_RET(i) / SHORT_OCC(i)) * SHORT_SMAE(i) / SHORT_OCC(i)
Calculation: SHORT_OPT = lowest i with maximum SHORT_EXP(i) among i where SHORT_OCC(i) >= minimum occurrences AND SHORT_RET(i) / SHORT_OCC(i) >= minimum win-rate AND SHORT_EXP(i) > minimum expectancy; undefined if no i qualifies
Calculation: SHORT_SIGNAL = bars so far >= minimum history bars AND SHORT_OPT is defined AND (NOT volume filter OR volume > SMA(volume, volume lookback)) AND (NOT session filter OR time(T1, session window, session time zone) of forming bar is defined) AND (NOT ATR filter OR ATR(atr lookback) >= minimum ATR) AND (NOT trend filter OR EMA(close, trend lookback) - EMA(close, trend lookback)[trend slope lookback] <= slope tolerance * EMA(close, trend lookback)) AND close - MA(close, ma lookback) >= THR(SHORT_OPT)
Long: LONG_SIGNAL AND NOT LONG_SIGNAL[1]
Long: LONG_SIGNAL
Long: LONG_OPT is defined AND MA(close, ma lookback) - close >= THR(LONG_OPT)
Long: LONG_OPT is defined AND MA(close, ma lookback) - close >= extreme multiplier * THR(LONG_OPT)
Long: NOT LONG_EVENT(i)[1] AND MA(close, ma lookback) - close >= THR(i)
Short: SHORT_SIGNAL AND NOT SHORT_SIGNAL[1]
Short: SHORT_SIGNAL
Short: SHORT_OPT is defined AND close - MA(close, ma lookback) >= THR(SHORT_OPT)
Short: SHORT_OPT is defined AND close - MA(close, ma lookback) >= extreme multiplier * THR(SHORT_OPT)
Short: NOT SHORT_EVENT(i)[1] AND close - MA(close, ma lookback) >= THR(i)
Exit: long, close >= MA(close, ma lookback) OR bars since entry >= event timeout
Exit: short, close <= MA(close, ma lookback) OR bars since entry >= event timeout