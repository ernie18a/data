Calculation: SMA5, SMA8, SMA13 = simple moving averages of close with short, medium, and long lookbacks, respectively
Calculation: ATR = average true range
Calculation: Negative RSI divergence = on each confirmed pivot high (using equal left and right pivot lookbacks), true if the new pivot high exceeds the previous pivot high and RSI at the pivot is below RSI at the previous pivot; otherwise false. Reset to false when close crosses below SMA13.
Calculation: Bullish morning star = prior bar bearish; current bar bullish and closes above the midpoint of the bar two bars ago; intervening bar's body is less than half the body two bars ago
Calculation: Bullish engulfing = prior bar bearish, current bar bullish, and current close > prior open
Calculation: Bullish inside bar = current high < prior high, current low > prior low, and current close > current open
Calculation: Bullish pin bar = lower wick > 2 × body and lower wick > upper wick
Calculation: Doji = body ≤ 10% of high-low range
Calculation: Higher-timeframe D1–D5 = use the last completed higher-timeframe bar: pivot = (high + low + close) / 3; range = high − low (use minimum tick if range is zero); D1–D5 = pivot + range × [0.382, 0.618, 1.0, 1.618, 2.618], respectively
Calculation: Trailing stop = initialize at entry-bar low × (1 − trailing percentage); while long, track the highest high since entry and its percentage-based stop. Raise the stop to entry price when high ≥ D1; to D1 when high ≥ D2; to D2 when high ≥ D3; to D3 when high ≥ D4. At each bar use the greatest of the existing stop and the applicable levels, including the percentage-based stop.
Long: SMA5 > SMA8 AND SMA8 > SMA13 AND low ≤ SMA8 + ATR × ambush sensitivity AND (bullish morning star OR bullish engulfing OR bullish inside bar OR bullish pin bar OR doji) AND negative RSI divergence is false AND entry bar is confirmed AND position is flat
Exit: long, low ≤ trailing stop OR high ≥ D5