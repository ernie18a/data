Calculation: RSI high = rounded average of RSI values above the overbought minimum among the current bar and the configured lookback bars
Calculation: RSI low = rounded average of RSI values below the oversold minimum among the current bar and the configured lookback bars
Calculation: True dip = overall percentage change < 0 AND highest high in the configured lookback window is above its starting open AND lowest low is below its starting open AND highest high is above the previous bar's open AND lowest low is below the previous bar's open AND previous bar's close is below its open; overall percentage change is (current close − starting open) / starting open × 100
Calculation: True peak = overall percentage change > 0 AND highest high in the configured lookback window is above its starting open AND lowest low is below its starting open AND highest high is above the previous bar's open AND lowest low is below the previous bar's open AND previous bar's close is above its open
Calculation: RSI high/low window = extrema of RSI high/low over the RSI lookback period
Calculation: Dynamic stochastic = 100 × (RSI − lowest RSI low over the RSI lookback period) / (highest RSI high over the RSI lookback period − lowest RSI low over the RSI lookback period)
Calculation: K = configured moving average of dynamic stochastic; D = simple moving average of K
Calculation: RSI of OHLC4 = RSI calculated from (open + high + low + close) / 4
Calculation: Double EMA = 2 × EMA(series, length) − EMA(EMA(series, length), length)
Calculation: Fast RSI double EMA = double EMA of RSI of OHLC4 using the shorter EMA length
Calculation: Slow RSI double EMA = double EMA of RSI of OHLC4 using the longer EMA length
Calculation: Smoothed RSI = EMA of RSI of OHLC4 using the RSI length
Calculation: RSI overbought average = rounded average of RSI values above the configured overbought minimum across the configured overbought lookback
Calculation: RSI oversold average = rounded average of RSI values below the configured oversold minimum across the configured oversold lookback
Calculation: Price change = (current close − open of the bar N bars ago) / that open × 100, where N is the configured maximum lookback
Long: True dip AND RSI < oversold AND within the configured time window
Short: True peak AND RSI > overbought AND within the configured time window
Long: RSI crosses above oversold AND Price change > 0 AND within the configured time window
Short: RSI crosses below overbought AND Price change < 0 AND within the configured time window
Long: MACD line > signal line AND RSI < RSI oversold average AND Price change < 0 AND within the configured time window
Short: MACD line < signal line AND RSI > RSI overbought average AND Price change > 0 AND within the configured time window
Long: RSI crosses above RSI oversold average AND within the configured time window
Short: RSI crosses below RSI overbought average AND within the configured time window
Long: Fast RSI double EMA crosses below Smoothed RSI AND within the configured time window
Short: Fast RSI double EMA crosses above Slow RSI double EMA AND within the configured time window
Long: K crosses above D AND within the configured time window
Short: K crosses below D AND within the configured time window
Long: Shorter moving average of close > longer moving average of close AND open > longest moving average of close AND RSI >= overbought AND True peak AND within the configured time window
Short: Shorter moving average of close < medium moving average of close AND open < longest moving average of close AND RSI <= oversold AND True dip AND within the configured time window
Long: K > oversold AND D < overbought AND K > D AND K is rising AND D is rising
Short: K < overbought AND D > oversold AND K < D AND K is falling AND D is falling
Long: Flat position AND long trading enabled AND RSI of OHLC4 > RSI AND K < D AND selected entry signal is RSI crosses above oversold with True dip, RSI-cross-back long, MACD long, Connors long, or stochastic K-cross-above-D, according to the selected strategy
Short: Flat position AND short trading enabled AND RSI of OHLC4 < RSI AND D < K AND selected entry signal is RSI crosses below overbought with True peak, RSI-cross-back short, MACD short, Connors short, or stochastic K-cross-below-D, according to the selected strategy
Exit: Long, low <= entry price × (1 − configured stop-loss fraction) OR high >= entry price × (1 + configured take-profit fraction)
Exit: Short, high >= entry price × (1 + configured stop-loss fraction) OR low <= entry price × (1 − configured take-profit fraction)
Exit: Long, long trading enabled AND RSI of OHLC4 > RSI AND D > K AND selected exit signal is RSI crosses below overbought, RSI-cross-back short, MACD short, Connors short, or RSI above overbought with True peak, according to the selected strategy
Exit: Short, short trading enabled AND RSI of OHLC4 < RSI AND K > D AND selected exit signal is RSI crosses above oversold, RSI-cross-back long, MACD long, Connors long, or RSI below oversold with True dip, according to the selected strategy