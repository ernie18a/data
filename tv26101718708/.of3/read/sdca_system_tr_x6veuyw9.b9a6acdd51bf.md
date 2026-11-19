Calculation: Range normalization(x, lookback) = scale (x - lowest(x, lookback)) / (highest(x, lookback) - lowest(x, lookback)) to a percentage scale when the range is positive; otherwise use x[1], or zero if unavailable
Calculation: Recursive smoothing(x, factor) = x on the first bar; otherwise prior smoothed value + factor * (x - prior smoothed value)
Calculation: Normalized score component(x) = linearly map recursive smoothing(range normalization(recursive smoothing(range normalization(x, normalization lookback), smoothing factor), normalization lookback), smoothing factor) from the percentage scale midpoint to a symmetric score range
Calculation: Weighted score = weighted mean of normalized score component(clamp(MA(RSI(close, RSI lookback) centered at its midpoint, RSI smoothing lookback, RSI moving-average type), RSI clipping)), normalized score component(clamp(MA(ROC(close, ROC lookback), ROC smoothing lookback, ROC moving-average type), ROC clipping)), and normalized score component(clamp(Sharpe ratio((close - close[1]) / close[1], Sharpe lookback, annualized risk-free rate), Sharpe clipping)), using separate RSI, ROC, and Sharpe weights
Calculation: Active long-entry phase starts inactive, becomes active on a qualifying long-entry signal, and clears after a bar when weighted score is above the lower threshold
Calculation: Active exit phase starts inactive, becomes active on a qualifying exit signal, and clears after a bar when weighted score is below the upper threshold
Long: weighted score <= lower threshold
Long: weighted score <= lower threshold AND not in the active exit phase
Exit: long, weighted score >= upper threshold
Exit: long, weighted score >= upper threshold AND not in the active long-entry phase