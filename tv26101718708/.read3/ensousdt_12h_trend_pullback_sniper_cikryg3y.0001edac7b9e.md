Long: position side is flat AND EMA(close, fast lookback) > EMA(close, middle lookback) AND close > EMA(close, slow lookback) AND close > VWAP(hlc3) AND abs(close - EMA(close, middle lookback)) <= ATR(ATR lookback) * pullback-distance multiplier AND StochRSI K crosses above StochRSI D AND StochRSI K[1] < oversold threshold
Short: position side is flat AND EMA(close, fast lookback) < EMA(close, middle lookback) AND close < EMA(close, slow lookback) AND close < VWAP(hlc3) AND abs(close - EMA(close, middle lookback)) <= ATR(ATR lookback) * pullback-distance multiplier AND StochRSI K crosses below StochRSI D AND StochRSI K[1] > overbought threshold
Exit: long, low <= signal-bar close - ATR(signal bar, ATR lookback) * stop-loss multiplier
Exit: long, high >= signal-bar close + ATR(signal bar, ATR lookback) * first-target multiplier
Exit: long, high >= signal-bar close + ATR(signal bar, ATR lookback) * second-target multiplier
Exit: long, close < EMA(close, slow lookback)
Exit: short, high >= signal-bar close + ATR(signal bar, ATR lookback) * stop-loss multiplier
Exit: short, low <= signal-bar close - ATR(signal bar, ATR lookback) * first-target multiplier
Exit: short, low <= signal-bar close - ATR(signal bar, ATR lookback) * second-target multiplier
Exit: short, close > EMA(close, slow lookback)