Calculation: Trend vote = sign of short-term EMA(close) minus long-term EMA(close).
Calculation: Momentum vote = sign of RSI(close) minus the RSI midpoint.
Calculation: MACD vote = sign of the MACD histogram of close; its fast EMA is shorter than its slow EMA.
Calculation: Strength vote = 0 when ADX is below its threshold; otherwise the sign of positive DI minus negative DI. Use the same length for DI and ADX smoothing.
Calculation: Volume vote = sign of close minus open when volume divided by its SMA is at least the relative-volume threshold; otherwise 0. If the volume SMA is not positive, use a relative volume of 1.
Calculation: Location vote = +1 when the close's fractional position in the rolling high-low range is at or below a lower threshold, -1 when it is at or above an upper threshold, otherwise 0. Use the range's midpoint when its high equals its low.
Calculation: Smoothed score = EMA of 100 times the weighted sum of the six votes divided by the sum of their nonnegative weights; use 0 for the unsmoothed score when the weight sum is 0.
Calculation: Signal state = 0 initially; set to +1 on a qualifying long signal and -1 on a qualifying short signal, retaining its value otherwise. Evaluate each signal against the state before the current bar's update.
Calculation: Entry risk = ATR at the signal bar multiplied by the stop multiplier; if the result is not positive, use that ATR. Hold entry risk fixed from the signal bar.
Long: Trend vote > 0 OR momentum vote > 0 OR MACD vote > 0 OR strength vote > 0 OR volume vote > 0 OR location vote > 0.
Short: Trend vote < 0 OR momentum vote < 0 OR MACD vote < 0 OR strength vote < 0 OR volume vote < 0 OR location vote < 0.
Long: Smoothed score >= 0 OR signal state = +1.
Short: Smoothed score < 0 OR signal state = -1.
Long: Smoothed score >= positive score threshold AND number of positive votes >= minimum agreement AND prior signal state <= 0.
Short: Smoothed score <= negative score threshold AND number of negative votes >= minimum agreement AND prior signal state >= 0.
Exit: long, high >= entry price + entry risk × first target multiple OR low <= entry price - entry risk OR qualifying short signal = true.
Exit: short, low <= entry price - entry risk × first target multiple OR high >= entry price + entry risk OR qualifying long signal = true.