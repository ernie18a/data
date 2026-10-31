Calculation: Rounded five-stage EMA = round 5×EMA1 − 10×EMA2 + 10×EMA3 − 5×EMA4 + EMA5 to a configurable price increment; EMA1 is the EMA of a selected OHLC-derived price, and each subsequent EMA is the EMA of the preceding stage, all with the same length and each initialized with its first available input.
Calculation: Upper and lower envelope = rounded five-stage EMA multiplied by 1 plus or minus a configurable deviation fraction, respectively, then shifted by a configurable price offset; compare each bar with the envelope calculated a configurable number of bars earlier.
Long: Chart-timeframe close > upper envelope.
Short: Chart-timeframe close < lower envelope.
Long: Chart-timeframe upper envelope > previous upper envelope.
Short: Chart-timeframe upper envelope < previous upper envelope.
Long: Signal-timeframe close > upper envelope AND previous signal-timeframe close <= its upper envelope.
Short: Signal-timeframe close < lower envelope AND previous signal-timeframe close >= its lower envelope.
Exit: short, signal-timeframe close > upper envelope.
Exit: long, signal-timeframe close < lower envelope.
Exit: long, low <= entry price − configurable stop distance OR high >= entry price + configurable profit distance.
Exit: short, high >= entry price + configurable stop distance OR low <= entry price − configurable profit distance.
Calculation: Signal-timeframe values = values on a configurable timeframe that can be higher or lower than the chart timeframe; use the last completed bar or the still-forming bar according to the configurable signal-bar selection.