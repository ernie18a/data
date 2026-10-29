Calculation: Bar midpoint = (high + low) / 2
Calculation: Smoothed applied price = configured smoothing of the configured applied-price series
Long: On the last completed signal-timeframe bar, smoothed applied price < bar midpoint AND on the preceding completed signal-timeframe bar, smoothed applied price >= bar midpoint
Short: On the last completed signal-timeframe bar, smoothed applied price > bar midpoint AND on the preceding completed signal-timeframe bar, smoothed applied price <= bar midpoint
Exit: short, On the last completed signal-timeframe bar, smoothed applied price < bar midpoint AND on the preceding completed signal-timeframe bar, smoothed applied price >= bar midpoint
Exit: long, On the last completed signal-timeframe bar, smoothed applied price > bar midpoint AND on the preceding completed signal-timeframe bar, smoothed applied price <= bar midpoint