Calculation: Entry-period highest high = highest high over the entry lookback on the configured trading timeframe (higher or lower than the chart timeframe as configured), using completed bars only.
Calculation: Entry-period lowest low = lowest low over the entry lookback on the configured trading timeframe (higher or lower than the chart timeframe as configured), using completed bars only.
Calculation: Exit-period lowest low = lowest low over the exit lookback on the configured trading timeframe (higher or lower than the chart timeframe as configured), using completed bars only.
Calculation: Exit-period highest high = highest high over the exit lookback on the configured trading timeframe (higher or lower than the chart timeframe as configured), using completed bars only.
Long: No existing long position AND entry price is at least one tick above the entry-period highest high.
Short: No existing short position AND entry price is at least one tick below the entry-period lowest low.
Exit: long, current price < exit-period lowest low
Exit: short, current price > exit-period highest high