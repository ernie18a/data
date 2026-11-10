Calculation: Source = close or, when Heikin Ashi is selected, (open + high + low + close) / 4; calculate each decision independently on each selected timeframe, using the last completed higher-timeframe bar or the last completed lower-timeframe bar within the chart bar, or the chart bar itself when timeframes match.
Calculation: ATR trailing stop = initialize the previous stop to zero when unavailable; let loss = ATR multiplied by a sensitivity parameter. If current and previous source are both above the previous stop, use max(previous stop, current source - loss); otherwise, if both are below the previous stop, use min(previous stop, current source + loss); otherwise, if current source is above the previous stop, use current source - loss; otherwise use current source + loss. Calculate ATR from the selected timeframe's ordinary high, low, and close.
Long: source > ATR trailing stop
Short: source < ATR trailing stop
Long: short-period EMA of source > medium-period EMA of source AND medium-period EMA of source > long-period EMA of source
Short: short-period EMA of source < medium-period EMA of source AND medium-period EMA of source < long-period EMA of source
Long: MACD signal line of source > 0
Short: MACD signal line of source < 0
Long: RSI of source > midpoint AND previous RSI <= midpoint OR RSI > midpoint AND RSI <= upper threshold OR RSI < lower threshold AND NOT (RSI < midpoint AND previous RSI >= midpoint)
Short: RSI of source < midpoint AND previous RSI >= midpoint OR RSI >= lower threshold AND RSI <= midpoint OR RSI > upper threshold AND NOT (RSI > midpoint AND previous RSI <= midpoint)