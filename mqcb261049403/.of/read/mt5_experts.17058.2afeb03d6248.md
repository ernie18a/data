Calculation: Daily high = high of the higher-timeframe daily bar still forming when orders are placed; use the last completed daily bar when placement time is midnight.
Calculation: Daily low = low of the higher-timeframe daily bar still forming when orders are placed; use the last completed daily bar when placement time is midnight.
Long: At the configured placement time, entry price >= daily high + offset
Short: At the configured placement time, entry price <= daily low - offset
Exit: long, price <= stop loss OR price >= take profit
Exit: short, price >= stop loss OR price <= take profit