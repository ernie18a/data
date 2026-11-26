Calculation: configured range high = maximum high of chart bars in the configured timed range
Calculation: configured range low = minimum low of chart bars in the configured timed range
Calculation: configured range midpoint = (configured range high + configured range low) / 2
Long: At a configured timed range’s close, its close is greater than or equal to its open.
Short: At a configured timed range’s close, its close is less than its open.
Long: On confirmed chart bars, for each T1–T5 period with no latched low sweep, low < the low of its last completed bar and close > that low; latch once per side per period.
Short: On confirmed chart bars, for each T1–T5 period with no latched high sweep, high > the high of its last completed bar and close < that high; latch once per side per period.
Long: At least three of T1–T5 have latched low sweeps in their current periods and fewer than three have latched high sweeps.
Long: At least three of T1–T5 have latched low sweeps in their current periods, fewer than three have latched high sweeps, and this condition was false on the preceding chart bar.
Short: At least three of T1–T5 have latched high sweeps in their current periods and fewer than three have latched low sweeps.
Short: At least three of T1–T5 have latched high sweeps in their current periods, fewer than three have latched low sweeps, and this condition was false on the preceding chart bar.
Long: On a confirmed chart bar in a configured timed range’s projection window, if no earlier purge occurred for that range, low ≤ configured range low and (high < configured range high or (high ≥ configured range high and close < configured range midpoint)).
Short: On a confirmed chart bar in a configured timed range’s projection window, if no earlier purge occurred for that range, high ≥ configured range high and (low > configured range low or (low ≤ configured range low and close ≥ configured range midpoint)).
Long: While a configured timed range’s projection monitor is active, low < configured range low, high ≤ configured range high, and configured range low ≤ close ≤ configured range high.
Short: While a configured timed range’s projection monitor is active, high > configured range high and configured range low ≤ close ≤ configured range high.