Calculation: Prior range high = Highest(high[1], range lookback)
Calculation: Prior range support = Lowest(low[1], range lookback)
Calculation: Inside-range close count = count of closes within the prior range over the preceding range lookback bars
Calculation: Range width ATR = max(prior range high - prior range support, minimum tick) / ATR(ATR lookback)
Calculation: Mature range = sufficient history AND inside-range close count >= minimum range age AND range width ATR >= minimum mature width ATR AND range width ATR <= maximum range width ATR
Calculation: Range maturity score = clamp(range-age weight * clamp((inside-range close count - minimum range age) / (mature range age - minimum range age) * 100, 0, 100) + range-width weight * (if range width ATR <= ideal range width ATR then clamp((range width ATR - lower range-width score bound) / (ideal range width ATR - lower range-width score bound) * 100, 0, 100) else clamp((maximum range width ATR - range width ATR) / (maximum range width ATR - ideal range width ATR) * 100, 0, 100)), 0, 100)
Calculation: Breakdown start event = confirmed bar AND mature range AND close < prior range support - minimum close-below-support ATR * ATR(ATR lookback) AND (no active breakdown review on the preceding bar OR its age exceeds the review window)
Calculation: Active breakdown review = starts on a breakdown start event and continues from the preceding bar while its age <= review window AND close <= captured breakdown support + reclaim buffer ATR * ATR(ATR lookback); capture prior range support and prior range height at review start
Calculation: Breakdown support = captured breakdown support while a breakdown review is active, otherwise prior range support
Calculation: Breakdown range height = captured prior range height while a breakdown review is active, otherwise max(prior range high - prior range support, minimum tick)
Calculation: Breakdown distance ATR = (breakdown support - close) / ATR(ATR lookback)
Calculation: Breakdown progress score = clamp((breakdown distance ATR - minimum close-below-support ATR) / (follow-through distance ATR - minimum close-below-support ATR) * 100, 0, 100)
Calculation: Bearish close quality = clamp((high - close) / max(high - low, minimum tick) * 100, 0, 100)
Calculation: Lower wick percent = clamp((min(open, close) - low) / max(high - low, minimum tick) * 100, 0, 100)
Calculation: Relative volume = volume / SMA(volume, volume lookback) when volume and its SMA are positive and available
Calculation: Volume support score = clamp((relative volume - weak relative-volume level) / (strong relative-volume level - weak relative-volume level) * 100, 0, 100) when relative volume is available, otherwise neutral volume score
Calculation: Retest touched = active breakdown review AND high >= breakdown support - retest tolerance ATR * ATR(ATR lookback) AND high <= breakdown support + upper retest tolerance multiplier * retest tolerance ATR * ATR(ATR lookback)
Calculation: Retest rejected = retest touched AND close < breakdown support AND close < open
Calculation: Retest score = rejected retest score when retest rejected, otherwise touched retest score when retest touched, otherwise untouched retest score
Calculation: Target guide = breakdown support - breakdown range height * target range multiple
Calculation: Target room ATR = max(close - target guide, 0) / ATR(ATR lookback)
Calculation: Target room score = clamp((target room ATR - weak target-room level) / (strong target-room level - weak target-room level) * 100, 0, 100)
Calculation: Breakdown score = clamp(range-maturity weight * range maturity score + progress weight * breakdown progress score + close-quality weight * bearish close quality + volume weight * volume support score + retest weight * retest score + target-room weight * target room score, 0, 100)
Calculation: Failure risk = clamp(proximity-risk weight * (100 - breakdown progress score) + wick-risk weight * clamp((lower wick percent - weak lower-wick level) / (strong lower-wick level - weak lower-wick level) * 100, 0, 100) + volume-risk weight * (100 - volume support score) + support-distance-risk weight * clamp((follow-through distance ATR - abs(close - breakdown support) / ATR(ATR lookback)) / follow-through distance ATR * 100, 0, 100) + maturity-risk weight * (100 - range maturity score), 0, 100) while a breakdown review is active
Calculation: Breakdown ready = active breakdown review AND breakdown distance ATR >= minimum close-below-support ATR AND breakdown score >= ready score threshold AND failure risk <= maximum ready failure risk
Calculation: Follow-through state = active breakdown review AND breakdown distance ATR >= follow-through distance ATR AND failure risk < failure-risk threshold
Long: none
Short: breakdown start event
Short: confirmed bar AND breakdown ready AND NOT breakdown ready[1]
Short: confirmed bar AND retest rejected AND NOT retest rejected[1]
Short: confirmed bar AND follow-through state AND NOT follow-through state[1]
Exit: short, confirmed bar AND active breakdown review[1] AND close > captured breakdown support + reclaim buffer ATR * ATR(ATR lookback)