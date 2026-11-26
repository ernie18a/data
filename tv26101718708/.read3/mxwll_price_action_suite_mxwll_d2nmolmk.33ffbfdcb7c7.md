Calculation: Alternating pivots(lookback) = initialize state as high; on each bar set state to high if high[lookback] > highest(high, lookback), else to low if low[lookback] < lowest(low, lookback), else retain state; emit high[lookback] when state changes to high and low[lookback] when state changes to low
Long: new longer-lookback swing high > previous longer-lookback swing high
Short: new longer-lookback swing high <= previous longer-lookback swing high
Long: new longer-lookback swing low >= previous longer-lookback swing low
Short: new longer-lookback swing low < previous longer-lookback swing low
Short: new longer-lookback swing high
Long: new longer-lookback swing low
Long: close > open AND close[1] > open[1] AND close[2] > open[2]
Short: close < open AND close[1] < open[1] AND close[2] < open[2]
Long: close crosses above latest unbroken longer-lookback swing high AND ((prior external break direction is short AND selected external structure classes include CHoCH) OR (prior external break direction is not short AND selected external structure classes include BoS))
Short: close crosses below latest unbroken longer-lookback swing low AND ((prior external break direction is long AND selected external structure classes include CHoCH) OR (prior external break direction is not long AND selected external structure classes include BoS))
Long: close crosses above latest unbroken shorter-lookback swing high AND ((prior internal break direction is short AND selected internal structure classes include CHoCH) OR (prior internal break direction is not short AND selected internal structure classes include BoS))
Short: close crosses below latest unbroken shorter-lookback swing low AND ((prior internal break direction is long AND selected internal structure classes include CHoCH) OR (prior internal break direction is not long AND selected internal structure classes include BoS))