Calculation: MACD line = shorter-lookback EMA of close minus longer-lookback EMA of close
Calculation: MACD signal line = EMA of the MACD line
Calculation: MACD difference = MACD line minus MACD signal line
Calculation: Pivot high/low = a high/low that is higher/lower than the highs/lows in the same number of bars before and after it; signal on confirmation
Long: the MACD difference crosses above 0
Short: the MACD difference crosses below 0
Long: RSI crosses above the oversold level
Short: RSI crosses below the overbought level
Long: the shorter-lookback moving average crosses below the longer-lookback moving average
Short: the shorter-lookback moving average crosses above the longer-lookback moving average
Long: a confirmed pivot low forms AND no position is open AND no long position was open the configured number of bars ago
Short: a confirmed pivot high forms AND no position is open AND no short position was open the configured number of bars ago
Exit: long, low <= active stop-loss price OR high >= active take-profit price OR an opposite short signal occurs
Exit: short, high >= active stop-loss price OR low <= active take-profit price OR an opposite long signal occurs