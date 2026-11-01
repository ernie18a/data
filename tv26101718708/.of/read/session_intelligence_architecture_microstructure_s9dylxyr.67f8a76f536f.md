Calculation: Session state = for each configured session window, retain its first bar's open, latest in-session close, latest in-session ATR, cumulative volume, and session VWAP computed as cumulative sum of ((high + low + close) / 3 × volume) divided by cumulative volume; retain these values outside the session until the next session starts.
Calculation: Session relative volume = retained session volume divided by the mean total volume of up to the specified number of most recently completed sessions of the same type; update the mean when a session ends and calculate the ratio after that update on every bar. The dominance decision uses the preceding bar's ratio.
Calculation: Reference session high and low = the highest high and lowest low of the latest instance of the configured reference session, updated while it is active and retained afterward.
Calculation: Structure bias = initially neutral; update the latest confirmed swing high and low using pivots with equal left and right lookbacks, then set bias bullish when close crosses above the latest swing high and bearish when close crosses below the latest swing low. A crossover requires current close > current level and previous close <= previous level; a crossunder requires current close < current level and previous close >= previous level. Process the high crossover before the low crossunder if both occur on one bar.
Long: For any session, session close > session open AND session close - session open > session ATR × expansion multiplier AND preceding bar's session relative volume > relative-volume threshold.
Short: For any session, session close < session open AND session open - session close > session ATR × expansion multiplier AND preceding bar's session relative volume > relative-volume threshold.
Long: For any session, session close > session VWAP.
Short: For any session, session close <= session VWAP.
Long: For any session, session open != 0 AND session close >= session open.
Short: For any session, session open != 0 AND session close < session open.
Long: A configured later session is active AND the reference session is inactive AND low < reference session low AND close > reference session low.
Short: A configured later session is active AND the reference session is inactive AND high > reference session high AND close < reference session high.
Long: A configured later session is active AND the reference session is inactive AND close > reference session high AND high > low AND abs(close - open) / (high - low) >= body-ratio threshold.
Short: A configured later session is active AND the reference session is inactive AND close < reference session low AND high > low AND abs(close - open) / (high - low) >= body-ratio threshold.
Long: Close crosses above the latest confirmed swing high AND structure bias immediately before this crossover is bearish.
Short: Close crosses below the latest confirmed swing low AND structure bias immediately before this crossunder is bullish.