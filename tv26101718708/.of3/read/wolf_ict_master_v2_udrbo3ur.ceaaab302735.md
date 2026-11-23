Calculation: SessionOK = bar datetime in New York time lies within session window A OR within session window B OR within session window C
Calculation: ChopFree = ATR(short length) > ATR(long length) * chop multiple, where long length > short length
Calculation: Displaced = abs(close - open) > ATR(short length) * displacement multiple
Calculation: BullFVGGap = low > high[2] AND low - high[2] >= min FVG ticks * tick size
Calculation: BearFVGGap = high < low[2] AND low[2] - high >= min FVG ticks * tick size
Calculation: BullZones = bullish zones created on each bar where BullFVGGap holds, with zone top = low and zone bottom = high[2]; a zone is inverted on the first later bar with close < zone bottom; an inverted zone is removed on the first later bar with high > zone top; at most max zones per direction are kept, oldest removed first
Calculation: BearZones = bearish zones created on each bar where BearFVGGap holds, with zone top = low[2] and zone bottom = high; a zone is inverted on the first later bar with close > zone top; an inverted zone is removed on the first later bar with low < zone bottom; at most max zones per direction are kept, oldest removed first
Calculation: TouchBullFVG = for some tracked BullZone not inverted as of this bar, low <= zone top AND high >= zone bottom
Calculation: TouchBullIFVG = for some tracked BearZone inverted as of this bar, low <= zone top AND high >= zone bottom
Calculation: TouchBearFVG = for some tracked BearZone not inverted as of this bar, low <= zone top AND high >= zone bottom
Calculation: TouchBearIFVG = for some tracked BullZone inverted as of this bar, low <= zone top AND high >= zone bottom
Calculation: SweepHigh = most recent PivotHigh(high, sweep length, sweep length) confirmed as of this bar
Calculation: SweepLow = most recent PivotLow(low, sweep length, sweep length) confirmed as of this bar
Calculation: ChochHigh = most recent PivotHigh(high, structure pivot length, structure pivot length) confirmed as of this bar
Calculation: ChochLow = most recent PivotLow(low, structure pivot length, structure pivot length) confirmed as of this bar
Calculation: SSLSweep = low < SweepLow AND close > SweepLow AND (min(open, close) - low) / (high - low) > sweep wick fraction
Calculation: BSLSweep = high > SweepHigh AND close < SweepHigh AND (high - max(open, close)) / (high - low) > sweep wick fraction
Calculation: Trend = down if close < ChochLow; else up if close > ChochHigh AND Trend[1] is not up; else Trend[1]; none initially
Calculation: SMTBull = a PivotLow(low, SMT pivot length, SMT pivot length) is confirmed as of this bar and is below the previous confirmed PivotLow, AND (correlated instrument A low at that pivot bar > its value at the previous pivot bar OR correlated instrument B low at that pivot bar > its value at the previous pivot bar)
Calculation: SMTBear = a PivotHigh(high, SMT pivot length, SMT pivot length) is confirmed as of this bar and is above the previous confirmed PivotHigh, AND (correlated instrument A high at that pivot bar < its value at the previous pivot bar OR correlated instrument B high at that pivot bar < its value at the previous pivot bar)
Calculation: CISDBull = close > close[1] AND close[1] > close[2] AND (no prior CISD marking OR (the most recent prior CISD marking is not bullish AND bars since it >= CISD spacing))
Calculation: CISDBear = close < close[1] AND close[1] < close[2] AND (no prior CISD marking OR (the most recent prior CISD marking is not bearish AND bars since it >= CISD spacing))
Calculation: BullTrigger = (SSLSweep OR TouchBullIFVG) AND close > open AND Displaced
Calculation: BearTrigger = (BSLSweep OR TouchBearIFVG) AND close < open AND Displaced
Calculation: BullConf = number of the following that are true: BullTrigger; BarsSince(SMTBull) <= SMT recency; (close > ChochHigh OR Trend is up); (TouchBullFVG OR TouchBullIFVG); CISDBull
Calculation: BearConf = number of the following that are true: BearTrigger; BarsSince(SMTBear) <= SMT recency; (close < ChochLow OR Trend is down); (TouchBearFVG OR TouchBearIFVG); CISDBear
Long: close > ChochHigh AND Trend[1] is not up
Long: SMTBull
Long: SSLSweep
Long: close > top of a tracked BearZone not inverted as of the previous bar
Long: BullFVGGap
Long: close > high[1] AND close - open > ATR(short length) * order block multiple
Long: CISDBull
Long: BullTrigger AND BullConf >= B min confluence AND BullConf < A++ min confluence AND SessionOK AND ChopFree AND (no prior long setup OR bars since most recent prior long setup > signal cooldown)
Long: BullTrigger AND BullConf >= A++ min confluence AND SessionOK AND ChopFree AND (no prior long setup OR bars since most recent prior long setup > signal cooldown)
Long: (low < SweepLow OR TouchBullIFVG OR SMTBull) AND SessionOK AND ChopFree AND (no prior early long OR bars since most recent prior early long > early cooldown)
Short: close < ChochLow AND Trend[1] is not down
Short: SMTBear
Short: BSLSweep
Short: close < bottom of a tracked BullZone not inverted as of the previous bar
Short: BearFVGGap
Short: close < low[1] AND open - close > ATR(short length) * order block multiple
Short: CISDBear
Short: BearTrigger AND BearConf >= B min confluence AND BearConf < A++ min confluence AND SessionOK AND ChopFree AND (no prior short setup OR bars since most recent prior short setup > signal cooldown)
Short: BearTrigger AND BearConf >= A++ min confluence AND SessionOK AND ChopFree AND (no prior short setup OR bars since most recent prior short setup > signal cooldown)
Short: (high > SweepHigh OR TouchBearIFVG OR SMTBear) AND SessionOK AND ChopFree AND (no prior early short OR bars since most recent prior early short > early cooldown)