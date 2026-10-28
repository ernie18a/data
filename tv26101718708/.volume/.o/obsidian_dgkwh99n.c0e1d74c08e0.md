Calculation: Composite TEMA = arithmetic mean of six TEMAs on close, using lengths ordered from shortest to longest
Calculation: Medium RSI slope = current medium-length RSI minus its value on the previous bar; the RSI stack is bullish when the short-, medium-, and long-length RSIs are all above 50
Calculation: Multi-ADX = (2 × ADX using the shorter length + ADX using the longer length) / 3
Calculation: Normalized ADX = minimum of Multi-ADX / 50 and 1
Calculation: Acceleration z-score = current second difference of Composite TEMA, standardized against its lookback mean and standard deviation; use 0 when the standard deviation is 0
Calculation: Volume spike = current volume z-score over a 20-bar lookback exceeds 1.2; use 0 for the z-score when standard deviation is 0
Calculation: Score = clamp to [0, 100] the sum of 20 if close > Composite TEMA, 20 if the RSI stack is bullish, 20 if Volume spike is true, 20 × Normalized ADX, and Acceleration z-score × 5 clamped to [-20, 20]
Calculation: Rolling POC = center of the equal-width price bin with the greatest summed volume, using close to assign each bar to a bin over the lookback range from lowest low to highest high; bins include their lower bound and exclude their upper bound, and ties select the lowest bin
Calculation: Value area high = Rolling POC + standard deviation of close over its lookback; Value area low = Rolling POC − that standard deviation
Calculation: POC drift = current Rolling POC − Rolling POC from its lookback bars ago
Calculation: Confirmed swing high/low = pivot high/low with equal left and right lookbacks; use the latest confirmed pivot level
Calculation: Average range = simple moving average of high − low over 20 bars
Calculation: Compression baseline = simple moving average of high − low over the compression lookback
Long: Score > 70 AND Multi-ADX >= 18 AND Medium RSI slope > 0
Short: Score > 70 AND Multi-ADX >= 18 AND Medium RSI slope < 0
Long: Composite TEMA crosses above Rolling POC AND Multi-ADX > 20
Short: Composite TEMA crosses below Rolling POC AND Multi-ADX > 20
Long: POC drift > 0 AND Composite TEMA > Rolling POC AND close > Value area high AND previous close <= current Value area high AND abs(POC drift) > 10 × minimum tick
Short: POC drift < 0 AND Composite TEMA < Rolling POC AND close < Value area low AND previous close >= current Value area low AND abs(POC drift) > 10 × minimum tick
Short: high > latest confirmed swing high AND close < latest confirmed swing high AND high − low > Compression baseline
Long: low < latest confirmed swing low AND close > latest confirmed swing low AND high − low > Compression baseline