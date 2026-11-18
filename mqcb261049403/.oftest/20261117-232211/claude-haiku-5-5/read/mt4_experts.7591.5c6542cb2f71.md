Calculation: Pivot = (High(T1, last completed bar) + Low(T1, last completed bar) + Close(T1, last completed bar)) / 3
Calculation: UpLevel = Pivot + offset
Calculation: DownLevel = Pivot - offset
Calculation: OuterLow = Pivot - 2 * offset
Calculation: LongTarget = MAX(Close(T1, last completed bar) + (High(T1, last completed bar) - Low(T1, last completed bar)) * multiplier, OuterLow - floor)
Calculation: ShortTarget = MIN(Close(T1, last completed bar) - (High(T1, last completed bar) - Low(T1, last completed bar)) * multiplier, OuterLow - floor)
Calculation: LongStop = IF highest close of bars since entry up to previous bar > entry price + trail distance THEN MAX(DownLevel[bars since entry], highest close of bars since entry up to previous bar - trail distance) ELSE DownLevel[bars since entry]
Calculation: ShortStop = IF lowest close of bars since entry up to previous bar < entry price - trail distance THEN MIN(UpLevel[bars since entry], lowest close of bars since entry up to previous bar + trail distance) ELSE UpLevel[bars since entry]
Long: position side is flat AND hour of datetime >= start hour AND hour of datetime <= end hour AND Close crosses above UpLevel
Short: position side is flat AND hour of datetime >= start hour AND hour of datetime <= end hour AND Close crosses below DownLevel
Exit: long, Low <= LongStop OR High >= LongTarget
Exit: long, hour of datetime < start hour OR hour of datetime > end hour
Exit: short, High >= ShortStop OR Low <= ShortTarget
Exit: short, hour of datetime < start hour OR hour of datetime > end hour