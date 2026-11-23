Calculation: SwingDir = 0 if high[structure lookback] > Highest(high, structure lookback); else 1 if low[structure lookback] < Lowest(low, structure lookback); else SwingDir[1]
Calculation: SwingHigh = high[structure lookback] if SwingDir = 0 AND SwingDir[1] != 0; else SwingHigh[1]
Calculation: SwingLow = low[structure lookback] if SwingDir = 1 AND SwingDir[1] != 1; else SwingLow[1]
Calculation: Regime = 0 if close < SwingLow for the first time since SwingLow was set; else 1 if close > SwingHigh for the first time since SwingHigh was set; else Regime[1]
Calculation: RunHigh = high if Regime != Regime[1]; else max(high, RunHigh[1])
Calculation: RunLow = low if Regime != Regime[1]; else min(low, RunLow[1])
Calculation: HighSweep = Regime, Regime[1] and Regime[2] all equal 1 AND high > RunHigh[1] AND close < RunHigh[1] AND high[1] <= RunHigh[2]
Calculation: LowSweep = Regime, Regime[1] and Regime[2] all equal 0 AND low < RunLow[1] AND close > RunLow[1] AND low[1] >= RunLow[2]
Calculation: InWindow = session filter not enabled OR bar datetime within session window
Calculation: HighLevel = RunHigh[1] if HighSweep; na if BullSetup; else HighLevel[1]
Calculation: LowLevel = RunLow[1] if LowSweep; na if BearSetup; else LowLevel[1]
Calculation: BullSetup = InWindow AND NOT HighSweep AND close > HighLevel[1]
Calculation: BearSetup = InWindow AND NOT LowSweep AND close < LowLevel[1]
Calculation: LongTest = close or low, per execution mode
Calculation: ShortTest = close or high, per execution mode
Calculation: Pending {side, trigger, stop} = {bull, high, Lowest(low, structure lookback) or min(low, HighLevel[1]), per stop placement mode} if BullSetup; {bear, low, Highest(high, structure lookback) or max(high, LowLevel[1]), per stop placement mode} if BearSetup; none if LongEntry OR ShortEntry OR (Pending[1].side is bull AND LongTest < Pending[1].stop) OR (Pending[1].side is bear AND ShortTest > Pending[1].stop); else Pending[1]
Calculation: LongEntry = Pending[1].side is bull AND NOT (BullSetup OR BearSetup) AND close > Pending[1].trigger AND LongTest >= Pending[1].stop
Calculation: ShortEntry = Pending[1].side is bear AND NOT (BullSetup OR BearSetup) AND close < Pending[1].trigger AND ShortTest <= Pending[1].stop
Calculation: EntryStop = Pending[1].stop if LongEntry OR ShortEntry; else EntryStop[1]
Calculation: Trend = long if LongEntry; else short if ShortEntry; else flat if (Trend[1] = long AND LongTest < EntryStop[1]) OR (Trend[1] = short AND ShortTest > EntryStop[1]); else Trend[1]
Long: LongEntry AND position side is not long
Short: ShortEntry AND position side is not short
Exit: long, LongTest < EntryStop
Exit: short, ShortTest > EntryStop
Long: Trend(T1 bars, last completed bar) = long
Long: Trend(T2 bars, last completed bar) = long
Long: Trend(T3 bars, last completed bar) = long
Long: Trend(T4 bars, last completed bar) = long
Short: Trend(T1 bars, last completed bar) = short
Short: Trend(T2 bars, last completed bar) = short
Short: Trend(T3 bars, last completed bar) = short
Short: Trend(T4 bars, last completed bar) = short