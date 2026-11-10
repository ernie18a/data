Calculation: Confirmed pivot high or low = the high or low of a bar that is respectively the pivot high or pivot low over equal numbers of preceding and following bars; report it on the bar that confirms the pivot and return undefined on other bars.
Long: Short EMA of close crosses above medium EMA of close AND close > long EMA of close AND RSI < upper threshold.
Short: Short EMA of close crosses below medium EMA of close AND close < long EMA of close AND RSI > lower threshold.
Long: Short EMA of close > medium EMA of close AND medium EMA of close > long EMA of close.
Short: Short EMA of close <= medium EMA of close OR medium EMA of close <= long EMA of close.
Long: At least two structure-lookback pivot highs have been confirmed AND close > latest confirmed structure-lookback pivot high AND previous close <= that same pivot high.
Short: At least two structure-lookback pivot lows have been confirmed AND close < latest confirmed structure-lookback pivot low AND previous close >= that same pivot low.
Long: Previous short EMA of close < previous medium EMA of close AND previous medium EMA of close < previous long EMA of close AND short EMA of close > medium EMA of close AND medium EMA of close > long EMA of close.
Short: Previous short EMA of close > previous medium EMA of close AND previous medium EMA of close > previous long EMA of close AND short EMA of close < medium EMA of close AND medium EMA of close < long EMA of close.
Long: Volume > SMA of volume multiplied by a threshold AND close >= open.
Short: Volume > SMA of volume multiplied by a threshold AND close < open.
Long: A price-low pivot and an RSI-low pivot are confirmed on the current bar AND a price-low pivot and an RSI-low pivot were confirmed on the immediately preceding bar AND current price-low pivot < preceding bar's price-low pivot AND current RSI-low pivot > preceding bar's RSI-low pivot.
Short: A price-high pivot and an RSI-high pivot are confirmed on the current bar AND a price-high pivot and an RSI-high pivot were confirmed on the immediately preceding bar AND current price-high pivot > preceding bar's price-high pivot AND current RSI-high pivot < preceding bar's RSI-high pivot.
Long: MACD line crosses above its signal line.
Short: MACD line crosses below its signal line.
Long: A price-high pivot is confirmed AND its value > the preceding confirmed price-high pivot OR a price-low pivot is confirmed AND its value > the preceding confirmed price-low pivot.
Short: A price-high pivot is confirmed AND its value < the preceding confirmed price-high pivot OR a price-low pivot is confirmed AND its value < the preceding confirmed price-low pivot.