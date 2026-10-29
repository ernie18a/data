Calculation: Flow candle = a rolling bar on a timeframe higher than the chart timeframe, using the still-forming chart bar: open from the oldest bar in the aggregation window, close from the current bar, and high and low across the window.
Calculation: Midline = moving average of flow-candle midpoints, where each midpoint is (flow-candle open + flow-candle close) / 2.
Calculation: Upper and lower ATR bands = midline + and −, respectively, the chart-timeframe ATR multiplied by a multiplier.
Long: (current close > current midline AND previous close < previous midline) OR (flow-candle close > upper ATR band AND flow-candle close != flow-candle open)
Short: (current close < current midline AND previous close > previous midline) OR (flow-candle close < lower ATR band AND flow-candle close != flow-candle open)
Exit: long, current close < current midline AND previous close > previous midline
Exit: short, current close > current midline AND previous close < previous midline