Calculation: Gravity = SMA of selected bar price multiplied by linear-weighted moving average of the same price over the same lookback; the selected price can be open, high, low, close, median, typical, weighted, (open + close) / 2, OHLC average, high if close > open otherwise low if close < open otherwise close, or (high + close) / 2 if close > open otherwise (low + close) / 2 if close < open otherwise close.
Calculation: Signal = selected simple, exponential, smoothed, or linear-weighted moving average of Gravity over an independently selected lookback. For the indicator markings, use chart bars; for the trading decisions, use a selectable chart, higher, or lower timeframe and a selectable last completed or still-forming bar, with the previous bar in that same timeframe.
Long: Gravity >= Signal.
Short: Gravity < Signal.
Long: Gravity >= Signal AND previous Gravity < previous Signal.
Short: Gravity < Signal AND previous Gravity >= previous Signal.
Exit: long, Gravity < Signal OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, Gravity >= Signal OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.