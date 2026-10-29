Calculation: Upper band = simple moving average of close over a lookback + ATR × band-width multiplier
Calculation: Lower band = simple moving average of close over the same lookback − ATR × band-width multiplier
Long: Position is flat AND ((low < lower band AND close > lower band AND volume < simple moving average of volume over the same lookback × relative-volume threshold) OR (close > upper band AND previous close > upper band))
Short: Position is flat AND ((high > upper band AND close < upper band AND volume < simple moving average of volume over the same lookback × relative-volume threshold) OR (close < lower band AND previous close < lower band))
Exit: long, low ≤ entry price − ATR × stop multiplier OR high ≥ entry price + ATR × stop multiplier × risk/reward ratio
Exit: short, high ≥ entry price + ATR × stop multiplier OR low ≤ entry price − ATR × stop multiplier × risk/reward ratio