Calculation: Bullish fair value gap = the current chart bar's low is above the high two chart bars earlier, and the gap is at least the minimum size threshold; the zone is [high two chart bars earlier, current low].
Calculation: Bearish fair value gap = the current chart bar's high is below the low two chart bars earlier, and the gap is at least the minimum size threshold; the zone is [current high, low two chart bars earlier].
Calculation: Long entry price = high two chart bars earlier.
Calculation: Short entry price = low two chart bars earlier.
Long: A bullish fair value gap on a confirmed chart bar is wholly within or within the proximity tolerance of an active bullish fair value gap formed from the last three completed higher-timeframe bars; within the session window; signal cooldown elapsed.
Short: A bearish fair value gap on a confirmed chart bar is wholly within or within the proximity tolerance of an active bearish fair value gap formed from the last three completed higher-timeframe bars; within the session window; signal cooldown elapsed.
Exit: long, low <= entry price - stop distance OR high >= entry price + target distance
Exit: short, high >= entry price + stop distance OR low <= entry price - target distance