Calculation: CCI slope = CCI(source, CCI lookback) - CCI(source, CCI lookback)[1] when slope smoothing length is 1; otherwise EMA of that difference over slope smoothing length
Calculation: Momentum histogram = CCI(source, CCI lookback) - selected smoothing MA of CCI(source, CCI lookback) over smoothing MA length
Calculation: Momentum histogram state = unavailable when the histogram is unavailable; otherwise LAUNCH when it crosses zero and increases, FLIP when it crosses zero without increasing, SURGE when it does not cross zero and increases, FADE when it does not cross zero and decreases, or its previous state when unchanged
Calculation: Slope decay ratio = abs(CCI slope) / highest(abs(CCI slope), absorption lookback) when the highest value is positive; otherwise 1
Calculation: Fast bullish divergence = a pair of consecutive paired pivot lows using the shorter fast pivot lookback, both CCI pivots below negative fast minimum CCI, with price making a lower low and CCI a higher low; OR a pair of consecutive paired pivot highs using that lookback, both CCI pivots above fast minimum CCI, with price making a lower high and CCI a higher high; the pair is separated by no more than fast maximum bars
Calculation: Fast bearish divergence = a pair of consecutive paired pivot highs using the shorter fast pivot lookback, both CCI pivots above fast minimum CCI, with price making a higher high and CCI a lower high; OR a pair of consecutive paired pivot lows using that lookback, both CCI pivots below negative fast minimum CCI, with price making a higher low and CCI a lower low; the pair is separated by no more than fast maximum bars
Calculation: Slow bullish divergence = a pair of consecutive paired pivot lows using the longer slow pivot lookback, both CCI pivots below negative slow minimum CCI, with price making a lower low and CCI a higher low; OR a pair of consecutive paired pivot highs using that lookback, both CCI pivots above slow minimum CCI, with price making a lower high and CCI a higher high; the pair is separated by no more than slow maximum bars
Calculation: Slow bearish divergence = a pair of consecutive paired pivot highs using the longer slow pivot lookback, both CCI pivots above slow minimum CCI, with price making a higher high and CCI a lower high; OR a pair of consecutive paired pivot lows using that lookback, both CCI pivots below negative slow minimum CCI, with price making a higher low and CCI a lower low; the pair is separated by no more than slow maximum bars
Calculation: CCI volatility ratio = (highest(CCI(source, CCI lookback), volatility range lookback) - lowest(CCI(source, CCI lookback), volatility range lookback)) / SMA of that range over the longer volatility average lookback when the average is positive; otherwise 1
Calculation: Bullish divergence confluence event = the latest fast and slow bullish divergence events both exist and occurred within the confluence window, and this condition has just changed from false to true
Calculation: Bearish divergence confluence event = the latest fast and slow bearish divergence events both exist and occurred within the confluence window, and this condition has just changed from false to true
Long: CCI slope > 0
Short: CCI slope < 0
Long: CCI(source, CCI lookback) > 0
Short: CCI(source, CCI lookback) <= 0
Long: smoothing MA is enabled AND CCI(source, CCI lookback) > selected smoothing MA of CCI(source, CCI lookback) over smoothing MA length
Short: smoothing MA is enabled AND CCI(source, CCI lookback) <= selected smoothing MA of CCI(source, CCI lookback) over smoothing MA length
Long: smoothing MA is enabled AND Momentum histogram > 0
Short: smoothing MA is enabled AND Momentum histogram < 0
Long: CCI(source, CCI lookback) crosses above 0
Short: CCI(source, CCI lookback) crosses below 0
Long: Momentum histogram crosses above 0
Long: PivotLow(CCI(source, CCI lookback), pivot lookback, pivot lookback) < negative pivot minimum CCI
Short: PivotHigh(CCI(source, CCI lookback), pivot lookback, pivot lookback) > pivot minimum CCI
Long: Fast bullish divergence OR Slow bullish divergence OR Bullish divergence confluence event
Short: Fast bearish divergence OR Slow bearish divergence OR Bearish divergence confluence event
Long: CCI(source, CCI lookback) crosses above SMA(CCI(source, CCI lookback), velocity envelope lookback) + StDev(CCI(source, CCI lookback), velocity envelope lookback) * velocity envelope multiplier
Short: CCI(source, CCI lookback) crosses below SMA(CCI(source, CCI lookback), velocity envelope lookback) - StDev(CCI(source, CCI lookback), velocity envelope lookback) * velocity envelope multiplier
Long: CCI(source, CCI lookback) < negative absorption extreme CCI level AND Slope decay ratio < absorption slope decay threshold AND Slope decay ratio[1] >= absorption slope decay threshold
Short: CCI(source, CCI lookback) > absorption extreme CCI level AND Slope decay ratio < absorption slope decay threshold AND Slope decay ratio[1] >= absorption slope decay threshold
Long: Momentum histogram state is FADE AND CCI(source, CCI lookback) < negative absorption extreme CCI level AND Slope decay ratio < absorption slope decay threshold AND Slope decay ratio[1] >= absorption slope decay threshold
Short: Momentum histogram state is FADE AND CCI(source, CCI lookback) > absorption extreme CCI level AND Slope decay ratio < absorption slope decay threshold AND Slope decay ratio[1] >= absorption slope decay threshold
Long: Momentum histogram state is SURGE AND CCI slope > slope threshold AND CCI volatility ratio >= volatility expansion threshold
Short: Momentum histogram state is SURGE AND CCI slope < negative slope threshold AND CCI volatility ratio >= volatility expansion threshold
Long: CCI(source, CCI lookback) > 0 AND CCI(source, CCI lookback) on T1's current forming bar, sampled on chart bars with lookahead off, > 0 AND CCI(source, CCI lookback) on T2's current forming bar, sampled on chart bars with lookahead off, > 0
Short: CCI(source, CCI lookback) < 0 AND CCI(source, CCI lookback) on T1's current forming bar, sampled on chart bars with lookahead off, < 0 AND CCI(source, CCI lookback) on T2's current forming bar, sampled on chart bars with lookahead off, < 0
Exit: long, Momentum histogram state is FADE AND abs(CCI slope) <= slope threshold AND abs(CCI(source, CCI lookback)) > CCI regime extreme threshold AND neither absorption condition is true
Exit: short, Momentum histogram state is FADE AND abs(CCI slope) <= slope threshold AND abs(CCI(source, CCI lookback)) > CCI regime extreme threshold AND neither absorption condition is true
Exit: long, CCI(source, CCI lookback) > absorption extreme CCI level AND CCI slope < negative slope threshold * hard slope multiplier AND NOT (Momentum histogram state is FADE AND either absorption condition is true) AND NOT (Momentum histogram state is SURGE AND abs(CCI slope) > slope threshold AND CCI volatility ratio >= volatility expansion threshold)
Exit: short, CCI(source, CCI lookback) < negative absorption extreme CCI level AND CCI slope > slope threshold * hard slope multiplier AND NOT (Momentum histogram state is FADE AND either absorption condition is true) AND NOT (Momentum histogram state is SURGE AND abs(CCI slope) > slope threshold AND CCI volatility ratio >= volatility expansion threshold)