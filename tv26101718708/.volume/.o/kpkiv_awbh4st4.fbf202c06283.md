Calculation: Intrinsic value = max(0, Call ? spotHigh − strikePrice : strikePrice − spotLow)
Calculation: Rₙ = Intrinsic value + n × step, for n = 1…7
Long: (close > Rₙ AND previous close ≤ previous Rₙ) for any n = 1…6
Exit: Long, high ≥ the stored target Rₙ₊₁ for the smallest crossed n at entry OR close ≤ the low of the bar immediately before entry