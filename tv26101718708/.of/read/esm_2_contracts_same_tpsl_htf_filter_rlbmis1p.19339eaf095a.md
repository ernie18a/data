Calculation: Opening-range high = highest high during the current day's opening-range window
Calculation: Opening-range low = lowest low during the current day's opening-range window
Calculation: Higher-timeframe EMA = EMA of closes on a higher timeframe, using the current higher-timeframe bar
Long: after the opening-range window is complete AND close crosses above opening-range high AND close > VWAP AND higher-timeframe close > higher-timeframe EMA AND position size = 0 AND trades today < daily trade limit AND long entries today = 0
Short: after the opening-range window is complete AND close crosses below opening-range low AND close < VWAP AND higher-timeframe close < higher-timeframe EMA AND position size = 0 AND trades today < daily trade limit AND short entries today = 0
Exit: long, low <= entry price - stop distance OR high >= entry price + target distance
Exit: short, high >= entry price + stop distance OR low <= entry price - target distance