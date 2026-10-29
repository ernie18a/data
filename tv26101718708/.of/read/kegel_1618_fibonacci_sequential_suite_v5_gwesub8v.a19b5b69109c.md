Calculation: Confirmed pivot high = a bar high greater than the highs of the specified number of bars on both sides; confirmed pivot low = a bar low less than the lows of that many bars on both sides
Calculation: Fibonacci level = anchor0 + (anchor1 - anchor0) × level fraction; on a bullish break, anchor0 is the latest pivot low and anchor1 the latest pivot high; on a bearish break, anchor0 is the latest pivot high and anchor1 the latest pivot low
Calculation: Doji = high > low AND absolute(close - open) / (high - low) < the doji body fraction
Long: close crosses above the latest confirmed pivot high
Short: close crosses below the latest confirmed pivot low
Long: low < latest confirmed pivot low AND close > latest confirmed pivot low AND low equals the lowest low over twice the pivot lookback
Short: high > latest confirmed pivot high AND close < latest confirmed pivot high AND high equals the highest high over twice the pivot lookback
Long: volume[1] > 20-bar simple moving average of volume × volume-spike multiplier AND close[1] < open[1] AND current bar is a doji
Short: volume[1] > 20-bar simple moving average of volume × volume-spike multiplier AND close[1] > open[1] AND current bar is a doji
Long: consecutive closes each exceed the close 4 bars earlier, and the count reaches 6, 7, 8, 9, 11, or 13
Short: consecutive closes each are below the close 4 bars earlier, and the count reaches 6, 7, 8, 9, 11, or 13
Long: a bullish break has activated a setup AND price has reached the 1.618 extension AND subsequently retraced to the 1.0 level AND low <= the selected entry Fibonacci level AND no position is open AND (a recent bullish sweep exists if the sweep requirement is enabled)
Short: a bearish break has activated a setup AND price has reached the 1.618 extension AND subsequently retraced to the 1.0 level AND high >= the selected entry Fibonacci level AND no position is open AND (a recent bearish sweep exists if the sweep requirement is enabled)
Long: a bullish count reaches 13, and within the trigger-line validity period close > the low of that count's bar
Short: a bearish count reaches 13, and within the trigger-line validity period close < the high of that count's bar
Exit: long, high >= the setup's take-profit Fibonacci level OR low <= anchor0
Exit: short, low <= the setup's take-profit Fibonacci level OR high >= anchor0