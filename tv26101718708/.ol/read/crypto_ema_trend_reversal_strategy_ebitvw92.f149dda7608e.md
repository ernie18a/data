Long: Fast EMA of open (shorter lookback) crosses above slow EMA of open (longer lookback) AND shorter-lookback confirmation EMA of open > longer-lookback confirmation EMA of open AND fast EMA of open < exit EMA of open AND position side is not long
Short: Fast EMA of open (shorter lookback) crosses below slow EMA of open (longer lookback) AND shorter-lookback confirmation EMA of open < longer-lookback confirmation EMA of open AND fast EMA of open > exit EMA of open AND position side is not short
Calculation: Long stop level = low of the most recent long-entry signal bar − ATR × stop-loss multiplier
Calculation: Short stop level = high of the most recent short-entry signal bar + ATR × stop-loss multiplier
Calculation: Long take-profit level = high of the most recent long-entry signal bar + ATR × take-profit multiplier
Calculation: Short take-profit level = low of the most recent short-entry signal bar − ATR × take-profit multiplier
Exit: Long, low < long stop level OR high >= long take-profit level OR fast EMA of open crosses above exit EMA of open
Exit: Short, high > short stop level OR low <= short take-profit level OR exit EMA of open crosses above fast EMA of open