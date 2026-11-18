Calculation: shortDema = 2 * EMA(close, shortLength) - EMA(EMA(close, shortLength), shortLength), computed on bars of calculationTimeframe and taken from the last completed calculationTimeframe bar, where shortLength < longLength
Calculation: longDema = 2 * EMA(close, longLength) - EMA(EMA(close, longLength), longLength), computed on bars of calculationTimeframe and taken from the last completed calculationTimeframe bar
Long: shortDema crosses above longDema
Short: shortDema crosses below longDema