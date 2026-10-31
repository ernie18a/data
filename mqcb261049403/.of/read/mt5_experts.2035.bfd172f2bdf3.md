Calculation: Oscillator = 200 × triple-smoothed (selected price − lowest low over a lookback) / triple-smoothed (highest high − lowest low over the same lookback) − 100; use zero when the smoothed range is zero. Apply the same selected moving-average method and the same three successive smoothing periods to both series.
Calculation: Signal = moving average of the oscillator using the same method and the same period as the third smoothing stage.
Calculation: O and S = oscillator and signal on the selected indicator timeframe; use the chart timeframe or a higher or lower timeframe, with the selected signal bar being the last completed bar, a bar still forming, or an earlier completed bar. Subscripts 1 and 2 mean one and two bars before that signal bar.
Long: O > 0 AND O1 <= 0
Short: O < 0 AND O1 >= 0
Long: O > O1 AND O1 < O2
Short: O < O1 AND O1 > O2
Long: O > S AND O1 <= S1
Short: O < S AND O1 >= S1
Long: O > 0 AND O > O1
Long: O > 0 AND O < O1
Short: O < 0 AND O < O1
Short: O < 0 AND O > O1
Long: O > S
Short: O < S
Exit: short, O > 0
Exit: long, O < 0
Exit: short, O > O1
Exit: long, O < O1
Exit: short, O > S
Exit: long, O < S
Exit: long, low <= entry price − stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price − take-profit distance