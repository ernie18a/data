Calculation: Price ratio = close of one instrument on the still-forming T1 bar / close of another instrument on the still-forming T1 bar, sampled on chart bars
Calculation: Bars since peak = current chart bar index minus the most recent chart bar index where Price ratio equaled or exceeded every earlier Price ratio
Long: Bars since peak >= N
Long: On chart bars, Price ratio crosses above EMA(Price ratio, P)
Calculation: BTC-to-gold ratio = BTCUSD close on T1 / XAUUSD close on T1
Calculation: chart bars since BTC-to-gold ratio peak = current chart bar index - bar index of the latest bar whose BTC-to-gold ratio is at least every earlier bar's ratio
Long: chart bars since BTC-to-gold ratio peak >= bounce threshold
Long: BTC-to-gold ratio crosses above EMA(BTC-to-gold ratio, EMA length)