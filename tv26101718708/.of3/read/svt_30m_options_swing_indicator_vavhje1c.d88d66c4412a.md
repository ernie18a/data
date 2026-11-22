Calculation: Bull score = number of these that hold: RSI(close, RSI length) > RSI midline; RSI(close, fast RSI length) > RSI(close, RSI length); WaveTrend(hlc3, WaveTrend channel length, WaveTrend average length) > SMA(WaveTrend(hlc3, WaveTrend channel length, WaveTrend average length), WaveTrend signal length); CCI(hlc3, CCI length) > 0; ADX(DI length, ADX smoothing length) >= min ADX AND +DI(DI length) > -DI(DI length); Bull MACD momentum; close > EMA(close, fast length) AND close > EMA(close, mid length)
Calculation: Bear score = number of these that hold: RSI(close, RSI length) < RSI midline; RSI(close, fast RSI length) < RSI(close, RSI length); WaveTrend(hlc3, WaveTrend channel length, WaveTrend average length) < SMA(WaveTrend(hlc3, WaveTrend channel length, WaveTrend average length), WaveTrend signal length); CCI(hlc3, CCI length) < 0; ADX(DI length, ADX smoothing length) >= min ADX AND -DI(DI length) > +DI(DI length); Bear MACD momentum; close < EMA(close, fast length) AND close < EMA(close, mid length)
Calculation: MACD line = MACD(close, MACD fast, MACD slow, MACD signal).line
Calculation: MACD signal line = MACD(close, MACD fast, MACD slow, MACD signal).signal
Calculation: MACD histogram = MACD(close, MACD fast, MACD slow, MACD signal).histogram
Calculation: Bull MACD momentum = MACD line > MACD signal line AND MACD histogram > MACD histogram[1]
Calculation: Bear MACD momentum = MACD line < MACD signal line AND MACD histogram < MACD histogram[1]
Calculation: Recent bull MACD cross = MACD line crosses above MACD signal line on any of the last MACD cross active bars, including the current bar
Calculation: Recent bear MACD cross = MACD line crosses below MACD signal line on any of the last MACD cross active bars, including the current bar
Calculation: Recent call pullback = (low <= EMA(close, fast length) OR low <= EMA(close, mid length) OR RSI(close, RSI length) < RSI low level) on any of the last pullback active bars, including the current bar
Calculation: Recent put pullback = (high >= EMA(close, fast length) OR high >= EMA(close, mid length) OR RSI(close, RSI length) > RSI high level) on any of the last pullback active bars, including the current bar
Calculation: Chart bull = close > EMA(close, fast length) AND EMA(close, fast length) >= EMA(close, mid length)
Calculation: Chart bear = close < EMA(close, fast length) AND EMA(close, fast length) <= EMA(close, mid length)
Calculation: Not extended call = close <= EMA(close, fast length) + ATR(ATR length) * extension multiple
Calculation: Not extended put = close >= EMA(close, fast length) - ATR(ATR length) * extension multiple
Calculation: Chop zone = ADX(DI length, ADX smoothing length) < chop ADX threshold AND ABS(EMA(close, fast length) - EMA(close, mid length)) < ATR(ATR length) * EMA compression multiple AND highest(high, chop lookback) - lowest(low, chop lookback) < ATR(ATR length) * range multiple AND close < highest(high, chop lookback) AND close > lowest(low, chop lookback)
Calculation: Chop-allowed trade = NOT Chop zone OR (close > highest(high, chop lookback)[1] AND Bull MACD momentum AND RSI(close, RSI length) > RSI midline) OR (close < lowest(low, chop lookback)[1] AND Bear MACD momentum AND RSI(close, RSI length) < RSI midline)
Calculation: T1 bull = close(T1, last completed bar) > EMA(close, mid length, T1, last completed bar) AND RSI(close, RSI length, T1, last completed bar) > RSI midline
Calculation: T1 bear = close(T1, last completed bar) < EMA(close, mid length, T1, last completed bar) AND RSI(close, RSI length, T1, last completed bar) < RSI midline
Calculation: T1 strong bull = close(T1, last completed bar) > EMA(close, mid length, T1, last completed bar) AND EMA(close, mid length, T1, last completed bar) > EMA(close, slow length, T1, last completed bar) AND RSI(close, RSI length, T1, last completed bar) > T1 strong bull RSI level
Calculation: T1 strong bear = close(T1, last completed bar) < EMA(close, mid length, T1, last completed bar) AND EMA(close, mid length, T1, last completed bar) < EMA(close, slow length, T1, last completed bar) AND RSI(close, RSI length, T1, last completed bar) < T1 strong bear RSI level
Calculation: T2 MACD line = MACD(close, MACD fast, MACD slow, MACD signal, T2, last completed bar).line
Calculation: T2 MACD signal line = MACD(close, MACD fast, MACD slow, MACD signal, T2, last completed bar).signal
Calculation: T2 MACD histogram = MACD(close, MACD fast, MACD slow, MACD signal, T2, last completed bar).histogram
Calculation: T2 bull = close(T2, last completed bar) > EMA(close, fast length, T2, last completed bar) AND RSI(close, RSI length, T2, last completed bar) > RSI midline AND T2 MACD line > T2 MACD signal line
Calculation: T2 bear = close(T2, last completed bar) < EMA(close, fast length, T2, last completed bar) AND RSI(close, RSI length, T2, last completed bar) < RSI midline AND T2 MACD line < T2 MACD signal line
Calculation: T2 strong bull = close(T2, last completed bar) > EMA(close, mid length, T2, last completed bar) AND EMA(close, fast length, T2, last completed bar) > EMA(close, mid length, T2, last completed bar) AND RSI(close, RSI length, T2, last completed bar) > RSI midline AND T2 MACD line > T2 MACD signal line
Calculation: T2 strong bear = close(T2, last completed bar) < EMA(close, mid length, T2, last completed bar) AND EMA(close, fast length, T2, last completed bar) < EMA(close, mid length, T2, last completed bar) AND RSI(close, RSI length, T2, last completed bar) < RSI midline AND T2 MACD line < T2 MACD signal line
Calculation: T2 bull recovery = T2 MACD histogram > T2 MACD histogram[1 T2 bar] AND RSI(close, RSI length, T2, last completed bar) > RSI low level AND close(T2, last completed bar) > EMA(close, fast length, T2, last completed bar)
Calculation: T2 bear recovery = T2 MACD histogram < T2 MACD histogram[1 T2 bar] AND RSI(close, RSI length, T2, last completed bar) < RSI high level AND close(T2, last completed bar) < EMA(close, fast length, T2, last completed bar)
Calculation: Long bias = (signal mode is Safe AND T1 bull AND (T2 bull OR T2 bull recovery)) OR (signal mode is not Safe AND (T1 bull OR T2 bull OR T2 bull recovery))
Calculation: Short bias = (signal mode is Safe AND T1 bear AND (T2 bear OR T2 bear recovery)) OR (signal mode is not Safe AND (T1 bear OR T2 bear OR T2 bear recovery))
Calculation: Call setup = Chart bull AND Bull score >= L-score threshold(signal mode) AND Not extended call AND Chop-allowed trade AND Recent bull MACD cross AND ((Long bias AND Recent call pullback AND Bull MACD momentum AND close > close[1] AND close > open) OR (T1 strong bull AND T2 strong bull))
Calculation: Put setup = Chart bear AND Bear score >= L-score threshold(signal mode) AND Not extended put AND Chop-allowed trade AND Recent bear MACD cross AND ((Short bias AND Recent put pullback AND Bear MACD momentum AND close < close[1] AND close < open) OR (T1 strong bear AND T2 strong bear))
Calculation: Entry ATR = ATR(ATR length) at the entry bar
Calculation: Highest high since entry = maximum of high from the entry bar through the current bar
Calculation: Lowest low since entry = minimum of low from the entry bar through the current bar
Calculation: Long stop = IF Highest high since entry >= entry price + Entry ATR * trail start multiple THEN max(entry price + Entry ATR * break-even offset, Highest high since entry - Entry ATR * trail multiple) ELSE entry price - Entry ATR * emergency stop multiple
Calculation: Short stop = IF Lowest low since entry <= entry price - Entry ATR * trail start multiple THEN min(entry price - Entry ATR * break-even offset, Lowest low since entry + Entry ATR * trail multiple) ELSE entry price + Entry ATR * emergency stop multiple
Option: buy call, Call setup AND NOT T2 strong bear AND position side is not long AND bars since last entry > entry cooldown bars AND bars since last exit > exit cooldown bars
Option: buy put, Put setup AND NOT T2 strong bull AND position side is not short AND bars since last entry > entry cooldown bars AND bars since last exit > exit cooldown bars
Long: T1 bull
Long: T2 strong bull
Long: T2 bull recovery AND NOT T2 strong bull AND NOT T2 strong bear
Long: Chart bull
Long: Recent bull MACD cross
Long: Bull score >= L-score threshold(signal mode)
Long: Recent call pullback
Long: position side is flat AND Call setup
Short: T1 bear
Short: T2 strong bear
Short: T2 bear recovery AND NOT T2 strong bull AND NOT T2 strong bear
Short: Chart bear
Short: Recent bear MACD cross AND NOT Recent bull MACD cross
Short: Bear score >= L-score threshold(signal mode)
Short: Recent put pullback AND NOT Recent call pullback
Short: position side is flat AND Put setup
Exit: long, bars since entry >= min hold bars AND MACD line crosses below MACD signal line AND RSI(close, RSI length) < SMA(RSI(close, RSI length), RSI MA length) AND close < EMA(close, fast length) AND Bear score >= exit L-score minimum
Exit: long, bars since entry >= min hold bars AND T2 strong bear
Exit: long, bars since entry >= min hold bars AND close < EMA(close, mid length) AND MACD line < MACD signal line AND RSI(close, RSI length) < RSI low level
Exit: long, bars since entry >= theta check bars AND Highest high since entry < entry price + Entry ATR * min move to hold AND NOT T2 strong bull
Exit: long, bars since entry >= max hold bars
Exit: long, low <= Long stop
Exit: short, bars since entry >= min hold bars AND MACD line crosses above MACD signal line AND RSI(close, RSI length) > SMA(RSI(close, RSI length), RSI MA length) AND close > EMA(close, fast length) AND Bull score >= exit L-score minimum
Exit: short, bars since entry >= min hold bars AND T2 strong bull
Exit: short, bars since entry >= min hold bars AND close > EMA(close, mid length) AND MACD line > MACD signal line AND RSI(close, RSI length) > RSI high level
Exit: short, bars since entry >= theta check bars AND Lowest low since entry > entry price - Entry ATR * min move to hold AND NOT T2 strong bear
Exit: short, bars since entry >= max hold bars
Exit: short, high >= Short stop