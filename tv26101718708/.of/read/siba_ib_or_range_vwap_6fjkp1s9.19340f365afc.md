Calculation: Initial Balance high/low = highest high / lowest low from the configured session start through end; use only after the interval is complete.
Calculation: Prior-session POC, VAH, VAL = volume-profile point of control and value-area bounds from the prior configured profile session. Use lower-timeframe bars, completed within each chart bar; distribute each bar’s volume evenly across price bins spanning its low to high, then grow the value area from the highest-volume bin toward the adjacent bin with greater volume until the configured percentage is reached.
Calculation: Daily ATR = ATR over the configured lookback on the last completed daily bar; lock its value when the Initial Balance completes.
Calculation: Breakout buffer = ATR × configured multiplier; if ATR is unavailable, use Initial Balance width × the same multiplier.
Calculation: Upside breakout state = set when Initial Balance is complete and close > Initial Balance high; reset when close < Initial Balance high − breakout buffer. Downside breakout state = set when Initial Balance is complete and close < Initial Balance low; reset when close > Initial Balance low + breakout buffer.
Calculation: Trend long stop = the closer of Initial Balance low and entry price − (ATR × configured stop multiplier); if ATR is unavailable, use Initial Balance low. Trend short stop = the closer of Initial Balance high and entry price + (ATR × configured stop multiplier); if ATR is unavailable, use Initial Balance high.
Calculation: Trend long target = Initial Balance high + 0.5 × Initial Balance width. Trend short target = Initial Balance low − 0.5 × Initial Balance width.
Calculation: Fade long stop = prior-session VAL − ATR × configured buffer multiplier; if ATR is unavailable, subtract 10% of prior-session value-area width from VAL. Fade short stop = prior-session VAH + ATR × configured buffer multiplier; if ATR is unavailable, add 10% of prior-session value-area width to VAH.
Calculation: Fade target = prior-session POC.
Long: Initial Balance is complete AND close > Initial Balance high AND the upside breakout state was false on the prior bar.
Short: Initial Balance is complete AND close < Initial Balance low AND the downside breakout state was false on the prior bar.
Long: Initial Balance is complete AND the downside breakout state was previously set AND close > Initial Balance low AND prior-bar close ≤ Initial Balance low.
Short: Initial Balance is complete AND the upside breakout state was previously set AND close < Initial Balance high AND prior-bar close ≥ Initial Balance high.
Long: Initial Balance is complete AND this session’s VAL rejection is armed AND prior-session VAL and POC exist AND low ≤ prior-session VAL AND close > prior-session VAL AND close < prior-session POC.
Short: Initial Balance is complete AND this session’s VAH rejection is armed AND prior-session VAH and POC exist AND high ≥ prior-session VAH AND close < prior-session VAH AND close > prior-session POC.
Exit: Long, low ≤ stop OR high ≥ target.
Exit: Short, high ≥ stop OR low ≤ target.