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
Calculation: Relative strength = traded instrument close / selected benchmark index close, or zero when benchmark close ≤ 0
Calculation: Relative strength at a high = relative strength ≥ highest(relative strength, relative-strength high lookback parameter) × (1 − high tolerance parameter)
Calculation: Relative-strength slope (%) = (relative strength / relative strength at the RS slope lookback parameter bars ago − 1) × 100, or zero when the past value is zero
Calculation: Base lookback bars = max(int(base duration parameter × chart-bar conversion factor), minimum base-bar count parameter)
Calculation: Base pivot = highest traded instrument high over the prior base lookback bars
Calculation: Base support = lowest traded instrument low over the prior base lookback bars
Calculation: Base range (%) = (base pivot − base support) / base support × 100, or the invalid-support fallback parameter when base support ≤ 0
Calculation: Distance from pivot (%) = (traded instrument close − base pivot) / base pivot × 100, or the invalid-pivot fallback parameter when base pivot ≤ 0
Calculation: ATR contraction = ATR(short ATR length parameter) < ATR(base lookback bars) × ATR contraction ratio parameter
Calculation: Valid base = ATR contraction AND base range < maximum stage base-range parameter AND traded instrument close < base pivot × (1 + pivot ceiling tolerance parameter) AND traded instrument close > base support × (1 − support tolerance parameter)
Calculation: Stage-2 trend = traded instrument close > SMA(traded instrument close, fast moving-average length parameter) AND SMA(traded instrument close, fast moving-average length parameter) > SMA(traded instrument close, slow moving-average length parameter) AND the slow moving average is rising over the slow moving-average rise lookback parameter
Calculation: Relative-strength change (%) over a lookback = (relative strength / relative strength at the selected lookback bars ago − 1) × 100, or zero when the past value is zero
Calculation: Relative-strength acceleration = short-lookback relative-strength change > positive relative-performance cutoff parameter AND long-lookback relative-strength change > positive relative-performance cutoff parameter AND short-lookback relative-strength change > long-lookback relative-strength change / acceleration divisor parameter
Calculation: Composite score = sum of the separate score weights for passing checks: relative strength at a high, RS slope ≥ minimum RS slope parameter, Mansfield Relative Strength > minimum Mansfield parameter, relative-strength acceleration, valid base, ATR contraction, base range within its minimum and maximum parameters, pivot distance within its minimum and maximum parameters, and the Stage-2 trend requirement
Calculation: Checklist count = number of passing checks among: relative strength at a high; RS slope ≥ minimum RS slope parameter; Mansfield Relative Strength > minimum Mansfield parameter; relative-strength acceleration; valid base; ATR contraction; base range within its minimum and maximum parameters; pivot distance within its minimum and maximum parameters; volume requirement disabled or volume ≥ SMA(volume, volume-average lookback parameter) × volume multiplier parameter; Stage-2 trend requirement disabled or Stage-2 trend
Long: Relative strength at a high AND valid base AND traded instrument close < base pivot AND relative-strength slope > positive RS-slope cutoff parameter AND Mansfield Relative Strength > positive Mansfield cutoff parameter
Long: crossover of traded instrument close above base pivot × (1 + breakout-buffer parameter / 100) AND relative strength at a high AND volume > SMA(volume, volume-average lookback parameter) × volume multiplier parameter
Long: crossover of traded instrument close above base pivot × (1 + breakout-buffer parameter / 100) AND relative strength at a high AND volume > SMA(volume, volume-average lookback parameter) × volume multiplier parameter AND relative-strength slope > positive RS-slope cutoff parameter AND (Stage-2 trend requirement disabled OR Stage-2 trend) AND Mansfield Relative Strength > positive Mansfield cutoff parameter
Long: Relative strength at a high AND relative-strength slope ≥ minimum RS-slope parameter AND Mansfield Relative Strength > minimum Mansfield parameter AND relative-strength acceleration AND valid base AND base range ≥ minimum base-range parameter AND base range ≤ maximum base-range parameter AND distance from pivot ≥ minimum pivot-distance parameter AND distance from pivot ≤ maximum pivot-distance parameter AND (volume requirement disabled OR volume ≥ SMA(volume, volume-average lookback parameter) × volume multiplier parameter) AND (Stage-2 trend requirement disabled OR Stage-2 trend) AND composite score ≥ minimum score parameter
Long: Checklist count ≥ minimum near-golden passing-checks parameter AND NOT (checklist count = 10 AND composite score ≥ minimum score parameter)