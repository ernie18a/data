Calculation: Stop = MIN(LOWEST(low, stop lookback), EMA(close, longer EMA lookback)) - ATR(ATR lookback) * ATR multiplier
Calculation: Risk per share = close - Stop when close > Stop, otherwise NA
Long: close > EMA(close, longer EMA lookback) AND close < EMA(close, shorter EMA lookback) AND EMA(OBV, OBV smoothing lookback) > SMA(EMA(OBV, OBV smoothing lookback), OBV average lookback)
Long: close > EMA(close, longer EMA lookback) AND close < EMA(close, shorter EMA lookback) AND volume < SMA(volume, volume lookback)
Long: close > HIGHEST(high[1], breakout lookback) AND volume > SMA(volume, volume lookback) * volume multiplier AND EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback) AND EMA(OBV, OBV smoothing lookback) > SMA(EMA(OBV, OBV smoothing lookback), OBV average lookback) AND Risk per share is not NA
Exit: long, low <= Stop OR (Risk per share is not NA AND high >= close + Risk per share * reward multiple)