Calculation: Body = abs(close - open)
Calculation: Upper wick = high - max(open, close)
Calculation: Lower wick = min(open, close) - low
Long: low < lowest(low, pin-bar lookback)[1] AND close > low[1] AND (volume > volume[1] when the volume filter is enabled) AND Lower wick > body-ratio parameter × Body AND Lower wick > opposite-wick-ratio parameter × Upper wick
Short: high > highest(high, pin-bar lookback)[1] AND close < high[1] AND (volume > volume[1] when the volume filter is enabled) AND Upper wick > body-ratio parameter × Body AND Upper wick > opposite-wick-ratio parameter × Lower wick
Long: high > highest(high, outside-bar lookback)[1] AND low < lowest(low, outside-bar lookback)[1] AND close >= open
Short: high > highest(high, outside-bar lookback)[1] AND low < lowest(low, outside-bar lookback)[1] AND close < open