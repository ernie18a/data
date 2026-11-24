Calculation: CVD = cumulative sum from zero of volume × ((close − low) − (high − close)) / (high − low + minimum tick)
Calculation: CVD rate of change = (CVD − CVD[momentum lookback]) / (abs(CVD[momentum lookback]) + minimum tick)
Calculation: Price rate of change = (close − close[momentum lookback]) / (close[momentum lookback] + minimum tick)
Calculation: Flow momentum feature = (CVD rate of change − SMA(CVD rate of change, normalization lookback)) / StDev(CVD rate of change, normalization lookback), or zero when the standard deviation is zero
Calculation: Price-flow divergence feature = (price rate of change − CVD rate of change, normalized by its SMA and StDev over the normalization lookback), or zero when the standard deviation is zero
Calculation: CVD slope feature = (LinReg(CVD, slope lookback, offset 0) − LinReg(CVD, slope lookback, offset 1), normalized by its SMA and StDev over the normalization lookback), or zero when the standard deviation is zero
Calculation: Classifier posteriors = normalize, across Bull, Bear, and Diverged, each class prior times the product of Gaussian PDFs for the three features; update per-class counts, sums, and squared sums online using each bar's features, labeling it Bull when price and CVD rates of change are both positive, Bear when both are negative, and Diverged otherwise; priors are class frequencies, or initially the prior Bull probability and an equal split of its remainder; class means are zero with no samples, and class standard deviations are one with fewer than two samples or otherwise sqrt(max(mean squared feature − squared mean, distribution floor)); Gaussian standard deviations use the distribution floor and the posterior denominator adds the evidence epsilon
Calculation: Classifier ready = total labeled bars ≥ classifier training lookback
Calculation: Bull regime = classifier ready AND Bull posterior ≥ entry threshold AND close > EMA(close, trend lookback)
Calculation: Bear regime = classifier ready AND Bear posterior ≥ entry threshold AND close < EMA(close, trend lookback)
Calculation: Long signal = Bull regime AND CVD > CVD[1] AND NOT (the same condition on the prior bar) AND (bar-close confirmation disabled OR current bar confirmed) AND (volume-surge requirement disabled OR volume > SMA(volume, volume lookback) × surge multiplier) AND (cooldown disabled OR bars since the last signal ≥ cooldown)
Calculation: Short signal = Bear regime AND CVD < CVD[1] AND NOT (the same condition on the prior bar) AND (bar-close confirmation disabled OR current bar confirmed) AND (volume-surge requirement disabled OR volume > SMA(volume, volume lookback) × surge multiplier) AND (cooldown disabled OR bars since the last signal ≥ cooldown)
Long: Long signal
Short: Short signal
Long: Long signal AND Bull posterior ≥ high-confidence threshold
Short: Short signal AND Bear posterior ≥ high-confidence threshold
Long: Bull regime
Short: Bear regime
Long: Bull regime AND NOT Bull regime[1]
Short: Bear regime AND NOT Bear regime[1]
Long: classifier ready AND close > EMA(close, trend lookback)
Short: classifier ready AND close < EMA(close, trend lookback)
Long: Bull posterior ≥ entry threshold
Short: Bear posterior ≥ entry threshold
Long: CVD > CVD[1]
Short: CVD < CVD[1]