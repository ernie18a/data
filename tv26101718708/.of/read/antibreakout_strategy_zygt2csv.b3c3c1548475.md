Calculation: Prior high = highest high over the configured number of completed bars before the current bar
Calculation: Prior low = lowest low over the configured number of completed bars before the current bar
Calculation: Price source = configured choice of open, high, low, close, HL2, OC2, OHL3, HLC3, or OHLC4
Calculation: Volume filter = HMA of 14-period RSI of volume, with a 10-period HMA
Calculation: Volatility filter = ATR with the shorter configured lookback > ATR with the longer configured lookback
Long: Price source crosses above Prior high AND configured filter passes AND signal changes to long
Short: Price source crosses below Prior low AND configured filter passes AND signal changes to short
Exit: long, signal changes to short OR bars since signal changed = configured holding period
Exit: short, signal changes to long OR bars since signal changed = configured holding period