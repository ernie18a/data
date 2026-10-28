Calculation: basis = simple moving average of close over the energy lookback
Calculation: upper band = basis + band width × standard deviation of close over the energy lookback
Calculation: lower band = basis − band width × standard deviation of close over the energy lookback
Calculation: average volume = simple moving average of volume over the energy lookback
Calculation: average body = simple moving average of abs(close − open) over the energy lookback
Long: volume > average volume × volume-spike multiplier AND abs(close − open) > average body AND close > upper band AND abs(change(basis)) >= ATR × slope threshold
Short: volume > average volume × volume-spike multiplier AND abs(close − open) > average body AND close < lower band AND abs(change(basis)) >= ATR × slope threshold