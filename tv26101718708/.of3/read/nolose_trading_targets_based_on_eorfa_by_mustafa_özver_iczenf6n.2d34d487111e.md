Calculation: Smoothed price = WMA(VWAP + reference-price input, lookback parameter)
Calculation: Price score = (smoothed price - EMA(smoothed price, score lookback)) / StDev(smoothed price, score lookback)
Calculation: Long signal = price score < -threshold parameter AND change(price score) > 0
Calculation: Short signal = price score > threshold parameter AND change(price score) < 0
Calculation: Base lower level = min(OHLC4, HLC3, HL2, open, close)
Calculation: Base upper level = max(OHLC4, HLC3, HL2, open, close)
Calculation: Long candidate = long signal one bar ago OR long setup active one bar ago; initially 0
Calculation: Short candidate = short signal one bar ago OR short setup active one bar ago; initially 0
Calculation: Long boundary = long candidate ? long boundary one bar ago : base upper level
Calculation: Short boundary = short candidate ? short boundary one bar ago : base lower level
Calculation: Long low trail = long candidate ? min(long low trail one bar ago, low) : low; use 0 when the prior value is unavailable
Calculation: Short high trail = short candidate ? max(short high trail one bar ago, high) : high; use 0 when the prior value is unavailable
Calculation: Long reset line = first retracement parameter × (short high trail - short boundary) + short boundary
Calculation: Short reset line = fourth retracement parameter × (long boundary - long low trail) + long low trail
Calculation: Long setup active = long candidate AND NOT (long boundary <= max(open, close) OR short signal OR prior short reset line < close); use current high when the prior short reset line is unavailable
Calculation: Short setup active = short candidate AND NOT (short boundary >= min(open, close) OR long signal OR prior long reset line > close); use current low when the prior long reset line is unavailable
Calculation: Upper setup level = long setup active ? long boundary : short setup active ? short high trail : reference-price input
Calculation: Lower setup level = short setup active ? short boundary : long setup active ? long low trail : reference-price input
Calculation: Valid setup = (long setup active OR short setup active) AND change(upper setup level + lower setup level) = 0 AND upper setup level / lower setup level > 1 + tolerance parameter
Calculation: Retracement = (close - lower setup level) / (upper setup level - lower setup level)
Calculation: Long exit level = lower setup level + third retracement parameter × (upper setup level - lower setup level), captured when the long entry occurs
Calculation: Short exit level = lower setup level + second retracement parameter × (upper setup level - lower setup level), captured when the short entry occurs
Long: long signal AND NOT long setup active
Long: long setup active AND valid setup
Long: long setup active AND valid setup AND position is flat AND retracement > first retracement parameter AND retracement < second retracement parameter AND change(price score) > 0
Short: short signal AND NOT short setup active
Short: short setup active AND valid setup
Short: short setup active AND valid setup AND position is flat AND retracement > third retracement parameter AND retracement < fourth retracement parameter AND change(price score) < 0
Exit: long, close > long exit level
Exit: short, close < short exit level