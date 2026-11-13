Calculation: SwingHigh/SwingLow = most recent confirmed pivot high/low, i.e. a bar whose high/low is the extreme among an equal number of bars on each side; confirmed only after the right-side bars have closed; the latest one replaces the previous.
Calculation: BullFVG = for each bar t, if low[t] > high[t-2] a zone is created with lower edge = high[t-2] and upper edge = low[t]; zones never expire or get removed.
Calculation: BearFVG = for each bar t, if high[t] < low[t-2] a zone is created with upper edge = low[t-2] and lower edge = high[t]; zones never expire or get removed.
Calculation: BullOB = on each bar where the Long BOS condition is true, the high and low of the most recent bearish candle (close < open) among the previous N bars (bar offsets 1..N, excluding the current bar); the latest one replaces the previous. BearOB = same on the Short BOS condition, using the most recent bullish candle (close > open).
Calculation: HTFHigh/HTFLow = high/low of the last completed bar of a higher timeframe than the chart, carried onto every chart bar and indexed in chart bars (HTFLow[k] = value k chart bars ago).
Long: close > SwingHigh AND previous close <= SwingHigh
Long: for any previously created BullFVG zone, low <= zone lower edge AND close >= zone upper edge
Long: BullOB exists AND low <= BullOB high AND close >= BullOB low AND close > previous close
Long: for any k in 2..L (chart bars, L is a lookback), |HTFLow[k] - HTFLow[k+1]| / HTFLow[k] < small threshold AND low < min(HTFLow[k], HTFLow[k+1]) AND close > min(HTFLow[k], HTFLow[k+1])
Short: close < SwingLow AND previous close >= SwingLow
Short: for any previously created BearFVG zone, high >= zone upper edge AND close <= zone lower edge
Short: BearOB exists AND high >= BearOB low AND close <= BearOB high AND close < previous close
Short: for any k in 2..L (chart bars, L is a lookback), |HTFHigh[k] - HTFHigh[k+1]| / HTFHigh[k] < small threshold AND high > max(HTFHigh[k], HTFHigh[k+1]) AND close < max(HTFHigh[k], HTFHigh[k+1])