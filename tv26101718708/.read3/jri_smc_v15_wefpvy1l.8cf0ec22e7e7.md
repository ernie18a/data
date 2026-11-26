Calculation: Bullish structure = the latest two confirmed PivotHigh(high, swing lookback, swing lookback) values are rising AND the latest two confirmed PivotLow(low, swing lookback, swing lookback) values are rising
Calculation: Bearish structure = the latest two confirmed pivot-high values are falling AND the latest two confirmed pivot-low values are falling
Calculation: Upward BOS = close > the second-most-recent confirmed pivot high AND close[1] <= that level
Calculation: Downward BOS = close < the second-most-recent confirmed pivot low AND close[1] >= that level
Calculation: Demand zones = confirmed pivot lows expanded by a shared zone buffer; a later pivot low inside an existing zone increments its count, otherwise it creates a zone; qualifying zones have at least the rejection-count parameter
Calculation: Supply zones = confirmed pivot highs expanded by the shared zone buffer; a later pivot high inside an existing zone increments its count, otherwise it creates a zone; qualifying zones have at least the rejection-count parameter
Calculation: Long score = count of true conditions among bullish structure, close in a qualifying demand zone, upward BOS, an unconsumed upward-BOS retest (high >= broken level × (1 − shared zone buffer) AND close > broken level), close > VWAP(hlc3, T1 session anchor, evaluated on chart bars using the still-forming T1 session), EMA(close, shorter lookback) > EMA(close, longer lookback), and RSI(close, RSI lookback) > RSI midpoint
Calculation: Short score = count of true conditions among bearish structure, close in a qualifying supply zone, downward BOS, an unconsumed downward-BOS retest (low <= broken level × (1 + shared zone buffer) AND close < broken level), close < VWAP(hlc3, T1 session anchor, evaluated on chart bars using the still-forming T1 session), EMA(close, shorter lookback) < EMA(close, longer lookback), and RSI(close, RSI lookback) < RSI midpoint
Calculation: Signal latch = after either signal fires, both signals are blocked until that signal's score falls below the minimum score minus the reset-gap parameter
Calculation: Loss lock = active after consecutive stop-loss exits reach the maximum-loss parameter; reset the loss count and lock on a T3 target exit or calendar date change
Long: bullish structure
Short: bearish structure
Long: upward BOS
Short: downward BOS
Long: close is in a qualifying demand zone AND the previous bar's close was not in any qualifying demand zone
Short: close is in a qualifying supply zone AND the previous bar's close was not in any qualifying supply zone
Long: low < lowest(low, lookback)[1] AND close > lowest(low, lookback)[1]
Short: high > highest(high, lookback)[1] AND close < highest(high, lookback)[1]
Long: long score >= minimum score AND neither signal latch is active AND loss lock is inactive AND (no prior long signal OR bars since the prior long signal > swing lookback × applicable cooldown multiplier)
Short: short score >= minimum score AND neither signal latch is active AND loss lock is inactive AND (no prior short signal OR bars since the prior short signal > swing lookback × applicable cooldown multiplier)
Exit: long, low <= entry price − ATR(ATR lookback at entry) × applicable stop multiplier
Exit: long, high >= entry price + ATR(ATR lookback at entry) × applicable stop multiplier × target multiple
Exit: short, high >= entry price + ATR(ATR lookback at entry) × applicable stop multiplier
Exit: short, low <= entry price − ATR(ATR lookback at entry) × applicable stop multiplier × target multiple