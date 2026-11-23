Calculation: Bar buy pressure = volume × (0.5 + 0.5 × clamp((close − open) / max(high − low, minimum tick size), −1, 1))
Calculation: Bar sell pressure = volume − bar buy pressure
Calculation: Bar buy-pressure percentage = if bar buy pressure + bar sell pressure > 0, then 100 × bar buy pressure / (bar buy pressure + bar sell pressure); otherwise 50
Calculation: Rolling buy-pressure percentage = if SMA(bar buy pressure, pressure lookback) + SMA(bar sell pressure, pressure lookback) > 0, then 100 × SMA(bar buy pressure, pressure lookback) / (SMA(bar buy pressure, pressure lookback) + SMA(bar sell pressure, pressure lookback)); otherwise 50
Calculation: Session-accumulated net delta = sum of bar buy pressure − bar sell pressure on chart bars since the first chart bar of the current T1 period; include the current, forming chart bar
Long: Bar buy-pressure percentage ≥ dominance threshold
Short: Bar buy-pressure percentage ≤ 100% − dominance threshold AND bar buy-pressure percentage < dominance threshold
Long: Rolling buy-pressure percentage ≥ dominance threshold
Short: Rolling buy-pressure percentage ≤ 100% − dominance threshold AND rolling buy-pressure percentage < dominance threshold
Long: Session-accumulated net delta > 0
Short: Session-accumulated net delta < 0
Long: Rolling buy-pressure percentage ≥ dominance threshold AND the most recent prior chart bar with non-neutral rolling dominance was bearish
Short: Rolling buy-pressure percentage ≤ 100% − dominance threshold AND rolling buy-pressure percentage < dominance threshold AND the most recent prior chart bar with non-neutral rolling dominance was bullish
Long: The current run of bull-classified chart bars has length equal to the minimum streak parameter
Short: The current run of bear-classified chart bars has length equal to the minimum streak parameter
Long: A bull-classified chart-bar run ends with length ≥ the streak-label minimum
Short: A bear-classified chart-bar run ends with length ≥ the streak-label minimum