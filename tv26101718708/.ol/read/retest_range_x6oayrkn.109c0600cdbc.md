Long: close[3] < open[3] AND close[2] > open[2] AND close[1] > open[1] AND close > open AND (body filter disabled OR each of the last 3 candle bodies > body multiplier × its average body over the configured lookback)
Long: close > midpoint of the most recent bearish setup before its inverse triggers
Long: close > latest unbroken confirmed fractal pivot high
Short: close[3] > open[3] AND close[2] < open[2] AND close[1] < open[1] AND close < open AND (body filter disabled OR each of the last 3 candle bodies > body multiplier × its average body over the configured lookback)
Short: close < midpoint of the most recent bullish setup before its inverse triggers
Short: close < latest unbroken confirmed fractal pivot low
Calculation: Average candle body = simple moving average of absolute close minus open over the configured lookback
Calculation: Confirmed fractal pivot high/low = a bar whose high/low is greater/less than the highs/lows of the configured number of bars on both sides; even fractal lengths are rounded up to the next odd length
Calculation: Setup midpoint = (highest high + lowest low of the three setup candles) / 2
Calculation: Latest confirmed fractal pivot high/low = most recently confirmed pivot high/low; after a break, that pivot is marked broken until replaced by a newer confirmed pivot
Exit: None