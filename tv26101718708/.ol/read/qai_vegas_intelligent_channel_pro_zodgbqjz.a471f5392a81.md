Calculation: Vegas EMAs = two exponential moving averages with the shorter and longer lookbacks; optionally calculated on a higher timeframe using its last completed bar, otherwise on the chart timeframe.
Calculation: Confirmed pivot low/high = a low/high that is lower/higher than surrounding bars on both sides; confirmation requires the specified right-side bars to complete.
Calculation: Bollinger bandwidth = (upper band − lower band) / basis × 100; basis is a simple moving average and the bands are the basis plus/minus a standard-deviation multiple.
Calculation: Signed volume = volume when close > open, −volume when close < open, and 0 when close = open.
Long: close > EMA filter
Long: close > short-channel upper EMA
Long: close > Vegas upper EMA
Long: close > mid-channel upper EMA
Long: close > long-channel upper EMA
Long: volume > previous-bar volume
Long: close > open
Long: confirmed pivot low AND close > Vegas upper EMA AND volume > volume average
Long: confirmed pivot low AND close < Vegas lower EMA
Long: confirmed pivot low AND close > Vegas upper EMA AND previous close < previous Vegas upper EMA
Long: close crosses above Bollinger upper band AND Bollinger bandwidth > expansion threshold AND previous Bollinger bandwidth was not below the squeeze threshold
Long: close > 50-period SMA AND 50-period SMA > 100-period SMA AND 100-period SMA > 200-period SMA
Short: close <= EMA filter
Short: close <= short-channel upper EMA
Short: close <= Vegas upper EMA
Short: close <= mid-channel upper EMA
Short: close <= long-channel upper EMA
Short: volume <= previous-bar volume
Short: close < open
Short: confirmed pivot high AND close < Vegas lower EMA AND volume > volume average
Short: confirmed pivot high AND close > Vegas upper EMA
Short: confirmed pivot high AND close < Vegas lower EMA AND previous close > previous Vegas lower EMA
Short: close crosses below Bollinger lower band AND Bollinger bandwidth > expansion threshold AND previous Bollinger bandwidth was not below the squeeze threshold
Short: close < 50-period SMA AND 50-period SMA < 100-period SMA AND 100-period SMA < 200-period SMA
Short: signed volume <= 0