Calculation: Confirmed swing high/low = pivot high/low confirmed after the pivot lookback bars on each side
Calculation: Equal-high/low pool = consecutive confirmed swing highs/lows whose difference is within the ATR-based tolerance
Calculation: Session high/low = highest high/lowest low of the current session
Calculation: Reclaim boundary = prior swing-high/low midpoint when both exist and that midpoint is beyond the sweep extreme in the reclaim direction; otherwise the sweep candle’s body midpoint
Long: A confirmed bar sweeps below a confirmed swing low, equal-low pool, or session low by at least the minimum ATR penetration, closes above that liquidity level and the reclaim boundary, and the event’s observation window completes
Short: A confirmed bar sweeps above a confirmed swing high, equal-high pool, or session high by at least the minimum ATR penetration, closes below that liquidity level and the reclaim boundary, and the event’s observation window completes