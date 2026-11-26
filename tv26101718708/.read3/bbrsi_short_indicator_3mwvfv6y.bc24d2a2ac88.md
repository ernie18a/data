Calculation: safety-order deviation(k) = first safety-order deviation × sum((deviation step multiplier)^i, i = 0 to k−1)
Calculation: safety-order size(k) = first safety-order size × order-size multiplier^(k−1)
Calculation: running average entry = (base order size + sum of filled safety-order sizes) / (base order size / base entry price + sum of each filled safety-order size / its fill close)
Short: position is flat AND Bollinger Bands %B(close, BB lookback, BB deviation, T1 still-forming bar) crosses above BB level AND RSI(close, RSI lookback, T2 still-forming bar) crosses above RSI level; the crosses are evaluated on chart bars at close
Short: position is short AND fewer than the maximum safety orders are filled AND close >= base entry price × (1 + safety-order deviation(next safety order) / 100), evaluated at chart-bar close
Exit: short, close <= running average entry × (1 − take-profit distance / 100)