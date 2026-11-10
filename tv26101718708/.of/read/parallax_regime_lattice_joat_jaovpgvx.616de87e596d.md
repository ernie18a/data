Calculation: Swing high/low = a high/low confirmed as a pivot using equal numbers of preceding and subsequent chart bars; use the latest confirmed pivot of each kind, including pivots confirmed on the current bar.
Calculation: Bullish structure break = close > latest swing high AND previous close <= current latest swing high. Bearish structure break = close < latest swing low AND previous close >= current latest swing low.
Calculation: Structure state = initially neutral; set bullish on a bullish structure break and bearish on a bearish structure break, retaining the state between breaks; if both occur, bearish takes precedence.
Calculation: Liquidity registry = retain a bounded number of confirmed swing highs and lows together, adding highs before lows and removing the oldest levels first. Each level is initially unswept. A sell-side sweep occurs when an unswept swing low has low < level AND close > level; a buy-side sweep occurs when an unswept swing high has high > level AND close < level. Mark swept levels as swept. Retain the most recent sweep side until another sweep occurs; if several occur on one bar, process levels oldest to newest.
Calculation: Body ratio = absolute value of close minus open divided by high minus low, or 0 when high equals low.
Calculation: Demand absorption = volume > volume SMA multiplied by a volume threshold AND body ratio < a body threshold AND close >= open AND close <= high minus a fraction of high minus low. Supply absorption = volume > volume SMA multiplied by the same volume threshold AND body ratio < the same body threshold AND close <= open AND close >= low plus the same fraction of high minus low.
Calculation: Trend score = sum of four terms, each +1 when its comparison is true and -1 otherwise: shorter EMA > intermediate EMA; intermediate EMA > longer EMA; close > mean of the three EMAs; positive directional indicator > negative directional indicator. All EMAs use the same source. Direction state is bullish when trend score >= a positive threshold, bearish when trend score <= its negative, and neutral otherwise.
Calculation: Choppiness = 100 multiplied by log10(sum of true range over the lookback divided by highest high minus lowest low over that lookback) divided by log10(lookback); use 50 when the high-low range is 0.
Calculation: Compression ratio = highest high minus lowest low over the compression lookback, divided by ATR multiplied by that lookback; use 1 when the denominator is not positive. Expansion = compression ratio >= its threshold AND choppiness < its ceiling AND ADX >= its floor.
Calculation: Normalized slope = clamp to the range 0–100 the sum of a midpoint and a positive multiplier times the rolling z-score of the average of the three EMAs' one-bar changes; use z-score 0 when its standard deviation is 0.
Calculation: Bias score = clamp the sum of the following signed contributions to symmetric bounds: direction-state weight; structure-state weight; healthy-trend weight in the direction-state direction when ADX >= its floor AND choppiness < its ceiling; structure-break weight positive for a bullish break, otherwise negative for a bearish break; absorption weight positive for demand absorption, otherwise negative for supply absorption; sweep weight positive for the most recent sell-side sweep or negative for the most recent buy-side sweep; slope weight positive when normalized slope > an upper threshold or negative when normalized slope < a lower threshold. Neutral or unmet contributions are 0. The direction-state weight is greater than the structure-state weight, which is greater than the equal healthy-trend and structure-break weights, which are greater than the absorption, sweep, and slope weights in that order.
Long: bullish structure break OR structure state = bullish
Short: bearish structure break OR structure state = bearish
Long: sell-side sweep OR most recent sweep side = sell-side
Short: buy-side sweep OR most recent sweep side = buy-side
Long: demand absorption
Short: supply absorption
Long: direction state = bullish OR direction state = neutral
Short: direction state = bearish
Long: expansion AND bias score > 0
Short: expansion AND bias score < 0
Long: bias score > a positive transition threshold AND previous bias score <= the same threshold
Short: bias score < the negative transition threshold AND previous bias score >= the same negative threshold