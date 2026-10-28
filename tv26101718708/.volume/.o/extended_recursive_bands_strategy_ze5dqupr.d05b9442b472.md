Calculation: Recursive upper band = with α = 2 / (length + 1), max(previous upper band, source) − α × selected volatility measure of |source − previous upper band|; initialize previous upper band to source
Calculation: Recursive lower band = with α = 2 / (length + 1), min(previous lower band, source) + α × selected volatility measure of |source − previous lower band|; initialize previous lower band to source
Calculation: Selected volatility measure = the configured choice of ATR, standard deviation, average high-low range, recursively carried absolute source change when the source is rising or falling over the band length (otherwise retain its prior value), or the absolute source-to-previous-band distance
Calculation: Long stop = entry-bar low − entry-bar ATR × stop multiplier
Calculation: Short stop = entry-bar high + entry-bar ATR × stop multiplier
Calculation: Long target = entry price + (entry price − long stop) × reward/risk multiple
Calculation: Short target = entry price − (short stop − entry price) × reward/risk multiple
Long: current low < current recursive lower band AND previous low ≥ previous recursive lower band AND recursive lower band has increased on each of the last lookback bar-to-bar changes AND RSI < oversold threshold AND MFI < oversold threshold
Short: current high > current recursive upper band AND previous high ≤ previous recursive upper band AND recursive upper band has decreased on each of the last lookback bar-to-bar changes AND RSI > overbought threshold AND MFI > overbought threshold
Exit: long, current low < long stop OR current high > long target
Exit: short, current high > short stop OR current low < short target