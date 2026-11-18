Calculation: Long signal = crossover(EMA(open, shorter crossover lookback), EMA(open, longer crossover lookback)) AND EMA(open, shorter confirmation lookback) > EMA(open, longer confirmation lookback) AND EMA(open, shorter crossover lookback) < EMA(open, exit lookback) AND (prior position is not long OR prior position is undefined)
Calculation: Short signal = crossunder(EMA(open, shorter crossover lookback), EMA(open, longer crossover lookback)) AND EMA(open, shorter confirmation lookback) < EMA(open, longer confirmation lookback) AND EMA(open, shorter crossover lookback) > EMA(open, exit lookback) AND (prior position is not short OR prior position is undefined)
Long: Long signal AND direction mode permits long AND datetime > start-time parameter AND datetime < end-time parameter
Short: Short signal AND direction mode permits short AND datetime > start-time parameter AND datetime < end-time parameter
Calculation: Long stop level = valuewhen(Long signal, low - ATR(ATR lookback) * stop-loss multiplier, latest occurrence)
Calculation: Short stop level = valuewhen(Short signal, high + ATR(ATR lookback) * stop-loss multiplier, latest occurrence)
Calculation: Long take-profit level = valuewhen(Long signal, high + ATR(ATR lookback) * take-profit multiplier, latest occurrence)
Calculation: Short take-profit level = valuewhen(Short signal, low - ATR(ATR lookback) * take-profit multiplier, latest occurrence)
Exit: long, (crossover(EMA(open, shorter crossover lookback), EMA(open, exit lookback)) AND prior position was long) OR low <= long stop level OR high >= long take-profit level
Exit: short, (crossover(EMA(open, exit lookback), EMA(open, shorter crossover lookback)) AND prior position was short) OR high >= short stop level OR low <= short take-profit level