Calculation: Bullish volume = volume when close > open; otherwise volume × (high − open) / (high − low)
Calculation: Bearish volume = volume when open > close; otherwise volume × (open − low) / (high − low)
Calculation: Average bullish volume = volume-weighted moving average of bullish volume over the lookback
Calculation: Average bearish volume = volume-weighted moving average of bearish volume over the same lookback
Calculation: Average volume force = (average bullish volume + average bearish volume) / 2
Long: Average bullish volume > average bearish volume AND average volume force / average bullish volume < 1 − flat threshold AND this is the first bullish-zone bar since the most recent bearish-zone bar (or since the most recent neutral bar when each setup is enabled)
Short: Average bullish volume < average bearish volume AND average volume force / average bearish volume < 1 − flat threshold AND this is the first bearish-zone bar since the most recent bullish-zone bar (or since the most recent neutral bar when each setup is enabled)
Exit: short, same condition as Long
Exit: long, same condition as Short