Calculation: Overnight-anchored VWAP = Volume-weighted average of (high + low + close) / 3 across chart bars, including the current bar; reset when entering an overnight session defined by start and end times in America/New_York, and continue accumulating outside that session until the next reset.
Long: close >= overnight-anchored VWAP
Short: close < overnight-anchored VWAP