Calculation: Upper band = SMA(close, lookback) + ATR(shorter lookback) × band-width multiplier
Calculation: Lower band = SMA(close, lookback) − ATR(shorter lookback) × band-width multiplier
Long: Position side is flat AND ((low < Lower band AND close > Lower band AND volume < SMA(volume, same lookback as SMA(close)) × relative-volume threshold) OR (close > Upper band AND previous bar close > Upper band))
Short: Position side is flat AND ((high > Upper band AND close < Upper band AND volume < SMA(volume, same lookback as SMA(close)) × relative-volume threshold) OR (close < Lower band AND previous bar close < Lower band))
Exit: long, low ≤ entry price − ATR × stop multiplier OR high ≥ entry price + ATR × stop multiplier × risk-reward ratio
Exit: short, high ≥ entry price + ATR × stop multiplier OR low ≤ entry price − ATR × stop multiplier × risk-reward ratio