Calculation: Selected moving average = selected EMA, SMA, WMA, or HMA of close; long-term lookback is longer than short-term and medium-term lookbacks
Calculation: ATR threshold = simple moving average of ATR over the same lookback as ATR × multiplier
Long: (short-term moving average crosses above medium-term moving average OR short-term moving average > medium-term moving average) AND close > long-term moving average; when the volatility filter is enabled, also require ATR > ATR threshold
Exit: long, daily or weekly MACD line crosses below its signal line on the selected daily or weekly timeframe (use the last completed bar when that timeframe is higher than the chart timeframe, or the current bar when it is lower than or equal to the chart timeframe)
Exit: long, close < selected moving average
Exit: long, short-term moving average crosses below medium-term moving average
Exit: long, low <= highest high since entry × (1 − trailing stop percentage)