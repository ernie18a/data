Calculation: Rate spread = SMMA(median price, shorter lookback, T1, forming bar) − SMMA(median price, longer lookback, T1, forming bar)
Calculation: Combined rate spread = sum of rate spreads for U.S. dollars per euro, U.S. dollars per pound sterling, Swiss francs per U.S. dollar, and Japanese yen per U.S. dollar
Long: rate spread for U.S. dollars per euro > 0
Long: rate spread for U.S. dollars per pound sterling > 0
Long: rate spread for Swiss francs per U.S. dollar > 0
Long: rate spread for Japanese yen per U.S. dollar > 0
Short: rate spread for U.S. dollars per euro < 0
Short: rate spread for U.S. dollars per pound sterling < 0
Short: rate spread for Swiss francs per U.S. dollar < 0
Long: combined rate spread > 0
Short: combined rate spread < 0
Long: combined rate spread > 0 AND local rate spread > 0
Short: combined rate spread < 0 AND local rate spread < 0
Calculation: Profit distance = point size × round(round(high of the last completed T2 bar − low of the last completed T2 bar to the nearest integer) / profit divisor to the nearest integer)
Exit: long, close > entry price + profit distance
Exit: short, close < entry price − profit distance