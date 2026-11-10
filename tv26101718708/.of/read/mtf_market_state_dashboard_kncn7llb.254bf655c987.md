Calculation: Timeframe data = For each selected timeframe independently, use its last completed bar when it is higher than the chart timeframe, its last completed intrabar within the chart bar when it is lower, or the current chart bar when it is the chart timeframe; calculate all indicators and lookbacks in that timeframe.
Calculation: Volume delta = volume if close > previous close, -volume if close < previous close, otherwise 0.
Calculation: Delta threshold = sensitivity multiplier times the simple moving average of absolute volume delta.
Calculation: Trend score = sum of three components, each equal to 1 if close is above the long-term EMA, short-term EMA, or Supertrend line respectively, and -1 otherwise.
Calculation: Flow score = sum of CMF sign (1 if positive, -1 if negative, otherwise 0), volume delta sign (1 if delta > delta threshold, -1 if delta < -delta threshold, otherwise 0), and OBV breakout sign (1 if OBV exceeds the highest OBV over the preceding lookback, -1 if OBV is below the lowest OBV over the preceding lookback, otherwise 0).
Long: Close > long-term EMA OR close > short-term EMA OR close > Supertrend line.
Short: Close <= long-term EMA OR close <= short-term EMA OR close <= Supertrend line.
Long: Volume delta > delta threshold.
Short: Volume delta < -delta threshold.
Long: OBV > highest OBV over the preceding lookback.
Short: OBV < lowest OBV over the preceding lookback.
Long: Trend score >= 2 AND trend score + flow score > 0.
Short: Trend score <= -2 AND trend score + flow score < 0.