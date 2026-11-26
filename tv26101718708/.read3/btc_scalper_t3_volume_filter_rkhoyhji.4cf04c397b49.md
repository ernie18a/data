Long: close crosses above T3(close, lookback, volume factor) AND (volume filter disabled OR volume > SMA(volume, lookback))
Short: close crosses below T3(close, lookback, volume factor) AND (volume filter disabled OR volume > SMA(volume, lookback))
Exit: long, high >= entry price + entry-signal-bar close * (1 + take-profit parameter / 100) OR low <= entry price - entry-signal-bar close * (1 - stop-loss parameter / 100)
Exit: short, low <= entry price - entry-signal-bar close * (1 - take-profit parameter / 100) OR high >= entry price + entry-signal-bar close * (1 + stop-loss parameter / 100)