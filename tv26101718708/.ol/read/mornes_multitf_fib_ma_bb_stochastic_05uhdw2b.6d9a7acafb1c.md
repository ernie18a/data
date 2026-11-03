Calculation: Fast EMA = EMA(close, shorter lookback)
Calculation: Slow EMA = EMA(close, longer lookback)
Calculation: Bollinger middle = SMA(close, lookback)
Calculation: Long stop = Bollinger lower band at entry; thereafter, the greater of the prior stop and current Bollinger lower band
Calculation: Short stop = Bollinger upper band at entry; thereafter, the lesser of the prior stop and current Bollinger upper band
Long: While flat, fast EMA crosses above Bollinger middle or slow EMA and fast EMA is not above both; OR a long setup is armed when fast EMA first becomes above both Bollinger middle and slow EMA, remains so for fewer than the setup-validity bars, and close > Bollinger middle and (close − Bollinger middle ≤ maximum break distance × ATR OR ATR filter is off) and (high − low ≤ maximum candle range × ATR OR ATR filter is off)
Short: While flat, fast EMA crosses below Bollinger middle or slow EMA and fast EMA is not below both; OR a short setup is armed when fast EMA first becomes below both Bollinger middle and slow EMA, remains so for fewer than the setup-validity bars, and close < Bollinger middle and (Bollinger middle − close ≤ maximum break distance × ATR OR ATR filter is off) and (high − low ≤ maximum candle range × ATR OR ATR filter is off)
Exit: long, low ≤ long stop OR high ≥ Bollinger upper band OR slow EMA crosses below Bollinger middle
Exit: short, high ≥ short stop OR low ≤ Bollinger lower band OR slow EMA crosses above Bollinger middle