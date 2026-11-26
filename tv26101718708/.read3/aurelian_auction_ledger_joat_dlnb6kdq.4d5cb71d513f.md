Calculation: range width in ATR = (highest(high, range lookback) - lowest(low, range lookback)) / max(ATR(ATR lookback), minimum tick size)
Calculation: candle body efficiency = SMA(abs(close - open) / max(high - low, minimum tick size), range lookback)
Calculation: directional candle balance = SUM(sign(close - open), range lookback) / range lookback
Calculation: range compression score = 100 - clamp(100 × range width in ATR / compression ceiling, 0, 100)
Calculation: developing-map readiness = clamp(compression weight × range compression score + balance weight × (100 - 100 × abs(directional candle balance)) + body weight × (100 - 100 × prior chart bar candle body efficiency), 0, 100)
Calculation: upper developing band = lowest(low, range lookback) + upper-band fraction × (highest(high, range lookback) - lowest(low, range lookback))
Calculation: lower developing band = lowest(low, range lookback) + lower-band fraction × (highest(high, range lookback) - lowest(low, range lookback)); upper-band fraction > lower-band fraction
Calculation: active auction shell = after range data and ATR are available, activate when range width in ATR <= compression ceiling AND prior chart bar candle body efficiency <= body-efficiency ceiling AND abs(directional candle balance) <= directional-balance ceiling hold for the arming-persistence parameter consecutive chart bars; set shell high to highest(high, range lookback) and shell low to lowest(low, range lookback), then retain both until close > shell high + ATR(ATR lookback) × breakout buffer OR close < shell low - ATR(ATR lookback) × breakout buffer
Long: active auction shell AND confirmed chart bar AND close > shell high + ATR(ATR lookback) × breakout buffer
Short: active auction shell AND confirmed chart bar AND close < shell low - ATR(ATR lookback) × breakout buffer
Short: active auction shell AND confirmed chart bar AND high > shell high AND close < shell high
Long: active auction shell AND confirmed chart bar AND low < shell low AND close > shell low
Long: no active auction shell AND range data and ATR are available AND developing-map readiness >= readiness threshold AND confirmed chart bar AND close crosses above upper developing band
Short: no active auction shell AND range data and ATR are available AND developing-map readiness >= readiness threshold AND confirmed chart bar AND close crosses below lower developing band