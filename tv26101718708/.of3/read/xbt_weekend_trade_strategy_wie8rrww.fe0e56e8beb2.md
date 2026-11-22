Calculation: Friday close = close of the last completed Friday bar on T1, calculated on T1 bars and mapped to chart bars
Long: On Saturday or Sunday, close < Friday close × (1 − entry deviation)
Long: On Saturday or Sunday, position side is not short
Short: On Saturday or Sunday, close > Friday close × (1 + entry deviation)
Short: On Saturday or Sunday, position side is short AND close > average entry price × (1 + entry deviation)
Exit: Long or short, open profit / initial capital > profit threshold
Exit: Long or short, day is Monday
Short: traded instrument close > Friday GXBT close (T1) × (1 + P1) AND UTC day is Saturday or Sunday
Long: traded instrument close < Friday GXBT close (T1) × (1 − P2) AND UTC day is Saturday or Sunday
Exit: long or short, UTC day = Monday