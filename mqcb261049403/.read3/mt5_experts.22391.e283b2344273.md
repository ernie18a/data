Calculation: Skyscraper trend = initialize neutral with both trigger levels at close; each bar becomes bullish if close > the prior upper trigger, bearish if close < the prior lower trigger, and otherwise retains its prior state. Step = floor(0.5 × sensitivity × (highest(ATR(ATR period), lookback) + lowest(ATR(ATR period), lookback)) / minimum price increment) × minimum price increment. Candidate upper trigger = low + 2 × step in high/low mode, otherwise close + 2 × step; candidate lower trigger = high − 2 × step in high/low mode, otherwise close − 2 × step. While bullish, lower trigger = max(candidate lower trigger, prior lower trigger) and upper trigger = +infinity; while bearish, upper trigger = min(candidate upper trigger, prior upper trigger) and lower trigger = −infinity.
Calculation: AML = let R1 be the high-low range over the current Fractal bars divided by Fractal, R2 the range over the preceding Fractal bars divided by Fractal, and R3 the range over the current 2 × Fractal bars divided by 2 × Fractal; dimension = log2((R1 + R2) / R3) when R1 + R2 > 0 and R3 > 0, otherwise 0; alpha = clamp(exp(−Lag × (dimension − 1)), 0.01, 1); price = (high + low + 2 × open + 2 × close) / 6; smoothed price = alpha × price + (1 − alpha) × prior smoothed price; output = smoothed price when its absolute difference from the smoothed price Lag bars ago is at least Lag² × minimum price increment, otherwise prior output.
Calculation: AML color state = bullish when AML > AML[1], bearish when AML < AML[1], otherwise the prior color state.
Calculation: Twice-smoothed open and close = for each series separately, apply the first selected smoothing method, lookback, and phase, then the second selected smoothing method, lookback, and phase; each stage has separate method, lookback, and phase parameters.
Long: Skyscraper trend is bullish on chart bars, including the bar still forming.
Short: Skyscraper trend is bearish on chart bars, including the bar still forming.
Long: Skyscraper trend changes from bearish to bullish on chart bars, including the bar still forming.
Short: Skyscraper trend changes from bullish to bearish on chart bars, including the bar still forming.
Long: On each newly completed T1 bar, Skyscraper trend changes from bearish to bullish AND Skyscraper long-entry permission is enabled.
Short: On each newly completed T1 bar, Skyscraper trend changes from bullish to bearish AND Skyscraper short-entry permission is enabled.
Exit: long, Skyscraper trend is bearish on the last completed T1 bar
Exit: short, Skyscraper trend is bullish on the last completed T1 bar
Long: AML color state is bullish on chart bars, including the bar still forming.
Short: AML color state is bearish on chart bars, including the bar still forming.
Long: On each newly completed T2 bar, AML color state changes from not bullish to bullish AND AML long-entry permission is enabled.
Short: On each newly completed T2 bar, AML color state changes from not bearish to bearish AND AML short-entry permission is enabled.
Exit: long, AML color state is bearish on the last completed T2 bar AND AML long-exit permission is enabled
Exit: short, AML color state is bullish on the last completed T2 bar AND AML short-exit permission is enabled
Long: Twice-smoothed close > twice-smoothed open on chart bars, including the bar still forming.
Short: Twice-smoothed close < twice-smoothed open on chart bars, including the bar still forming.
Long: On each newly completed T3 bar, twice-smoothed close > twice-smoothed open AND twice-smoothed close <= twice-smoothed open on the preceding completed T3 bar AND candle long-entry permission is enabled.
Short: On each newly completed T3 bar, twice-smoothed close < twice-smoothed open AND twice-smoothed close >= twice-smoothed open on the preceding completed T3 bar AND candle short-entry permission is enabled.
Exit: long, twice-smoothed close < twice-smoothed open on the last completed T3 bar AND candle long-exit permission is enabled
Exit: short, twice-smoothed close > twice-smoothed open on the last completed T3 bar AND candle short-exit permission is enabled