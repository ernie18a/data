Calculation: Rolling VWAP = sum(source × volume) / sum(volume) over a lookback
Calculation: Price supertrend = supertrend bands around the rolling VWAP using price ATR; direction changes up when close crosses above the prior upper band and down when close crosses below the prior lower band
Calculation: Volume supertrend = supertrend applied to volume using an ATR calculated from volume
Long: (volume > volume supertrend AND price supertrend direction changes from down to up) OR (volume supertrend direction changes from down to up AND source > price supertrend)
Short: (volume ≤ volume supertrend AND price supertrend direction changes from up to down) OR (volume supertrend direction changes from up to down AND source ≤ price supertrend)
Exit: long, (volume ≤ volume supertrend AND price supertrend direction changes from up to down) OR (volume supertrend direction changes from up to down AND source ≤ price supertrend)