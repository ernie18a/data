Calculation: ZLEMA(x,n) = EMA(x + (x − x[ floor((n−1)/2) ]), n)
Calculation: Normalized(x,n) = clamp(200 × tanh(((x − SMA(x,n)) / stdev(x,n)) / 2), −220, 220), using 0 when stdev is 0
Calculation: Money flow = Normalized(ZLEMA(EMA(volume × (0.60 × (close−open)/max(high−low,tick) + 0.40 × ((close−low)−(high−close))/max(high−low,tick)), money-flow length), money-flow smoothing length), normalization length); use current chart bars when no other timeframe is selected, otherwise use the selected timeframe’s latest available bar with lookahead off
Calculation: Price impulse = Normalized(ZLEMA(close − close[main length], smoothing length), normalization length)
Calculation: Trend deviation = Normalized(close − ZLEMA(close, main length), normalization length)
Calculation: RSI component = clamp((RSI(close, max(7, floor(main length/2))) − 50) × 4, −200, 200)
Calculation: CCI component = clamp(CCI(hlc3, max(10, floor(main length/1.5))) × 0.75, −200, 200)
Calculation: MFI component = clamp((MFI(hlc3, max(10, money-flow length)) − 50) × 4, −200, 200)
Calculation: Volume matrix = clamp(ZLEMA(200 × EMA(bullish volume − bearish volume, money-flow length) / max(EMA(volume, money-flow length),1) × volume sensitivity, money-flow smoothing length), −200, 200); bullish volume is volume when close ≥ open, otherwise 0; bearish volume is volume when close < open, otherwise 0
Calculation: Main oscillator = ZLEMA(0.28 × price impulse + 0.20 × trend deviation + 0.18 × RSI component + 0.14 × CCI component + 0.12 × MFI component + 0.08 × money flow, smoothing length) in Prime mode; in MVP mode use ZLEMA(0.42 × volume matrix + 0.28 × money flow + 0.18 × price impulse + 0.12 × MFI component, smoothing length)
Calculation: Signal line = ZLEMA(main oscillator, signal length)
Calculation: Bullish rank = count of: main oscillator > 0; main oscillator > signal line; main oscillator rising for 3 bars; money flow > 0; volume matrix > 0; close > EMA(close, fast length) and fast EMA > EMA(close, slower length); close > EMA(close, longest length). The fast, slower, and longest lengths are ordered shortest to longest.
Calculation: Bearish rank = count of: main oscillator < 0; main oscillator < signal line; main oscillator falling for 3 bars; money flow < 0; volume matrix < 0; close < EMA(close, fast length) and fast EMA < EMA(close, slower length); close < EMA(close, longest length). The fast, slower, and longest lengths are ordered shortest to longest.
Calculation: Confirmed oscillator pivot low/high = oscillator low/high with the configured number of lower/higher neighboring bars on each side; available only after the right-side bars complete. Pair each with the price low/high on its pivot bar.
Long: main oscillator crosses above signal line AND main oscillator < oversold level AND money flow > its prior bar
Long: main oscillator crosses above signal line AND bullish rank ≥ power-confirm threshold
Long: confirmed oscillator pivot low < oversold level
Long: confirmed oscillator pivot low is higher than the prior confirmed oscillator pivot low AND its paired price low is lower than the prior paired price low
Long: MVP mode AND main oscillator < oversold level AND main oscillator rising for 2 bars
Short: main oscillator crosses below signal line AND main oscillator > overbought level AND money flow < its prior bar
Short: main oscillator crosses below signal line AND bearish rank ≥ power-confirm threshold
Short: confirmed oscillator pivot high > overbought level
Short: confirmed oscillator pivot high is lower than the prior confirmed oscillator pivot high AND its paired price high is higher than the prior paired price high
Short: MVP mode AND main oscillator > overbought level AND main oscillator falling for 2 bars