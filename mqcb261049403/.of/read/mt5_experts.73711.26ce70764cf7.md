Calculation: Box high/low = highest high and lowest low over the configured number of consecutive chart-timeframe bars ending before the session start
Long: trading day is enabled AND high >= Box high + configured entry offset AND current time < configured signal-expiration time
Short: trading day is enabled AND low <= Box low - configured entry offset AND current time < configured signal-expiration time
Exit: long, low <= stop-loss price OR high >= take-profit price
Exit: short, high >= stop-loss price OR low <= take-profit price
Exit: long, elapsed time since entry >= configured duration AND (close - entry price) >= configured minimum profit
Exit: short, elapsed time since entry >= configured duration AND (entry price - close) >= configured minimum profit