Calculation: EMA slope = EMA(close, long EMA lookback) − EMA(close, long EMA lookback)[slope lag]
Calculation: ATR trailing stop = H on the first bar; otherwise, let H = HHV(high − ATR multiplier × ATR(ATR lookback), stop lookback), candidate = H if close > prior ATR trailing stop AND close > prior close, else prior ATR trailing stop; current stop = H if close < candidate, else candidate
Calculation: Pending long signal = a qualifying signal occurred within the pending lifetime AND close has not crossed below EMA(close, short EMA lookback) since that signal, where a qualifying signal is ((close crosses above EMA(close, short EMA lookback) OR (close > prior high AND close > EMA(close, short EMA lookback))) AND volume > SMA(volume, volume lookback) × volume multiplier AND (Bollinger BandWidth(close, Bollinger lookback, deviation multiplier) < SMA(Bollinger BandWidth(close, Bollinger lookback, deviation multiplier), quiet-zone lookback) OR the trend-death condition occurred fewer than the phoenix-window bars ago)
Long: EMA slope >= 0
Short: EMA slope < 0
Long: close > ATR trailing stop
Short: close <= ATR trailing stop
Long: Pending long signal AND (EMA(ROC(close, ROC lookback), ROC smoothing lookback) < 0 OR EMA slope < 0 OR close <= ATR trailing stop)
Long: position is flat AND Pending long signal AND close > EMA(close, long EMA lookback) AND close > EMA(close, short EMA lookback) AND EMA(ROC(close, ROC lookback), ROC smoothing lookback) >= 0 AND EMA slope >= 0 AND close > ATR trailing stop
Long: position is long AND close > entry price × (1 + gain threshold) AND close > EMA(close, long EMA lookback) AND close > EMA(close, short EMA lookback) AND EMA slope >= 0 AND close > ATR trailing stop AND open-trade count < pyramiding cap
Long: position is long AND low crosses below EMA(close, short EMA lookback) AND close > EMA(close, short EMA lookback) AND close > EMA(close, long EMA lookback) AND EMA slope >= 0 AND close > ATR trailing stop
Exit: Long, close < ATR trailing stop OR close crosses below EMA(close, long EMA lookback)