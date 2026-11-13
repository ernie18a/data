Calculation: EMA fast/slow = exponential moving averages of close, fast = shorter length, slow = longer length
Calculation: ADX = ADX from DMI (standard Wilder-style ADX)
Calculation: TrendRegime = ADX > trend_threshold AND abs(EMA fast - EMA slow) / close * 100 > min_distance_threshold
Calculation: RangeRegime = NOT TrendRegime AND ADX < range_threshold (range_threshold is lower than trend_threshold)
Calculation: PriorHigh/PriorLow = highest high / lowest low over the previous N completed bars, excluding the current bar
Calculation: Z = (close - VWAP) / stdev over a long lookback of (hlc3 - VWAP), where VWAP = session-anchored VWAP of hlc3 that resets each session
Long: (TrendRegime AND EMA fast > EMA slow AND close > PriorHigh) OR (RangeRegime AND Z < -z_threshold AND close > previous close); enter only on the first bar where this condition becomes true after being false on the previous bar, and only if not already long (a short position is reversed); entry price = close
Short: (TrendRegime AND EMA fast < EMA slow AND close < PriorLow) OR (RangeRegime AND Z > z_threshold AND close < previous close); enter only on the first bar where this condition becomes true after being false on the previous bar, and only if not already short (a long position is reversed); entry price = close
Exit: long, low <= entry - k * ATR(at entry bar) OR high >= entry + rr * k * ATR(at entry bar) OR the Short entry condition triggers (reversal)
Exit: short, high >= entry + k * ATR(at entry bar) OR low <= entry - rr * k * ATR(at entry bar) OR the Long entry condition triggers (reversal)