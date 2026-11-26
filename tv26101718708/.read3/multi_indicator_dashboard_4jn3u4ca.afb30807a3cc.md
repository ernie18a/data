Long: close > EMA(close, shortest EMA lookback)
Short: close <= EMA(close, shortest EMA lookback)
Long: close > EMA(close, second-shortest EMA lookback)
Short: close <= EMA(close, second-shortest EMA lookback)
Long: close > EMA(close, second-longest EMA lookback)
Short: close <= EMA(close, second-longest EMA lookback)
Long: close > EMA(close, longest EMA lookback)
Short: close <= EMA(close, longest EMA lookback)
Long: RSI(close, RSI lookback) <= lower RSI threshold
Short: RSI(close, RSI lookback) >= upper RSI threshold
Long: close <= lower Bollinger Band(close, Bollinger lookback, deviation multiplier)
Short: close >= upper Bollinger Band(close, Bollinger lookback, deviation multiplier)
Long: close > VWAP(close)
Short: close <= VWAP(close)
Long: Supertrend(hl2, close, ATR(ATR lookback), ATR multiplier).direction = bullish
Short: Supertrend(hl2, close, ATR(ATR lookback), ATR multiplier).direction = bearish
Calculation: OBV displacement = if SD(OBV - SMA(OBV, shorter OBV smoothing lookback), longer shared spread lookback) = 0 then 0 else (OBV - SMA(OBV, shorter OBV smoothing lookback)) / SD(OBV - SMA(OBV, shorter OBV smoothing lookback), longer shared spread lookback) * SD(high - low, longer shared spread lookback)
Calculation: OBV-derived price = if OBV displacement > 0 then high + OBV displacement else low + OBV displacement
Calculation: Modified OBV MACD = DEMA(OBV-derived price, shorter fast lookback) - EMA(close, longer slow lookback)
Calculation: Adaptive threshold = cumulative sum of ABS(Modified OBV MACD - previous threshold-filtered Modified OBV MACD) / max(current chart bar index, 1)
Calculation: Threshold-filtered Modified OBV MACD = Modified OBV MACD if it is above the previous filtered value plus Adaptive threshold or below the previous filtered value minus Adaptive threshold; otherwise the previous filtered value; on the first bar, use Modified OBV MACD as the previous filtered value
Calculation: Modified OBV direction = 1 if change(Threshold-filtered Modified OBV MACD) > 0, -1 if change(Threshold-filtered Modified OBV MACD) < 0, otherwise the previous direction, initialized to 0
Long: Modified OBV direction = 1
Short: Modified OBV direction != 1