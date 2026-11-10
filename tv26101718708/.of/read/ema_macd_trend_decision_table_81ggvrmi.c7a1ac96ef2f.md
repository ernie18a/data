Calculation: Decision score = sum of these contributions, each zero when neither condition applies: +2 if short EMA > longer EMA AND close > still longer EMA, else -2 if short EMA < longer EMA AND close < still longer EMA; +1 if close > longest EMA, else -1 if close < longest EMA; +2 if MACD line > signal line AND histogram > 0, else -2 if MACD line < signal line AND histogram < 0; +1 if MACD line crosses above signal line, else -1 if it crosses below; +1 if RSI > upper RSI threshold, else -1 if RSI < lower RSI threshold; +1 if ADX >= trend threshold AND +DI > -DI, else -1 if ADX >= trend threshold AND -DI > +DI; +1 if volume > volume SMA AND close > open, else -1 if volume > volume SMA AND close < open; when the higher-timeframe filter is enabled, +1 if higher-timeframe close > its EMA, else -1 if higher-timeframe close < its EMA. The four chart EMAs use the same selected price source, with increasing lookbacks; MACD and RSI use that source. Higher-timeframe values use the last completed higher-timeframe bar on historical bars and the still-forming higher-timeframe bar in real time. A cross above means current value > comparator AND previous value <= previous comparator; a cross below reverses the inequalities.
Long: Decision score >= buy threshold
Long: Decision score >= strong-buy threshold AND previous decision score < strong-buy threshold
Long: MACD line crosses above signal line
Long: Short EMA > longer EMA AND close > still longer EMA
Long: Close > longest EMA
Long: MACD line > signal line AND histogram > 0
Long: RSI > upper RSI threshold
Long: ADX >= trend threshold AND +DI > -DI
Long: Volume > volume SMA AND close > open
Long: Higher-timeframe filter enabled AND higher-timeframe close > its EMA
Short: Decision score <= sell threshold
Short: Decision score <= strong-sell threshold AND previous decision score > strong-sell threshold
Short: MACD line crosses below signal line
Short: Short EMA < longer EMA AND close < still longer EMA
Short: Close < longest EMA
Short: MACD line < signal line AND histogram < 0
Short: RSI < lower RSI threshold
Short: ADX >= trend threshold AND -DI > +DI
Short: Volume > volume SMA AND close < open
Short: Higher-timeframe filter enabled AND higher-timeframe close < its EMA