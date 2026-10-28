Calculation: Opening range high/low = highest high and lowest low during the first configured number of minutes from each session open; available after that interval completes
Calculation: Opening-range volume baseline = exponentially smoothed opening-range volume from completed sessions, using the configured lookback; compare today’s opening-range volume with the baseline before updating it
Calculation: Opening-range direction = sign of the close of the first bar after the opening-range interval versus the open of the first bar in that interval
Calculation: Target 1 = either the breakout edge plus/minus a configured multiple of opening-range size, or entry price plus/minus a configured multiple of risk
Calculation: Risk stop = either the opposite opening-range edge, the opening-range midpoint, or entry price minus/plus a configured multiple of ATR
Calculation: Failed-break target = opposite opening-range edge; failed-break stop = most extreme high/low reached since the accepted break
Long: opening range is complete AND no break has yet been accepted this session AND close > opening-range high (and previous close > opening-range high if confirmation is required) AND (both directions are allowed OR opening-range direction is up) AND (relative-volume filter is disabled OR opening-range volume is at least the configured multiple of its baseline)
Long: an accepted short break has closed back above the opening-range low
Long: after an accepted long break and before it fails, low <= opening-range high AND close > opening-range high
Long: high exceeds a prior-day or prior-week low by at least the configured ATR fraction AND close is above that level
Short: opening range is complete AND no break has yet been accepted this session AND close < opening-range low (and previous close < opening-range low if confirmation is required) AND (both directions are allowed OR opening-range direction is down) AND (relative-volume filter is disabled OR opening-range volume is at least the configured multiple of its baseline)
Short: an accepted long break has closed back below the opening-range high
Short: after an accepted short break and before it fails, high >= opening-range low AND close < opening-range low
Short: high exceeds a prior-day or prior-week high by at least the configured ATR fraction AND close is below that level
Exit: long, high >= target 1 OR low <= risk stop OR high >= failed-break target OR low <= failed-break stop
Exit: short, low <= target 1 OR high >= risk stop OR low <= failed-break target OR high >= failed-break stop