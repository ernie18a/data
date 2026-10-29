Calculation: Adjusted expected move = configured asset volatility estimate × configured volatility multiplier
Calculation: Lower expected-move boundary = VWAP − configured multiple × adjusted expected move
Calculation: Upper expected-move boundary = VWAP + configured multiple × adjusted expected move
Long: low <= lower expected-move boundary adjusted by configured touch tolerance AND close > open AND volume > SMA(volume, configured lookback) × configured volume threshold AND close > long-term EMA AND datetime is within the configured New York session
Short: high >= upper expected-move boundary adjusted by configured touch tolerance AND close < open AND volume > SMA(volume, configured lookback) × configured volume threshold AND close < long-term EMA AND datetime is within the configured New York session
Exit: long, high >= entry price + configured take-profit distance OR low <= entry price − configured stop-loss distance
Exit: short, low <= entry price − configured take-profit distance OR high >= entry price + configured stop-loss distance