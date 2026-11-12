Calculation: Pivot high = a bar whose high is the highest among the same number of bars on each side (before and after it); it is confirmed only after the right-side bars have completed. Pivot low = the mirror image, using lows.
Calculation: Open pivot = a confirmed pivot whose price has not yet been broken by a close beyond it (a close above a pivot high, or below a pivot low, removes it). Only the 3 most recent open pivots of each kind are kept.
Calculation: ATR distance = multiplier * simple moving average of true range, taken on the entry bar.
Calculation: Stop level = for long, entry-bar low minus ATR distance; for short, entry-bar high plus ATR distance. Alternatives: the low (long) or high (short) of the entry bar or of a candle a fixed number of bars back; or entry price -/+ a fixed price distance.
Calculation: Target level = entry price +/- risk-reward ratio * |entry price - stop level| (plus for long, minus for short).
Long: no open position AND bar close time is within a time-of-day window (when enabled) AND close > price of any open pivot high AND (optional MA filter: close > moving average of close). Enter at the close of this bar.
Short: no open position AND bar close time is within a time-of-day window (when enabled) AND close < price of any open pivot low AND (optional MA filter: close < moving average of close). Enter at the close of this bar.
Exit: long, low <= stop level OR high >= target level
Exit: short, high >= stop level OR low <= target level