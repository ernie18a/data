Calculation: Trend average = selected moving average of hl2
Calculation: Slope = (current trend average − previous trend average) / previous trend average × 100
Calculation: Bull trend = becomes true when slope exceeds the impulse threshold and false when slope is below the negative threshold or close crosses below the trend average
Calculation: Bear trend = becomes true when slope is below the negative impulse threshold and false when slope exceeds the impulse threshold or close crosses above the trend average
Calculation: Upper zone = trend average × (1 + zone width percentage / 100)
Calculation: Lower zone = trend average × (1 − zone width percentage / 100)
Calculation: Clearance distance = trend average × zone width percentage / 100 × clearance strictness
Calculation: Zone cleared = initially true; becomes true when bull trend and high exceeds upper zone plus clearance distance, or bear trend and low falls below lower zone minus clearance distance; becomes false after either entry signal
Calculation: Long retest = bull trend AND zone cleared AND low ≤ upper zone AND close > trend average
Calculation: Short retest = bear trend AND zone cleared AND high ≥ lower zone AND close < trend average
Calculation: RSI = standard RSI of close
Long: previous bar's long retest AND close > trend average AND slope > impulse threshold AND bars since last entry signal > minimum signal spacing
Short: previous bar's short retest AND close < trend average AND slope < negative impulse threshold AND bars since last entry signal > minimum signal spacing
Exit: Long, RSI crosses below the overbought level
Exit: Short, RSI crosses above the oversold level