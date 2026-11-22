Long: SMA(close, shorter lookback) crosses above SMA(close, longer lookback) AND volume > volume[1] AND datetime in the entry window (inclusive, America/New_York)
Short: SMA(close, shorter lookback) crosses below SMA(close, longer lookback) AND volume > volume[1] AND datetime in the entry window (inclusive, America/New_York)
Exit: long, high >= entry price + take-profit distance OR low <= entry price - stop-loss distance
Exit: short, low <= entry price - take-profit distance OR high >= entry price + stop-loss distance
Long: SMA(close, P1) crosses above SMA(close, P2) AND volume > prior-bar volume AND New York time is between P3 and P4
Short: SMA(close, P1) crosses below SMA(close, P2) AND volume > prior-bar volume AND New York time is between P3 and P4
Exit: long, SPY price >= average entry price + P5 OR SPY price <= average entry price - P6
Exit: short, SPY price <= average entry price - P5 OR SPY price >= average entry price + P6