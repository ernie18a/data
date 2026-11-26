Calculation: Bound(x) = min(100, max(0, x))
Calculation: RangePct(x, n) = 100 * (x - lowest(x, n)) / (highest(x, n) - lowest(x, n)), or 50 if highest(x, n) = lowest(x, n)
Calculation: PvmTrend = EMA((Correlation(close - close[1], volume - volume[1], correlation length) + 1) * 50, smoothing length)
Calculation: PvmImpulse = EMA(RangePct(ATR(impulse length) / EMA(ATR(impulse length), volume length) * RelativeVolume(volume, volume length), normalization length), smoothing length)
Calculation: PvmDirection = EMA(RangePct(ROC(close, impulse length), normalization length), smoothing length)
Calculation: BullFilter = PVM filter off OR (PvmTrend > trend threshold AND PvmDirection > direction threshold AND PvmImpulse > impulse threshold)
Calculation: BearFilter = PVM filter off OR (PvmTrend > trend threshold AND PvmDirection < direction threshold AND PvmImpulse > impulse threshold)
Calculation: Closeness(p, q, t) = Bound(100 - (abs(p - q) / abs(q) * 100) / t * 100)
Calculation: PatternQuality = geometry weight * (shoulder weight * Closeness(X, D, shoulder tolerance) + neck weight * Closeness(A, C, neck tolerance) + width weight * Bound(100 - abs(L - R) / max(L, R) * 100) + head weight * Bound(HeadDepth / ATR(ATR length) * head depth scale)) + impulse weight * PvmImpulse + trend weight * PvmTrend, where L = bars from X to B, R = bars from B to D, and HeadDepth = min(X, D) - B for an inverse pattern or B - max(X, D) for a head-and-shoulders pattern
Calculation: InvHSFormed = PivotLow(low, pivot left, pivot right) is confirmed on this bar AND the last five confirmed pivots, oldest to newest X, A, B, C, D, alternate low, high, low, high, low AND abs(X - D) / abs(D) * 100 <= shoulder tolerance AND B < min(X, D) AND (quality filter off OR PatternQuality >= quality threshold)
Calculation: HSFormed = PivotHigh(high, pivot left, pivot right) is confirmed on this bar AND the last five confirmed pivots, oldest to newest X, A, B, C, D, alternate high, low, high, low, high AND abs(X - D) / abs(D) * 100 <= shoulder tolerance AND B > max(X, D) AND (quality filter off OR PatternQuality >= quality threshold)
Calculation: InvHSActive = true from a bar where InvHSFormed holds, false from the first later bar where close crosses above neckline max(A, C) with BullFilter, or close < B, or HSFormed holds
Calculation: HSActive = true from a bar where HSFormed holds, false from the first later bar where close crosses below neckline min(A, C) with BearFilter, or close > B, or InvHSFormed holds
Calculation: CupSpanAtr = (highest(high, cup length) - lowest(low, cup length)) / ATR(ATR length)
Calculation: CupQualityLong = geometry weight * Bound(CupSpanAtr / min cup depth * cup depth scale + cup mid weight * [bars since lowest(low, cup length) is strictly between lower middle fraction * cup length and upper middle fraction * cup length] + cup recovery weight * [close > EMA(close, cup recovery length)]) + impulse weight * PvmImpulse + trend weight * PvmTrend
Calculation: CupQualityShort = geometry weight * Bound(CupSpanAtr / min cup depth * cup depth scale + cup mid weight * [bars since highest(high, cup length) is strictly between lower middle fraction * cup length and upper middle fraction * cup length] + cup recovery weight * [close < EMA(close, cup recovery length)]) + impulse weight * PvmImpulse + trend weight * PvmTrend
Calculation: BullRetest = low <= throwback neckline + ATR(ATR length) * throwback tolerance AND close > throwback neckline AND BullFilter AND bars since throwback bar <= max throwback bars
Calculation: BearRetest = high >= throwback neckline - ATR(ATR length) * throwback tolerance AND close < throwback neckline AND BearFilter AND bars since throwback bar <= max throwback bars
Calculation: BullCancel = close < throwback neckline - ATR(ATR length) * throwback tolerance OR bars since throwback bar > max throwback bars
Calculation: BearCancel = close > throwback neckline + ATR(ATR length) * throwback tolerance OR bars since throwback bar > max throwback bars
Calculation: BullThrowback = true from a bar where throwback on AND InvHSActive[1] AND close crosses above the inverse H&S neckline with BullFilter, storing that neckline as throwback neckline and that bar as throwback bar; false after the first bar, starting from that bar, where BullRetest or BullCancel holds; false on any bar where throwback on AND HSActive[1] AND close crosses below the H&S neckline with BearFilter
Calculation: BearThrowback = true from a bar where throwback on AND HSActive[1] AND close crosses below the H&S neckline with BearFilter, storing that neckline as throwback neckline and that bar as throwback bar; false after the first bar, starting from that bar, where BearRetest or BearCancel holds; false on any bar where throwback on AND InvHSActive[1] AND close crosses above the inverse H&S neckline with BullFilter
Long: InvHSFormed
Short: HSFormed
Long: InvHSActive[1] AND close crosses above the inverse H&S neckline AND BullFilter AND throwback off
Short: HSActive[1] AND close crosses below the H&S neckline AND BearFilter AND throwback off
Long: BullThrowback AND BullRetest
Short: BearThrowback AND BearRetest
Exit: long, BullThrowback AND BullCancel
Exit: long, InvHSActive[1] AND close < B
Exit: short, BearThrowback AND BearCancel
Exit: short, HSActive[1] AND close > B
Long: cup on AND CupSpanAtr >= min cup depth AND bars since lowest(low, cup length) is strictly between lower middle fraction * cup length and upper middle fraction * cup length AND close > EMA(close, cup recovery length) AND close crosses above highest(high, cup length)[1] AND BullFilter AND (quality filter off OR CupQualityLong >= quality threshold)
Short: cup on AND CupSpanAtr >= min cup depth AND bars since highest(high, cup length) is strictly between lower middle fraction * cup length and upper middle fraction * cup length AND close < EMA(close, cup recovery length) AND close crosses below lowest(low, cup length)[1] AND BearFilter AND (quality filter off OR CupQualityShort >= quality threshold)