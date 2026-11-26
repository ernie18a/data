Calculation: Ozymandias change = Ozymandias(high, low, close, Ozymandias lookback) - Ozymandias(high, low, close, Ozymandias lookback)[1]
Calculation: Ozymandias line direction = sign(Ozymandias change) when nonzero; otherwise the previous Ozymandias line direction, initially neutral
Long: Ozymandias line direction > 0
Short: Ozymandias line direction < 0
Long: Ozymandias change > standard-deviation multiplier * StandardDeviation(Ozymandias change, standard-deviation lookback)
Short: Ozymandias change < -standard-deviation multiplier * StandardDeviation(Ozymandias change, standard-deviation lookback)
Calculation: T1 Ozymandias change = Ozymandias(high, low, close, Ozymandias lookback, T1 bar) - Ozymandias(high, low, close, Ozymandias lookback, previous T1 bar); calculated on T1 bars, with chart bars taking values from the T1 bar still forming
Calculation: T1 Ozymandias line direction = sign(T1 Ozymandias change) when nonzero; otherwise the previous T1 Ozymandias line direction, initially neutral
Long: T1 Ozymandias line direction > 0
Short: T1 Ozymandias line direction < 0
Long: T1 Ozymandias change > standard-deviation multiplier * StandardDeviation(T1 Ozymandias change, standard-deviation lookback)
Short: T1 Ozymandias change < -standard-deviation multiplier * StandardDeviation(T1 Ozymandias change, standard-deviation lookback)