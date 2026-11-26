Calculation: MACD = MACD(close, fast lookback, slow lookback, signal lookback, selected oscillator and signal moving-average types)
Calculation: Normalized(x, lookback) = 0 when standard deviation(x, lookback) is zero or unavailable; otherwise x / standard deviation(x, lookback)
Calculation: MACD deviation = Normalized(MACD, normalization lookback)
Calculation: MACD bias score = Normalized(MACD - MACD[MACD slope lookback], normalization lookback) + Normalized(histogram - histogram[previous bar], normalization lookback) + Normalized(EMA(ROC(close, momentum lookback), momentum smoothing), normalization lookback) + trend coefficient * Normalized(((close - EMA(close, fast EMA lookback)) + (EMA(close, fast EMA lookback) - EMA(close, slow EMA lookback))) / ATR(ATR lookback), normalization lookback)
Calculation: Selected trend(T) = bullish when the selected method gives EMA(close, fast EMA lookback, T) > EMA(close, slow EMA lookback, T), close > EMA(close, fast EMA lookback, T), or MACD(close, fast lookback, slow lookback, signal lookback, T) > its signal, respectively; otherwise bearish. Calculate on T bars, using the developing bar or last completed bar as selected for display; confirmed signal grading uses the last completed bar.
Long: MACD crosses above its signal AND (weak circles are not hidden OR the cross is strong)
Short: MACD crosses below its signal AND (weak circles are not hidden OR the cross is strong)
Long: MACD crosses above its signal AND the signal line is below zero AND (weak circles are not hidden OR the cross is strong)
Short: MACD crosses below its signal AND the signal line is above zero AND (weak circles are not hidden OR the cross is strong)
Long: MACD crosses above its signal AND Selected trend(T1), Selected trend(T2), Selected trend(T3), and Selected trend(T4) are bullish AND (weak circles are not hidden OR the cross is strong)
Short: MACD crosses below its signal AND Selected trend(T1), Selected trend(T2), Selected trend(T3), and Selected trend(T4) are bearish AND (weak circles are not hidden OR the cross is strong)
Long: MACD crosses above its signal AND at least the agreement threshold of Selected trend(T1), Selected trend(T2), Selected trend(T3), Selected trend(T4), and Selected trend(T5), using last completed bars, are bullish AND (fresh-cross requirement is disabled OR MACD < 0) AND (ADX-regime requirement is disabled OR ADX >= threshold)
Short: MACD crosses below its signal AND at least the agreement threshold of Selected trend(T1), Selected trend(T2), Selected trend(T3), Selected trend(T4), and Selected trend(T5), using last completed bars, are bearish AND (fresh-cross requirement is disabled OR MACD > 0) AND (ADX-regime requirement is disabled OR ADX >= threshold)
Long: MACD crosses above its signal AND (filters are disabled OR (higher-timeframe filter is disabled OR EMA(close, fast EMA lookback, T_HTF, last completed bar) > EMA(close, slow EMA lookback, T_HTF, last completed bar)) AND (ADX filter is disabled OR (ADX >= threshold AND +DI > -DI)) AND (zero-line filter is disabled OR MACD < 0) AND no filtered signal occurred within the cooldown lookback)
Short: MACD crosses below its signal AND (filters are disabled OR (higher-timeframe filter is disabled OR EMA(close, fast EMA lookback, T_HTF, last completed bar) < EMA(close, slow EMA lookback, T_HTF, last completed bar)) AND (ADX filter is disabled OR (ADX >= threshold AND -DI > +DI)) AND (zero-line filter is disabled OR MACD > 0) AND no filtered signal occurred within the cooldown lookback)
Long: for each T in T1, T2, T3, T4, and T5, Selected trend(T) is bullish using the dashboard's developing-bar or last-completed-bar setting
Short: for each T in T1, T2, T3, T4, and T5, Selected trend(T) is bearish using the dashboard's developing-bar or last-completed-bar setting
Long: for each T in T1, T2, T3, T4, and T5, MACD(close, fast lookback, slow lookback, signal lookback, T) is above its signal using the dashboard's developing-bar or last-completed-bar setting
Short: for each T in T1, T2, T3, T4, and T5, MACD(close, fast lookback, slow lookback, signal lookback, T) is below its signal using the dashboard's developing-bar or last-completed-bar setting
Long: MACD is above its signal on the chart timeframe
Short: MACD is below its signal on the chart timeframe
Long: a filtered bullish signal occurs, or no filtered signal occurs and MACD bias score >= 0
Short: a filtered bearish signal occurs, or no filtered signal occurs and MACD bias score < 0
Long: MACD crosses above its signal AND MACD deviation <= -extreme threshold
Short: MACD crosses below its signal AND MACD deviation >= extreme threshold
Long: a confirmed MACD pivot low is higher than the previous confirmed MACD pivot low AND the corresponding price low is lower than the previous price pivot low; enable regular divergence detection
Short: a confirmed MACD pivot high is lower than the previous confirmed MACD pivot high AND the corresponding price high is higher than the previous price pivot high; enable regular divergence detection
Long: a confirmed MACD pivot low is lower than the previous confirmed MACD pivot low AND the corresponding price low is higher than the previous price pivot low; enable regular and hidden divergence detection
Short: a confirmed MACD pivot high is higher than the previous confirmed MACD pivot high AND the corresponding price high is lower than the previous price pivot high; enable regular and hidden divergence detection
Long: MACD crosses above its signal AND MACD deviation <= -extreme threshold AND a regular bullish divergence was confirmed within the divergence-validity lookback
Short: MACD crosses below its signal AND MACD deviation >= extreme threshold AND a regular bearish divergence was confirmed within the divergence-validity lookback
Long: the most recent MACD cross was bullish and occurred within the recommendation window AND (the cross was strong OR ADX >= threshold)
Short: the most recent MACD cross was bearish and occurred within the recommendation window AND (the cross was strong OR ADX >= threshold)
Long: bullish MACD cross with MACD deviation <= -extreme threshold occurred within the recommendation window AND no confirmed reversal occurred within that window
Short: bearish MACD cross with MACD deviation >= extreme threshold occurred within the recommendation window AND no confirmed reversal occurred within that window
Long: at least the agreement threshold of displayed Selected trend values across T1, T2, T3, T4, and T5 are bullish AND at least the same threshold of displayed MACD directions across those timeframes are bullish AND ADX >= threshold
Short: at least the agreement threshold of displayed Selected trend values across T1, T2, T3, T4, and T5 are bearish AND at least the same threshold of displayed MACD directions across those timeframes are bearish AND ADX >= threshold
Long: MACD is above its signal on the last completed bars of T1, T2, T3, and T4, and this alignment was false on the previous chart bar
Short: MACD is below its signal on the last completed bars of T1, T2, T3, and T4, and this alignment was false on the previous chart bar
Exit: long, low <= entry price - stop multiple * ATR-at-entry
Exit: short, high >= entry price + stop multiple * ATR-at-entry
Exit: long, high >= entry price + target multiple * ATR-at-entry AND low > entry price - stop multiple * ATR-at-entry
Exit: short, low <= entry price - target multiple * ATR-at-entry AND high < entry price + stop multiple * ATR-at-entry
Exit: long, histogram momentum is negative against the position for the fade lookback consecutive bars
Exit: short, histogram momentum is positive against the position for the fade lookback consecutive bars
Exit: long, histogram momentum has weakened against the predicted long direction for the fade lookback consecutive bars
Exit: short, histogram momentum has weakened against the predicted short direction for the fade lookback consecutive bars
Exit: long, a bearish extreme cross occurred within the recommendation window AND no confirmed reversal occurred within that window
Exit: short, a bullish extreme cross occurred within the recommendation window AND no confirmed reversal occurred within that window