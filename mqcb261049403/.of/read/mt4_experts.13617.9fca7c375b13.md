Calculation: Fast moving average = moving average with a shorter lookback than the slow moving average; both use the configured trading timeframe’s current bar, which may be the chart timeframe or a configured higher or lower timeframe.
Long: Fast moving average > slow moving average AND (distance filter disabled OR absolute difference between the moving averages > configured minimum distance)
Short: Fast moving average < slow moving average AND (distance filter disabled OR absolute difference between the moving averages > configured minimum distance)
Long: Price >= highest existing long entry price + configured Step Up distance OR lowest existing long entry price - price >= configured Step Down distance
Short: Price <= lowest existing short entry price - configured Step Up distance OR price - highest existing short entry price >= configured Step Down distance
Long: Price reaches the pending long entry placed at the stop-loss level of a short position
Short: Price reaches the pending short entry placed at the stop-loss level of a long position
Exit: long, price <= entry price - configured stop-loss distance OR price >= take-profit level OR fast moving average < slow moving average in operation mode 1 OR price <= active trailing-stop level
Exit: short, price >= entry price + configured stop-loss distance OR price <= take-profit level OR fast moving average > slow moving average in operation mode 1 OR price >= active trailing-stop level