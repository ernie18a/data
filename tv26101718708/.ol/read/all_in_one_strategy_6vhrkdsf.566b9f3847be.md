Calculation: RSI high = rounded mean of RSI values above the overbought lookback minimum, from the current bar through the configured overbought lookback
Calculation: RSI low = rounded mean of RSI values below the oversold lookback minimum, sampled every five bars from 5 bars ago through the configured oversold lookback
Calculation: RSI EMA = EMA of RSI using the RSI lookback
Calculation: Fast RSI EMA = 2 × EMA(RSI EMA, short EMA length) − EMA(EMA(RSI EMA, short EMA length), short EMA length)
Calculation: Slow RSI EMA = 2 × EMA(RSI EMA, long EMA length) − EMA(EMA(RSI EMA, long EMA length), long EMA length); long EMA length is greater than short EMA length
Calculation: Overall change = (close − open from the configured lookback bars ago) / that open × 100
Calculation: True dip = overall change < 0 AND highest high from the lookback bar through the current bar is above that starting open AND lowest low is below that starting open AND highest high from the previous bar through the current bar is above the previous bar's open AND lowest low is below that open AND previous bar's close < previous bar's open
Calculation: True peak = overall change > 0 AND highest high from the lookback bar through the current bar is above that starting open AND lowest low is below that starting open AND highest high from the previous bar through the current bar is above the previous bar's open AND lowest low is below that open AND previous bar's close > previous bar's open
Calculation: Bullish rule = fast RSI EMA > slow RSI EMA AND EMA(RSI, RSI lookback) >= its previous value
Calculation: Bearish rule = fast RSI EMA < slow RSI EMA AND EMA(RSI, RSI lookback) <= its previous value
Calculation: Stochastic K = configured moving average of the stochastic oscillator, using the configured smoothing length; Stochastic D = simple moving average of K using the configured D length
Calculation: MACD line and signal line = MACD of close using the short EMA length, long EMA length, and RSI lookback as its signal length
Calculation: Price change over lookback = (current close − open from the configured lookback bars ago) / that open × 100
Long: Stochastic K crosses above Stochastic D AND K is rising AND D is rising AND K < RSI AND D < RSI AND within the configured date window
Long: RSI crosses above oversold AND price change over lookback > 0 AND within the configured date window
Long: RSI EMA > RSI AND Stochastic K < Stochastic D AND RSI crosses above oversold AND price change over lookback > 0 AND within the configured date window
Long: MACD line > MACD signal line AND RSI < RSI low AND price change over lookback < 0 AND within the configured date window
Long: RSI EMA > RSI AND Stochastic K < Stochastic D AND MACD line > MACD signal line AND RSI < RSI low AND price change over lookback < 0 AND within the configured date window
Long: Short-lookback SMA(close) > long-lookback SMA(close) AND long-lookback SMA(close) > close AND RSI <= oversold AND true dip AND within the configured date window; short SMA lookback is less than both longer SMA lookbacks
Long: RSI EMA crosses above both fast and slow RSI EMAs AND bullish rule AND within the configured date window
Short: Stochastic K crosses below Stochastic D AND K is falling AND D is falling AND K < RSI AND D < RSI AND within the configured date window
Short: RSI > overbought AND true peak AND within the configured date window
Short: RSI EMA < RSI AND Stochastic D < Stochastic K AND RSI crosses below overbought AND price change over lookback < 0 AND within the configured date window
Short: MACD line < MACD signal line AND RSI > RSI high AND price change over lookback > 0 AND within the configured date window
Short: RSI EMA < RSI AND Stochastic D < Stochastic K AND MACD line < MACD signal line AND RSI > RSI high AND price change over lookback > 0 AND within the configured date window
Short: Short-lookback SMA(close) > medium-lookback SMA(close) AND open > long-lookback SMA(close) AND RSI >= overbought AND true peak AND within the configured date window; short SMA lookback is less than both longer SMA lookbacks
Short: RSI EMA crosses below both fast and slow RSI EMAs AND bearish rule AND within the configured date window
Exit: Long, close < entry price × (1 − stop loss percentage) OR close > entry price × (1 + target profit percentage) OR RSI EMA < RSI AND Stochastic D < Stochastic K AND RSI > overbought AND true peak AND within the configured date window
Exit: Short, close > entry price × (1 + stop loss percentage) OR close < entry price × (1 − target profit percentage) OR RSI EMA > RSI AND Stochastic K < Stochastic D AND RSI crosses above oversold AND price change over lookback > 0 AND within the configured date window OR RSI EMA crosses above both fast and slow RSI EMAs AND bullish rule AND within the configured date window