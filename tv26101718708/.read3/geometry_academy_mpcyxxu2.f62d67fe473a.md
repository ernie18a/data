Calculation: Relative strength change = 100 × ((close / benchmark close) / (close[lookback] / benchmark close[lookback]) − 1), using benchmark closes from the chart timeframe with lookahead off
Calculation: Anchored VWAP = sum(((high + low + close) / 3) × volume) / sum(volume) since the latest bar confirming a pivot high or low (pivot-left and pivot-right lookbacks); treat missing volume as zero
Long: On a confirmed chart bar, close crosses above the Ichimoku cloud top calculated with separate Tenkan, Kijun, and Senkou Span B lookbacks, using cloud values from the displacement lookback ago
Short: On a confirmed chart bar, close crosses below the Ichimoku cloud bottom calculated with separate Tenkan, Kijun, and Senkou Span B lookbacks, using cloud values from the displacement lookback ago
Long: On a confirmed chart bar, Ichimoku Tenkan-sen (Tenkan lookback) crosses above Ichimoku Kijun-sen (Kijun lookback)
Short: On a confirmed chart bar, Ichimoku Tenkan-sen (Tenkan lookback) crosses below Ichimoku Kijun-sen (Kijun lookback)
Long: On a confirmed chart bar, close crosses above Anchored VWAP
Short: On a confirmed chart bar, close crosses below Anchored VWAP
Long: On a confirmed chart bar, relative strength change crosses above zero
Short: On a confirmed chart bar, relative strength change crosses below zero
Short: The latest three confirmed alternating pivots (pivot high-low-high, using pivot-left and pivot-right lookbacks) have highs within ATR(lookback) at the pivot-right bar × tolerance, and the intermediate low is below both highs; while pending, close crosses below that low before a close above the higher high plus the same tolerance
Long: The latest three confirmed alternating pivots (pivot low-high-low, using pivot-left and pivot-right lookbacks) have lows within ATR(lookback) at the pivot-right bar × tolerance, and the intermediate high is above both lows; while pending, close crosses above that high before a close below the lower low minus the same tolerance