Calculation: opening-range high = maximum(high) during the opening-range-duration parameter after market open, reset each session
Calculation: opening-range low = minimum(low) during the opening-range-duration parameter after market open, reset each session
Long: close > opening-range high AND close > VWAP(close) AND close > EMA(close, lookback parameter) AND low <= VWAP(close) AND datetime > market open + opening-range-duration parameter
Short: close < opening-range low AND close < VWAP(close) AND close < EMA(close, lookback parameter) AND high >= VWAP(close) AND datetime > market open + opening-range-duration parameter
Exit: Long, low <= entry-signal-bar close - ATR(lookback parameter) × stop-multiplier parameter OR high >= entry-signal-bar close + ATR(lookback parameter) × risk/reward parameter
Exit: Short, high >= entry-signal-bar close + ATR(lookback parameter) × stop-multiplier parameter OR low <= entry-signal-bar close - ATR(lookback parameter) × risk/reward parameter