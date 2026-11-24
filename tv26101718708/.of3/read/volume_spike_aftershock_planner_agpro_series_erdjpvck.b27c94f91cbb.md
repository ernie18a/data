Calculation: Bar range = max(high - low, minimum tick size)
Calculation: Relative volume = volume / SMA(volume, relative-volume lookback), or 1 if the SMA is 0
Calculation: Range ratio = bar range / SMA(bar range, range lookback), or 1 if the SMA is 0
Calculation: Body ratio = abs(close - open) / bar range
Calculation: Close location = (close - low) / bar range
Calculation: Bullish spike condition = relative volume >= minimum relative volume AND range ratio >= minimum range ratio AND body ratio >= minimum body ratio AND close > open AND close location >= bullish close-location threshold
Calculation: Bearish spike condition = relative volume >= minimum relative volume AND range ratio >= minimum range ratio AND body ratio >= minimum body ratio AND close < open AND close location <= bearish close-location threshold
Long: bullish spike condition AND NOT (bullish spike condition[1] OR bearish spike condition[1])
Short: bearish spike condition AND NOT (bullish spike condition[1] OR bearish spike condition[1])
Calculation: Safe ATR = max(ATR(ATR lookback), true range if ATR is unavailable, minimum tick size)
Calculation: Spike ATR = safe ATR on the latest spike bar
Calculation: Spike depth = min(spike-bar range * spike-range fraction, spike ATR * aftershock-band ATR multiplier)
Calculation: Bullish hold rail = spike close - spike depth + spike ATR * hold-buffer ATR multiplier
Calculation: Bearish hold rail = spike close + spike depth - spike ATR * hold-buffer ATR multiplier
Calculation: Bullish absorption rail = spike close - spike ATR * absorption-buffer ATR multiplier
Calculation: Bearish absorption rail = spike close + spike ATR * absorption-buffer ATR multiplier
Calculation: Bullish failure rail = spike low - spike ATR * failure-buffer ATR multiplier
Calculation: Bearish failure rail = spike high + spike ATR * failure-buffer ATR multiplier
Calculation: Bullish room rail = max(spike high + spike ATR * target-room ATR multiplier, Highest(high[1], room lookback))
Calculation: Bearish room rail = min(spike low - spike ATR * target-room ATR multiplier, Lowest(low[1], room lookback))
Calculation: Active aftershock = a latest spike exists, its age in chart bars is <= maximum spike age, and its failure condition has not occurred
Calculation: Bullish absorbed = a close since the latest bullish spike is below its absorption rail
Calculation: Bearish absorbed = a close since the latest bearish spike is above its absorption rail
Calculation: Bullish failed = while the latest bullish spike is unexpired, a close is below its failure rail
Calculation: Bearish failed = while the latest bearish spike is unexpired, a close is above its failure rail
Calculation: Room reached = while the latest spike is unexpired and not failed, a bullish spike's high reaches its room rail or a bearish spike's low reaches its room rail
Calculation: Holding state = active aftershock AND ((latest spike is bullish AND close >= bullish hold rail) OR (latest spike is bearish AND close <= bearish hold rail))
Calculation: Aftershock score = round(clamp(volume score + range score + body score + hold score + decay score + room score - age penalty - absorption penalty, 0, score ceiling)), where volume score = clamp(spike relative volume / minimum relative volume * volume-score cap, 0, volume-score cap), range score = clamp(current range ratio / minimum range ratio * range-score cap, 0, range-score cap), body score = clamp(current body ratio / max(minimum body ratio, body-ratio divisor floor) * body-score cap, 0, body-score cap), hold score = for a bullish spike clamp((close - bullish hold rail) / max(spike high - bullish hold rail, minimum tick size) * hold-score cap, 0, hold-score cap), or for a bearish spike clamp((bearish hold rail - close) / max(bearish hold rail - spike low, minimum tick size) * hold-score cap, 0, hold-score cap), decay score = clamp((1 - abs(current relative volume / spike relative volume - decay target ratio) / decay target ratio) * decay-score cap, 0, decay-score cap), room score = for a bullish spike clamp((bullish room rail - close) / safe ATR * room-score scale, 0, room-score cap), or for a bearish spike clamp((close - bearish room rail) / safe ATR * room-score scale, 0, room-score cap), age penalty = clamp(spike age / maximum spike age * age-penalty cap, 0, age-penalty cap), and absorption penalty = absorption penalty amount if absorbed, otherwise 0
Calculation: Ready state = active aftershock AND holding state AND NOT absorbed AND NOT room reached AND aftershock score >= minimum ready score
Long: holding state AND latest spike is bullish AND NOT holding state[1]
Short: holding state AND latest spike is bearish AND NOT holding state[1]
Long: ready state AND latest spike is bullish AND NOT ready state[1]
Short: ready state AND latest spike is bearish AND NOT ready state[1]
Exit: long, latest spike is bullish AND its age is <= maximum spike age AND NOT previously failed AND ((close < bullish absorption rail AND NOT previously absorbed) OR close < bullish failure rail)
Exit: short, latest spike is bearish AND its age is <= maximum spike age AND NOT previously failed AND ((close > bearish absorption rail AND NOT previously absorbed) OR close > bearish failure rail)