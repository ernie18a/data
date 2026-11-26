Calculation: AML range(n,k) on chart bars = HHV(high,n,k) - LLV(low,n,k), where k is bars ago
Calculation: AML on chart bars = S if |S - S[Lag]| >= Lag² × price increment, otherwise AML[1]; S = alpha × (high + low + 2 × open + 2 × close) / 6 + (1 - alpha) × S[1]; alpha = clamp(exp(-Lag × (D - 1)), 0.01, 1); D = (ln((AML range(Fractal,0) + AML range(Fractal,Fractal)) / Fractal) - ln(AML range(2 × Fractal,0) / (2 × Fractal))) / ln(2), or 0 unless both logarithm arguments are positive
Calculation: AML color state = 2 when AML > AML[1], 0 when AML < AML[1], otherwise the prior AML color state
Long: AML color state = 2
Short: AML color state = 0
Calculation: Skyscraper trend on T1 bars = bullish when close > prior upper band, bearish when close < prior lower band, otherwise retain prior trend; step = floor(0.5 × sensitivity × (HHV(ATR(ATR lookback), Length) + LLV(ATR(ATR lookback), Length)) / price increment) × price increment; in high/low mode, candidate upper/lower bands are low + 2 × step and high - 2 × step, and in close mode they are close + 2 × step and close - 2 × step; in bullish trend set the lower band to max(candidate lower band, prior lower band), and in bearish trend set the upper band to min(candidate upper band, prior upper band); color state is 0 when bullish and 1 otherwise
Long: previous completed T1 Skyscraper trend was bearish and latest completed T1 Skyscraper trend is bullish
Short: previous completed T1 Skyscraper trend was bullish and latest completed T1 Skyscraper trend is bearish
Long: on each T1 bar close, the preceding completed Skyscraper color state is 0 and the latest completed color state is not 0, and long entries are enabled
Short: on each T1 bar close, the preceding completed Skyscraper color state is 1 and the latest completed color state is not 1, and short entries are enabled
Exit: long, low <= entry price - A stop distance OR high >= entry price + A target distance
Exit: short, high >= entry price + A stop distance OR low <= entry price - A target distance
Exit: long, low <= entry price - B stop distance OR high >= entry price + B target distance
Exit: short, high >= entry price + B stop distance OR low <= entry price - B target distance