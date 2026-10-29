Calculation: Bullish structure = latest confirmed swing high > previous confirmed swing high AND latest confirmed swing low > previous confirmed swing low; swing pivots use the chart timeframe and become confirmed after the right-side lookback bars complete
Calculation: Bearish structure = latest confirmed swing high < previous confirmed swing high AND latest confirmed swing low < previous confirmed swing low
Calculation: Upward BOS = close crosses above the second-latest confirmed swing high
Calculation: Downward BOS = close crosses below the second-latest confirmed swing low
Calculation: Demand zone = a price interval around a confirmed swing low, with interval width set by a price-relative buffer; valid after multiple confirmed swing lows fall in the interval
Calculation: Supply zone = a price interval around a confirmed swing high, with interval width set by a price-relative buffer; valid after multiple confirmed swing highs fall in the interval
Calculation: In demand = close is within any valid demand zone
Calculation: In supply = close is within any valid supply zone
Calculation: Upward BOS retest = after an upward BOS, before another such retest, low reaches the broken swing high within the price-relative buffer and close is above that swing high
Calculation: Downward BOS retest = after a downward BOS, before another such retest, high reaches the broken swing low within the price-relative buffer and close is below that swing low
Calculation: Bullish score = count of these true conditions: bullish structure, in demand, upward BOS, upward BOS retest, close above daily VWAP, shorter-lookback EMA above longer-lookback EMA, RSI above its midpoint
Calculation: Bearish score = count of these true conditions: bearish structure, in supply, downward BOS, downward BOS retest, close below daily VWAP, shorter-lookback EMA below longer-lookback EMA, RSI below its midpoint
Long: bullish score meets the configured minimum AND no long or short signal state is active AND trading is not locked after consecutive losses AND the long signal cooldown has elapsed
Short: bearish score meets the configured minimum AND no long or short signal state is active AND trading is not locked after consecutive losses AND the short signal cooldown has elapsed
Exit: long, low <= entry price - entry-bar ATR × configured stop multiplier OR high >= entry price + configured final reward-risk multiple × (entry price - stop price)
Exit: short, high >= entry price + entry-bar ATR × configured stop multiplier OR low <= entry price - configured final reward-risk multiple × (stop price - entry price)