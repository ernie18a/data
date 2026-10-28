Calculation: HTF band position = (last completed HTF close − (HTF EMA(close) − band width × HTF ATR)) / (2 × band width × HTF ATR)
Calculation: Box high/low = highest high / lowest low over the configured number of most recent completed HTF bars; rolls on each HTF close until a bar qualifies
Calculation: HTF volume filter = last completed HTF volume ≥ configured multiple of its HTF simple-average volume
Calculation: Chart volume filter = current chart-bar volume ≥ configured multiple of its chart-timeframe simple-average volume
Calculation: Target price = broken box edge plus/minus an ATR-scaled distance; ATR is from the chart timeframe or HTF, and the distance multiple is fixed or scales with breakout volume relative to chart average volume
Long: on an HTF close, HTF band position ≤ lower threshold AND HTF volume filter
Long: box is armed or consolidating AND close > box high AND chart volume filter
Long: box is locked short AND close > box high
Short: on an HTF close, HTF band position ≥ upper threshold AND HTF volume filter
Short: box is armed or consolidating AND close < box low AND chart volume filter
Short: box is locked long AND close < box low
Exit: long, high ≥ long target price
Exit: short, low ≤ short target price