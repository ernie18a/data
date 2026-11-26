Calculation: Confirmed bar = bar is closed OR confirmation mode is P4
Calculation: ATR = ATR(high, low, close, ATR length)
Calculation: Active high = Highest(high, range lookback)[1]
Calculation: Active low = Lowest(low, range lookback)[1]
Calculation: Active mid = (Active high + Active low) / 2
Calculation: Range width ATR = (Active high - Active low) / ATR
Calculation: Ramp(x, weak, strong) = clamp(100 * (x - weak) / (strong - weak), 0, 100)
Calculation: Fall(x, good, bad) = clamp(100 * (bad - x) / (bad - good), 0, 100)
Calculation: Range quality = if Range width ATR <= ideal range width ATR multiple then Ramp(Range width ATR, minimum range width ATR multiple, ideal range width ATR multiple) else Fall(Range width ATR, ideal range width ATR multiple, maximum range width ATR multiple)
Calculation: Mature range = Range width ATR <= maximum range width ATR multiple AND Range quality >= mature range quality threshold
Calculation: Upper edge touched = Mature range AND (edge mode is P1 OR edge mode is P2) AND High >= Active high - edge zone ATR multiple * ATR
Calculation: Lower edge touched = Mature range AND (edge mode is P1 OR edge mode is P3) AND Low <= Active low + edge zone ATR multiple * ATR
Calculation: Upper close-back = (Active high - Close) / ATR
Calculation: Lower close-back = (Close - Active low) / ATR
Calculation: Upper room = max(Close - Active mid, 0) / ATR
Calculation: Lower room = max(Active mid - Close, 0) / ATR
Calculation: Upper wick share = (High - max(Open, Close)) / (High - Low)
Calculation: Lower wick share = (min(Open, Close) - Low) / (High - Low)
Calculation: Volume score = if SMA(Volume, volume length) > 0 then Ramp(Volume / SMA(Volume, volume length), volume low, volume high) else volume default score
Calculation: Upper candidate = Upper edge touched AND Upper close-back >= close-back ATR multiple AND Close < Active high AND Upper wick share >= minimum wick share * wick valid factor AND Upper room >= minimum midline room ATR multiple * room valid factor
Calculation: Lower candidate = Lower edge touched AND Lower close-back >= close-back ATR multiple AND Close > Active low AND Lower wick share >= minimum wick share * wick valid factor AND Lower room >= minimum midline room ATR multiple * room valid factor
Calculation: Upper score = round(clamp(edge weight * (if Upper edge touched then Fall(abs(High - Active high) / ATR, 0, edge span factor * edge zone ATR multiple) else 0) + wick weight * Ramp(Upper wick share, minimum wick share * wick weak factor, minimum wick share * wick strong factor) + close-back weight * Ramp(Upper close-back, close-back ATR multiple * close-back weak factor, max(close-back ATR multiple * close-back strong factor, close-back floor)) + volume weight * Volume score + room weight * Ramp(Upper room, minimum midline room ATR multiple * room weak factor, minimum midline room ATR multiple * room strong factor) + range weight * Range quality, 0, 100))
Calculation: Lower score = round(clamp(edge weight * (if Lower edge touched then Fall(abs(Low - Active low) / ATR, 0, edge span factor * edge zone ATR multiple) else 0) + wick weight * Ramp(Lower wick share, minimum wick share * wick weak factor, minimum wick share * wick strong factor) + close-back weight * Ramp(Lower close-back, close-back ATR multiple * close-back weak factor, max(close-back ATR multiple * close-back strong factor, close-back floor)) + volume weight * Volume score + room weight * Ramp(Lower room, minimum midline room ATR multiple * room weak factor, minimum midline room ATR multiple * room strong factor) + range weight * Range quality, 0, 100))
Calculation: Upper selected = Upper candidate AND (edge mode is P2 OR Upper score >= Lower score)
Calculation: Lower selected = Lower candidate AND NOT Upper selected
Calculation: Long entry = Confirmed bar AND Lower selected AND Lower score >= reject-ready threshold AND Bars since last event >= label cooldown bars
Calculation: Short entry = Confirmed bar AND Upper selected AND Upper score >= reject-ready threshold AND Bars since last event >= label cooldown bars
Calculation: Long exit marking = Confirmed bar AND bars since Long entry <= rejection review window AND no Short entry since that Long entry AND no earlier Long exit marking since that Long entry AND (High >= Active mid at that Long entry OR Close < Active low at that Long entry - invalidation ATR multiple * ATR at that Long entry)
Calculation: Short exit marking = Confirmed bar AND bars since Short entry <= rejection review window AND no Long entry since that Short entry AND no earlier Short exit marking since that Short entry AND (Low <= Active mid at that Short entry OR Close > Active high at that Short entry + invalidation ATR multiple * ATR at that Short entry)
Calculation: Edge watch = Confirmed bar AND ((Upper selected AND Upper score >= edge-watch threshold AND Upper score < reject-ready threshold) OR (Lower selected AND Lower score >= edge-watch threshold AND Lower score < reject-ready threshold)) AND Bars since last event >= label cooldown bars
Calculation: Midline review = review labels enabled AND Confirmed bar AND 0 < bars since most recent Long or Short entry <= rejection review window AND no exit marking of that entry's side since that entry, including this bar AND Bars since last event >= label cooldown bars AND score at that entry >= edge-watch threshold
Calculation: Bars since last event = bars before this bar since the latest bar at which Long entry, Short entry, Edge watch, Long exit marking, Short exit marking, or Midline review occurred (infinite if none)
Long: Long entry
Short: Short entry
Exit: Long, Long exit marking
Exit: Short, Short exit marking