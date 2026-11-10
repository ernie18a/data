Calculation: Zero-lag EMA(x, length) = EMA(2 × x − x[lag], length), where lag = floor((length − 1) / 2) and unavailable x[lag] is replaced by x.
Calculation: Normalize(x) = clamp(200 × tanh((x − SMA(x, normalization lookback)) / (2 × standard deviation(x, normalization lookback))), −220, 220); return 0 when the standard deviation is 0.
Calculation: Money flow = Normalize(zero-lag EMA(EMA(volume × (0.6 × (close − open) / range + 0.4 × (2 × close − high − low) / range), money-flow lookback), money-flow smoothing lookback)), where range = high − low, zero-range candle pressure is 0, and missing volume is 1. Calculate on the chart timeframe or an optional other timeframe; for a higher timeframe use its last completed bar, and for a lower timeframe use its last completed bar within the chart bar.
Calculation: Volume matrix = clamp(zero-lag EMA(200 × EMA(up volume − down volume, money-flow lookback) / max(EMA(volume, money-flow lookback), 1) × volume sensitivity, money-flow smoothing lookback), −200, 200), where up volume is volume when close >= open and otherwise 0, down volume is volume when close < open and otherwise 0, and missing volume is 1.
Calculation: Price impulse = Normalize(zero-lag EMA(source − source[main lookback], oscillator smoothing lookback)), replacing an unavailable historical source with the current source. Trend deviation = Normalize(source − zero-lag EMA(source, main lookback)). RSI component = clamp(4 × (RSI(source, RSI lookback) − 50), −200, 200). CCI component = clamp(0.75 × CCI((high + low + close) / 3, CCI lookback), −200, 200). MFI component = clamp(4 × (MFI((high + low + close) / 3, MFI lookback) − 50), −200, 200). RSI and CCI lookbacks are derived from the main lookback; MFI lookback is derived from the money-flow lookback.
Calculation: Oscillator = zero-lag EMA of either (0.28 × price impulse + 0.20 × trend deviation + 0.18 × RSI component + 0.14 × CCI component + 0.12 × MFI component + 0.08 × money flow) in Prime mode, or (0.42 × volume matrix + 0.28 × money flow + 0.18 × price impulse + 0.12 × MFI component) in MVP mode, using the oscillator smoothing lookback. Signal = zero-lag EMA(oscillator, signal lookback).
Calculation: Bullish score = count of these true conditions: oscillator > 0; oscillator > signal; oscillator > every oscillator value in a preceding lookback; money flow > 0; volume matrix > 0; close > short EMA of close AND short EMA > medium EMA of close; close > long EMA of close. Bearish score = count of the corresponding conditions with every comparison reversed. The short, medium and long EMA lookbacks increase in that order.
Calculation: An oscillator pivot low is an oscillator value confirmed as a local minimum over configurable left and right bar counts; a pivot high is the corresponding local maximum. Evaluate pivot decisions on the confirmation bar, using the price high or low at the pivot bar and the previous confirmed pivot of the same type.
Long: Oscillator >= signal.
Short: Oscillator < signal.
Long: Bullish score >= bearish score.
Short: Bullish score < bearish score.
Long: Money flow > 0.
Short: Money flow < 0.
Long: Volume matrix > 0.
Short: Volume matrix < 0.
Long: Bullish score >= confirmation threshold.
Short: Bearish score >= confirmation threshold.
Long: Oscillator crosses above signal AND oscillator < oversold threshold AND money flow > previous money flow.
Short: Oscillator crosses below signal AND oscillator > overbought threshold AND money flow < previous money flow.
Long: Oscillator crosses above signal AND bullish score >= confirmation threshold.
Short: Oscillator crosses below signal AND bearish score >= confirmation threshold.
Long: Mode = MVP AND oscillator < oversold threshold AND oscillator > every oscillator value in a preceding warning lookback.
Short: Mode = MVP AND oscillator > overbought threshold AND oscillator < every oscillator value in a preceding warning lookback.
Long: Confirmed oscillator pivot low < oversold threshold.
Short: Confirmed oscillator pivot high > overbought threshold.
Long: Confirmed oscillator pivot low > previous oscillator pivot low AND price low at current pivot < price low at previous oscillator pivot low.
Short: Confirmed oscillator pivot high < previous oscillator pivot high AND price high at current pivot > price high at previous oscillator pivot high.
Long: Oscillator > signal AND oscillator > 0.
Short: Oscillator < signal AND oscillator < 0.