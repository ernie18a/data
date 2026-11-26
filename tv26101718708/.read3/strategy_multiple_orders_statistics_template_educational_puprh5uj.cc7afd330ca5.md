Calculation: BullishPattern = close > open AND close > MAX(close[2], open[2]) AND low[1] < low[2] AND high[1] < high[2]
Calculation: BearishPattern = close < open AND close < MIN(close[2], open[2]) AND low[1] > low[2] AND high[1] > high[2]
Calculation: DateAllowed = NOT DateRangeOn OR (datetime >= StartDateTime AND datetime <= EndDateTime)
Long: BullishPattern AND DateAllowed AND LongsAllowed
Long: BullishPattern AND NOT BullishPattern[1]
Short: BearishPattern AND DateAllowed AND ShortsAllowed
Short: BearishPattern AND NOT BearishPattern[1]
Exit: long, low < low[bars since long entry 1] * (1 - StopPercent1) OR high > high[bars since long entry 1] * (1 + TargetPercent1)
Exit: long, low < low[bars since long entry 2] * (1 - StopPercent2) OR high > high[bars since long entry 2] * (1 + TargetPercent2)
Exit: long, low < low[bars since long entry 3] * (1 - StopPercent3) OR high > high[bars since long entry 3] * (1 + TargetPercent3)
Exit: long, low < low[bars since long entry 4] * (1 - StopPercent4) OR high > high[bars since long entry 4] * (1 + TargetPercent4)
Exit: short, high > high[bars since short entry 1] * (1 + StopPercent1) OR low < low[bars since short entry 1] * (1 - TargetPercent1)
Exit: short, high > high[bars since short entry 2] * (1 + StopPercent2) OR low < low[bars since short entry 2] * (1 - TargetPercent2)
Exit: short, high > high[bars since short entry 3] * (1 + StopPercent3) OR low < low[bars since short entry 3] * (1 - TargetPercent3)
Exit: short, high > high[bars since short entry 4] * (1 + StopPercent4) OR low < low[bars since short entry 4] * (1 - TargetPercent4)