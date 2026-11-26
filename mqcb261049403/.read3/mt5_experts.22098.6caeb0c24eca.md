Long: current time is within the placing window AND low[1] < Lowest(low, bars from channel start time through channel end time) - breakthrough
Short: current time is within the placing window AND high[1] > Highest(high, bars from channel start time through channel end time) + breakthrough
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance