Calculation: Raw upper/lower bands = bar midpoint ± ATR × configurable multiplier
Calculation: Trailing lower band = max(raw lower band, previous trailing lower band) when previous close is above the previous trailing lower band; otherwise raw lower band. Trailing upper band = min(raw upper band, previous trailing upper band) when previous close is below the previous trailing upper band; otherwise raw upper band.
Calculation: Trend state = bullish when close is above the trailing upper band; bearish when close is below the trailing lower band; otherwise retain the previous state.
Calculation: Deviation levels = flip-bar close plus or minus sequential multiples of the configurable multiplier × a rolling SMA of high minus low; use plus for bullish flips and minus for bearish flips.
Long: Close is above the trailing upper band AND the previous trend state is bearish
Short: Close is below the trailing lower band AND the previous trend state is bullish
Exit: long, current high is above an upward deviation level AND previous high was at or below that level
Exit: short, current low is below a downward deviation level AND previous low was at or above that level