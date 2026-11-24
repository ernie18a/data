Calculation: Bullish local trend = close > EMA(close, fast EMA lookback) AND EMA(close, fast EMA lookback) > EMA(close, middle EMA lookback) AND EMA(close, middle EMA lookback) > EMA(close, slow EMA lookback)
Calculation: Bearish local trend = close < EMA(close, fast EMA lookback) AND EMA(close, fast EMA lookback) < EMA(close, middle EMA lookback) AND EMA(close, middle EMA lookback) < EMA(close, slow EMA lookback)
Calculation: Bullish T1 trend = T1 close > EMA(close, fast EMA lookback, T1) AND EMA(close, fast EMA lookback, T1) > EMA(close, middle EMA lookback, T1) AND EMA(close, middle EMA lookback, T1) > EMA(close, slow EMA lookback, T1); evaluate on chart bars using the current T1 bar, which can still be forming in real time
Calculation: Bearish T1 trend = T1 close < EMA(close, fast EMA lookback, T1) AND EMA(close, fast EMA lookback, T1) < EMA(close, middle EMA lookback, T1) AND EMA(close, middle EMA lookback, T1) < EMA(close, slow EMA lookback, T1); evaluate on chart bars using the current T1 bar, which can still be forming in real time
Calculation: Bullish T2 trend = T2 close > EMA(close, fast EMA lookback, T2) AND EMA(close, fast EMA lookback, T2) > EMA(close, middle EMA lookback, T2) AND EMA(close, middle EMA lookback, T2) > EMA(close, slow EMA lookback, T2); evaluate on chart bars using the current T2 bar, which can still be forming in real time
Calculation: Bearish T2 trend = T2 close < EMA(close, fast EMA lookback, T2) AND EMA(close, fast EMA lookback, T2) < EMA(close, middle EMA lookback, T2) AND EMA(close, middle EMA lookback, T2) < EMA(close, slow EMA lookback, T2); evaluate on chart bars using the current T2 bar, which can still be forming in real time
Calculation: Bullish sweep recent = within the sweep validity lookback, low fell below and close finished above the latest confirmed pivot low using the sweep pivot lookback
Calculation: Bearish sweep recent = within the sweep validity lookback, high rose above and close finished below the latest confirmed pivot high using the sweep pivot lookback
Calculation: Bullish BOS recent = close above the latest confirmed pivot high using the BOS pivot lookback has been true within the BOS validity lookback
Calculation: Bearish BOS recent = close below the latest confirmed pivot low using the BOS pivot lookback has been true within the BOS validity lookback
Calculation: Bullish CHOCH recent = within the BOS validity lookback, a bullish BOS occurred while the stored structure direction was bearish
Calculation: Bearish CHOCH recent = within the BOS validity lookback, a bearish BOS occurred while the stored structure direction was bullish
Calculation: Bullish internal shift recent = within the internal shift validity lookback, close exceeded the latest confirmed pivot high using the internal pivot lookback
Calculation: Bearish internal shift recent = within the internal shift validity lookback, close fell below the latest confirmed pivot low using the internal pivot lookback
Calculation: Bullish fib zone recent = within the fib validity lookback, a bullish BOS had a last pivot low, and low <= close - (close - last pivot low) times the fib upper retracement parameter AND high >= close - (close - last pivot low) times the fib lower retracement parameter
Calculation: Bearish fib zone recent = within the fib validity lookback, a bearish BOS had a last pivot high, and high >= close + (last pivot high - close) times the fib upper retracement parameter AND low <= close + (last pivot high - close) times the fib lower retracement parameter
Calculation: Bullish displacement recent = within the momentum validity lookback, close > open and abs(close - open) > ATR(ATR lookback) times the displacement body ATR multiplier
Calculation: Bearish displacement recent = within the momentum validity lookback, close < open and abs(close - open) > ATR(ATR lookback) times the displacement body ATR multiplier
Calculation: Bullish momentum confirmed = momentum confirmation enabled AND bullish displacement recent AND EMA(close, fast EMA lookback) > its value momentum slope lookback bars ago AND close > EMA(close, fast EMA lookback)
Calculation: Bearish momentum confirmed = momentum confirmation enabled AND bearish displacement recent AND EMA(close, fast EMA lookback) < its value momentum slope lookback bars ago AND close < EMA(close, fast EMA lookback)
Calculation: Bullish momentum weak = momentum confirmation enabled AND bullish local trend AND NOT bullish momentum confirmed AND abs(close - open) < ATR(ATR lookback) times the weak momentum body ATR multiplier
Calculation: Bearish momentum weak = momentum confirmation enabled AND bearish local trend AND NOT bearish momentum confirmed AND abs(close - open) < ATR(ATR lookback) times the weak momentum body ATR multiplier
Calculation: Bullish IFVG recent = within the IFVG validity lookback, close crossed above the upper boundary of the latest active qualifying bearish fair value gap; a qualifying gap has high < low two bars ago and low two bars ago - high > ATR(ATR lookback) times the IFVG ATR filter
Calculation: Bearish IFVG recent = within the IFVG validity lookback, close crossed below the lower boundary of the latest active qualifying bullish fair value gap; a qualifying gap has low > high two bars ago and low - high two bars ago > ATR(ATR lookback) times the IFVG ATR filter
Calculation: Accepted above = close > EMA(close, fast EMA lookback) AND the prior close > the current EMA(close, fast EMA lookback) AND the close one further bar ago > the current EMA(close, fast EMA lookback)
Calculation: Accepted below = close < EMA(close, fast EMA lookback) AND the prior close < the current EMA(close, fast EMA lookback) AND the close one further bar ago < the current EMA(close, fast EMA lookback)
Calculation: Rejecting higher = high > EMA(close, fast EMA lookback) AND close < EMA(close, fast EMA lookback) AND high - max(open, close) > ATR(ATR lookback) times the rejection wick ATR multiplier
Calculation: Rejecting lower = low < EMA(close, fast EMA lookback) AND close > EMA(close, fast EMA lookback) AND min(open, close) - low > ATR(ATR lookback) times the rejection wick ATR multiplier
Calculation: EMA spread = abs(EMA(close, fast EMA lookback) - EMA(close, slow EMA lookback))
Calculation: EMA compression = EMA spread < ATR(ATR lookback) times the compression ATR multiplier
Calculation: Bullish EMA expansion = bullish local trend AND EMA spread > EMA spread at the EMA spread comparison lag
Calculation: Bearish EMA expansion = bearish local trend AND EMA spread > EMA spread at the EMA spread comparison lag
Calculation: Near buy-side liquidity = close >= highest high over the liquidity lookback - ATR(ATR lookback) times the liquidity proximity ATR multiplier
Calculation: Near sell-side liquidity = close <= lowest low over the liquidity lookback + ATR(ATR lookback) times the liquidity proximity ATR multiplier
Calculation: Bearish RSI divergence recent = divergence warning enabled AND within the divergence validity lookback, a confirmed price pivot high is higher than its prior paired confirmed price pivot high while its paired RSI pivot high is lower; RSI uses its divergence RSI lookback and both pivots use the divergence pivot lookback
Calculation: Bullish RSI divergence recent = divergence warning enabled AND within the divergence validity lookback, a confirmed price pivot low is lower than its prior paired confirmed price pivot low while its paired RSI pivot low is higher; RSI uses its divergence RSI lookback and both pivots use the divergence pivot lookback
Calculation: Bullish CISD recent = within the CISD validity lookback, after a bullish sweep not superseded by a bearish sweep, a later close exceeded that sweep bar high; the event fires once per armed sweep and internal CISD must be enabled
Calculation: Bearish CISD recent = within the CISD validity lookback, after a bearish sweep not superseded by a bullish sweep, a later close fell below that sweep bar low; the event fires once per armed sweep and internal CISD must be enabled
Calculation: Matrix bullish tally = on T3 bars, count the true conditions EMA(close, matrix short EMA lookback) > EMA(close, matrix medium EMA lookback), EMA(close, matrix medium EMA lookback) > EMA(close, matrix long EMA lookback), EMA(close, matrix long EMA lookback) > EMA(close, matrix extra-long EMA lookback), RSI(close, matrix RSI lookback) > matrix RSI midpoint, MACD line > MACD signal, MACD histogram > zero, DMI positive DI > negative DI, MFI(hlc3, matrix MFI lookback) > matrix MFI midpoint, OBV > prior OBV, and Supertrend direction < zero; evaluate on chart bars using the current T3 result, which can still be forming in real time
Calculation: Matrix bearish tally = on T3 bars, count the true conditions EMA(close, matrix short EMA lookback) < EMA(close, matrix medium EMA lookback), EMA(close, matrix medium EMA lookback) < EMA(close, matrix long EMA lookback), EMA(close, matrix long EMA lookback) < EMA(close, matrix extra-long EMA lookback), RSI(close, matrix RSI lookback) < matrix RSI midpoint, MACD line < MACD signal, MACD histogram < zero, negative DI > positive DI, MFI(hlc3, matrix MFI lookback) < matrix MFI midpoint, OBV <= prior OBV, and Supertrend direction > zero; evaluate on chart bars using the current T3 result, which can still be forming in real time
Calculation: Matrix bullish percentage = rounded percentage of matrix bullish tally divided by max(matrix bullish tally + matrix bearish tally, denominator floor)
Calculation: Matrix bearish percentage = rounded percentage of matrix bearish tally divided by max(matrix bullish tally + matrix bearish tally, denominator floor)
Calculation: Matrix bullish support = market health enabled AND matrix bullish percentage >= matrix support threshold
Calculation: Matrix bearish support = market health enabled AND matrix bearish percentage >= matrix support threshold
Calculation: Matrix strong trend = market health enabled AND T3 ADX from DMI >= strong ADX threshold; evaluate on chart bars using the current T3 result, which can still be forming in real time
Calculation: Matrix weak trend = market health enabled AND T3 ADX from DMI < weak ADX threshold; evaluate on chart bars using the current T3 result, which can still be forming in real time
Calculation: Session score boost = expansion session score if within the London expansion or New York expansion window in the session timezone; otherwise sweep or manipulation session score if within the London sweep or New York manipulation window; otherwise Asia session score if within the Asia window; otherwise zero
Calculation: Bullish structure points = count one point each for bullish BOS recent, bullish CHOCH recent, bullish internal shift recent, bullish local trend, and bullish displacement recent
Calculation: Bearish structure points = count one point each for bearish BOS recent, bearish CHOCH recent, bearish internal shift recent, bearish local trend, and bearish displacement recent
Calculation: Bull score = max(zero, bullish local trend times local trend score weight + bullish T1 trend times T1 trend score weight + bullish T2 trend times T2 trend score weight + bullish sweep recent times bullish sweep score weight + bullish BOS recent times bullish BOS score weight + bullish CHOCH recent times bullish CHOCH score weight + bullish internal shift recent times bullish internal score weight + bullish displacement recent times bullish momentum score weight + bullish momentum confirmed times confirmed momentum score weight - bullish momentum weak times weak momentum penalty - bearish RSI divergence recent times divergence penalty - bullish IFVG recent times IFVG score weight + bullish fib zone recent times fib score weight + accepted above times acceptance score weight + rejecting lower times rejection score weight + (bullish EMA expansion ? bullish expansion score weight : EMA compression ? compression score weight : zero) + near sell-side liquidity times liquidity score weight + session score boost + matrix bullish support times matrix aligned boost - matrix bearish support times matrix opposite penalty + (matrix bullish support AND matrix strong trend ? strong technology boost : zero) - matrix weak trend times weak technology penalty)
Calculation: Bear score = max(zero, bearish local trend times local trend score weight + bearish T1 trend times T1 trend score weight + bearish T2 trend times T2 trend score weight + bearish sweep recent times bearish sweep score weight + bearish BOS recent times bearish BOS score weight + bearish CHOCH recent times bearish CHOCH score weight + bearish internal shift recent times bearish internal score weight + bearish displacement recent times bearish momentum score weight + bearish momentum confirmed times confirmed momentum score weight - bearish momentum weak times weak momentum penalty - bullish RSI divergence recent times divergence penalty - bearish IFVG recent times IFVG score weight + bearish fib zone recent times fib score weight + accepted below times acceptance score weight + rejecting higher times rejection score weight + (bearish EMA expansion ? bearish expansion score weight : EMA compression ? compression score weight : zero) + near buy-side liquidity times liquidity score weight + session score boost + matrix bearish support times matrix aligned boost - matrix bullish support times matrix opposite penalty + (matrix bearish support AND matrix strong trend ? strong technology boost : zero) - matrix weak trend times weak technology penalty)
Calculation: Bull probability = rounded percentage of bull score divided by max(bull score + bear score, denominator floor)
Calculation: Bear probability = rounded percentage of bear score divided by max(bull score + bear score, denominator floor)
Calculation: Distance okay = chasing avoidance disabled OR abs(close - EMA(close, fast EMA lookback)) <= ATR(ATR lookback) times maximum EMA distance ATR multiplier
Calculation: Bullish EMA retest held = a close crossed above EMA(close, fast EMA lookback) within the retest validity lookback AND low <= EMA(close, fast EMA lookback) AND close > EMA(close, fast EMA lookback) AND close >= open
Calculation: Bearish EMA retest held = a close crossed below EMA(close, fast EMA lookback) within the retest validity lookback AND high >= EMA(close, fast EMA lookback) AND close < EMA(close, fast EMA lookback) AND close <= open
Calculation: Bull A+ raw score = bullish T2 trend times A+ T2 weight + bullish sweep recent times A+ sweep weight + (bullish BOS recent OR bullish CHOCH recent OR bullish internal shift recent) times A+ structure weight + (bullish EMA expansion OR bullish momentum confirmed) times A+ momentum weight + (accepted above OR rejecting lower) times A+ acceptance weight + (bullish displacement recent OR bullish momentum confirmed) times A+ displacement weight + bullish EMA retest held times A+ retest weight + matrix bullish support times matrix aligned boost + (matrix bullish support AND matrix strong trend ? strong technology boost : zero) - matrix bearish support times matrix opposite penalty - matrix weak trend times weak technology penalty; clamp to the A+ score range
Calculation: Bear A+ raw score = bearish T2 trend times A+ T2 weight + bearish sweep recent times A+ sweep weight + (bearish BOS recent OR bearish CHOCH recent OR bearish internal shift recent) times A+ structure weight + (bearish EMA expansion OR bearish momentum confirmed) times A+ momentum weight + (accepted below OR rejecting higher) times A+ acceptance weight + (bearish displacement recent OR bearish momentum confirmed) times A+ displacement weight + bearish EMA retest held times A+ retest weight + matrix bearish support times matrix aligned boost + (matrix bearish support AND matrix strong trend ? strong technology boost : zero) - matrix bullish support times matrix opposite penalty - matrix weak trend times weak technology penalty; clamp to the A+ score range
Calculation: Bull A+ score = bull A+ raw score, capped at the no-sweep score cap if a sweep is required and bullish sweep recent is false, then capped at the divergence score cap if bearish RSI divergence recent, then capped at the distance score cap if distance is not okay
Calculation: Bear A+ score = bear A+ raw score, capped at the no-sweep score cap if a sweep is required and bearish sweep recent is false, then capped at the divergence score cap if bullish RSI divergence recent, then capped at the distance score cap if distance is not okay
Calculation: Bull final momentum okay = bullish momentum confirmed OR (matrix momentum confirmation enabled AND bullish displacement recent AND matrix bullish support)
Calculation: Bear final momentum okay = bearish momentum confirmed OR (matrix momentum confirmation enabled AND bearish displacement recent AND matrix bearish support)
Calculation: Bull final shift okay = final IFVG/CISD filter disabled OR bullish IFVG recent OR bullish CISD recent
Calculation: Bear final shift okay = final IFVG/CISD filter disabled OR bearish IFVG recent OR bearish CISD recent
Calculation: Bull A+ forming = A+ engine enabled AND bull A+ score >= A+ forming threshold AND bull A+ score < A+ ready threshold AND bull A+ score > bear A+ score AND NOT bullish EMA retest held
Calculation: Bear A+ forming = A+ engine enabled AND bear A+ score >= A+ forming threshold AND bear A+ score < A+ ready threshold AND bear A+ score > bull A+ score AND NOT bearish EMA retest held
Calculation: Bull A+ ready = A+ engine enabled AND bull A+ score >= A+ ready threshold AND bull A+ score > bear A+ score AND bullish EMA retest held AND (matrix support not required for A+ ready OR matrix bullish support)
Calculation: Bear A+ ready = A+ engine enabled AND bear A+ score >= A+ ready threshold AND bear A+ score > bull A+ score AND bearish EMA retest held AND (matrix support not required for A+ ready OR matrix bearish support)
Calculation: Bull B+ = NOT bull A+ ready AND NOT bull A+ forming AND bull probability >= B+ probability threshold AND bull probability > bear probability + B+ probability edge AND (bullish BOS recent OR bullish CHOCH recent OR bullish internal shift recent) AND accepted above AND (bullish momentum confirmed OR bullish EMA expansion OR matrix bullish support) AND NOT bearish RSI divergence recent
Calculation: Bear B+ = NOT bear A+ ready AND NOT bear A+ forming AND bear probability >= B+ probability threshold AND bear probability > bull probability + B+ probability edge AND (bearish BOS recent OR bearish CHOCH recent OR bearish internal shift recent) AND accepted below AND (bearish momentum confirmed OR bearish EMA expansion OR matrix bearish support) AND NOT bullish RSI divergence recent
Calculation: Bull B- = NOT bull B+ AND NOT bull A+ ready AND NOT bull A+ forming AND bull probability >= B- probability threshold AND bull probability > bear probability AND NOT accepted below AND NOT bearish RSI divergence recent
Calculation: Bear B- = NOT bear B+ AND NOT bear A+ ready AND NOT bear A+ forming AND bear probability >= B- probability threshold AND bear probability > bull probability AND NOT accepted above AND NOT bullish RSI divergence recent
Calculation: Bull scalp = bull probability >= scalp probability threshold AND bull probability < forming probability threshold AND NOT bearish EMA expansion AND NOT accepted below
Calculation: Bear scalp = bear probability >= scalp probability threshold AND bear probability < forming probability threshold AND NOT bullish EMA expansion AND NOT accepted above
Calculation: Bull forming = bull probability >= forming probability threshold AND bull probability < ready probability threshold AND NOT bearish EMA expansion
Calculation: Bear forming = bear probability >= forming probability threshold AND bear probability < ready probability threshold AND NOT bullish EMA expansion
Calculation: Bull ready = bull probability >= ready probability threshold AND bull probability < now probability threshold AND (bullish BOS recent OR bullish CHOCH recent OR bullish internal shift recent) AND NOT accepted below
Calculation: Bear ready = bear probability >= ready probability threshold AND bear probability < now probability threshold AND (bearish BOS recent OR bearish CHOCH recent OR bearish internal shift recent) AND NOT accepted above
Calculation: Bull now = bull probability >= now probability threshold AND distance okay AND accepted above AND bullish BOS recent AND bull final momentum okay AND bull final shift okay AND NOT bearish RSI divergence recent AND bull probability > bear probability + final probability edge
Calculation: Bear now = bear probability >= now probability threshold AND distance okay AND accepted below AND bearish BOS recent AND bear final momentum okay AND bear final shift okay AND NOT bullish RSI divergence recent AND bear probability > bull probability + final probability edge
Long: bullish local trend
Short: bearish local trend
Long: bullish local trend AND ((bullish T1 trend AND bullish T2 trend) OR (bearish T1 trend AND bearish T2 trend))
Short: bearish local trend AND ((bearish T1 trend AND bearish T2 trend) OR (bullish T1 trend AND bullish T2 trend))
Long: bullish structure points >= strong structure point threshold OR (bullish structure points < strong structure point threshold AND bearish structure points < strong structure point threshold AND bullish structure points >= weak structure point threshold)
Short: bullish structure points < strong structure point threshold AND (bearish structure points >= strong structure point threshold OR (bearish structure points < strong structure point threshold AND bullish structure points < weak structure point threshold AND bearish structure points >= weak structure point threshold))
Long: bullish sweep recent
Short: NOT bullish sweep recent AND bearish sweep recent
Long: bullish BOS recent
Short: NOT bullish BOS recent AND bearish BOS recent
Long: bullish CHOCH recent
Short: NOT bullish CHOCH recent AND bearish CHOCH recent
Long: accepted above OR (NOT accepted above AND NOT accepted below AND NOT rejecting higher AND rejecting lower)
Short: accepted below OR (NOT accepted above AND NOT accepted below AND rejecting higher)
Long: bullish EMA expansion
Short: bearish EMA expansion
Long: near sell-side liquidity
Short: NOT near sell-side liquidity AND near buy-side liquidity
Long: bullish fib zone recent
Short: NOT bullish fib zone recent AND bearish fib zone recent
Long: bullish momentum confirmed OR (NOT bearish momentum confirmed AND bullish momentum weak)
Short: bearish momentum confirmed OR (NOT bullish momentum confirmed AND NOT bearish momentum confirmed AND NOT bullish momentum weak AND bearish momentum weak)
Long: bullish RSI divergence recent
Short: NOT bullish RSI divergence recent AND bearish RSI divergence recent
Long: bull probability > bear probability
Short: bear probability > bull probability
Long: bull A+ score > bear A+ score
Short: bear A+ score > bull A+ score
Long: matrix bullish support
Short: NOT matrix bullish support AND matrix bearish support
Long: bull A+ ready OR bull A+ forming OR bull B+ OR bull B-
Short: NOT (bull A+ ready OR bull A+ forming OR bull B+ OR bull B-) AND (bear A+ ready OR bear A+ forming OR bear B+ OR bear B-)
Long: bull now OR bull ready OR bull forming OR bull scalp OR bull A+ forming OR bull B+ OR bull B-
Short: NOT (bull now OR bull ready OR bull forming OR bull scalp OR bull A+ forming OR bull B+ OR bull B-) AND (bear now OR bear ready OR bear forming OR bear scalp OR bear A+ forming OR bear B+ OR bear B-)
Long: bull A+ forming
Short: bear A+ forming
Long: bull A+ ready
Short: bear A+ ready
Long: bull B+
Short: bear B+
Long: bull B-
Short: bear B-
Long: bull scalp
Short: bear scalp
Long: bull forming
Short: bear forming
Long: bull ready
Short: bear ready
Long: bull now
Short: bear now
Long: bull scalp AND NOT bull scalp on the prior bar
Short: bear scalp AND NOT bear scalp on the prior bar
Long: bull forming AND NOT bull forming on the prior bar
Short: bear forming AND NOT bear forming on the prior bar
Long: bull ready AND NOT bull ready on the prior bar
Short: bear ready AND NOT bear ready on the prior bar
Long: bull now AND NOT bull now on the prior bar
Short: bear now AND NOT bear now on the prior bar
Long: (bull scalp OR bull forming OR bull ready OR bull now) AND NOT (bull scalp OR bull forming OR bull ready OR bull now on the prior bar)
Short: (bear scalp OR bear forming OR bear ready OR bear now) AND NOT (bear scalp OR bear forming OR bear ready OR bear now on the prior bar)
Long: bull A+ forming AND NOT bull A+ forming on the prior bar
Short: bear A+ forming AND NOT bear A+ forming on the prior bar
Long: bull A+ ready AND NOT bull A+ ready on the prior bar
Short: bear A+ ready AND NOT bear A+ ready on the prior bar