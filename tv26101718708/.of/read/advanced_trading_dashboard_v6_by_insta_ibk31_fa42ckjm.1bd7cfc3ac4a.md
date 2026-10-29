Calculation: Bull score = count of: RSI is >55 and <75; fast EMA > slow EMA; MACD histogram >0 and greater than its previous value; stochastic %K > %D and %K <80; +DI > -DI and ADX >20; close > open and volume > its 20-bar SMA
Calculation: Bear score = count of: RSI is <45 and >25; fast EMA < slow EMA; MACD histogram <0 and less than its previous value; stochastic %K < %D and %K >20; -DI > +DI and ADX >20; close < open and volume > its 20-bar SMA
Calculation: Strong long = Bull score >=4 AND fast EMA > slow EMA AND RSI >50 AND MACD histogram >0 and greater than its previous value
Calculation: Strong short = Bear score >=4 AND fast EMA < slow EMA AND RSI <50 AND MACD histogram <0 and less than its previous value
Calculation: Bullish engulfing = previous candle close < previous candle open AND close > open AND close > previous candle open AND open < previous candle close
Calculation: Bearish engulfing = previous candle close > previous candle open AND close < open AND close < previous candle open AND open > previous candle close
Calculation: Hammer = high-low > 3*abs(close-open) AND (close-low)/(0.001+high-low) >0.6 AND (high-close)/(0.001+high-low) <0.1
Calculation: Shooting star = high-low > 3*abs(close-open) AND (high-close)/(0.001+high-low) >0.6 AND (close-low)/(0.001+high-low) <0.1
Calculation: Doji = abs(close-open) <= (high-low)*0.1
Calculation: Morning star = candle two bars ago is bearish AND previous candle is a doji AND current candle is bullish AND close > (open two bars ago + close two bars ago)/2
Calculation: Evening star = candle two bars ago is bullish AND previous candle is a doji AND current candle is bearish AND close < (open two bars ago + close two bars ago)/2
Calculation: Three soldiers = current and previous two candles are bullish AND close > previous close AND previous close > close two bars ago
Calculation: Three crows = current and previous two candles are bearish AND close < previous close AND previous close < close two bars ago
Long: (Bull score >=3 AND NOT Strong long) OR Strong long OR Bullish engulfing OR Hammer OR Morning star OR Three soldiers
Short: (Bear score >=3 AND NOT Strong short) OR Strong short OR Bearish engulfing OR Shooting star OR Evening star OR Three crows