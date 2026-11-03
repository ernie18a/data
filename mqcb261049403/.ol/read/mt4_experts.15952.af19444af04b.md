Calculation: Average daily range = arithmetic mean of high − low over the configured number of most recent completed daily bars (daily timeframe higher than the chart timeframe).
Calculation: Stop distance = configured stop-loss percentage of average daily range; target distance = configured take-profit percentage of average daily range.
Long: During the pending-order window from the configured placement hour until the configured removal hour, high >= buy-stop price; buy-stop price = Bid at placement + half the stop distance.
Short: During the pending-order window from the configured placement hour until the configured removal hour, low <= sell-stop price; sell-stop price = Bid at placement − half the stop distance.
Exit: long, low <= entry price − stop distance OR high >= entry price + target distance.
Exit: short, high >= entry price + stop distance OR low <= entry price − target distance.