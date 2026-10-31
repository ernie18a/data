Calculation: Oscillator = a configurable moving average of close minus Ichimoku leading span A at its plotted position minus conversion line plus base line. Calculate on a configurable higher or lower timeframe using the last completed bar, or the still-forming bar if configured. The conversion and base line lookbacks are truncated from one-half and one-and-a-half times the same base lookback; leading span A is displaced forward by the base line lookback. Index oscillator values as O0 for the selected bar, O1 for its predecessor, and O2 for the bar before that.
Long: ((O0 > 0 AND O0 > O1) OR (O0 < 0 AND O0 < O1)) AND ((O1 = 0) OR (O1 = O2) OR (O1 > 0 AND O1 < O2) OR (O1 < 0 AND O1 > O2))
Short: ((O0 < 0 AND O0 > O1) OR (O0 > 0 AND O0 < O1)) AND ((O1 > 0 AND O1 > O2) OR (O1 > 0 AND O1 < O2) OR (O1 < 0 AND O1 < O2))
Exit: short, (O0 > 0 AND O0 > O1) OR (O0 < 0 AND O0 < O1)
Exit: long, (O0 < 0 AND O0 > O1) OR (O0 > 0 AND O0 < O1)
Exit: long, low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance
Exit: short, high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance