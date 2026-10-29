Calculation: Candle body = max(abs(close − open), minimum price tick)
Calculation: Upper wick = high − max(open, close); lower wick = min(open, close) − low
Calculation: Prior-volume average = simple moving average of volume over the selected lookback, excluding the current bar
Calculation: Volume spread = volume × (high − low)
Calculation: Confirmed swing high/low = pivot high/low confirmed after the selected number of bars to its right; retain the latest unbroken pivot
Calculation: Structure state = bullish or bearish after price breaks the latest confirmed pivot high or low, respectively; a major break resets internal pivots
Calculation: Rolling range high/low = highest high / lowest low over the selected lookback, excluding the current bar
Calculation: Extended-price boundary = EMA ± (standard deviation of close over the EMA lookback × selected multiplier)
Long: close > open AND (volume ≥ prior-volume average × peak-volume multiplier OR (volume ≥ prior-volume average × surge-volume multiplier OR volume spread ≥ maximum prior volume spread) OR (volume ≥ prior-volume average × pulse-volume multiplier AND neither surge nor peak condition applies))
Short: close ≤ open AND (volume ≥ prior-volume average × peak-volume multiplier OR (volume ≥ prior-volume average × surge-volume multiplier OR volume spread ≥ maximum prior volume spread) OR (volume ≥ prior-volume average × pulse-volume multiplier AND neither surge nor peak condition applies))
Long: close ≤ open AND volume ≥ prior-volume average × extreme-volume multiplier AND close < extended-price lower boundary AND candle body > average candle body × body-size multiplier
Short: close > open AND volume ≥ prior-volume average × extreme-volume multiplier AND close > extended-price upper boundary AND candle body > average candle body × body-size multiplier
Long: RSI crosses above its oversold threshold
Short: RSI crosses below its overbought threshold
Long: low < selected sweep reference AND close > selected sweep reference AND lower wick / candle body ≥ wick ratio AND volume > prior-volume average × volume multiplier AND (range ≥ ATR OR ATR filter disabled) AND (bullish structure state OR structure filter disabled)
Short: high > selected sweep reference AND close < selected sweep reference AND upper wick / candle body ≥ wick ratio AND volume > prior-volume average × volume multiplier AND (range ≥ ATR OR ATR filter disabled) AND (bearish structure state OR structure filter disabled)
Long: selected location condition passes AND close < open AND volume > selected volume reference × volume multiplier AND lower wick / candle body ≥ wick ratio AND candle body < ATR × body limit AND low < previous low AND cooldown since prior bullish condition has elapsed
Short: selected location condition passes AND close > open AND volume > selected volume reference × volume multiplier AND upper wick / candle body ≥ wick ratio AND candle body < ATR × body limit AND high > previous high AND cooldown since prior bearish condition has elapsed
Long: volume ≥ prior-volume average × volume multiplier AND close ≥ EMA × (1 + distance percentage) AND (low ≥ rolling range high OR recent-high filter disabled)
Short: volume ≥ prior-volume average × volume multiplier AND close ≤ EMA × (1 − distance percentage) AND (high ≤ rolling range low OR recent-low filter disabled)
Long: candle body > prior average candle body × body multiplier AND volume > prior-volume average × volume multiplier AND low < rolling range low AND close > rolling range low AND close > open
Short: candle body > prior average candle body × body multiplier AND volume > prior-volume average × volume multiplier AND high > rolling range high AND close < rolling range high AND close < open
Long: lower wick ≥ candle body × wick ratio AND upper wick ≤ candle body × 0.2 AND volume ≥ prior-volume average × volume multiplier AND abs(close − EMA) ≥ EMA × distance percentage
Short: upper wick ≥ candle body × wick ratio AND lower wick ≤ candle body × 0.2 AND volume ≥ prior-volume average × volume multiplier AND abs(close − EMA) ≥ EMA × distance percentage
Long: close > latest confirmed internal or external pivot high, using close or high as the break price according to the selected break rule
Short: close < latest confirmed internal or external pivot low, using close or low as the break price according to the selected break rule