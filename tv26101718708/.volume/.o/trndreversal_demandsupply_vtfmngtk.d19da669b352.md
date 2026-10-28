Calculation: Confirmed pivot high/low = a swing high/low using the same left- and right-bar lookbacks; recognize it only when the right-bar lookback has elapsed.
Calculation: Demand-zone hit = current low <= the top of an unhit demand zone created at a confirmed pivot low; its top is the pivot low plus ATR(14) at the pivot multiplied by a zone-width parameter. Retire the zone on its first hit.
Calculation: Supply-zone hit = current high >= the bottom of an unhit supply zone created at a confirmed pivot high; its bottom is the pivot high minus ATR(14) at the pivot multiplied by the same zone-width parameter. Retire the zone on its first hit.
Calculation: Bullish CHoCH pending = set when a demand-zone hit and close crosses above the latest confirmed pivot high; clear on a demand-zone hit unless set again that bar, or when a long is confirmed.
Calculation: Bearish CHoCH pending = set when a supply-zone hit and close crosses below the latest confirmed pivot low; clear on a supply-zone hit unless set again that bar, or when a short is confirmed.
Calculation: Volume delta = volume * (2 * (close - low) / (high - low) - 1); when high = low, use 0.
Calculation: Positive delta outlier = volume delta > its moving average + its standard deviation multiplied by a parameter; use the same lookback for both statistics.
Calculation: Negative delta outlier = volume delta < its moving average - its standard deviation multiplied by the same parameter.
Long: bullish CHoCH pending AND a new confirmed pivot low whose price is greater than the previous confirmed pivot low AND positive delta outlier
Short: bearish CHoCH pending AND a new confirmed pivot high whose price is less than the previous confirmed pivot high AND negative delta outlier