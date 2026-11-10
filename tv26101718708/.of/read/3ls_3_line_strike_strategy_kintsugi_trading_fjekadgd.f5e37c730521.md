Calculation: Bullish strike = each of the preceding three bars has close < open AND current close > open AND abs(current close - current open) > abs(previous close - previous open).
Calculation: Bearish strike = each of the preceding three bars has close > open AND current close < open AND abs(current close - current open) > abs(previous close - previous open).
Calculation: Initial long stop = entry bar low minus a price offset in fixed-stop mode; entry price minus ATR at entry multiplied by a factor in either ATR mode.
Calculation: Initial short stop = entry bar high plus a price offset in fixed-stop mode; entry price plus ATR at entry multiplied by a factor in either ATR mode.
Calculation: Active long stop = initial long stop in fixed-stop mode; otherwise start at the initial long stop and, at each subsequent bar close, replace it with close minus ATR multiplied by a factor if that value is greater than the previous stop and less than close. The updated stop applies from the next bar.
Calculation: Active short stop = initial short stop in fixed-stop mode; otherwise start at the initial short stop and, at each subsequent bar close, replace it with close plus ATR multiplied by a factor if that value is less than the previous stop and greater than close. The updated stop applies from the next bar.
Calculation: Long target = entry price plus a reward-to-risk factor multiplied by entry price minus initial long stop.
Calculation: Short target = entry price minus a reward-to-risk factor multiplied by initial short stop minus entry price.
Long: Bullish strike.
Short: Bearish strike.
Long: Bullish strike AND volume > SMA of volume multiplied by a factor AND shorter-period SMA of close > longer-period SMA of close AND position is flat AND (session filter disabled OR bar datetime is within the configured session).
Short: Bearish strike AND volume > SMA of volume multiplied by a factor AND shorter-period SMA of close < longer-period SMA of close AND position is flat AND (session filter disabled OR bar datetime is within the configured session).
Exit: long, low <= active long stop OR (stop mode is fixed-stop or ATR trail-stop AND high >= long target).
Exit: short, high >= active short stop OR (stop mode is fixed-stop or ATR trail-stop AND low <= short target).