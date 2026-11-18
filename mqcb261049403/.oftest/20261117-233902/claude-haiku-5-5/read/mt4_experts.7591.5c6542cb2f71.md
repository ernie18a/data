Calculation: upper entry level = ClassicPivot(T1, last completed bar) + entry offset * point
Calculation: lower entry level = ClassicPivot(T1, last completed bar) - entry offset * point
Calculation: upper target = MAX(Camarilla R4(T1, last completed bar, range factor), ClassicPivot(T1, last completed bar) - (outer multiple * entry offset + clamp offset) * point)
Calculation: lower target = MIN(Camarilla S4(T1, last completed bar, range factor), ClassicPivot(T1, last completed bar) - (outer multiple * entry offset + clamp offset) * point)
Calculation: long stop = IF(Highest(close, since entry) - trail offset * point > entry price, Highest(close, since entry) - trail offset * point, lower entry level)
Calculation: short stop = IF(entry price > Lowest(close, since entry) + trail offset * point, Lowest(close, since entry) + trail offset * point, upper entry level)
Long: Close crosses above upper entry level AND position side is flat AND Hour(datetime) >= session start hour AND Hour(datetime) <= session end hour
Short: Close crosses below lower entry level AND position side is flat AND Hour(datetime) >= session start hour AND Hour(datetime) <= session end hour
Exit: long, Low <= long stop OR High >= upper target OR Hour(datetime) < session start hour OR Hour(datetime) > session end hour
Exit: short, High >= short stop OR Low <= lower target OR Hour(datetime) < session start hour OR Hour(datetime) > session end hour