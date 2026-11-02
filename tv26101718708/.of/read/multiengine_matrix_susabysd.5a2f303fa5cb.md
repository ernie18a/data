Calculation: Historical range = the high and low of a completed configured session in America/New_York or a completed higher-timeframe bar; retain the most recent configured number of completed ranges per session or timeframe, and track whether each high and low has already been breached since completion.
Calculation: WaveTrend momentum = EMA of ((HLC3 - EMA(HLC3, channel length)) / (0.015 * EMA(abs(HLC3 - EMA(HLC3, channel length)), channel length)), using zero when the denominator is zero, minus the SMA of that EMA using a separate signal length.
Calculation: Cumulative volume delta = sum of volume when close > open and negative volume when close < open, resetting at the start of each higher-timeframe period.
Long: low < an unswept historical range low.
Short: high > an unswept historical range high.
Long: close > higher-timeframe open.
Short: close <= higher-timeframe open.
Long: WaveTrend momentum >= 0.
Short: WaveTrend momentum <= 0.
Long: cumulative volume delta > 0.
Short: cumulative volume delta <= 0.
Calculation: Higher-timeframe open = open returned from the higher timeframe with lookahead off: the last completed higher-timeframe bar on historical bars until the final chart bar of the higher-timeframe period, and the still-forming bar on realtime bars. Apply the bias comparison independently to a shorter and a longer higher timeframe.