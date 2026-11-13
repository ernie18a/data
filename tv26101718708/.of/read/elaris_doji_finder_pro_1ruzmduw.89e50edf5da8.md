Calculation: Range = high - low; BodyPct = |close - open| / Range * 100 (100 if Range = 0); UpperPct = (high - max(open, close)) / Range * 100 (0 if Range = 0); LowerPct = (min(open, close) - low) / Range * 100 (0 if Range = 0)
Calculation: Dragonfly = BodyPct <= small body threshold AND LowerPct >= long-wick threshold AND UpperPct <= small-wick threshold (long-wick threshold > small-wick threshold)
Calculation: Gravestone = BodyPct <= small body threshold AND UpperPct >= long-wick threshold AND LowerPct <= small-wick threshold
Calculation: LongLegged = BodyPct <= small body threshold AND UpperPct >= long-wick threshold AND LowerPct >= long-wick threshold
Calculation: Neutral = BodyPct <= small body threshold AND NOT Dragonfly AND NOT Gravestone AND NOT LongLegged
Calculation: ATR = Wilder average true range on chart timeframe; EMA = exponential moving average of close, long-term relative to ATR/volume lookbacks; VolMA = simple moving average of volume
Calculation: SupportLevel = most recent confirmed swing low (low is the lowest among the same number of bars on each side, known only after that many later bars close); ResistanceLevel = most recent confirmed swing high (high is the highest among the same number of bars on each side, known after the same delay)
Calculation: NearSupport = SupportLevel exists AND |low - SupportLevel| <= ATR * distance factor; NearResistance = ResistanceLevel exists AND |high - ResistanceLevel| <= ATR * distance factor
Calculation: BullBias = Dragonfly OR NearSupport OR close > open; BearBias = Gravestone OR NearResistance OR close < open
Calculation: Setup, evaluated on the completed bar = (Dragonfly OR Gravestone OR LongLegged OR Neutral, each type optionally excludable) AND Range >= ATR * small fraction AND [optional volume filter: volume >= VolMA * multiplier] AND [optional S/R filter: NearSupport OR NearResistance] AND [optional trend filter: (BullBias AND close < EMA) OR (BearBias AND close > EMA) OR LongLegged]
Long: Setup AND BullBias AND NOT BearBias
Short: Setup AND BearBias AND NOT BullBias