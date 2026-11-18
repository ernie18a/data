Calculation: Pivot = (high(T1, last completed bar) + low(T1, last completed bar) + close(T1, last completed bar)) / 3
Calculation: LongEntryLevel = Pivot + metric × instrument point size
Calculation: ShortEntryLevel = Pivot − metric × instrument point size
Calculation: LowerOuterLevel = Pivot − 2 × metric × instrument point size
Calculation: LongExitLevel = max(close(T1, last completed bar) + 1.1 × (high(T1, last completed bar) − low(T1, last completed bar)) / 2, LowerOuterLevel − 20 × instrument point size)
Calculation: ShortExitLevel = min(close(T1, last completed bar) − 1.1 × (high(T1, last completed bar) − low(T1, last completed bar)) / 2, LowerOuterLevel − 20 × instrument point size)
Long: close crosses above LongEntryLevel AND hour(datetime) is between StartFromHour and EndToHour inclusive AND no position is open AND no entry has been made on the current chart bar
Short: close crosses below ShortEntryLevel AND hour(datetime) is between StartFromHour and EndToHour inclusive AND no position is open AND no entry has been made on the current chart bar
Exit: long, low <= ShortEntryLevel OR high >= LongExitLevel OR hour(datetime) is before StartFromHour or after EndToHour
Exit: short, high >= LongEntryLevel OR low <= ShortExitLevel OR hour(datetime) is before StartFromHour or after EndToHour