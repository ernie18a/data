Calculation: Relative volume = current bar volume divided by its simple moving average over a lookback.
Calculation: Range ratio = current bar high minus low, divided by the simple moving average of high minus low over a separate lookback.
Calculation: Dry-up pocket = on the first completed bar where relative volume and range ratio are each below their thresholds, record the highest high and lowest low over a pocket window ending on that bar, plus that bar’s ATR; retain the pocket until its age exceeds a limit, and replace it only when no reversal is active and it is absent, expired, or old enough to refresh.
Calculation: Reversal buffer = pocket-creation ATR multiplied by a buffer parameter; failure shelf distance = pocket-creation ATR multiplied by a shelf parameter.
Long: A dry-up pocket is active, no reversal is active, the current completed bar is after the pocket bar, close > pocket high + reversal buffer, and close > open.
Short: A dry-up pocket is active, no reversal is active, the current completed bar is after the pocket bar, close < pocket low - reversal buffer, and close < open.
Exit: long, close < pocket low - failure shelf distance.
Exit: short, close > pocket high + failure shelf distance.