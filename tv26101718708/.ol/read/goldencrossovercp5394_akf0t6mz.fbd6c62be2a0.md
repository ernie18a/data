Calculation: Short-, middle-, and long-term EMA = exponential moving averages of close, with progressively longer lookbacks
Calculation: Volume average = simple moving average of volume
Calculation: Signal candle range % = (signal candle high − signal candle low) / signal candle low × 100
Calculation: Long risk = min(entry price − signal candle low, entry price × risk cap %)
Calculation: Short risk = min(signal candle high − entry price, entry price × risk cap %)
Calculation: Reward multiple = 1 when signal candle range % > threshold; otherwise 2
Calculation: Long stop = entry price − long risk; long target = entry price + reward multiple × long risk
Calculation: Short stop = entry price + short risk; short target = entry price − reward multiple × short risk
Long: Previous-bar short-term EMA < previous-bar middle-term EMA AND previous-bar short-term EMA < previous-bar long-term EMA AND current short-term EMA > current middle-term EMA AND current short-term EMA > current long-term EMA AND volume > volume average
Short: Previous-bar short-term EMA > previous-bar middle-term EMA AND previous-bar short-term EMA > previous-bar long-term EMA AND current short-term EMA < current middle-term EMA AND current short-term EMA < current long-term EMA AND volume > volume average
Exit: Short, long condition
Exit: Long, short condition
Exit: Long, low ≤ long stop OR high ≥ long target OR datetime hour = configured exit hour AND datetime minute ≥ configured exit minute
Exit: Short, high ≥ short stop OR low ≤ short target OR datetime hour = configured exit hour AND datetime minute ≥ configured exit minute