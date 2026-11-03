Calculation: Lower threshold = lowest low over a lookback, including the current bar, plus the distance between the highest high and lowest price multiplied by a risk fraction; the lowest price is the lower of the current close and the lookback lows.
Calculation: Upper threshold = highest high over the same lookback, including the current bar, minus the distance between the highest high and lowest price multiplied by the same risk fraction.
Calculation: SilverTrend state = bullish if close is above the upper threshold; bearish if close is below the lower threshold; otherwise retain the previous state.
Long: SilverTrend state is bullish AND the previous bar's SilverTrend state was not bullish
Short: SilverTrend state is bearish AND the previous bar's SilverTrend state was not bearish