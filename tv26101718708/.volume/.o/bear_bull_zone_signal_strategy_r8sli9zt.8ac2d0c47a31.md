Calculation: OHLC4 RSI = RSI of (open + high + low + close) / 4
Calculation: Fast RSI EMA = double EMA of OHLC4 RSI using the shorter EMA length
Calculation: Slow RSI EMA = double EMA of OHLC4 RSI using the longer EMA length
Calculation: K = SMA, EMA, or WMA of Stochastic RSI; D = SMA of K
Calculation: Stochastic RSI = RSI of close, normalized against its lowest and highest values over the RSI lookback
Calculation: High VWMA = volume-weighted moving average of high
Calculation: Low VWMA = volume-weighted moving average of low
Long: Fast RSI EMA > Slow RSI EMA OR K > oversold AND D < overbought AND K > D AND K is rising AND D is rising OR bearish EMA zone AND signal-up conditions OR bullish EMA zone AND signal-up conditions AND (close > SMA or EMA of close for any of the 50, 100, 236, 500, or 1000 lookbacks) AND none of those comparisons was true on the previous bar OR High VWMA > the prior bar's highest high over the lookback
Short: Fast RSI EMA < Slow RSI EMA OR K < overbought AND D > oversold AND K < D AND K is falling AND D is falling OR bearish EMA zone AND signal-down conditions OR bullish EMA zone AND signal-down conditions AND (close < SMA or EMA of close for any of the 50, 100, 236, 500, or 1000 lookbacks) AND none of those comparisons was true on the previous bar OR Low VWMA < the prior bar's lowest low over the lookback
Exit: Long, short-entry condition OR close reaches entry price plus target profit OR close reaches entry price minus stop loss
Exit: Short, long-entry condition OR close reaches entry price minus target profit OR close reaches entry price plus stop loss