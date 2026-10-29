Calculation: Recent swing high/low = the latest high equal to the highest high and latest low equal to the lowest low over the same lookback; determine which occurred more recently.
Calculation: Projected path = if the high is more recent, [high, high − qR, high − qR + q²R, high − kR]; otherwise [low, low + qR, low + qR − q²R, low + kR], where R = high − low, q = configured projection ratio, and k = extension ratio.
Long: Any consecutive projected path price is lower than the next price.
Short: Any consecutive projected path price is higher than the next price.