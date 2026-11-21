Calculation: GapUpRef = last completed T1 close if gap-up close-reference option, else last completed T1 high
Calculation: GapDownRef = last completed T1 close if gap-down close-reference option, else last completed T1 low
Calculation: NewT1Bar = T1 bar time != T1 bar time[1]
Long: NewT1Bar AND bullish filter on AND forming T1 open > GapUpRef
Long: bullish filter on AND forming T1 open > GapUpRef AND low < forming T1 open AND (NewT1Bar OR low[1] >= forming T1 open)
Short: NewT1Bar AND bearish filter on AND forming T1 open < GapDownRef
Short: bearish filter on AND forming T1 open < GapDownRef AND high > forming T1 open AND (NewT1Bar OR high[1] <= forming T1 open)
Exit: long, bullish filter on AND forming T1 open > GapUpRef AND low <= last completed T1 close AND (NewT1Bar OR low[1] > last completed T1 close)
Exit: short, bearish filter on AND forming T1 open < GapDownRef AND high >= last completed T1 close AND (NewT1Bar OR high[1] < last completed T1 close)