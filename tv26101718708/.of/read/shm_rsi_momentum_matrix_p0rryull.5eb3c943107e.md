Calculation: P = (open+high+low+close)/4
Calculation: FastWMA = weighted moving average of P over a shorter lookback; SlowWMA = weighted moving average of P over a longer lookback (SlowWMA lookback > FastWMA lookback)
Calculation: FilterSMA = simple moving average of P, lookback shorter than FastWMA lookback
Calculation: HTF_RSI = RSI of P (Wilder smoothing) computed on bars of a timeframe higher than the chart timeframe, taking the value of the last completed higher-timeframe bar (never the bar still forming)
Calculation: crosses above X = value > X on this bar AND value <= X on the previous bar; crosses below X = value < X on this bar AND value >= X on the previous bar
Calculation: RSI bands satisfy LongMin < ShortMin < LongMax < ShortMax (long band lies below short band, overlapping in [ShortMin, LongMax])
Long: (close crosses above FastWMA OR close crosses above SlowWMA OR high crosses above FastWMA OR high crosses above SlowWMA) AND close > FilterSMA AND close > SlowWMA AND HTF_RSI >= LongMin AND HTF_RSI <= LongMax
Short: (close crosses below FastWMA OR close crosses below SlowWMA OR low crosses below FastWMA OR low crosses below SlowWMA) AND close < FilterSMA AND close < SlowWMA AND HTF_RSI <= ShortMax AND HTF_RSI >= ShortMin