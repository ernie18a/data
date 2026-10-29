Long: no open position AND hour is within the configured trading window AND close[2] <= close[1] AND RSI on the chart timeframe at the last completed bar >= the long threshold
Long: long position open AND trade count is below the configured maximum AND hour is within the configured trading window AND last long entry price - current price >= configured spacing
Short: no open position AND hour is within the configured trading window AND close[2] > close[1] AND RSI on the chart timeframe at the last completed bar < the short threshold
Short: short position open AND trade count is below the configured maximum AND hour is within the configured trading window AND current price - last short entry price >= configured spacing
Exit: long, price <= entry price - configured stop distance OR price >= position average entry price + configured profit distance
Exit: short, price >= entry price + configured stop distance OR price <= position average entry price - configured profit distance