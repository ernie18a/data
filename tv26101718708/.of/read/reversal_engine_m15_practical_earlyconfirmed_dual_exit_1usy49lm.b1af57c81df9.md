Calculation: EMA_fast, EMA_mid = EMAs of close, EMA_fast has the shorter length
Calculation: ATR, RSI, Stochastic %K (from close/high/low), %D = SMA of %K
Calculation: LowerWick = (min(open,close) - low)/(high - low), requires high>low
Calculation: UpperWick = (high - max(open,close))/(high - low), requires high>low
Calculation: PivotLowRecent = a pivot low (low is the lowest among a few bars on each side, confirmed only after the right-side bars close) was confirmed within the last N bars, current bar included
Calculation: DropPct = (highest high over lookback - low)/highest high*100
Calculation: Gate_X = for each signal type X, no signal of the same type has fired since the last bar with close >= EMA_fast (flag cleared on such a bar before evaluating the signal) AND the bars since the previous same-type signal exceed that type's cooldown
Long (Early): low <= lowest low over a long lookback AND close < EMA_mid - k_a*ATR AND close > previous low AND RSI < early RSI cap AND (%K < early %K cap OR %K > previous %K) AND Gate_Early (the early caps are looser than the confirmed caps)
Long (Confirmed): PivotLowRecent AND low <= lowest low over the long lookback AND low <= lowest low over a shorter lookback AND close < EMA_mid - k_a*ATR AND close > previous close AND close > previous low AND LowerWick >= wick_min AND RSI < RSI cap AND %K < %K cap AND %K crosses above %D AND Gate_Confirmed
Long (Crash Early): DropPct >= drop threshold AND (close > open OR close > previous low) AND (RSI < crash-early RSI cap OR %K > previous %K) AND Gate_CrashEarly, where for the crash types the flag is also cleared when DropPct < drop threshold OR close > EMA_fast OR RSI > a neutral-zone level
Long (Crash Confirmed): DropPct >= drop threshold AND LowerWick >= crash_wick_min AND close > previous close AND close > previous low AND (%K crosses above %D OR RSI < crash-confirmed RSI cap, which is lower than the crash-early cap) AND Gate_CrashConfirmed
Exit: long, high >= highest high over an exit lookback AND close > EMA_mid + k_b*ATR AND close < previous close AND close < open AND RSI > R_b AND %K > S_b AND %K crosses below %D AND close > EMA_fast AND Gate_Exit (Gate_Exit flag is cleared when close < EMA_fast OR RSI < neutral level OR %K < neutral level)
Exit: long, same as the previous Exit line but with a stricter set: k_c > k_b, R_c > R_b, S_c > S_b, AND UpperWick >= upper_wick_min