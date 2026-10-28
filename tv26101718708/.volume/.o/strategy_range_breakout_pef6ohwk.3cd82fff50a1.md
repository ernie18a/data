Calculation: Opening-range high = highest high during the configured opening-range session, retained until the next session
Calculation: Opening-range low = lowest low during the configured opening-range session, retained until the next session
Calculation: Long stop = lowest low over its configured lookback minus ATR
Calculation: Short stop = highest high over its configured lookback plus ATR
Calculation: Long target = entry price + (entry price − long stop) × configured risk-reward ratio
Calculation: Short target = entry price − (short stop − entry price) × configured risk-reward ratio
Long: close crosses above opening-range high OR close crosses above the previous completed daily bar’s high; close > open; RSI > configured bullish threshold; volume > VWMA of close over its configured lookback × configured volume multiplier
Short: close crosses below opening-range low OR close crosses below the previous completed daily bar’s low; close < open; RSI < configured bearish threshold; volume > VWMA of close over its configured lookback × configured volume multiplier
Exit: long, close >= long target OR close <= long stop
Exit: short, close <= short target OR close >= short stop
Exit: long or short, configured end-of-day time reached when the market-always-on setting is disabled