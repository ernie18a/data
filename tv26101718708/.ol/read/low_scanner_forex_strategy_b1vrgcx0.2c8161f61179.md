Calculation: HMA3 = WMA(3 × WMA(close, p/3) − WMA(close, p/2) − WMA(close, p), p), where p is half the selected lookback; calculate on the prior completed bar of the configured signal timeframe, then apply the configured shift in signal-timeframe bars.
Calculation: Scanner value = negative EMA of (the prior-bar RSI of the cumulative sum of changes in the sampled higher-timeframe close multiplied by volume, minus its prior-bar WMA); sample the higher-timeframe close at each period boundary and hold it until the next boundary.
Long: Scanner value crosses above 0 OR linear regression of close crosses above HMA3, AND datetime is within the configured test period.
Short: Linear regression of close crosses below HMA3.
Exit: long, high reaches entry price plus the first configured profit distance OR low reaches entry price minus the configured stop distance.
Exit: long, high reaches entry price plus the second configured profit distance OR low reaches entry price minus the configured stop distance.
Exit: long, high reaches entry price plus the third configured profit distance OR low reaches entry price minus the configured stop distance.
Exit: long, high reaches entry price plus the fourth configured profit distance OR low reaches entry price minus the configured stop distance.