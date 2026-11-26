Calculation: Friday reference close = close of the T1 bar indexed by elapsed T1 bars since Friday, selected on T1 bars and sampled on chart bars (the current T1 bar on Friday; the completed Friday bar afterward)
Long: close < Friday reference close × (1 − deviation parameter)
Short: close > Friday reference close × (1 + deviation parameter)
Short: position side is short AND close > average entry price × (1 + deviation parameter)
Long: position side is not short
Exit: long, open profit / initial capital > profit target parameter OR day of week = Monday
Exit: short, open profit / initial capital > profit target parameter OR day of week = Monday
Long: Saturday or Sunday UTC chart close < Friday GXBT T1 close × (1 − P1)
Short: Saturday or Sunday UTC chart close > Friday GXBT T1 close × (1 + P1)
Exit: Long, UTC day = Monday
Exit: Short, UTC day = Monday