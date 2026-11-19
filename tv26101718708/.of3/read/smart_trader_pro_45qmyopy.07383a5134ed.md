Long: close crosses above VWAP(hlc3)
Short: close crosses below VWAP(hlc3)
Long: EMA(close, shorter lookback) crosses above EMA(close, longer lookback)
Short: EMA(close, shorter lookback) crosses below EMA(close, longer lookback)
Long: at least two of close > VWAP(hlc3), EMA(close, shorter lookback) > EMA(close, longer lookback), and RSI(close, lookback) > midpoint parameter
Short: at least two of close <= VWAP(hlc3), EMA(close, shorter lookback) <= EMA(close, longer lookback), and RSI(close, lookback) <= midpoint parameter
Long: ADX(lookback) >= ADX threshold AND at least two of close > VWAP(hlc3), EMA(close, shorter lookback) > EMA(close, longer lookback), and RSI(close, lookback) > midpoint parameter
Short: ADX(lookback) >= ADX threshold AND at least two of close <= VWAP(hlc3), EMA(close, shorter lookback) <= EMA(close, longer lookback), and RSI(close, lookback) <= midpoint parameter
Long: engulfing signals enabled AND close > open AND close[1] < open[1] AND close > open[1] AND open < close[1] AND (ADX filter disabled OR ADX(lookback) >= ADX threshold) AND (RSI filter disabled OR RSI(close, lookback) > lower RSI bound AND RSI(close, lookback) < upper RSI bound) AND (EMA trend filter disabled OR EMA(close, shorter lookback) > EMA(close, longer lookback))
Short: engulfing signals enabled AND close < open AND close[1] > open[1] AND close < open[1] AND open > close[1] AND (ADX filter disabled OR ADX(lookback) >= ADX threshold) AND (RSI filter disabled OR RSI(close, lookback) > lower RSI bound AND RSI(close, lookback) < upper RSI bound) AND (EMA trend filter disabled OR EMA(close, shorter lookback) <= EMA(close, longer lookback))