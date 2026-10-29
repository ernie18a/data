Calculation: Upper band = SMA(close) + band-width multiplier × standard deviation(close), using the same lookback for both
Calculation: Lower band = SMA(close) − band-width multiplier × standard deviation(close), using the same lookback for both
Calculation: Average volume = SMA(volume), using the same lookback as the bands
Calculation: Average body size = SMA(abs(close − open)), using the same lookback as the bands
Long: volume > average volume × volume multiplier AND abs(close − open) > average body size AND close > upper band AND abs(change(SMA(close, band lookback))) >= ATR × flat-filter multiplier
Short: volume > average volume × volume multiplier AND abs(close − open) > average body size AND close < lower band AND abs(change(SMA(close, band lookback))) >= ATR × flat-filter multiplier