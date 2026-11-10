Calculation: Fixed MA 1 and Fixed MA 2 = independently configured EMA, SMA, VWMA, or HMA of a chosen price source on a higher timeframe, using the last completed higher-timeframe bar.
Calculation: Fast, trend, and slow MAs = independently configured EMA, SMA, VWMA, or HMA of a chosen chart-timeframe price source, with respectively shorter, intermediate, and longer lookbacks.
Long: Fast MA > trend MA.
Short: Fast MA <= trend MA.
Long: Fixed MA 1 bull/bear coloring enabled AND close > fixed MA 1.
Short: Fixed MA 1 bull/bear coloring enabled AND close <= fixed MA 1.
Long: Fixed MA 2 bull/bear coloring enabled AND close > fixed MA 2.
Short: Fixed MA 2 bull/bear coloring enabled AND close <= fixed MA 2.
Long: No-SL/TP mode enabled AND fast MA > trend MA AND trend MA > slow MA AND close > fixed MA 1 AND RSI > long threshold AND ((retest enabled AND close crosses below fast MA) OR (breakout enabled AND close crosses above fast MA)).
Short: No-SL/TP mode enabled AND fast MA < trend MA AND trend MA < slow MA AND close < fixed MA 1 AND RSI < short threshold AND ((retest enabled AND close crosses above fast MA) OR (breakout enabled AND close crosses below fast MA)).
Long: Fixed-percentage or ATR risk mode enabled AND trend MA > slow MA AND close > fixed MA 1 AND RSI > long threshold AND ((retest enabled AND close crosses below fast MA) OR (breakout enabled AND close crosses above fast MA)).
Short: Fixed-percentage or ATR risk mode enabled AND trend MA < slow MA AND close < fixed MA 1 AND RSI < short threshold AND ((retest enabled AND close crosses above fast MA) OR (breakout enabled AND close crosses below fast MA)).
Exit: Long in no-SL/TP mode, low crosses below fast MA.
Exit: Short in no-SL/TP mode, high crosses above fast MA.
Exit: Long in fixed-percentage mode, low <= average entry price × (1 − stop-loss fraction) OR high >= average entry price × (1 + take-profit fraction).
Exit: Short in fixed-percentage mode, high >= average entry price × (1 + stop-loss fraction) OR low <= average entry price × (1 − take-profit fraction).
Exit: Long in ATR mode, low <= average entry price − stop-loss multiplier × previous completed chart-bar ATR OR high >= average entry price + take-profit multiplier × previous completed chart-bar ATR.
Exit: Short in ATR mode, high >= average entry price + stop-loss multiplier × previous completed chart-bar ATR OR low <= average entry price − take-profit multiplier × previous completed chart-bar ATR.