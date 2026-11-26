Calculation: AverageRange(Tn) = SMA(high - low, average range lookback, Tn, last completed bar), taken on chart bars
Calculation: TfHigh(Tn) = high(Tn, still forming bar), taken on chart bars
Calculation: TfLow(Tn) = low(Tn, still forming bar), taken on chart bars
Calculation: BullBlock = zone of the bar at the smallest offset from search start to search end whose close is below its open (offset 0 if none), top = high and bottom = low of that bar, created on a bar where ROC(open, momentum lookback) crosses above threshold and more than spacing bars have passed since the previous crossing above threshold or below negative threshold, removed on the first bar where mitigation price is below bottom, mitigation price = close[1] or low chosen by the mitigation parameter
Calculation: BearBlock = zone of the bar at the smallest offset from search start to search end whose close is above its open (offset 0 if none), top = high and bottom = low of that bar, created on a bar where ROC(open, momentum lookback) crosses below negative threshold and more than spacing bars have passed since the previous crossing above threshold or below negative threshold, removed on the first bar where mitigation price is above top, mitigation price = close[1] or high chosen by the mitigation parameter
Long: low < top of any BullBlock not removed through the current bar
Short: high > bottom of any BearBlock not removed through the current bar
Exit: long, high > TfLow(T1) + AverageRange(T1) AND low < TfLow(T1) + AverageRange(T1)
Exit: long, high > TfLow(T2) + AverageRange(T2) AND low < TfLow(T2) + AverageRange(T2)
Exit: long, high > TfLow(T3) + AverageRange(T3) AND low < TfLow(T3) + AverageRange(T3)
Exit: long, high > TfLow(T4) + AverageRange(T4) AND low < TfLow(T4) + AverageRange(T4)
Exit: short, low < TfHigh(T1) - AverageRange(T1) AND high > TfLow(T1) + AverageRange(T1)
Exit: short, low < TfHigh(T2) - AverageRange(T2) AND high > TfHigh(T2) - AverageRange(T2)
Exit: short, low < TfHigh(T3) - AverageRange(T3) AND high > TfHigh(T3) - AverageRange(T3)
Exit: short, low < TfHigh(T4) - AverageRange(T4) AND high > TfLow(T4) + AverageRange(T4)