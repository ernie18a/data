Long: close > EMA(close, fast lookback) AND EMA(close, fast lookback) > EMA(close, slow lookback) AND close > VWAP(high, low, close, volume)
Short: close < EMA(close, fast lookback) AND EMA(close, fast lookback) < EMA(close, slow lookback) AND close < VWAP(high, low, close, volume)
Long: EMA(close, fast lookback) - EMA(close, slow lookback) >= range ratio * ATR(high, low, close, ATR lookback)
Short: EMA(close, slow lookback) - EMA(close, fast lookback) >= range ratio * ATR(high, low, close, ATR lookback)
Long: EMA(close, fast lookback) > EMA(close, slow lookback)
Short: EMA(close, fast lookback) <= EMA(close, slow lookback)
Long: EMA(close, mid lookback) > EMA(close, fast lookback)
Short: EMA(close, mid lookback) <= EMA(close, fast lookback)
Long: close > EMA(close, short lookback)
Short: close <= EMA(close, short lookback)
Long: EMA(close, short lookback) > EMA(close, short lookback)[1]
Short: EMA(close, short lookback) <= EMA(close, short lookback)[1]
Long: RSI(close, RSI lookback) > RSI(close, RSI lookback)[1]
Short: RSI(close, RSI lookback) <= RSI(close, RSI lookback)[1]
Long: close > VWAP(high, low, close, volume)
Short: close <= VWAP(high, low, close, volume)
Long: Stochastic(close, high, low, stochastic lookback) > stochastic midline
Short: Stochastic(close, high, low, stochastic lookback) <= stochastic midline
Calculation: signed volume = volume if close > open, -volume if close < open, 0 otherwise
Long: SMA(signed volume, smoothing lookback) > 0
Short: SMA(signed volume, smoothing lookback) <= 0
Long: OBV(close, volume) > OBV(close, volume)[1]
Short: OBV(close, volume) <= OBV(close, volume)[1]
Long: EMA(close, fast lookback, T1, last completed bar) > EMA(close, slow lookback, T1, last completed bar)
Short: EMA(close, fast lookback, T1, last completed bar) <= EMA(close, slow lookback, T1, last completed bar)
Long: RSI(close, RSI lookback, T1, last completed bar) > RSI midline
Short: RSI(close, RSI lookback, T1, last completed bar) <= RSI midline
Long: RSI(close, RSI lookback, T1, last completed bar) > RSI(close, RSI lookback, T1, last completed bar)[1]
Short: RSI(close, RSI lookback, T1, last completed bar) <= RSI(close, RSI lookback, T1, last completed bar)[1]
Long: MACD line(close, MACD fast lookback, MACD slow lookback, T1, last completed bar) > 0
Short: MACD line(close, MACD fast lookback, MACD slow lookback, T1, last completed bar) <= 0
Long: MACD line(close, MACD fast lookback, MACD slow lookback, T1, last completed bar) > MACD line(close, MACD fast lookback, MACD slow lookback, T1, last completed bar)[1]
Short: MACD line(close, MACD fast lookback, MACD slow lookback, T1, last completed bar) <= MACD line(close, MACD fast lookback, MACD slow lookback, T1, last completed bar)[1]