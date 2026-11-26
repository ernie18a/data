Calculation: NYMinute = minutes since midnight in NY time of the bar datetime
Calculation: KillZoneOK = NOT KZ_FILTER OR (NYMinute >= KZ_START AND NYMinute < KZ_END)
Calculation: InAsia = NYMinute >= ASIA_START OR NYMinute < ASIA_END
Calculation: InLondon = NYMinute >= LON_START AND NYMinute < LON_END
Calculation: InNY = NYMinute >= NY_START AND NYMinute < NY_END
Calculation: LondonOpen = InLondon AND NOT InLondon[1]
Calculation: LondonHighSwept = (InLondon AND high > highest high of the most recent completed InAsia session) OR (LondonHighSwept[1] AND NOT LondonOpen)
Calculation: LondonLowSwept = (InLondon AND low < lowest low of the most recent completed InAsia session) OR (LondonLowSwept[1] AND NOT LondonOpen)
Calculation: LondonBullManip = LondonLowSwept AND NOT LondonHighSwept
Calculation: LondonBearManip = LondonHighSwept AND NOT LondonLowSwept
Calculation: SwingHigh = last non-na value of PIVOTHIGH(high, PIVOT_LEN, PIVOT_LEN)
Calculation: SwingLow = last non-na value of PIVOTLOW(low, PIVOT_LEN, PIVOT_LEN)
Calculation: BSLSwept = high > SwingHigh AND close < SwingHigh
Calculation: BSLJust = BSLSwept AND NOT BSLSwept[1]
Calculation: SSLSwept = low < SwingLow AND close > SwingLow
Calculation: SSLJust = SSLSwept AND NOT SSLSwept[1]
Calculation: BOSBull = close > SwingHigh AND close[1] <= SwingHigh
Calculation: BOSBear = close < SwingLow AND close[1] >= SwingLow
Calculation: MarketDirection = -1 if BOSBear, else 1 if BOSBull, else MarketDirection[1], initially 0
Calculation: BullFVGAge(X) = BARSSINCE(low > high[2] AND low - high[2] >= MIN_GAP, X, last completed bar)
Calculation: BearFVGAge(X) = BARSSINCE(high < low[2] AND low[2] - high >= MIN_GAP, X, last completed bar)
Calculation: BullRecent(X) = BullFVGAge(X) <= LOOKBACK
Calculation: BearRecent(X) = BearFVGAge(X) <= LOOKBACK
Calculation: BullZoneTop(X) = VALUEWHEN(low > high[2] AND low - high[2] >= MIN_GAP, low, 0, X, last completed bar)
Calculation: BullZoneBottom(X) = VALUEWHEN(low > high[2] AND low - high[2] >= MIN_GAP, high[2], 0, X, last completed bar)
Calculation: BearZoneTop(X) = VALUEWHEN(high < low[2] AND low[2] - high >= MIN_GAP, low[2], 0, X, last completed bar)
Calculation: BearZoneBottom(X) = VALUEWHEN(high < low[2] AND low[2] - high >= MIN_GAP, high, 0, X, last completed bar)
Calculation: BullRetest = BullRecent(T3) AND close >= BullZoneBottom(T3) AND close <= BullZoneTop(T3)
Calculation: BearRetest = BearRecent(T3) AND close <= BearZoneTop(T3) AND close >= BearZoneBottom(T3)
Calculation: BullInvalid = BullRecent(T3) AND close < BullZoneBottom(T3)
Calculation: BearInvalid = BearRecent(T3) AND close > BearZoneTop(T3)
Calculation: BullInvalidJust = BullInvalid AND NOT BullInvalid[1]
Calculation: BearInvalidJust = BearInvalid AND NOT BearInvalid[1]
Calculation: BullScore = number of true values among BullRecent(T1) through BullRecent(T10)
Calculation: BearScore = number of true values among BearRecent(T1) through BearRecent(T10)
Calculation: ScoreHot = MAX(BullScore, BearScore) >= SCORE_THRESHOLD
Calculation: BullSeq = BullRecent(T2) AND BullRecent(T3) AND BullFVGAge(T2) >= BullFVGAge(T3)
Calculation: BearSeq = BearRecent(T2) AND BearRecent(T3) AND BearFVGAge(T2) >= BearFVGAge(T3)
Calculation: BullHTF = (BullFVGAge(T5) <= HTF_RECENCY OR BullFVGAge(T6) <= HTF_RECENCY) AND (BullRecent(T7) OR BullRecent(T8))
Calculation: BearHTF = (BearFVGAge(T5) <= HTF_RECENCY OR BearFVGAge(T6) <= HTF_RECENCY) AND (BearRecent(T7) OR BearRecent(T8))
Calculation: GradeBBull = KillZoneOK AND ScoreHot AND BullSeq AND NOT BullRetest AND BullScore > BearScore
Calculation: GradeBBear = KillZoneOK AND ScoreHot AND BearSeq AND NOT BearRetest AND BearScore > BullScore
Calculation: BullEntryAvailable = (BullZoneTop(T3) != BullZoneTop(T3)[1]) OR BullInvalidJust OR (BullEntryAvailable[1] AND NOT LongEntry[1]), initially true
Calculation: BearEntryAvailable = (BearZoneTop(T3) != BearZoneTop(T3)[1]) OR BearInvalidJust OR (BearEntryAvailable[1] AND NOT ShortEntry[1]), initially true
Calculation: LongEntry = KillZoneOK AND ScoreHot AND BullRetest AND NOT BullRetest[1] AND BullScore > BearScore AND (NOT SESSION_FILTER OR NOT InNY OR NOT LondonBearManip) AND (NOT STRUCT_FILTER OR MarketDirection >= 0) AND BullEntryAvailable
Calculation: ShortEntry = KillZoneOK AND ScoreHot AND BearRetest AND NOT BearRetest[1] AND BearScore > BullScore AND (NOT SESSION_FILTER OR NOT InNY OR NOT LondonBullManip) AND (NOT STRUCT_FILTER OR MarketDirection <= 0) AND BearEntryAvailable
Long: LongEntry AND BullSeq
Long: LongEntry AND NOT BullSeq
Long: GradeBBull AND NOT GradeBBull[1] AND BullEntryAvailable
Long: BullHTF AND NOT BullHTF[1]
Long: BOSBull AND MarketDirection[1] = -1
Long: SSLJust
Long: SSLJust AND KillZoneOK
Long: LondonBullManip
Long: InNY AND NOT InNY[1] AND LondonBullManip
Short: ShortEntry AND BearSeq
Short: ShortEntry AND NOT BearSeq
Short: GradeBBear AND NOT GradeBBear[1] AND BearEntryAvailable
Short: BearHTF AND NOT BearHTF[1]
Short: BOSBear AND MarketDirection[1] = 1
Short: BSLJust
Short: BSLJust AND KillZoneOK
Short: LondonBearManip
Short: InNY AND NOT InNY[1] AND LondonBearManip
Exit: long, BullInvalidJust
Exit: short, BearInvalidJust