Calculation: Bullish structure break = on a signal-ready bar, the latest confirmed fractal high (PivotHigh(high, structure pivot strength, structure pivot strength)) is exceeded by close or high according to the selected close-or-wick confirmation; each newer confirmed pivot replaces the candidate, and if the bearish candidate also breaks on that bar, close >= open
Calculation: Bearish structure break = on a signal-ready bar, the latest confirmed fractal low (PivotLow(low, structure pivot strength, structure pivot strength)) is broken by close or low according to the selected close-or-wick confirmation; each newer confirmed pivot replaces the candidate, and if the bullish candidate also breaks on that bar, close < open
Calculation: Bullish Shift = bullish structure break AND previous structure-break direction was bearish
Calculation: Bearish Shift = bearish structure break AND previous structure-break direction was bullish
Calculation: Bullish Pivot MA active = a confirmed low pivot has initialized the bullish state (every pivot, or only a lower low or the first pivot, according to the selected qualification); a qualifying pivot resets its broken state; close >= selected MA(configured bullish source, shared MA type and lookback), the MA is rising, and it is not locked by a break; if both sides are eligible, the bearish side wins when a qualifying high pivot occurs or close falls, otherwise the bullish side wins
Calculation: Bearish Pivot MA active = a confirmed high pivot has initialized the bearish state (every pivot, or only a higher high or the first pivot, according to the selected qualification); a qualifying pivot resets its broken state; close <= selected MA(configured bearish source, shared MA type and lookback), the MA is falling, and it is not locked by a break; if both sides are eligible, the bearish side wins when a qualifying high pivot occurs or close falls, otherwise the bullish side wins
Calculation: Long Health = the rounded percentage of enabled factors that are true: latest Shift is bullish, bullish Pivot MA is active, enabled close >= anchored VWAP, and enabled RSI(close, RSI lookback) >= configured RSI midline
Calculation: Short Health = the rounded percentage of enabled factors that are true: latest Shift is bearish, bearish Pivot MA is active, enabled close < anchored VWAP, and enabled RSI(close, RSI lookback) < configured RSI midline
Long: a new confirmed fractal high becomes the latest unbroken structure candidate
Short: a new confirmed fractal low becomes the latest unbroken structure candidate
Long: Bullish Shift
Short: Bearish Shift
Long: bullish structure break AND previous structure-break direction was not bearish
Short: bearish structure break AND previous structure-break direction was not bullish
Long: bullish Pivot MA is active
Short: bearish Pivot MA is active
Long: latest Shift is bullish AND bullish Pivot MA is active AND this alignment was false on the previous bar
Short: latest Shift is bearish AND bearish Pivot MA is active AND this alignment was false on the previous bar
Long: after the latest Bullish Shift, the first later signal-ready bar has a bullish Pivot MA and low <= bullish Pivot MA + ATR(ATR lookback) * retest tolerance AND high >= bullish Pivot MA - ATR(ATR lookback) * retest tolerance
Short: after the latest Bearish Shift, the first later signal-ready bar has a bearish Pivot MA and high >= bearish Pivot MA - ATR(ATR lookback) * retest tolerance AND low <= bearish Pivot MA + ATR(ATR lookback) * retest tolerance
Exit: long, the bullish Pivot MA was active before the signal-ready bar AND the selected close-or-wick price crosses below it AND no qualifying low pivot resets it on that bar
Exit: short, the bearish Pivot MA was active before the signal-ready bar AND the selected close-or-wick price crosses above it AND no qualifying high pivot resets it on that bar
Long: close >= anchored VWAP(configured source, configured anchor)
Short: close < anchored VWAP(configured source, configured anchor)
Long: RSI(close, RSI lookback) >= configured RSI midline
Short: RSI(close, RSI lookback) < configured RSI midline
Long: Long Health > Short Health
Short: Short Health > Long Health