Long: current price >= previous completed higher-timeframe daily high + configured entry buffer
Short: current price <= previous completed higher-timeframe daily low - configured entry buffer
Exit: long, current low <= max(entry price - stop distance, highest price since entry - stop distance)
Exit: short, current high >= min(entry price + stop distance, lowest price since entry + stop distance)