Calculation: large-body candle = abs(close - open) > (high - low) * body-size threshold
Long: MFI(close, MFI lookback)[1] = overbought level AND close > open AND large-body candle AND (MA filter disabled OR close > SMA(close, MA lookback)) AND within configured session
Short: MFI(close, MFI lookback)[1] = oversold level AND close < open AND large-body candle AND (MA filter disabled OR close <= SMA(close, MA lookback)) AND within configured session
Exit: Long, outside configured session OR low <= entry price * (1 - long stop-loss parameter) OR high >= entry price * (1 + long take-profit parameter)
Exit: Short, outside configured session OR high >= entry price * (1 + short stop-loss parameter) OR low <= entry price * (1 - short take-profit parameter)