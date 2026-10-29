Calculation: Channel high = highest high of the last N completed bars on the chart timeframe
Calculation: Channel low = lowest low of the last N completed bars on the chart timeframe
Calculation: Breakout buffer = buffer in points converted to price units
Calculation: RSI bias = bullish when RSI > 50; bearish when RSI < 50; neutral when RSI = 50
Calculation: Bull votes = count of bullish states among chart-timeframe trend, higher-timeframe trend, RSI bias, and channel breakout
Calculation: Bear votes = count of bearish states among chart-timeframe trend, higher-timeframe trend, RSI bias, and channel breakout
Long: chart-timeframe fast MA > chart-timeframe slow MA AND higher-timeframe fast MA > higher-timeframe slow MA AND RSI > 50 AND close > Channel high + Breakout buffer AND Bull votes >= 3 AND NOT (RSI >= overbought level AND Bull votes > Bear votes)
Short: chart-timeframe fast MA < chart-timeframe slow MA AND higher-timeframe fast MA < higher-timeframe slow MA AND RSI < 50 AND close < Channel low - Breakout buffer AND Bear votes >= 3 AND NOT (RSI <= oversold level AND Bear votes > Bull votes)
Long: higher-timeframe fast MA > higher-timeframe slow MA AND close > Channel high + Breakout buffer AND RSI < overbought level AND ATR is not low
Short: higher-timeframe fast MA < higher-timeframe slow MA AND close < Channel low - Breakout buffer AND RSI > oversold level AND ATR is not low
Long: chart-timeframe fast MA > chart-timeframe slow MA AND higher-timeframe fast MA > higher-timeframe slow MA AND RSI <= oversold level