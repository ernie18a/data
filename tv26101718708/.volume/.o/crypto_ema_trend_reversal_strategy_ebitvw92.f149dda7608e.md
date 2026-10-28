Calculation: Fast EMA = EMA of open on current chart bars; shorter lookback than the slow EMA
Calculation: Slow EMA = EMA of open on current chart bars; longer lookback than the fast EMA
Calculation: Exit EMA = EMA of open on current chart bars
Calculation: Fast confirmation EMA = EMA of open on current chart bars; shorter lookback than the slow confirmation EMA
Calculation: Slow confirmation EMA = EMA of open on current chart bars; longer lookback than the fast confirmation EMA
Calculation: Long stop = signal-bar low − signal-bar ATR × stop multiplier
Calculation: Short stop = signal-bar high + signal-bar ATR × stop multiplier
Calculation: Long target = signal-bar high + signal-bar ATR × target multiplier
Calculation: Short target = signal-bar low − signal-bar ATR × target multiplier
Long: Fast EMA crosses above slow EMA AND fast confirmation EMA > slow confirmation EMA AND fast EMA < exit EMA AND position is not already long
Short: Fast EMA crosses below slow EMA AND fast confirmation EMA < slow confirmation EMA AND fast EMA > exit EMA AND position is not already short
Exit: long, low <= long stop OR high >= long target OR fast EMA crosses above exit EMA
Exit: short, high >= short stop OR low <= short target OR exit EMA crosses above fast EMA