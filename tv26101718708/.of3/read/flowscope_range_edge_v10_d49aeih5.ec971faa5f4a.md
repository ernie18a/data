Calculation: InSession = bar datetime is within session_window in session_tz
Calculation: AutoSize = Highest(high, auto_lookback)[1] - Lowest(low, auto_lookback)[1]
Calculation: RangeTop = MAX(manual_high, manual_low) if use_manual, else Highest(high, auto_lookback)[1] if use_auto AND AutoSize >= min_range AND AutoSize <= max_range, else NA
Calculation: RangeBottom = MIN(manual_high, manual_low) if use_manual, else Lowest(low, auto_lookback)[1] if use_auto AND AutoSize >= min_range AND AutoSize <= max_range, else NA
Calculation: ValidRange = InSession AND RangeTop - RangeBottom >= min_range AND RangeTop - RangeBottom <= max_range
Calculation: EdgeZone = MIN(MAX(ATR(atr_length) * edge_mult, min_edge), max_edge)
Calculation: TouchesTop = high >= RangeTop - EdgeZone AND low <= RangeTop + EdgeZone
Calculation: TouchesBottom = high >= RangeBottom - EdgeZone AND low <= RangeBottom + EdgeZone
Calculation: BottomRejection = ValidRange AND TouchesBottom AND low <= RangeBottom AND close > RangeBottom AND close > open
Calculation: TopRejection = ValidRange AND TouchesTop AND high >= RangeTop AND close < RangeTop AND close < open
Calculation: LongSetup = (BottomRejection OR LongSetup[1]) AND NOT TopRejection AND NOT LongReversal
Calculation: LongSetupBarHigh = high if BottomRejection, else LongSetupBarHigh[1]
Calculation: LongReversal = InSession AND LongSetup[1] AND high > LongSetupBarHigh[1]
Calculation: ShortSetup = (TopRejection OR ShortSetup[1]) AND NOT BottomRejection AND NOT ShortReversal
Calculation: ShortSetupBarLow = low if TopRejection, else ShortSetupBarLow[1]
Calculation: ShortReversal = InSession AND ShortSetup[1] AND low < ShortSetupBarLow[1]
Calculation: UpBreak = ValidRange AND close > RangeTop + break_buffer AND close[1] <= RangeTop + break_buffer
Calculation: DownBreak = ValidRange AND close < RangeBottom - break_buffer AND close[1] >= RangeBottom - break_buffer
Calculation: UpBreakOpen = (UpBreak OR (UpBreakOpen[1] AND NOT DownBreak)) AND NOT UpExpired AND NOT LongCont
Calculation: UpHeldPre = ((UpBreak OR (UpBreakOpen[1] AND NOT DownBreak)) AND Lowest(close, hold_bars) > RangeTop) OR (UpHeld[1] AND NOT UpBreak AND NOT DownBreak)
Calculation: UpHeld = UpHeldPre AND NOT UpExpired AND NOT LongCont
Calculation: UpRetest = ValidRange AND UpHeldPre AND TouchesTop AND close > RangeTop AND close > open
Calculation: UpRetestArmed = (UpRetest OR (UpRetestArmed[1] AND NOT UpBreak AND NOT DownBreak)) AND NOT LongCont
Calculation: UpRetestBarHigh = high if UpRetest, else UpRetestBarHigh[1]
Calculation: UpExpired = BarsSince(UpBreak) > retest_timeout AND NOT UpRetestArmed[1] AND NOT UpRetest
Calculation: VolumeOK = NOT require_volume OR (SMA(volume, vol_length) > 0 AND volume / SMA(volume, vol_length) >= elevated_volume)
Calculation: LongCont = InSession AND UpRetestArmed[1] AND high > UpRetestBarHigh[1] AND VolumeOK
Calculation: DownBreakOpen = (DownBreak OR (DownBreakOpen[1] AND NOT UpBreak)) AND NOT DownExpired AND NOT ShortCont
Calculation: DownHeldPre = ((DownBreak OR (DownBreakOpen[1] AND NOT UpBreak)) AND Highest(close, hold_bars) < RangeBottom) OR (DownHeld[1] AND NOT UpBreak AND NOT DownBreak)
Calculation: DownHeld = DownHeldPre AND NOT DownExpired AND NOT ShortCont
Calculation: DownRetest = ValidRange AND DownHeldPre AND TouchesBottom AND close < RangeBottom AND close < open
Calculation: DownRetestArmed = (DownRetest OR (DownRetestArmed[1] AND NOT UpBreak AND NOT DownBreak)) AND NOT ShortCont
Calculation: DownRetestBarLow = low if DownRetest, else DownRetestBarLow[1]
Calculation: DownExpired = BarsSince(DownBreak) > retest_timeout AND NOT DownRetestArmed[1] AND NOT DownRetest
Calculation: ShortCont = InSession AND DownRetestArmed[1] AND low < DownRetestBarLow[1] AND VolumeOK
Long: BottomRejection
Long: LongReversal
Long: UpBreak
Long: UpRetest
Long: LongCont
Short: TopRejection
Short: ShortReversal
Short: DownBreak
Short: DownRetest
Short: ShortCont