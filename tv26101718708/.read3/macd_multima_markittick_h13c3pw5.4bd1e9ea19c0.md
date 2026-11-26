Calculation: MACD = MA(selected source, fast lookback, selected MA type and applicable type-specific parameters) - MA(selected source, slow lookback, same MA type and parameters)
Calculation: Signal = MA(MACD, signal lookback, same MA type and parameters)
Calculation: LLAMA(source, nominal lookback, predictor lookback, range, short RSI lookback, long RSI lookback) = adaptive EMA(source, max(nominal lookback × (1 + range × prediction), minimum dynamic length)); prediction is the weighted mean of close direction over the predictor lookback, where close direction at lag n is +1 if close[n-1] > close[n], -1 if close[n-1] < close[n], and 0 otherwise, and its weight is 1 / (1 + log(1 + |RSI(close, short RSI lookback) - RSI(close, short RSI lookback)[n]|) + log(1 + |RSI(close, long RSI lookback) - RSI(close, long RSI lookback)[n]|))
Calculation: Risk distance = ATR(ATR lookback) × stop ATR multiple
Calculation: Nearest, middle, and farthest target multiples = the three separate target multiple parameters sorted ascending
Calculation: Long stop = entry price - risk distance
Calculation: Short stop = entry price + risk distance
Calculation: Long target prices = entry price + risk distance × each sorted target multiple
Calculation: Short target prices = entry price - risk distance × each sorted target multiple
Long: MACD > Signal OR (candle reference is zero AND MACD > 0)
Short: MACD < Signal OR (candle reference is zero AND MACD < 0)
Long: MACD crosses above Signal on a confirmed chart bar AND fast lookback < slow lookback AND MACD, Signal, and ATR are available AND bars are standard OHLC bars AND (selected MA type is not volume-weighted OR positive volume exists in available history) AND NOT (signal lock is enabled AND this is the latest bar) AND no long position remains open after exits on this bar AND risk distance > minimum tick size AND long stop > 0 AND long stop < entry price AND nearest long target > entry price; entry price = signal bar close
Short: MACD crosses below Signal on a confirmed chart bar AND fast lookback < slow lookback AND MACD, Signal, and ATR are available AND bars are standard OHLC bars AND (selected MA type is not volume-weighted OR positive volume exists in available history) AND NOT (signal lock is enabled AND this is the latest bar) AND no short position remains open after exits on this bar AND risk distance > minimum tick size AND farthest short target > 0 AND short stop > entry price AND nearest short target < entry price; entry price = signal bar close
Exit: Long, high >= nearest long target for the first time on a bar after entry
Exit: Long, high >= middle long target for the first time on a bar after entry
Exit: Long, high >= farthest long target on a bar after entry
Exit: Long, confirmed close < long stop AND high < farthest long target on a bar after entry
Exit: Short, low <= nearest short target for the first time on a bar after entry
Exit: Short, low <= middle short target for the first time on a bar after entry
Exit: Short, low <= farthest short target on a bar after entry
Exit: Short, confirmed close > short stop AND low > farthest short target on a bar after entry
Exit: Long, position remains open after exits on this bar AND NOT (signal lock is enabled AND this is the latest bar) AND confirmed MACD crosses below Signal AND fast lookback < slow lookback AND MACD, Signal, and ATR are available AND bars are standard OHLC bars AND (selected MA type is not volume-weighted OR positive volume exists in available history) AND short-entry risk checks fail
Exit: Short, position remains open after exits on this bar AND NOT (signal lock is enabled AND this is the latest bar) AND confirmed MACD crosses above Signal AND fast lookback < slow lookback AND MACD, Signal, and ATR are available AND bars are standard OHLC bars AND (selected MA type is not volume-weighted OR positive volume exists in available history) AND long-entry risk checks fail