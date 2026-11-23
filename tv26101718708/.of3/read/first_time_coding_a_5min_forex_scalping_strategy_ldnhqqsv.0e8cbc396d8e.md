Calculation: FastEMA = EMA(close, shorter EMA length)
Calculation: SlowEMA = EMA(close, longer EMA length)
Calculation: FastAnchor = EMA(close, shorter anchor length, T1, last completed bar, on chart bars)
Calculation: SlowAnchor = EMA(close, longer anchor length, T1, last completed bar, on chart bars)
Calculation: TriggerPrice = open of T2 bars, last completed bar, on chart bars
Calculation: LongAnchor = for all i from 0 to anchor lookback: low[i] > SlowAnchor[i] AND FastAnchor[i] > SlowAnchor[i]
Calculation: ShortAnchor = for all i from 0 to anchor lookback: high[i] < SlowAnchor[i] AND FastAnchor[i] < SlowAnchor[i]
Calculation: LongSignal = position is flat AND NOT LongWindow[1] AND FastEMA >= SlowEMA AND LongAnchor AND close >= FastEMA AND low <= FastEMA
Calculation: ShortSignal = position is flat AND NOT ShortWindow[1] AND FastEMA <= SlowEMA AND ShortAnchor AND close <= FastEMA AND high >= FastEMA
Calculation: LongAge = BarsSince(LongSignal)
Calculation: ShortAge = BarsSince(ShortSignal)
Calculation: LongWindow = NOT(LongAge > validity bars) AND NOT(LongAge > ShortAge) AND close >= FastAnchor AND LongAnchor AND FastEMA >= SlowEMA
Calculation: ShortWindow = NOT(ShortAge > validity bars) AND NOT(ShortAge > LongAge) AND close <= FastAnchor AND ShortAnchor AND FastEMA <= SlowEMA
Calculation: LongEntryLevel = ValueWhen(LongSignal, Highest(high, entry lookback) + stop offset)
Calculation: ShortEntryLevel = ValueWhen(ShortSignal, Lowest(low, entry lookback) - stop offset)
Calculation: LongStop = ValueWhen(LongSignal, low - stop offset)
Calculation: ShortStop = ValueWhen(ShortSignal, high + stop offset)
Long: LongWindow AND TriggerPrice crosses above LongEntryLevel
Short: ShortWindow AND TriggerPrice crosses below ShortEntryLevel
Exit: long, low <= LongStop OR high >= entry price + target R multiple * (entry price - LongStop)
Exit: short, high >= ShortStop OR low <= entry price - target R multiple * (ShortStop - entry price)
Long: FastAnchor >= SlowAnchor
Short: FastAnchor < SlowAnchor
Long: LongWindow
Short: ShortWindow