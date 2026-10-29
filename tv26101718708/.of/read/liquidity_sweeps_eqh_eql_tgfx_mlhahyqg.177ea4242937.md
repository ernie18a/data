Calculation: Confirmed swing high/low = Williams pivot high/low confirmed after the configured right-side bars on the chart timeframe.
Calculation: Equal-high level = the higher of two consecutive confirmed swing highs when their difference is within the tolerance.
Calculation: Equal-low level = the lower of two consecutive confirmed swing lows when their difference is within the tolerance.
Calculation: Tolerance = ATR times a multiplier, or tick tolerance times minimum tick, according to the selected mode.
Calculation: Prior N-bar high/low = highest high/lowest low among the previous N completed bars on each configured higher timeframe. The sweep check uses that higher timeframe's bar still forming.
Calculation: Latest higher-timeframe sweep direction = bullish after a higher-timeframe low falls below its prior N-bar low and closes above it; bearish after its high rises above its prior N-bar high and closes below it; otherwise retain the previous direction, initially neutral.
Long: On a confirmed chart-timeframe bar, low < an untouched equal-low level AND close > that level OR the latest sweep direction on any configured higher timeframe is bullish.
Short: On a confirmed chart-timeframe bar, high > an untouched equal-high level AND close < that level OR the latest sweep direction on any configured higher timeframe is bearish.