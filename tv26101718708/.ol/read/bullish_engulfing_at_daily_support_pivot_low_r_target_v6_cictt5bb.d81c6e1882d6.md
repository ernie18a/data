Calculation: Support = most recent confirmed pivot low of higher-timeframe bars, using their lows; read the current source bar, which may still be forming.
Calculation: At support = absolute difference between current source-bar low and support divided by support is within the support tolerance, OR current source-bar low is at or below support times one plus the support tolerance.
Calculation: Bullish engulfing = current source-bar close is above its open AND its open is at or below the previous source-bar close AND its close is at or above the previous source-bar open; use strict inequalities instead when strict engulfing is enabled.
Calculation: Stop = the lower of support and current source-bar low, minus source-timeframe ATR times the stop-buffer setting.
Calculation: Target = entry price plus (entry price minus stop) times the R-multiple setting.
Long: (daily-only filter disabled OR chart timeframe equals the source timeframe) AND at support AND bullish engulfing AND current source-bar close minus stop exceeds the minimum price increment.
Exit: long, bar low is at or below stop OR bar high is at or above target