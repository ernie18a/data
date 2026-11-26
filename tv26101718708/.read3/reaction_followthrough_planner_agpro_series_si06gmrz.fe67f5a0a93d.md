Calculation: Safe ATR = max(ATR(ATR lookback) when available, otherwise True Range, minimum price increment)
Calculation: Bar range = max(high - low, minimum price increment)
Calculation: Close location = (close - low) / bar range
Calculation: Upper wick = high - max(open, close)
Calculation: Lower wick = min(open, close) - low
Calculation: Last confirmed swing support = latest nonmissing Pivot Low(low, swing lookback, swing lookback)
Calculation: Last confirmed swing resistance = latest nonmissing Pivot High(high, swing lookback, swing lookback)
Calculation: Support touched = support exists AND low <= support + safe ATR * reaction-zone ATR width AND high >= support - safe ATR * reaction-zone ATR width
Calculation: Resistance touched = resistance exists AND high >= resistance - safe ATR * reaction-zone ATR width AND low <= resistance + safe ATR * reaction-zone ATR width
Calculation: Support distance = if support touched then abs(close - support) else distance fallback
Calculation: Resistance distance = if resistance touched then abs(close - resistance) else distance fallback
Calculation: Reaction cooldown ready = no earlier reaction OR current bar index - most recent reaction bar >= reaction cooldown bars
Calculation: Bullish reaction component count = (support exists AND close > support ? 1 : 0) + (close >= open ? 1 : 0) + (lower wick >= upper wick ? 1 : 0) + (close location >= bullish close-location threshold ? 1 : 0)
Calculation: Bearish reaction component count = (resistance exists AND close < resistance ? 1 : 0) + (close <= open ? 1 : 0) + (upper wick >= lower wick ? 1 : 0) + (close location <= bearish close-location threshold ? 1 : 0)
Calculation: Reaction strength(side) = clamp((side is bullish ? close location : 1 - close location) * close-defense weight + (side is bullish ? lower wick : upper wick) / bar range * wick-defense weight + abs(close - open) / bar range * body-participation weight + (side is bullish and close >= open OR side is bearish and close <= open ? 1 : 0) * direction-agreement weight, 0, 100)
Calculation: Reaction volume score = clamp((if SMA(volume, volume baseline lookback) > 0 then volume / SMA(volume, volume baseline lookback) else fallback relative volume) / volume-score relative-volume scale * 100, 0, 100), calculated on the reaction bar
Calculation: Bullish invalidation edge = at the reaction bar, min(low, last confirmed swing support - safe ATR * reaction-zone ATR width) - safe ATR * invalidation buffer ATR; store this edge
Calculation: Bearish invalidation edge = at the reaction bar, max(high, last confirmed swing resistance + safe ATR * reaction-zone ATR width) + safe ATR * invalidation buffer ATR; store this edge
Calculation: Active reaction bars elapsed = current bar index - reaction bar index
Calculation: Active reaction invalidated = bullish close < stored bullish invalidation edge OR bearish close > stored bearish invalidation edge
Calculation: Best favorable ATR progress = running maximum from the reaction bar through the current bar of max(0, (bullish ? high - reaction close : reaction close - low) / safe ATR)
Calculation: Worst adverse ATR excursion = running maximum from the reaction bar through the current bar of max(0, (bullish ? reaction close - low : high - reaction close) / safe ATR)
Calculation: First-following-bar response score = 0 until the first confirmed bar after the reaction; on that bar, store clamp((bullish ? close - reaction close : reaction close - close) / (safe ATR * first-bar response ATR scale) * 100, 0, 100)
Calculation: Progress score = clamp(best favorable ATR progress / max(progress normalization ATR multiple, progress divisor floor) * 100, 0, 100)
Calculation: Defense score = if active reaction invalidated then 0 else clamp(100 - worst adverse ATR excursion / max(invalidation buffer ATR + reaction-zone ATR width, defense denominator floor) * adverse-excursion defense penalty, 0, 100)
Calculation: Time-decay score = clamp(100 - active reaction bars elapsed / follow-through track bars * time-decay amount, time-decay floor, 100)
Calculation: Follow-through score = clamp(reaction strength * reaction-strength score weight + progress score * progress score weight + first-following-bar response score * response score weight + reaction volume score * volume score weight + defense score * defense score weight + time-decay score * time-decay score weight, 0, 100)
Calculation: Continuation-ready = confirmed bar AND active outcome was unresolved before this update AND active reaction bars elapsed > 0 AND NOT active reaction invalidated AND follow-through score >= minimum planner score AND progress score >= minimum progress score
Calculation: Active reaction state = a new bullish or bearish reaction window stores its side, bar, close, invalidation edge, reaction strength, and reaction volume score and resets its outcome to unresolved; on each confirmed bar update progress, excursion, response, and scores; while unresolved, set outcome to failed if invalidated, otherwise continued if continuation-ready, otherwise expired if active reaction bars elapsed >= follow-through track bars AND follow-through score < minimum planner score; terminal outcomes stay terminal until a newer reaction replaces the state
Long: confirmed bar AND reaction cooldown ready AND support touched AND bullish reaction component count >= minimum reaction-component count AND support distance <= resistance distance
Short: confirmed bar AND reaction cooldown ready AND resistance touched AND bearish reaction component count >= minimum reaction-component count AND resistance distance < support distance
Long: continuation-ready AND active reaction side is bullish
Short: continuation-ready AND active reaction side is bearish
Exit: long, confirmed bar AND active reaction side is bullish AND active outcome was unresolved before this update AND close < stored bullish invalidation edge
Exit: short, confirmed bar AND active reaction side is bearish AND active outcome was unresolved before this update AND close > stored bearish invalidation edge