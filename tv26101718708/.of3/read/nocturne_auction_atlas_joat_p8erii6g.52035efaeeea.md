Calculation: BuyShare = clamp(base share + close-position weight * (close - low) / range + body weight * abs(close - open) / range + bullish-bar weight * [close >= open], share floor, share cap), where range = max(high - low, tick size)
Calculation: CVD = running sum over all bars of volume * (2 * BuyShare - 1), restarted at the first bar of each session
Calculation: DeltaImpulse = (EMA(CVD, shorter lookback) - EMA(CVD, longer lookback)) / max(abs(EMA(CVD, longer lookback)), volume), or 0 if EMA(CVD, longer lookback) = 0
Calculation: VWAP = sum((high + low + close) / 3 * volume) / sum(volume), summed over session bars from session start
Calculation: VWAPDistance = clamp((close - VWAP) / ATR(ATR length), -distance cap, distance cap), or 0 if ATR(ATR length) is not positive
Calculation: ProfileRows = volume profile of the last min(session bars so far including current bar, profile lookback) bars, splitting the range from their lowest low to highest high into profile row count equal rows; each bar adds its volume to the row containing its (high + low + close) / 3, clamped to the first or last row, and adds volume * BuyShare to that row's buy volume
Calculation: POC = midpoint of the ProfileRows row with the largest total volume (lowest such row on ties)
Calculation: VAL = lower edge of the volume-profile value area of ProfileRows (value-area share of total volume)
Calculation: VAH = upper edge of the same value area
Calculation: ProfileImbalance = (2 * sum of row buy volume - sum of row volume) / sum of row volume, or 0 if sum of row volume is 0
Calculation: BidShelfStrength = max(0, max over ProfileRows of (2 * row buy volume - row volume) / max row volume)
Calculation: AskShelfStrength = max(0, max over ProfileRows of (row volume - 2 * row buy volume) / max row volume)
Calculation: ValueTolerance = max(ATR(ATR length) * tolerance multiplier, tick size * tick multiplier)
Calculation: WidthScore = tight width score if (VAH - VAL) / ATR(ATR length) <= tight width limit, else moderate width score if <= moderate width limit, else 0
Calculation: BullDivergence = on a bar where a pivot low of low and a pivot low of CVD, both with pivot left bars and pivot right bars, are confirmed, the price pivot low is below the previous price pivot low AND the CVD pivot low is above the previous CVD pivot low, where previous = last bar on which both pivot lows were confirmed
Calculation: BearDivergence = on a bar where a pivot high of high and a pivot high of CVD, both with pivot left bars and pivot right bars, are confirmed, the price pivot high is above the previous price pivot high AND the CVD pivot high is below the previous CVD pivot high, where previous = last bar on which both pivot highs were confirmed
Calculation: BidScore = clamp(base score + bid location score + clamp(BidShelfStrength * shelf score scale, 0, shelf score cap) + clamp((DeltaImpulse - impulse threshold) * delta score scale, 0, delta score cap) + (BullDivergence ? divergence score : 0) + WidthScore + max(ProfileImbalance, 0) * imbalance score scale, 0, 100), where bid location score = location full score if close > VWAP, else location partial score if close > POC, else 0
Calculation: AskScore = clamp(base score + ask location score + clamp(AskShelfStrength * shelf score scale, 0, shelf score cap) + clamp((-DeltaImpulse - impulse threshold) * delta score scale, 0, delta score cap) + (BearDivergence ? divergence score : 0) + WidthScore + max(-ProfileImbalance, 0) * imbalance score scale, 0, 100), where ask location score = location full score if close < VWAP, else location partial score if close < POC, else 0
Calculation: CooldownReady = no earlier bar had LongEntry or ShortEntry true, OR bars since the last such bar > signal cooldown
Calculation: LongEntry = inside active session AND close > VWAP AND close >= VAL AND close <= upper VWAP band(outer sigma multiplier) AND EMA(CVD, shorter lookback) > EMA(CVD, longer lookback) AND DeltaImpulse > impulse threshold AND BidScore >= quality gate AND BidScore > AskScore AND ((close > POC AND close[1] <= POC) OR (low <= VAL + ValueTolerance AND close > VAL AND close > open) OR BullDivergence OR BidShelfStrength > shelf gate) AND CooldownReady
Calculation: ShortEntry = inside active session AND close < VWAP AND close <= VAH AND close >= lower VWAP band(outer sigma multiplier) AND EMA(CVD, shorter lookback) < EMA(CVD, longer lookback) AND DeltaImpulse < -impulse threshold AND AskScore >= quality gate AND AskScore > BidScore AND ((close < POC AND close[1] >= POC) OR (high >= VAH - ValueTolerance AND close < VAH AND close < open) OR BearDivergence OR AskShelfStrength > shelf gate) AND CooldownReady
Long: LongEntry
Short: ShortEntry
Exit: long, BearDivergence OR close < VWAP OR close < POC
Exit: short, BullDivergence OR close > VWAP OR close > POC
Long: BullDivergence
Short: BearDivergence
Long: (bias center + bias skew weight * ProfileImbalance + bias distance weight * VWAPDistance) >= bias threshold AND NOT ShortEntry
Short: (bias center - bias skew weight * ProfileImbalance - bias distance weight * VWAPDistance) >= bias threshold AND NOT LongEntry