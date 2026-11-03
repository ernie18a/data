Calculation: volume-weighted mean = sum(close * volume) / sum(volume) over the lookback
Calculation: volume-weighted deviation = sum(abs(close - volume-weighted mean) * volume / sum(volume)) over the same lookback
Calculation: oscillator = EMA of either 50 + (close - volume-weighted mean) / (volume-weighted deviation * sensitivity) * 25, or volume intensity; volume intensity = clamp((SMA(volume) - lowest(SMA(volume), lookback)) / (highest(SMA(volume), lookback) - lowest(SMA(volume), lookback)) * 100, 0, 100). Use 50 when a denominator is zero.
Calculation: midline = moving average of oscillator over its midline period, or 50 when adaptive midline is disabled
Calculation: upper zone = midline + standard deviation of oscillator over the midline period * zone width
Calculation: lower zone = midline - standard deviation of oscillator over the midline period * zone width
Calculation: fast signal = short-term EMA of oscillator
Calculation: slow signal = longer-term EMA of oscillator
Long: oscillator > midline OR fast signal > slow signal OR (oscillator > upper zone AND previous oscillator <= previous upper zone) OR (fast signal > slow signal AND previous fast signal <= previous slow signal)
Short: (oscillator <= midline AND fast signal <= slow signal) OR (oscillator < lower zone AND previous oscillator >= previous lower zone) OR (fast signal < slow signal AND previous fast signal >= previous slow signal)