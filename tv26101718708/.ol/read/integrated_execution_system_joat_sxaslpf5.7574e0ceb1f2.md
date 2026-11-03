Calculation: Fast, slow, and trend averages = EMAs of close with fast, medium, and long lookbacks, respectively
Calculation: Bullish bias score = 30 if fast EMA > slow EMA > trend EMA, plus 20 if close > fast EMA and slow EMA, plus 20 if close > trend EMA, plus 30 if +DI > −DI
Calculation: Bearish bias score = 30 if fast EMA < slow EMA < trend EMA, plus 20 if close < fast EMA and slow EMA, plus 20 if close < trend EMA, plus 30 if −DI > +DI
Calculation: Bullish momentum score = 1 each for RSI above its bullish threshold, RSI above its value three bars ago, and MACD histogram positive and rising
Calculation: Bearish momentum score = 1 each for RSI below its bearish threshold, RSI below its value three bars ago, and MACD histogram negative and falling
Calculation: Bullish structure score = 1 each for close above the latest confirmed swing low and close above the fast EMA
Calculation: Bearish structure score = 1 each for close below the latest confirmed swing high and close below the fast EMA
Calculation: Buying pressure = smoothed EMA of the per-bar fraction (close − low)/(high − low), treating a zero-range bar as 0.5
Calculation: Pressure momentum = buying pressure minus its value at a shorter lookback ago
Calculation: Volatility ratio = ATR divided by its longer-lookback simple moving average
Calculation: Bullish qualification score = 3 if bullish bias score meets its threshold, plus bullish momentum score, plus bullish structure score, plus 2 if ADX meets its trend threshold, plus 1 if bullish pressure, plus 1 if a low sweep, plus 1 if a squeeze release, plus 1 if higher-timeframe MACD majority is bullish
Calculation: Bearish qualification score = 3 if bearish bias score meets its threshold, plus bearish momentum score, plus bearish structure score, plus 2 if ADX meets its trend threshold, plus 1 if bearish pressure, plus 1 if a high sweep, plus 1 if a squeeze release, plus 1 if higher-timeframe MACD majority is bearish
Calculation: Low sweep = low below the latest confirmed swing low and close above it; high sweep = high above the latest confirmed swing high and close below it
Calculation: Squeeze release = Bollinger Bands were inside the Keltner Channels on the previous bar and are not inside them on this bar
Calculation: Bullish pressure = pressure state is positive or pressure momentum exceeds its positive threshold; pressure state is positive when buying pressure exceeds 0.5 plus its threshold
Calculation: Bearish pressure = pressure state is negative or pressure momentum is below its negative threshold; pressure state is negative when buying pressure is below 0.5 minus its threshold
Calculation: Higher-timeframe MACD majority = configured higher-timeframe MACD histograms, each using its latest completed bar, have the required majority above zero for bullish or below zero for bearish
Calculation: Volatile regime = volatility ratio meets its expansion threshold while ADX is below its trend threshold; trending regime = ADX meets its trend threshold; ranging regime = volatility ratio is below its contraction threshold
Calculation: Long stop = the lower of the latest confirmed swing low (or close minus adaptive ATR distance if unavailable) and close minus adaptive ATR distance
Calculation: Short stop = the higher of the latest confirmed swing high (or close plus adaptive ATR distance if unavailable) and close plus adaptive ATR distance
Calculation: Adaptive ATR distance = ATR times the stop multiplier, increased in volatile regimes, reduced in ranging regimes, and increased in trending regimes when adaptive stops are enabled
Calculation: Adaptive target multiplier = increased when volatility ratio meets its expansion threshold, reduced when it is below its contraction threshold, otherwise 1
Calculation: Long first and second targets = close + (close − long stop) × respective reward/risk multiple × adaptive target multiplier
Calculation: Short first and second targets = close − (short stop − close) × respective reward/risk multiple × adaptive target multiplier
Calculation: Trailing stop for a long = initial long stop, raised to close minus the risk-based trailing offset after close − entry price reaches the risk-based trailing activation distance
Calculation: Trailing stop for a short = initial short stop, lowered to close plus the risk-based trailing offset after entry price − close reaches the risk-based trailing activation distance
Long: bullish qualification score meets its minimum AND (close crosses above fast EMA OR MACD histogram crosses above zero OR RSI is above 50 and rising versus three bars ago OR squeeze release and bullish pressure OR low sweep) AND volatile regime is allowed AND bullish structure score meets its required minimum when structure filtering is enabled AND volume meets its moving-average filter when enabled AND higher-timeframe MACD majority is bullish when alignment filtering is enabled AND trade cooldown and daily trade limit permit entry AND bar-close confirmation is satisfied when enabled
Short: bearish qualification score meets its minimum AND (close crosses below fast EMA OR MACD histogram crosses below zero OR RSI is below 50 and falling versus three bars ago OR squeeze release and bearish pressure OR high sweep) AND volatile regime is allowed AND bearish structure score meets its required minimum when structure filtering is enabled AND volume meets its moving-average filter when enabled AND higher-timeframe MACD majority is bearish when alignment filtering is enabled AND trade cooldown and daily trade limit permit entry AND bar-close confirmation is satisfied when enabled
Exit: long, low <= trailing stop
Exit: long, high >= long first target (partial exit when scaling is enabled)
Exit: long, high >= long second target
Exit: short, high >= trailing stop
Exit: short, low <= short first target (partial exit when scaling is enabled)
Exit: short, low <= short second target