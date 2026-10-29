Calculation: Friday close = close of the last completed bar on a higher timeframe, corresponding to Friday
Long: (day of week is Saturday OR Sunday) AND (position is flat AND close < Friday close × (1 − entry threshold) OR position is long AND close < average entry price × (1 − entry threshold))
Short: (day of week is Saturday OR Sunday) AND (position is flat AND close > Friday close × (1 + entry threshold) OR position is short AND close > average entry price × (1 + entry threshold))
Exit: long or short, aggregate unrealized profit / initial capital > profit threshold OR day of week is Monday