Calculation: OBV histogram(x) = OBV(x) - MA(OBV(x), ma type, ma lookback)
Calculation: risk distance = ATR(atr lookback) at entry * stop multiplier
Long: OBV histogram(price source) crosses above 0 AND (NOT HTF confirm OR OBV histogram(close) on T1 bars, last completed bar > 0) AND (NOT ADX filter OR ADX(adx lookback) >= adx minimum) AND (NOT volume filter OR volume >= SMA(volume, volume lookback) * volume multiplier)
Short: OBV histogram(price source) crosses below 0 AND (NOT HTF confirm OR OBV histogram(close) on T1 bars, last completed bar <= 0) AND (NOT ADX filter OR ADX(adx lookback) >= adx minimum) AND (NOT volume filter OR volume >= SMA(volume, volume lookback) * volume multiplier)
Long: pivot low(low, pivot lookback) is confirmed on this bar AND pivot low(low, pivot lookback) < previous pivot low AND OBV histogram(price source)[pivot lookback + 1] > OBV histogram(price source) at previous pivot low bar
Long: pivot low(low, pivot lookback) is confirmed on this bar AND pivot low(low, pivot lookback) > previous pivot low AND OBV histogram(price source)[pivot lookback + 1] < OBV histogram(price source) at previous pivot low bar
Short: pivot high(high, pivot lookback) is confirmed on this bar AND pivot high(high, pivot lookback) > previous pivot high AND OBV histogram(price source)[pivot lookback + 1] < OBV histogram(price source) at previous pivot high bar
Short: pivot high(high, pivot lookback) is confirmed on this bar AND pivot high(high, pivot lookback) < previous pivot high AND OBV histogram(price source)[pivot lookback + 1] > OBV histogram(price source) at previous pivot high bar
Exit: long, first bar from entry where high >= entry price + risk distance * TP1 reward-risk ratio
Exit: long, first bar from entry where high >= entry price + risk distance * TP2 reward-risk ratio
Exit: long, first bar from entry where high >= entry price + risk distance * TP3 reward-risk ratio
Exit: short, first bar from entry where low <= entry price - risk distance * TP1 reward-risk ratio
Exit: short, first bar from entry where low <= entry price - risk distance * TP2 reward-risk ratio
Exit: short, first bar from entry where low <= entry price - risk distance * TP3 reward-risk ratio