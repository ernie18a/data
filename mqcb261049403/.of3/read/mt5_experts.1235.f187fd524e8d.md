Calculation: ExtremumScore(lookback) = upward term + downward term, computed on T1 bars; initialize both terms to 0, then for each i from 0 through lookback - 1 in ascending order, replace upward term with high - high[i] if high > high[i] and high - high[i] > upward term, and replace downward term with high - low[i] if low < low[i] and low - low[i] < downward term
Long: ExtremumScore(lookback, T1)[signal-bar index] > 0 AND ExtremumScore(lookback, T1)[signal-bar index + 1] < 0
Short: ExtremumScore(lookback, T1)[signal-bar index] < 0 AND ExtremumScore(lookback, T1)[signal-bar index + 1] > 0
Exit: long, ExtremumScore(lookback, T1)[signal-bar index] < 0 AND ExtremumScore(lookback, T1)[signal-bar index + 1] <= 0
Exit: short, ExtremumScore(lookback, T1)[signal-bar index] > 0 AND ExtremumScore(lookback, T1)[signal-bar index + 1] >= 0
Exit: long, low <= entry price - stop-loss distance in points OR high >= entry price + take-profit distance in points
Exit: short, high >= entry price + stop-loss distance in points OR low <= entry price - take-profit distance in points