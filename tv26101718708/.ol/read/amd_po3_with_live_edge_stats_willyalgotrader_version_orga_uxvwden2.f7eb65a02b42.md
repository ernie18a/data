Calculation: Accumulation range = during a compressed Donchian-width percentile, the highest confirmed pivot high and lowest confirmed pivot low in the range window; use raw window high/low if no confirmed pivots exist. The range must meet the minimum width, maturity, and age conditions.
Calculation: Donchian-width percentile = percentile rank of the current Donchian high-low width within its lookback distribution.
Calculation: Stop = beyond the full sweep extreme by an ATR-based buffer.
Calculation: Distribution target = Fibonacci extension of the manipulation leg from the sweep extreme (level 0) to the opposite accumulation boundary (level 1).
Long: confirmed bar, active mature accumulation range, low breaches the range low beyond its tolerance, and close is inside the range on the sweep bar or within the return deadline.
Short: confirmed bar, active mature accumulation range, high breaches the range high beyond its tolerance, and close is inside the range on the sweep bar or within the return deadline.
Exit: long, high >= distribution target OR low <= stop OR bars since entry > timeout.
Exit: short, low <= distribution target OR high >= stop OR bars since entry > timeout.