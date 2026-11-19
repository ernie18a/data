Calculation: Relative strength = close / benchmark close on the same chart bar when benchmark close > 0, otherwise 0
Calculation: Relative-strength high = Relative strength >= Highest(Relative strength, high lookback) × high-proximity factor
Calculation: Relative-strength slope = (Relative strength − Relative strength[ slope lookback ]) / Relative strength[ slope lookback ] × 100 when the prior value is nonzero, otherwise 0
Calculation: Mansfield relative strength = Mansfield Relative Strength(Relative strength, Mansfield lookback)
Calculation: Base lookback = max(integer(base-duration parameter converted to chart bars), minimum-lookback parameter)
Calculation: Base pivot = Highest(high[1], Base lookback)
Calculation: Base support = Lowest(low[1], Base lookback)
Calculation: Base range = (Base pivot − Base support) / Base support × 100 when Base support > 0, otherwise a fallback parameter
Calculation: ATR contraction = ATR(short ATR lookback) < ATR(Base lookback) × ATR contraction factor
Calculation: Valid base = ATR contraction AND Base range < stage base-range maximum AND close < Base pivot × upper-base factor AND close > Base support × lower-base factor
Calculation: RS-slope criterion = Relative-strength slope >= minimum RS slope
Calculation: Mansfield criterion = Mansfield relative strength > minimum Mansfield value
Calculation: Base-range criterion = Base range >= golden base-range minimum AND Base range <= golden base-range maximum
Calculation: Distance from pivot = (close − Base pivot) / Base pivot × 100 when Base pivot > 0, otherwise a fallback parameter
Calculation: Pivot-distance criterion = Distance from pivot >= minimum pivot distance AND Distance from pivot <= maximum pivot distance
Calculation: RS acceleration criterion = short RS percentage change > 0 AND long RS percentage change > 0 AND short RS percentage change > long RS percentage change / acceleration divisor, where each percentage change is (Relative strength / Relative strength[lookback] − 1) × 100 when the prior value is nonzero, otherwise 0; the long lookback is longer than the short lookback
Calculation: Stage-2 trend = close > SMA(close, fast trend lookback) AND SMA(close, fast trend lookback) > SMA(close, slow trend lookback) AND Rising(SMA(close, slow trend lookback), rising lookback); the fast lookback is shorter than the slow lookback
Calculation: Volume criterion = volume filter disabled OR (SMA(volume, volume lookback) > 0 AND volume / SMA(volume, volume lookback) >= volume multiplier)
Calculation: Trend criterion = trend filter disabled OR Stage-2 trend
Calculation: Composite score = sum of separate weight parameters for each passed criterion among Relative-strength high, RS-slope criterion, Mansfield criterion, RS acceleration criterion, Valid base, ATR contraction, Base-range criterion, Pivot-distance criterion, and Trend criterion
Calculation: Passed-criteria count = count of passed criteria among Relative-strength high, RS-slope criterion, Mansfield criterion, RS acceleration criterion, Valid base, ATR contraction, Base-range criterion, Pivot-distance criterion, Volume criterion, and Trend criterion
Calculation: Strict setup = Relative-strength high AND RS-slope criterion AND Mansfield criterion AND RS acceleration criterion AND Valid base AND ATR contraction AND Base-range criterion AND Pivot-distance criterion AND Volume criterion AND Trend criterion AND Composite score >= minimum score
Long: Relative-strength high AND Valid base AND close < Base pivot AND Relative-strength slope > 0 AND Mansfield relative strength > 0
Long: crossover(close, Base pivot × (1 + breakout buffer / 100)) AND Relative-strength high AND volume > SMA(volume, volume lookback) × volume multiplier
Long: crossover(close, Base pivot × (1 + breakout buffer / 100)) AND Relative-strength high AND volume > SMA(volume, volume lookback) × volume multiplier AND Relative-strength slope > 0 AND Trend criterion AND Mansfield relative strength > 0
Long: Strict setup
Long: Strict setup AND NOT Strict setup[1]
Long: Passed-criteria count >= near-golden minimum AND NOT Strict setup