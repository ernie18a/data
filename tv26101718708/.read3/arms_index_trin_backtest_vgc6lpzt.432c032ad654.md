Calculation: ratio = (advancing issues close(T1, bar still forming, sampled on chart bars) / declining issues close(T1, bar still forming, sampled on chart bars)) / (advancing volume close(T1, bar still forming, sampled on chart bars) / declining volume close(T1, bar still forming, sampled on chart bars))
Calculation: direction state = short if ratio > upper threshold, long if ratio < lower threshold, otherwise previous direction state (initially neutral)
Long: (reverse disabled AND direction state is long) OR (reverse enabled AND direction state is short)
Short: (reverse disabled AND direction state is short) OR (reverse enabled AND direction state is long)
Long: Arms Index on T1 < lower threshold when trade reversal is disabled OR Arms Index on T1 > upper threshold when trade reversal is enabled
Short: Arms Index on T1 > upper threshold when trade reversal is disabled OR Arms Index on T1 < lower threshold when trade reversal is enabled