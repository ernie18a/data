Calculation: Regression signal line = EMA(LinearRegression(close, regression lookback, current endpoint), regression smoothing)
Calculation: Simple true-range average = SMA(TrueRange, volatility lookback)
Calculation: Adaptive trend line = in cloud-line mode, if RSI(close, RSI lookback) is at or above its midpoint threshold then max(previous adaptive trend line, low − simple true-range average × volatility multiplier), else min(previous adaptive trend line, high + simple true-range average × volatility multiplier); otherwise Supertrend(volatility multiplier, volatility lookback)
Calculation: Cloud upper edge = max(EMA(close, fast EMA lookback), regression signal line, adaptive trend line lagged by the band-lag parameter)
Calculation: Cloud lower edge = min(EMA(close, fast EMA lookback), regression signal line, adaptive trend line lagged by the band-lag parameter)
Calculation: Confirmed pivot high = latest confirmed PivotHigh(high, pivot confirmation lookback, pivot confirmation lookback)
Calculation: Confirmed pivot low = latest confirmed PivotLow(low, pivot confirmation lookback, pivot confirmation lookback)
Calculation: Upper pivot reference = Highest(confirmed pivot high, pivot sizing lookback)
Calculation: Lower pivot reference = Lowest(confirmed pivot low, pivot sizing lookback)
Calculation: Cloud line = if Andean Oscillator bullish component > bearish component then max(previous cloud line, cloud lower edge), else if bearish component > bullish component then min(previous cloud line, cloud upper edge), else previous cloud line; initially zero
Calculation: Cloud direction = up when the cloud line rises over the slope lookback, down when it falls over that lookback, otherwise previous cloud direction; initially neutral
Calculation: Cloud-line display state = rising when the cloud line rises over the slope lookback, falling when it falls over that lookback, neutral when it equals the previous bar, otherwise previous display state; initially neutral
Calculation: Cloud-fill state = bullish when the selected pivot/cloud mode has close above the cloud upper edge, or the selected pivot/cloud/regression mode has close above that edge and the regression signal line is rising over the slope lookback; bearish under the corresponding below-edge and falling conditions; in cloud-line mode, equal to cloud-line display state; otherwise previous cloud-fill state; initially neutral
Calculation: Volume baseline = SMA(volume, volume lookback)
Calculation: High tracker = high when flat; while in a position, current high if it exceeds the previous bar high, otherwise previous high
Calculation: Low tracker = low when flat; while in a position, current low if it is below the previous bar low, otherwise previous low
Calculation: Long one-risk threshold = entry price + (entry price − lower pivot reference at the long action-state change) × breakeven activation multiple
Calculation: Short one-risk threshold = entry price − (upper pivot reference at the short action-state change − entry price) × breakeven activation multiple
Calculation: Long-close condition = in cloud-line mode, cloud direction changes to down; otherwise close < cloud lower edge AND close < confirmed pivot low
Calculation: Short-close condition = in cloud-line mode, cloud direction changes to up; otherwise close > cloud upper edge AND close > confirmed pivot high
Calculation: Long stop level = lower pivot reference when the short-close condition is true; else entry price when in a long position and high tracker > long one-risk threshold; else previous long stop level; initially zero
Calculation: Short stop level = upper pivot reference when the long-close condition is true; else entry price when in a short position and low tracker < short one-risk threshold; else previous short stop level; initially zero
Calculation: Long target 1 = entry price + (entry price − lower pivot reference at the long action-state change) × first reward/risk parameter; hold until the next long action-state change
Calculation: Long target 2 = entry price + (entry price − lower pivot reference at the long action-state change) × second reward/risk parameter; hold until the next long action-state change
Calculation: Short target 1 = entry price − (upper pivot reference at the short action-state change − entry price) × first reward/risk parameter; hold until the next short action-state change
Calculation: Short target 2 = entry price − (upper pivot reference at the short action-state change − entry price) × second reward/risk parameter; hold until the next short action-state change
Calculation: Long action state = datetime > configured start AND datetime < configured end AND (position is flat or short) AND (in pivot/cloud mode, close > confirmed pivot high AND close > cloud upper edge; OR in pivot/cloud/regression mode, close > confirmed pivot high AND close > cloud upper edge AND regression signal line rises over the slope lookback; OR in cloud-line mode, cloud direction is up AND close > cloud upper edge)
Calculation: Short action state = datetime > configured start AND datetime < configured end AND (position is flat or long) AND (in pivot/cloud mode, close < confirmed pivot low AND close < cloud lower edge; OR in pivot/cloud/regression mode, close < confirmed pivot low AND close < cloud lower edge AND regression signal line falls over the slope lookback; OR in cloud-line mode, cloud direction is down AND close < cloud lower edge)
Calculation: Long entry lock = set when cloud direction changes to up; else clear when low tracker crosses below the long stop level; else set while in a long position; else clear when cloud direction is down; else retain previous state; initially clear
Calculation: Short entry lock = set when cloud direction changes to down; else clear when high tracker crosses above the short stop level; else set while in a short position; else clear when cloud direction is up; else retain previous state; initially clear
Long: long action state changes value from the previous bar, in either direction AND previous-bar long entry lock is clear AND long entries are enabled
Short: short action state changes value from the previous bar, in either direction AND previous-bar short entry lock is clear AND short entries are enabled
Exit: Long, long-close condition
Exit: Short, short-close condition
Exit: Long, stop/target management is enabled AND (low <= long stop level OR high >= long target 1 OR high >= long target 2)
Exit: Short, stop/target management is enabled AND (high >= short stop level OR low <= short target 1 OR low <= short target 2)
Long: cloud-fill state is bullish
Short: cloud-fill state is bearish
Long: cloud-line display state is rising
Short: cloud-line display state is falling
Long: regression signal line rises over the slope lookback
Short: regression signal line falls over the slope lookback
Long: close > open AND volume > volume multiplier × volume baseline
Short: close < open AND volume > volume multiplier × volume baseline