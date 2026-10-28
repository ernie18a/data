Calculation: ATR = average true range over a lookback.
Calculation: HTF OHLC = open, high, low, and close of the last completed higher-timeframe bar.
Calculation: Volume feature = min(volume / moving-average volume, 3) / 3.
Calculation: HTF proximity feature = 1 - min(nearest distance from close to HTF open/high/low/close, divided by ATR, 3) / 3.
Calculation: Displacement feature = min(abs(close - open) / ATR, 3) / 3.
Calculation: Training label = 1 when the absolute close change after a fixed future-bar window exceeds the ATR at the sample bar times a threshold; otherwise 0. Retain only the most recent fixed number of labeled samples.
Calculation: Confidence = percentage of the k nearest training samples by Euclidean distance across the three features whose label is 1.
Calculation: Equal-high candidate = a confirmed pivot high within an ATR-scaled tolerance of the previous confirmed pivot high; equal-low candidate = same using pivot lows.
Calculation: Bullish order block = current up-candle body exceeds an ATR multiple and the previous candle is down; bearish order block = current down-candle body exceeds the same ATR multiple and the previous candle is up.
Calculation: Volume node = volume exceeds a multiplier of its moving average and is at least the highest volume in a rolling lookback.
Long: Confidence >= minimum confidence AND cooldown since the last accepted zone has elapsed AND the zone band does not overlap an existing zone within an ATR-scaled distance AND (bullish order block OR (NOT bullish order block AND NOT bearish order block AND NOT equal-high candidate AND equal-low candidate) OR (no order block or equal-high/equal-low candidate AND volume node AND close >= open)).
Short: Confidence >= minimum confidence AND cooldown since the last accepted zone has elapsed AND the zone band does not overlap an existing zone within an ATR-scaled distance AND (bearish order block OR (NOT bullish order block AND equal-high candidate) OR (no order block or equal-high/equal-low candidate AND volume node AND close < open)).