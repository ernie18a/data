Calculation: Stochastic RSI K = SMA(Stochastic(RSI(close, RSI lookback), RSI(close, RSI lookback), RSI(close, RSI lookback), stochastic lookback), stochastic smoothing lookback)
Calculation: Stochastic RSI D = SMA(Stochastic RSI K, stochastic smoothing lookback)
Calculation: higher-timeframe bullish = HTF filter disabled OR (on chart bars, T1 close > EMA(close, long-term EMA lookback) from T1 values returned with lookahead off; last completed T1 bar historically and forming T1 bar in realtime)
Calculation: higher-timeframe bearish = HTF filter disabled OR (on chart bars, T1 close < EMA(close, long-term EMA lookback) from T1 values returned with lookahead off; last completed T1 bar historically and forming T1 bar in realtime)
Calculation: bullish score = major weight × count of true predicates {close > EMA(close, long-term EMA lookback); Supertrend direction(high, low, close, multiplier, lookback) is bullish; MACD(close, fast lookback, slow lookback, signal lookback) line > signal; RSI(close, RSI lookback) > long RSI lower bound AND RSI(close, RSI lookback) < upper RSI threshold; higher-timeframe bullish} + minor weight × count of true predicates {EMA(close, short-term EMA lookback) > EMA(close, medium-term EMA lookback); Stochastic RSI K > Stochastic RSI D AND Stochastic RSI K < long stochastic ceiling; ADX(DMI(DI lookback, ADX smoothing)) > score ADX threshold AND +DI > -DI; volume > SMA(volume, volume lookback); close > open[engulf offset] AND open < close[engulf offset] AND close[engulf offset] < open[engulf offset]; ATR(high, low, close, ATR lookback) > SMA(ATR(high, low, close, ATR lookback), ATR average lookback) × ATR activity multiplier}; EMA lookbacks satisfy short-term < medium-term < long-term, and MACD lookbacks satisfy fast < slow
Calculation: bearish score = major weight × count of true predicates {close < EMA(close, long-term EMA lookback); Supertrend direction(high, low, close, multiplier, lookback) is bearish; MACD(close, fast lookback, slow lookback, signal lookback) line < signal; RSI(close, RSI lookback) < short RSI upper bound AND RSI(close, RSI lookback) > lower RSI threshold; higher-timeframe bearish} + minor weight × count of true predicates {EMA(close, short-term EMA lookback) < EMA(close, medium-term EMA lookback); Stochastic RSI K < Stochastic RSI D AND Stochastic RSI K > short stochastic floor; ADX(DMI(DI lookback, ADX smoothing)) > score ADX threshold AND -DI > +DI; volume > SMA(volume, volume lookback); close < open[engulf offset] AND open > close[engulf offset] AND close[engulf offset] > open[engulf offset]; ATR(high, low, close, ATR lookback) > SMA(ATR(high, low, close, ATR lookback), ATR average lookback) × ATR activity multiplier}
Calculation: long stop level = entry price - ATR(high, low, close, ATR lookback) evaluated on the entry bar × stop multiple
Calculation: long first target = entry price + ATR(high, low, close, ATR lookback) evaluated on the entry bar × first target multiple
Calculation: long second target = entry price + ATR(high, low, close, ATR lookback) evaluated on the entry bar × second target multiple
Calculation: long third target = entry price + ATR(high, low, close, ATR lookback) evaluated on the entry bar × third target multiple
Calculation: short stop level = entry price + ATR(high, low, close, ATR lookback) evaluated on the entry bar × stop multiple
Calculation: short first target = entry price - ATR(high, low, close, ATR lookback) evaluated on the entry bar × first target multiple
Calculation: short second target = entry price - ATR(high, low, close, ATR lookback) evaluated on the entry bar × second target multiple
Calculation: short third target = entry price - ATR(high, low, close, ATR lookback) evaluated on the entry bar × third target multiple
Long: EMA(close, short-term EMA lookback) crosses above EMA(close, medium-term EMA lookback) AND bullish score >= signal threshold
Short: EMA(close, short-term EMA lookback) crosses below EMA(close, medium-term EMA lookback) AND bearish score >= signal threshold
Long: close > EMA(close, long-term EMA lookback)
Short: close <= EMA(close, long-term EMA lookback)
Long: Supertrend direction(high, low, close, multiplier, lookback) is bullish
Short: Supertrend direction(high, low, close, multiplier, lookback) is bearish
Long: ADX(DMI(DI lookback, ADX smoothing)) > market trend ADX threshold AND close > EMA(close, long-term EMA lookback)
Short: ADX(DMI(DI lookback, ADX smoothing)) > market trend ADX threshold AND close <= EMA(close, long-term EMA lookback)
Long: RSI(close, RSI lookback) < lower RSI threshold
Short: RSI(close, RSI lookback) > upper RSI threshold
Long: higher-timeframe bullish
Short: HTF filter enabled AND T1 close <= EMA(close, long-term EMA lookback) from T1 values returned with lookahead off; last completed T1 bar historically and forming T1 bar in realtime
Long: low > high[FVG offset]
Short: high < low[FVG offset]
Exit: long, high >= long first target AND long first target has not already been reached since entry
Exit: long, high >= long second target AND long second target has not already been reached since entry
Exit: long, high >= long third target AND long third target has not already been reached since entry
Exit: long, low <= long stop level AND long first target has not been reached since entry through this bar
Exit: short, low <= short first target AND short first target has not already been reached since entry
Exit: short, low <= short second target AND short second target has not already been reached since entry
Exit: short, low <= short third target AND short third target has not already been reached since entry
Exit: short, high >= short stop level AND short first target has not been reached since entry through this bar