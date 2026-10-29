Calculation: EMA = exponential moving average of close; use shorter and longer lookbacks where both are compared
Calculation: Volume average = simple moving average of volume
Calculation: Close position = (close - low) / (high - low); use 0.5 when high equals low
Calculation: ATR = average true range; use the shorter lookback for the ignite signal and the longer lookback for extension signals
Calculation: Extension baseline = selected EMA or SMA; the selection is an input
Calculation: Base ceiling and floor = track a confirmed pivot high and the lowest low since its pivot; accept a new ceiling only when it exceeds the prior ceiling and the prior low-to-high rise meets a threshold, or when no ceiling exists. Reset the ceiling if depth exceeds its maximum or duration exceeds its maximum; if a new high occurs before minimum duration, reset ceiling and floor to that bar's high and low
Calculation: Base breakout = base duration meets its minimum and close crosses above the base ceiling; classify the breakout as a high-tight flag when duration and depth are both small, otherwise as a cup-with-handle when handle lows in the most recent quarter of the base stay above its midpoint and depth is sufficient, otherwise as a double bottom when the intervening peak is at least one quarter of the way from the floor to the ceiling and depth is sufficient, otherwise as a flat base when duration and depth are small, otherwise as a base breakout
Long: bullish close crosses above both shorter and longer EMAs after at least two of the prior four closes were below the shorter EMA, and the previous close was at or below either EMA
Long: close crosses above the active base ceiling after the base meets its minimum duration
Long: previous bar has an upper wick exceeding a fraction of its range, current open is above the higher of its open and close but below its high, and current close > current open
Long: low < previous low AND close > previous high AND close > open
Long: low < the lowest low over the prior lookback AND close > that lowest low AND close > open
Long: absolute(close - open) >= an ATR multiple AND close position >= a threshold AND volume > a multiple of its average
Long: volume >= a multiple of its average AND close position >= a threshold
Long: low < the lowest low over the prior lookback AND close > that lowest low AND close > open
Long: close < extension baseline AND extension baseline - close >= an ATR multiple AND close position >= a threshold AND high < extension baseline AND volume > its average AND close < higher-timeframe EMA
Short: close > extension baseline AND close - extension baseline >= an ATR multiple AND close position <= a threshold AND low > extension baseline AND volume > its average AND close > higher-timeframe EMA
Short: previous close was at or above either EMA AND close crosses below both shorter and longer EMAs AND close < open