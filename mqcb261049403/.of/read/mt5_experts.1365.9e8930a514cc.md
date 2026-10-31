Calculation: Trend oscillator = Smooth, using a selectable smoothing method and lookback, the integer-truncated value of 100 times the sum of votes divided by the number of votes. For each vote, compare close with a moving average of a selectable OHLC-derived price: vote +1 if close is greater, otherwise -1. Use the same selectable moving-average method with progressively longer lookbacks separated by a fixed step. For the indicator markings, calculate on the chart timeframe. For trading decisions, calculate on a selectable chart, higher, or lower timeframe; use the last completed bar or the still-forming bar according to the selected signal-bar offset, and use preceding bars from that same timeframe.
Long: Trend oscillator > 0
Short: Trend oscillator < 0
Long: Threshold mode selected AND trend oscillator > upper threshold AND previous trend oscillator <= upper threshold
Short: Threshold mode selected AND trend oscillator < lower threshold AND previous trend oscillator >= lower threshold
Long: Direction-change mode selected AND trend oscillator > previous trend oscillator AND previous trend oscillator < trend oscillator two bars ago
Short: Direction-change mode selected AND trend oscillator < previous trend oscillator AND previous trend oscillator > trend oscillator two bars ago
Exit: long, threshold mode selected AND trend oscillator < lower threshold
Exit: short, threshold mode selected AND trend oscillator > upper threshold
Exit: long, direction-change mode selected AND trend oscillator < previous trend oscillator
Exit: short, direction-change mode selected AND trend oscillator > previous trend oscillator
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance