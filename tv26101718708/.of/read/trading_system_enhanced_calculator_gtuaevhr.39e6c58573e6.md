Calculation: Long trailing stop = close or high, selected by a parameter, minus an ATR multiple; if the current close is above the previous long trailing stop, use the greater of this value and the previous stop; otherwise use this value. Initialize with the untrailed value.
Calculation: Reference high = highest high over a lookback on a reference timeframe; during the initial lookback of chart bars, use the greater of the reference-timeframe all-time high and the current chart high. When the reference timeframe is higher than the chart timeframe, use the last completed bar historically and the forming bar in real time; when it is lower, use the last intrabar. Use the current bar when the timeframes are the same.
Calculation: Reference low = lowest low over the same lookback and reference timeframe as the reference high; during the initial lookback of chart bars, use the lesser of the reference-timeframe all-time low and the current chart low. Apply the same bar-selection rules as for the reference high.
Long: close > long trailing stop
Short: close <= long trailing stop
Long: close > SMA of close
Short: close <= SMA of close
Long: close > short-term moving average of close
Long: close > medium-term moving average of close
Long: close > long-term moving average of close
Long: short-term moving average of close > medium-term moving average of close
Long: short-term moving average of close > long-term moving average of close
Long: long-term moving average of close > long-term EMA of close a lookback number of chart bars ago
Long: 1 - reference high / close > negative percentage threshold
Long: close / reference low - 1 >= positive percentage threshold
Long: close > short-term moving average of close AND close > medium-term moving average of close AND close > long-term moving average of close AND short-term moving average of close > medium-term moving average of close AND short-term moving average of close > long-term moving average of close AND long-term moving average of close > long-term EMA of close a lookback number of chart bars ago AND 1 - reference high / close > negative percentage threshold AND close / reference low - 1 >= positive percentage threshold