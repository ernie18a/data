Calculation: Trend reading(bars, bar) = clip((EMA(close, trend length) - EMA(close, trend length)[slope lookback]) / (ATR(ATR length) * trend scale), -score limit, score limit), unavailable if ATR is not positive or the lagged EMA is unavailable
Calculation: Momentum reading(bars, bar) = clip((RSI(close, RSI length) - RSI centre) / RSI scale, -score limit, score limit)
Calculation: Blended reading(bars, bar) = trend weight * Trend reading(bars, bar) + momentum weight * Momentum reading(bars, bar)
Calculation: Bias(bars, bar) = 1 if Trend reading, Momentum reading and PercentRank(ATR(ATR length), volatility lookback) are available, quiet percentile < hot percentile, NOT (abs(Trend reading) >= conflict threshold AND abs(Momentum reading) >= conflict threshold AND Trend reading * Momentum reading < 0), and Blended reading >= bias fraction * state threshold; -1 if those same conditions hold and Blended reading <= -(bias fraction * state threshold); 0 otherwise
Calculation: Eligible(T_k) = T_k enabled AND duration(T_k) >= duration(chart) AND NOT (duration(T_j) = duration(T_k) for some enabled T_j with j < k)
Calculation: Unanimous bullish = at least one Eligible(T_k) AND Bias(T_k, last completed bar) = 1 for every k with Eligible(T_k)
Calculation: Unanimous bearish = at least one Eligible(T_k) AND Bias(T_k, last completed bar) = -1 for every k with Eligible(T_k)
Long: chart bar closed AND Unanimous bullish AND NOT Unanimous bullish[1]
Short: chart bar closed AND Unanimous bearish AND NOT Unanimous bearish[1]
Long: Unanimous bullish
Short: Unanimous bearish
Long: Bias(chart, bar still forming) = 1
Short: Bias(chart, bar still forming) = -1
Long: Eligible(T1) AND Bias(T1, last completed bar) = 1
Short: Eligible(T1) AND Bias(T1, last completed bar) = -1
Long: Eligible(T1) AND Bias(T1, bar still forming) = 1
Short: Eligible(T1) AND Bias(T1, bar still forming) = -1
Long: Eligible(T1) AND Trend reading(T1, last completed bar) > trend label threshold
Short: Eligible(T1) AND Trend reading(T1, last completed bar) < -trend label threshold
Long: Eligible(T1) AND RSI(close, RSI length, T1, last completed bar) >= bull RSI label level
Short: Eligible(T1) AND RSI(close, RSI length, T1, last completed bar) <= bear RSI label level
Long: Eligible(T2) AND Bias(T2, last completed bar) = 1
Short: Eligible(T2) AND Bias(T2, last completed bar) = -1
Long: Eligible(T2) AND Bias(T2, bar still forming) = 1
Short: Eligible(T2) AND Bias(T2, bar still forming) = -1
Long: Eligible(T2) AND Trend reading(T2, last completed bar) > trend label threshold
Short: Eligible(T2) AND Trend reading(T2, last completed bar) < -trend label threshold
Long: Eligible(T2) AND RSI(close, RSI length, T2, last completed bar) >= bull RSI label level
Short: Eligible(T2) AND RSI(close, RSI length, T2, last completed bar) <= bear RSI label level
Long: Eligible(T3) AND Bias(T3, last completed bar) = 1
Short: Eligible(T3) AND Bias(T3, last completed bar) = -1
Long: Eligible(T3) AND Bias(T3, bar still forming) = 1
Short: Eligible(T3) AND Bias(T3, bar still forming) = -1
Long: Eligible(T3) AND Trend reading(T3, last completed bar) > trend label threshold
Short: Eligible(T3) AND Trend reading(T3, last completed bar) < -trend label threshold
Long: Eligible(T3) AND RSI(close, RSI length, T3, last completed bar) >= bull RSI label level
Short: Eligible(T3) AND RSI(close, RSI length, T3, last completed bar) <= bear RSI label level
Long: Eligible(T4) AND Bias(T4, last completed bar) = 1
Short: Eligible(T4) AND Bias(T4, last completed bar) = -1
Long: Eligible(T4) AND Bias(T4, bar still forming) = 1
Short: Eligible(T4) AND Bias(T4, bar still forming) = -1
Long: Eligible(T4) AND Trend reading(T4, last completed bar) > trend label threshold
Short: Eligible(T4) AND Trend reading(T4, last completed bar) < -trend label threshold
Long: Eligible(T4) AND RSI(close, RSI length, T4, last completed bar) >= bull RSI label level
Short: Eligible(T4) AND RSI(close, RSI length, T4, last completed bar) <= bear RSI label level
Long: Eligible(T5) AND Bias(T5, last completed bar) = 1
Short: Eligible(T5) AND Bias(T5, last completed bar) = -1
Long: Eligible(T5) AND Bias(T5, bar still forming) = 1
Short: Eligible(T5) AND Bias(T5, bar still forming) = -1
Long: Eligible(T5) AND Trend reading(T5, last completed bar) > trend label threshold
Short: Eligible(T5) AND Trend reading(T5, last completed bar) < -trend label threshold
Long: Eligible(T5) AND RSI(close, RSI length, T5, last completed bar) >= bull RSI label level
Short: Eligible(T5) AND RSI(close, RSI length, T5, last completed bar) <= bear RSI label level
Long: Eligible(T6) AND Bias(T6, last completed bar) = 1
Short: Eligible(T6) AND Bias(T6, last completed bar) = -1
Long: Eligible(T6) AND Bias(T6, bar still forming) = 1
Short: Eligible(T6) AND Bias(T6, bar still forming) = -1
Long: Eligible(T6) AND Trend reading(T6, last completed bar) > trend label threshold
Short: Eligible(T6) AND Trend reading(T6, last completed bar) < -trend label threshold
Long: Eligible(T6) AND RSI(close, RSI length, T6, last completed bar) >= bull RSI label level
Short: Eligible(T6) AND RSI(close, RSI length, T6, last completed bar) <= bear RSI label level