Calculation: Previous breakout-bar high/low = high/low of the last completed bar on the selected breakout timeframe, which may be higher or lower than the chart timeframe.
Calculation: Fast and slow moving averages = the same selected moving-average method and applied price on the chart timeframe's still-forming bar; the fast average has a shorter lookback than the slow average.
Long: price >= previous breakout-bar high + offset AND fast moving average > slow moving average AND time is within the configured entry window
Short: price <= previous breakout-bar low - offset AND fast moving average < slow moving average AND time is within the configured entry window
Exit: long, price <= stop-loss price OR price >= take-profit price
Exit: short, price >= stop-loss price OR price <= take-profit price