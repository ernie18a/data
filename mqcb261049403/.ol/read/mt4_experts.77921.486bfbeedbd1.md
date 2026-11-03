Long: current-bar high − current-bar low > minimum range AND (price > same-timeframe smoothed moving average of bar highs OR price < same-timeframe smoothed moving average of bar lows)
Short: current-bar high − current-bar low > minimum range AND (price < same-timeframe smoothed moving average of bar lows OR price > same-timeframe smoothed moving average of bar highs)
Exit: long, price <= initial stop-loss price OR price <= trailing stop OR price >= take-profit price
Exit: short, price >= initial stop-loss price OR price >= trailing stop OR price <= take-profit price