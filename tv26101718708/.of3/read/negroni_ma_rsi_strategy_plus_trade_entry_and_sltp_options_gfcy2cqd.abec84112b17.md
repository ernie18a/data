Calculation: Fast average = selected EMA/SMA/VWMA/HMA(fast source, shorter lookback)
Calculation: Trend average = selected EMA/SMA/VWMA/HMA(trend source, intermediate lookback)
Calculation: Slow average = selected EMA/SMA/VWMA/HMA(slow source, longer lookback)
Calculation: T1 average = selected EMA/SMA/VWMA/HMA(T1 source, lookback), calculated on T1 bars using the last completed T1 bar and mapped onto chart bars
Calculation: RSI = RSI(close, lookback)
Calculation: ATR = ATR(lookback)
Long: close crosses below Fast average AND Fast average > Trend average AND Trend average > Slow average AND RSI > long RSI threshold AND close > T1 average
Long: close crosses above Fast average AND Fast average > Trend average AND Trend average > Slow average AND RSI > long RSI threshold AND close > T1 average
Long: close crosses below Fast average AND Trend average > Slow average AND RSI > long RSI threshold AND close > T1 average
Long: close crosses above Fast average AND Trend average > Slow average AND RSI > long RSI threshold AND close > T1 average
Short: close crosses above Fast average AND Fast average < Trend average AND Trend average < Slow average AND RSI < short RSI threshold AND close < T1 average
Short: close crosses below Fast average AND Fast average < Trend average AND Trend average < Slow average AND RSI < short RSI threshold AND close < T1 average
Short: close crosses above Fast average AND Trend average < Slow average AND RSI < short RSI threshold AND close < T1 average
Short: close crosses below Fast average AND Trend average < Slow average AND RSI < short RSI threshold AND close < T1 average
Exit: long, low crosses below Fast average
Exit: short, high crosses above Fast average
Exit: long, low <= entry price * (1 - stop-loss percentage) OR high >= entry price * (1 + take-profit percentage)
Exit: short, high >= entry price * (1 + stop-loss percentage) OR low <= entry price * (1 - take-profit percentage)
Exit: long, low <= entry price - ATR * ATR stop-loss multiple OR high >= entry price + ATR * ATR take-profit multiple
Exit: short, high >= entry price + ATR * ATR stop-loss multiple OR low <= entry price - ATR * ATR take-profit multiple