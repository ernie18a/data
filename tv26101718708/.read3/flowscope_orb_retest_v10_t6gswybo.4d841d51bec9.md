Calculation: Opening range high = highest chart-bar high during the configured opening-range window for the current session, held until the next session’s window.
Calculation: Opening range low = lowest chart-bar low during the configured opening-range window for the current session, held until the next session’s window.
Calculation: Eligible bar = current chart bar is within the configured active-session window, outside the configured opening-range window, and the current session’s opening range is complete; evaluate session windows in the configured session timezone.
Calculation: Retest zone width = clamp(ATR(lookback) × multiplier, minimum width, maximum width).
Calculation: Valid upward breakout = an eligible close above the opening range high has occurred this session, with no later eligible close below the opening range high.
Calculation: Valid downward breakout = an eligible close below the opening range low has occurred this session, with no later eligible close above the opening range low.
Calculation: Two-sided breakout = eligible closes have occurred both above the opening range high and below the opening range low this session.
Calculation: Active long retest = a bullish retest confirmation has occurred this session and no long trigger has occurred on or after the latest confirmation this session.
Calculation: Active short retest = a bearish retest confirmation has occurred this session and no short trigger has occurred on or after the latest confirmation this session.
Long: Eligible bar AND close > opening range high AND no earlier eligible close this session > opening range high.
Short: Eligible bar AND close < opening range low AND no earlier eligible close this session < opening range low.
Long: Valid upward breakout AND NOT Two-sided breakout.
Short: Valid downward breakout AND NOT Two-sided breakout.
Long: Eligible bar AND Valid upward breakout AND low <= opening range high + Retest zone width AND high >= opening range high - Retest zone width.
Short: Eligible bar AND Valid downward breakout AND high >= opening range low - Retest zone width AND low <= opening range low + Retest zone width.
Long: Eligible bar AND Valid upward breakout AND low <= opening range high + Retest zone width AND high >= opening range high - Retest zone width AND close > opening range high AND close > open.
Short: Eligible bar AND Valid downward breakout AND high >= opening range low - Retest zone width AND low <= opening range low + Retest zone width AND close < opening range low AND close < open.
Long: Active long retest.
Short: Active short retest.
Long: Eligible bar AND Active long retest was true on the preceding chart bar AND high > the latest bullish retest-confirmation bar’s high as stored on the preceding chart bar AND (volume requirement is disabled OR (SMA(volume, lookback) > 0 AND volume / SMA(volume, lookback) >= elevated-volume threshold)).
Short: Eligible bar AND Active short retest was true on the preceding chart bar AND low < the latest bearish retest-confirmation bar’s low as stored on the preceding chart bar AND (volume requirement is disabled OR (SMA(volume, lookback) > 0 AND volume / SMA(volume, lookback) >= elevated-volume threshold)).