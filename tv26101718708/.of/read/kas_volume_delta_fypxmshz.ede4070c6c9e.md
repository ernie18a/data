Calculation: Delta = per-bar signed volume: +volume if close > open; -volume if close < open; if close == open then +0.5*volume when close >= (high+low)/2, otherwise -0.5*volume
Calculation: DeltaSMA = simple moving average of Delta over a lookback
Long: (previous Delta <= 0 AND current Delta > 0) OR (previous Delta <= previous DeltaSMA AND current Delta > current DeltaSMA)
Short: (previous Delta >= 0 AND current Delta < 0) OR (previous Delta >= previous DeltaSMA AND current Delta < current DeltaSMA)