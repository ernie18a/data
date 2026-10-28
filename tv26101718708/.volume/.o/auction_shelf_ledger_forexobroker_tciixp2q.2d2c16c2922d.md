Calculation: Confirmed pivot high/low = a high/low greater/less than the highs/lows of the configured number of bars on both sides; register it when confirmed.
Calculation: Shelf = a pivot price clustered with an existing shelf if within the configured ATR-based tolerance; increment that shelf’s touch count and recenter its price as the mean of its prior price and the pivot. Otherwise create a shelf with one touch. Keep only the configured maximum, removing the oldest when exceeded.
Calculation: Active shelf = the strong shelf with the smallest absolute distance from the current close; strong means touch count meets the configured minimum.
Calculation: Shelf test = current low <= active shelf price + configured ATR buffer AND current high >= active shelf price - configured ATR buffer.
Calculation: Upward rejection = shelf test AND current close > active shelf price + ATR buffer AND current close > current open.
Calculation: Downward rejection = shelf test AND current close < active shelf price - ATR buffer AND current close < current open.
Calculation: Bullish bias = set on upward rejection and remains until a downward rejection; bearish bias = set on downward rejection and remains until an upward rejection.
Long: In rejection-only mode, upward rejection; otherwise bullish bias AND close crosses above the reclaim EMA. AND optional session filter passes AND position is not already long AND configured cooldown has elapsed since the last signal AND bar is confirmed.
Short: In rejection-only mode, downward rejection; otherwise bearish bias AND close crosses below the reclaim EMA. AND optional session filter passes AND position is not already short AND configured cooldown has elapsed since the last signal AND bar is confirmed.
Long: Upward rejection.
Short: Downward rejection.