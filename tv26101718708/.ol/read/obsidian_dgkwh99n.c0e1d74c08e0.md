Calculation: Composite TEMA = average of six TEMAs of close, with progressively longer lookbacks.
Calculation: Multi-ADX = (2 × ADX with the shorter lookback + ADX with the longer lookback) / 3.
Calculation: Rolling POC = midpoint of the highest-volume price bin; divide the rolling high-to-low price range into bins and assign each bar’s volume to the bin containing its close.
Calculation: Value area high/low = Rolling POC ± standard deviation of close over the value-area lookback.
Calculation: Signal score = clamp(trend points + RSI-stack points + volume-spike points + 20 × min(Multi-ADX / ADX normalization cap, 1) + clamp(5 × acceleration z-score, −20, 20), 0, 100); trend points are 20 when close > Composite TEMA, RSI-stack points are 20 when RSI with each of the short, medium, and long lookbacks > 50, and volume-spike points are 20 when volume z-score > its spike threshold.
Long: Signal score > its threshold AND Multi-ADX >= its squeeze threshold AND medium-lookback RSI minus its prior-bar value > 0
Short: Signal score > its threshold AND Multi-ADX >= its squeeze threshold AND medium-lookback RSI minus its prior-bar value < 0
Long: Composite TEMA crosses above Rolling POC AND Multi-ADX > its strong-trend threshold
Short: Composite TEMA crosses below Rolling POC AND Multi-ADX > its strong-trend threshold
Calculation: POC drift = Rolling POC − Rolling POC from the prior drift-lookback bar.
Long: POC drift > 0 AND Composite TEMA > Rolling POC AND close > Value area high AND prior close <= Value area high AND absolute POC drift > its minimum-drift threshold
Short: POC drift < 0 AND Composite TEMA < Rolling POC AND close < Value area low AND prior close >= Value area low AND absolute POC drift > its minimum-drift threshold
Calculation: Liquidity high/low = latest confirmed pivot high/low, using the same swing lookback on both sides of each pivot.
Calculation: Average range = simple moving average of high − low over its range lookback.
Short: high > Liquidity high AND close < Liquidity high AND high − low > Average range
Long: low < Liquidity low AND close > Liquidity low AND high − low > Average range