Calculation: Risk = ATR(ATR length) * point scale * (scalp stop multiplier if chart timeframe is T2, T3 or T4, else stop multiplier)
Calculation: Spacing = swing length * (scalp cooldown multiplier if chart timeframe is T2, T3 or T4, else cooldown multiplier)
Calculation: SwingHigh(k) = High of the k-th most recent confirmed PivotHigh(High, swing length, swing length), where k = 1 is the latest
Calculation: SwingLow(k) = Low of the k-th most recent confirmed PivotLow(Low, swing length, swing length), where k = 1 is the latest
Calculation: BullStructure = SwingHigh(1) > SwingHigh(2) AND SwingHigh(2) > SwingHigh(3) AND SwingLow(1) > SwingLow(2) AND SwingLow(2) > SwingLow(3)
Calculation: BearStructure = SwingHigh(1) less than SwingHigh(2) AND SwingHigh(2) less than SwingHigh(3) AND SwingLow(1) less than SwingLow(2) AND SwingLow(2) less than SwingLow(3)
Calculation: UpBreak = Close crosses above SwingHigh(2)
Calculation: DownBreak = Close crosses below SwingLow(2)
Calculation: UpRetest = (UpBreak on this bar OR UpBreak on an earlier bar with no UpRetest since) AND Low ≤ SwingHigh(2) * (1 + tolerance) AND Close > SwingHigh(2)
Calculation: DownRetest = (DownBreak on this bar OR DownBreak on an earlier bar with no DownRetest since) AND High ≥ SwingLow(2) * (1 - tolerance) AND Close less than SwingLow(2)
Calculation: LiquiditySweep = (High > Highest(High, sweep lookback)[1] AND Close less than Highest(High, sweep lookback)[1]) OR (Low less than Lowest(Low, sweep lookback)[1] AND Close > Lowest(Low, sweep lookback)[1])
Calculation: Imbalance = (Low > High[2] AND Close[1] > High[2]) OR (High less than Low[2] AND Close[1] less than Low[2])
Calculation: LargeBody = ABS(Close - Open) > body multiplier * SMA(ABS(Close - Open), body lookback)
Calculation: SupplyBand = band from p * (1 - tolerance) to p * (1 + tolerance), for a confirmed swing high p that is not inside an earlier SupplyBand, where at least zone touches confirmed swing highs (counted from p onward, including p) lie inside the band
Calculation: DemandBand = band from p * (1 - tolerance) to p * (1 + tolerance), for a confirmed swing low p that is not inside an earlier DemandBand, where at least zone touches confirmed swing lows (counted from p onward, including p) lie inside the band
Calculation: Confirmations = number of the following that are true: (BullStructure OR BearStructure); LiquiditySweep; LargeBody; Imbalance; (UpBreak OR DownBreak); (UpRetest OR DownRetest); ((RSI(Close, RSI length) > RSI upper threshold) AND BullStructure) OR ((RSI(Close, RSI length) less than RSI lower threshold) AND BearStructure); (Close inside a SupplyBand OR Close inside a DemandBand); Risk > 0
Calculation: SignalFlat = the Long or Short condition has not held on any bar after the last bar with Confirmations less than minimum confirmations - exit margin
Calculation: LossStreakReached = count of trades closed by stop in a row, since the last trade closed by target or the start of the current calendar day, is at least max losses
Calculation: SessionAllowed = session filter off OR (bar time in session time zone is on a weekday AND (within session window 1 OR within session window 2))
Long: Confirmations >= minimum confirmations AND BullStructure AND UpBreak AND SignalFlat AND NOT LossStreakReached AND SessionAllowed AND (no earlier bar on which this condition held OR bars since the last such bar > Spacing)
Long: BullStructure
Long: UpBreak
Long: a swing high is confirmed on this bar AND SwingHigh(1) > SwingHigh(2)
Long: a swing low is confirmed on this bar AND SwingLow(1) > SwingLow(2)
Long: EMA(Close, shorter EMA length) > EMA(Close, longer EMA length)
Long: RSI(Close, RSI length) > RSI midline
Long: Close > VWAP(HLC3 on chart bars, reset at the start of each T1 bar)
Short: Confirmations >= minimum confirmations AND BearStructure AND DownBreak AND SignalFlat AND NOT LossStreakReached AND SessionAllowed AND (no earlier bar on which this condition held OR bars since the last such bar > Spacing)
Short: BearStructure
Short: DownBreak
Short: a swing high is confirmed on this bar AND SwingHigh(1) ≤ SwingHigh(2)
Short: a swing low is confirmed on this bar AND SwingLow(1) ≤ SwingLow(2)
Short: EMA(Close, shorter EMA length) ≤ EMA(Close, longer EMA length)
Short: RSI(Close, RSI length) ≤ RSI midline
Short: Close ≤ VWAP(HLC3 on chart bars, reset at the start of each T1 bar)
Exit: long, Low ≤ entry price - Risk on the entry bar
Exit: long, High ≥ entry price + target multiple * Risk on the entry bar AND Low > entry price - Risk on the entry bar
Exit: long, Confirmations less than minimum confirmations - exit margin
Exit: short, High ≥ entry price + Risk on the entry bar
Exit: short, Low ≤ entry price - target multiple * Risk on the entry bar AND High less than entry price + Risk on the entry bar
Exit: short, Confirmations less than minimum confirmations - exit margin