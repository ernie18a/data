Calculation: Previous completed daily high = high of the last completed bar on a timeframe higher than the chart timeframe
Calculation: Previous completed daily low = low of the last completed bar on a timeframe higher than the chart timeframe
Long: bar high >= previous completed daily high + price offset
Short: bar low <= previous completed daily low - price offset
Exit: long, bar low <= entry price - stop-loss distance OR bar high >= entry price + take-profit distance
Exit: short, bar high >= entry price + stop-loss distance OR bar low <= entry price - take-profit distance