Direction signals all use bar closes and the ATR of the prior higher-timeframe period. ATR is the 14-period Wilder ATR on the period bars, and the period is Day for the day timeframe. P = previous period close. U = P + 0.236*ATR (call trigger). L = P - 0.236*ATR (put trigger). Optional buffer b (fraction of ATR, default 0): long line = U + b*ATR, short line = L - b*ATR. Upper 38.2 = P + 0.382*ATR, upper 61.8 = P + 0.618*ATR, lower 38.2 = P - 0.382*ATR, lower 61.8 = P - 0.618*ATR.

LONG ENTRY (trigger): close > long line AND the previous close <= long line (the cross), only when no long is open, the entry budget for the session is left (default one long and one short per session) and the cooldown after the last long exit (default 3 bars) has passed. Going long closes any open short, since a long and a short are never open at the same time.
SHORT ENTRY (trigger): close < short line AND the previous close >= short line, with the same conditions mirrored.

EXIT LONG: while long, close < U (the trigger itself, not the buffered line). EXIT SHORT: while short, close > L. Reset all positions and entry counts at each new session or day.

PULLBACK RE-ENTRIES (only valid while the same-direction trade is open and the gate has opened, i.e. since entry some close was >= upper 38.2 for a long, or <= lower 38.2 for a short):
- Gate open long: close >= upper 38.2 and previous close < upper 38.2. Gate open short: close <= lower 38.2 and previous close > lower 38.2.
- Trigger pullback long: low <= U and close > U, only on the first bar of the touch (previous bar did not meet the same condition). Trigger pullback short: high >= L and close < L, first touch only.
- EMA8 pullback long (10-minute EMA8, needs chart of 10 minutes or finer): close <= upper 61.8, low <= EMA8 and close > EMA8, first touch only. The EMA8 is the 8-period EMA of 10-minute closes, last completed 10-minute bar. Short: close >= lower 61.8, high >= EMA8 and close < EMA8, first touch only.

FLIP SIGNAL (first hour, 10-minute chart or finer, evaluated on each new 10-minute bar, with the first hour being 60 minutes from the session start): bullish if the last completed 10-minute close > P and the one before it <= P and that earlier close was >= L. Bearish if the last completed 10-minute close < P and the one before it >= P and that earlier close was <= U.

Target (not a signal): 61.8 level. Gate completion (close crossing 61.8 level) is a scale-out event.