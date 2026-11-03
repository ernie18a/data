Long: previous completed indicator-timeframe close > its EMA AND latest completed close < its EMA
Long: older completed indicator-timeframe candle is bearish AND latest completed candle is bullish AND latest close > older open AND latest open < older close
Long: older completed indicator-timeframe RSI < oversold threshold AND latest completed RSI >= oversold threshold
Short: previous completed indicator-timeframe close < its EMA AND latest completed close > its EMA
Short: older completed indicator-timeframe candle is bullish AND latest completed candle is bearish AND latest close < older open AND latest open > older close
Short: older completed indicator-timeframe RSI > overbought threshold AND latest completed RSI <= overbought threshold
Exit: Long, low <= entry price - stop-loss distance OR high >= entry price + stop-loss distance × risk-reward ratio OR a short signal occurs
Exit: Short, high >= entry price + stop-loss distance OR low <= entry price - stop-loss distance × risk-reward ratio OR a long signal occurs