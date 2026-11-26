Calculation: profile mean and deviation = Every profile interval chart bars, over the current and preceding bars up to the lookback, mean = sum(price field * volume field) / sum(volume field) and deviation = sum(abs(price field - mean) * volume field) / sum(volume field); retain both until the next refresh; if volume sum is zero, use current price field as mean and zero as deviation
Calculation: volume profile score = EMA(input, smoothing length), where input is oscillator center + (price field - profile mean) / (profile deviation * sensitivity) * oscillator scale in mean-reversion mode, or the normalization lower bound + (normalization upper bound - normalization lower bound) * clamp((SMA(volume field, smoothing length) - lowest(SMA(volume field, smoothing length), lookback)) / (highest(SMA(volume field, smoothing length), lookback) - lowest(SMA(volume field, smoothing length), lookback)), 0, 1) in volume mode; use oscillator center when the highest and lowest values are equal
Calculation: adaptive midline = SMA(volume profile score, midline lookback) when adaptive midline is enabled, otherwise oscillator center
Calculation: fast signal = EMA(volume profile score, shorter signal lookback)
Calculation: slow signal = EMA(volume profile score, longer signal lookback)
Long: volume profile score crosses above adaptive midline
Short: volume profile score crosses below adaptive midline
Long: fast signal crosses above slow signal
Short: fast signal crosses below slow signal
Long: volume profile score > adaptive midline OR fast signal > slow signal
Short: volume profile score <= adaptive midline AND fast signal <= slow signal