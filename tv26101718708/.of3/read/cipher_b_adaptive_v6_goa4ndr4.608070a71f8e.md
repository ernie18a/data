Calculation: VolFactor = profile override if set, else clamp((EMA(stdev(log(close/close[1]), volatility lookback) * sqrt(bars per year), volatility smoothing length) - lower volatility threshold) / (upper volatility threshold - lower volatility threshold), 0, 1)
Calculation: LengthMult = 1 + length stretch * VolFactor
Calculation: Osc = WaveTrend(hlc3, channel length * LengthMult, average length * LengthMult)
Calculation: Sig = SMA(Osc, signal length)
Calculation: FixedMult = 1 + fixed level stretch * VolFactor
Calculation: Upper raw = clamp(IF(bar count >= level lookback, percentile(Osc, level lookback, extreme percentile), upper fixed level * FixedMult), level floor, level ceiling)
Calculation: Lower raw = clamp(IF(bar count >= level lookback, percentile(Osc, level lookback, 100 - extreme percentile), lower fixed level * FixedMult), -level ceiling, -level floor)
Calculation: Upper outer = IF(adaptive levels, IF(symmetric levels, max(Upper raw, -Lower raw), Upper raw), upper fixed level * FixedMult)
Calculation: Lower outer = IF(adaptive levels, IF(symmetric levels, -Upper outer, Lower raw), lower fixed level * FixedMult)
Calculation: Upper inner = Upper outer * inner level ratio
Calculation: Lower inner = Lower outer * inner level ratio
Calculation: Pivot low = Osc[pivot length] == lowest(Osc, 2 * pivot length + 1)
Calculation: Pivot high = Osc[pivot length] == highest(Osc, 2 * pivot length + 1)
Calculation: Low at pivot = lowest(low, 2 * pivot length + 1)
Calculation: High at pivot = highest(high, 2 * pivot length + 1)
Calculation: Low pair ok = Pivot low AND bar index - ValueWhen(Pivot low, bar index, 1) <= max bars between pivots
Calculation: High pair ok = Pivot high AND bar index - ValueWhen(Pivot high, bar index, 1) <= max bars between pivots
Calculation: Prev low osc = ValueWhen(Pivot low, Osc[pivot length], 1)
Calculation: Prev low price = ValueWhen(Pivot low, Low at pivot, 1)
Calculation: Prev high osc = ValueWhen(Pivot high, Osc[pivot length], 1)
Calculation: Prev high price = ValueWhen(Pivot high, High at pivot, 1)
Calculation: Bull divergence = Low pair ok AND Low at pivot < Prev low price AND Osc[pivot length] > Prev low osc AND (zone filter off OR (Osc[pivot length] < 0 AND (Osc[pivot length] < Lower inner OR Prev low osc < Lower inner)))
Calculation: Bear divergence = High pair ok AND High at pivot > Prev high price AND Osc[pivot length] < Prev high osc AND (zone filter off OR (Osc[pivot length] > 0 AND (Osc[pivot length] > Upper inner OR Prev high osc > Upper inner)))
Calculation: Hidden bull = Low pair ok AND Low at pivot > Prev low price AND Osc[pivot length] < Prev low osc AND Osc[pivot length] < 0
Calculation: Hidden bear = High pair ok AND High at pivot < Prev high price AND Osc[pivot length] > Prev high osc AND Osc[pivot length] > 0
Calculation: Money flow = SMA(IF(high > low, (close - open) / (high - low) * money flow multiplier, 0), money flow period)
Long: Osc crosses above Sig
Long: Osc crosses above Sig AND Sig > Lower inner
Long: Osc crosses above Sig AND Sig <= Lower inner
Long: Osc crosses above Sig AND Sig <= Lower inner AND (Sig <= Lower outer OR BarsSince(Bull divergence) <= divergence memory)
Long: Bull divergence = true
Long: Hidden bull = true
Long: Osc > Sig
Long: Money flow > 0
Short: Osc crosses below Sig
Short: Osc crosses below Sig AND Sig < Upper inner
Short: Osc crosses below Sig AND Sig >= Upper inner
Short: Osc crosses below Sig AND Sig >= Upper inner AND (Sig >= Upper outer OR BarsSince(Bear divergence) <= divergence memory)
Short: Bear divergence = true
Short: Hidden bear = true
Short: Osc <= Sig
Short: Money flow <= 0