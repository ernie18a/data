Calculation: hedger share = 100 * (producer/merchant long positions - producer/merchant short positions + (if swap dealers included, swap dealer long positions - swap dealer short positions, else 0)) / open interest, on last completed T1 bars
Calculation: Zone = upper if PercentRank(hedger share, lookback) >= 100 - band width, lower if PercentRank(hedger share, lookback) <= band width, neutral otherwise, undefined until hedger share has more than lookback defined values
Long: Zone = upper AND Zone[1] != upper AND Zone[1] is defined AND (no earlier Zone = upper bar OR BarsSince(Zone = upper)[1] >= separation)
Short: Zone = lower AND Zone[1] != lower AND Zone[1] is defined AND (no earlier Zone = lower bar OR BarsSince(Zone = lower)[1] >= separation)
Long: Zone = upper
Short: Zone = lower