Calculation: HMA change = HMA(close, HMA lookback) - HMA(close, HMA lookback)[1]
Long: HMA change > 0
Short: HMA change < 0
Long: HMA change > first multiplier * StDev(HMA change, standard-deviation lookback) AND HMA change <= second multiplier * StDev(HMA change, standard-deviation lookback)
Long: HMA change > second multiplier * StDev(HMA change, standard-deviation lookback)
Short: HMA change < -first multiplier * StDev(HMA change, standard-deviation lookback) AND HMA change >= -second multiplier * StDev(HMA change, standard-deviation lookback)
Short: HMA change < -second multiplier * StDev(HMA change, standard-deviation lookback)
Calculation: T1 HMA change = HMA(close, HMA lookback, T1, still-forming bar) - HMA(close, HMA lookback, T1)[1]
Long: T1 HMA change > 0, on chart bars using values from T1's still-forming bar
Short: T1 HMA change < 0, on chart bars using values from T1's still-forming bar
Long: T1 HMA change > first multiplier * StDev(T1 HMA change, standard-deviation lookback, T1, still-forming bar) AND T1 HMA change <= second multiplier * StDev(T1 HMA change, standard-deviation lookback, T1, still-forming bar), on chart bars using values from T1's still-forming bar
Long: T1 HMA change > second multiplier * StDev(T1 HMA change, standard-deviation lookback, T1, still-forming bar), on chart bars using values from T1's still-forming bar
Short: T1 HMA change < -first multiplier * StDev(T1 HMA change, standard-deviation lookback, T1, still-forming bar) AND T1 HMA change >= -second multiplier * StDev(T1 HMA change, standard-deviation lookback, T1, still-forming bar), on chart bars using values from T1's still-forming bar
Short: T1 HMA change < -second multiplier * StDev(T1 HMA change, standard-deviation lookback, T1, still-forming bar), on chart bars using values from T1's still-forming bar