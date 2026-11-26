Calculation: Displacement range = max(high - low, minimum tick)
Calculation: Safe ATR = max(ATR(ATR lookback) when available, true range otherwise, minimum tick)
Calculation: Relative volume = volume / SMA(volume, volume lookback) when the average volume is positive, relative-volume fallback otherwise
Calculation: Body ratio = abs(close - open) / displacement range
Calculation: Qualifying displacement = displacement range >= safe ATR * minimum displacement ATR AND body ratio >= minimum body ratio AND relative volume >= minimum relative volume
Calculation: Active imbalance = the latest chart bar with qualifying displacement; its direction is bullish when its close is above its open and bearish when its close is below its open; a new qualifying displacement replaces it, and it remains active through the bar its age exceeds maximum imbalance age or its invalidation condition occurs, then clears
Calculation: Active pocket = the active displacement candle's open-close midpoint as recovery rail, with pocket top and bottom at that midpoint plus and minus the greater of half its body size or half the minimum pocket width; minimum pocket width = safe ATR on the displacement bar * minimum pocket-width ATR
Calculation: Pocket age = chart bars elapsed since the active displacement bar
Calculation: Seed score = round(clamp(seed-score baseline + clamp((displacement range / safe ATR - minimum displacement ATR) * seed range-score weight, score floor, seed range-score cap) + clamp((relative volume - minimum relative volume) * seed volume-score weight, score floor, seed volume-score cap) + body ratio * seed body-score weight, score floor, score ceiling)), calculated on the displacement bar and retained for its active imbalance
Calculation: Recent pocket test = an active imbalance exists AND the most recent chart bar whose high >= pocket bottom AND low <= pocket top occurred no more than the pocket-test window bars ago
Calculation: Recovery close = recent pocket test AND (active bullish imbalance AND close > recovery rail + safe ATR * recovery buffer ATR OR active bearish imbalance AND close < recovery rail - safe ATR * recovery buffer ATR)
Calculation: Recovery score = round(clamp(seed score * seed-score contribution weight + clamp(depth * recovery-depth weight, score floor, depth-score cap) + clamp(rejection-wick fraction * rejection-wick weight, score floor, wick-score cap) + clamp(relative volume * recovery-volume weight, score floor, recovery-volume score cap) + freshness score * freshness contribution weight, score floor, score ceiling)); depth = (close - recovery rail) / max(pocket top - pocket bottom, minimum tick) for bullish imbalance or (recovery rail - close) / max(pocket top - pocket bottom, minimum tick) for bearish imbalance; rejection-wick fraction = lower wick / displacement range for bullish imbalance or upper wick / displacement range for bearish imbalance; freshness score = clamp(score ceiling - pocket age / maximum imbalance age * freshness decay, score floor, score ceiling)
Calculation: Ready recovery = recovery close AND recovery score >= minimum ready score
Calculation: Recovery active = an active imbalance exists AND a ready recovery occurred within the pocket-test window multiplied by the recovery-active duration multiplier
Long: close > open AND qualifying displacement
Short: close < open AND qualifying displacement
Long: active bullish imbalance AND high >= pocket bottom AND low <= pocket top AND NOT ready recovery AND NOT qualifying displacement
Short: active bearish imbalance AND high >= pocket bottom AND low <= pocket top AND NOT ready recovery AND NOT qualifying displacement
Long: active bullish imbalance AND recovery active
Short: active bearish imbalance AND recovery active
Exit: long, active bullish imbalance AND close < pocket bottom - safe ATR * invalidation buffer ATR
Exit: short, active bearish imbalance AND close > pocket top + safe ATR * invalidation buffer ATR