Calculation: UpPivot = high[1] < high[2] < ... < high[W+1] > high[W+2] > ... > high[2W+1] AND volume[W+1] > SMA(volume, V)[W+1], on T1 bars using the last completed T1 bar
Calculation: ResistanceLevel = high[W+1] if UpPivot, else ResistanceLevel[1], on T1 bars using the last completed T1 bar
Calculation: ResistanceZoneBottom = max(open[W+1], close[W+1]) if UpPivot, else ResistanceZoneBottom[1], on T1 bars using the last completed T1 bar
Calculation: DownPivot = low[1] > low[2] > ... > low[W+1] < low[W+2] < ... < low[2W+1] AND volume[W+1] > SMA(volume, V)[W+1], on T1 bars using the last completed T1 bar
Calculation: SupportLevel = low[W+1] if DownPivot, else SupportLevel[1], on T1 bars using the last completed T1 bar
Calculation: SupportZoneTop = min(open[W+1], close[W+1]) if DownPivot, else SupportZoneTop[1], on T1 bars using the last completed T1 bar
Long: close crosses above ResistanceLevel
Long: close crosses below ResistanceLevel
Long: close crosses below SupportZoneTop
Short: close crosses above ResistanceZoneBottom
Short: close crosses above SupportLevel
Short: close crosses below SupportLevel