Long: Supertrend turns bullish
Short: Supertrend turns bearish
Calculation: Short moving average = selected moving average of close with the shortest lookback
Calculation: Middle moving average = selected moving average of open with a longer lookback than the short moving average
Calculation: Long moving average = selected moving average of close with a longer lookback than the middle moving average
Calculation: Moving-average spread = maximum of the three moving averages minus their minimum
Long: Short moving average > middle moving average AND moving-average spread > ATR(14) × separation percentage
Short: Middle moving average > short moving average AND moving-average spread > ATR(14) × separation percentage
Long: Close breaks above the latest recorded pivot high
Short: Close breaks below the latest recorded pivot low
Long: Close >= latest active bullish order-block level AND close <= that level + ATR(14)
Short: Close >= latest active bearish order-block level - ATR(14) AND close <= that level
Calculation: Latest active bullish order-block level = lowest low from the latest recorded pivot high through the bar that closes above that pivot high
Calculation: Latest active bearish order-block level = highest high from the latest recorded pivot low through the bar that closes below that pivot low