Calculation: Confirmed swing high/low = a bar whose high/low is higher/lower than the highs/lows of the configurable number of bars on both sides; add its price as a live pool when confirmed, retaining only the configured maximum number of newest pools per side
Calculation: Raid wick percentage = distance from the swept pool level to the most extreme high/low since the raid began, divided by the raid bar's high-low range
Calculation: Volume expansion = current volume >= its moving average over a configurable lookback × configurable multiplier; this filter may be disabled
Calculation: Risk distance = ATR × configurable multiplier, or entry price × configurable percentage
Calculation: Final target = entry price plus/minus risk distance × the highest configured take-profit risk/reward multiple whose target is enabled
Long: low < a live swing-low pool level, then within the configurable confirmation window on a later bar close > that level AND close > open AND raid wick percentage >= configurable minimum AND volume expansion (if enabled)
Short: high > a live swing-high pool level, then within the configurable confirmation window on a later bar close < that level AND close < open AND raid wick percentage >= configurable minimum AND volume expansion (if enabled)
Exit: Long, after the entry bar, low <= entry price - risk distance OR high >= final target
Exit: Short, after the entry bar, high >= entry price + risk distance OR low <= final target