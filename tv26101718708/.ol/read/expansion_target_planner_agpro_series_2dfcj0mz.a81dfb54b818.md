Calculation: Prior range high/low = highest high / lowest low over a lookback, excluding the current bar
Calculation: Target band = centered on the prior range edge in the expansion direction; its distance is the average of a scaled prior-range width and scaled ATR, clamped between ATR-scaled minimum and maximum distances; its half-width is ATR-scaled
Calculation: Invalidation shelf = lowest low (long) or highest high (short) over a lookback, excluding the current bar
Long: On a confirmed bar, close > prior range high + ATR × break buffer AND cooldown since the previous plan has elapsed AND no active same-direction plan remains
Short: On a confirmed bar, close < prior range low − ATR × break buffer AND cooldown since the previous plan has elapsed AND no active same-direction plan remains
Exit: Long, on a confirmed bar, close ≥ active target band lower edge OR close < active invalidation shelf − captured ATR × violation buffer
Exit: Short, on a confirmed bar, close ≤ active target band upper edge OR close > active invalidation shelf + captured ATR × violation buffer