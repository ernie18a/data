Calculation: Opening range high = highest high during the opening-range session
Calculation: Opening range low = lowest low during the opening-range session
Calculation: Previous day high = high of the last completed higher-timeframe daily bar
Calculation: Previous day low = low of the last completed higher-timeframe daily bar
Calculation: Long stop = lowest low over a shorter lookback − ATR
Calculation: Short stop = highest high over a shorter lookback + ATR
Calculation: Long target = entry price + (entry price − long stop) × risk-reward ratio
Calculation: Short target = entry price − (short stop − entry price) × risk-reward ratio
Long: On bar close, close crosses above opening range high OR previous day high, AND close > open, AND RSI > its bullish threshold, AND current volume > VWMA of close over a longer lookback × volume multiplier
Short: On bar close, close crosses below opening range low OR previous day low, AND close < open, AND RSI < its bearish threshold, AND current volume > VWMA of close over a longer lookback × volume multiplier
Exit: long, close >= long target OR close <= long stop OR end-of-day cutoff when the market is not always-on
Exit: short, close <= short target OR close >= short stop OR end-of-day cutoff when the market is not always-on