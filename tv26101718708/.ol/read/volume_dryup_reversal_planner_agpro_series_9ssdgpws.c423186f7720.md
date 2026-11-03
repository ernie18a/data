Calculation: Relative volume = current volume / simple moving average of volume over a lookback
Calculation: Range ratio = current high-low range / simple moving average of high-low range over a lookback
Calculation: Dry-up pocket = highest high and lowest low over a rolling lookback, captured on the first completed bar where relative volume and range ratio are each at or below their respective thresholds, after the preceding bar did not meet both conditions; create or replace the pocket only when no reversal is active and no pocket exists, the existing pocket has expired, or its age has reached the refresh interval
Calculation: Pocket ATR = ATR on the pocket creation bar
Calculation: Reversal buffer = pocket ATR × reversal buffer factor
Calculation: Failure shelf = pocket ATR × failure shelf factor
Long: completed bar AND an unexpired dry-up pocket exists AND the pocket was created on an earlier bar AND no reversal is active AND close > pocket high + reversal buffer AND close > open
Short: completed bar AND an unexpired dry-up pocket exists AND the pocket was created on an earlier bar AND no reversal is active AND close < pocket low - reversal buffer AND close < open
Exit: long position, completed bar AND close < pocket low - failure shelf
Exit: short position, completed bar AND close > pocket high + failure shelf