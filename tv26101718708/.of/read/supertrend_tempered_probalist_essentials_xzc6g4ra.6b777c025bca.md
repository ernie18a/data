Calculation: Trailing bands = For a selectable OHLC-derived source, calculate short-lookback and longer-lookback Wilder ATR. Set the effective multiplier to the base multiplier, or in adaptive mode to the base multiplier times short ATR / longer ATR, clamped to configurable bounds; use a ratio of 1 when longer ATR is not positive. Raw upper and lower bands are source plus and minus effective multiplier times short ATR. Initialize each trailing band to its raw band. Thereafter, set the upper band to the raw upper band if it is lower than the previous upper band or the previous close is above the previous upper band; otherwise retain the previous upper band. Set the lower band to the raw lower band if it is higher than the previous lower band or the previous close is below the previous lower band; otherwise retain the previous lower band.
Calculation: Trend direction = Initialize bullish. On each bar, set direction bullish if close is above the previous upper band, then set it bearish if close is below the previous lower band; otherwise retain the previous direction. A bullish flip is a change from bearish to bullish; a bearish flip is a change from bullish to bearish.
Calculation: Confirmed flip = A bullish or bearish flip a configurable number of chart bars ago. Flip strength is the absolute difference between that flip bar's close and its active trailing band, divided by the greater of its short ATR and a small positive floor; the active band is lower for bullish direction and upper for bearish direction.
Calculation: Recent history backed = For each direction, record each flip's direction-adjusted return after a configurable horizon: direction sign times (horizon close minus flip close) / max(flip close, a small positive floor). Retain at most a configurable number of the latest outcomes per direction. From the latest configurable number of retained outcomes, require a configurable minimum sample count, positive median return, and a Wilson lower confidence bound for the fraction of positive returns greater than one half. Calculate the bound as (p + z²/(2n) - z × sqrt(p(1-p)/n + z²/(4n²))) / (1 + z²/n), where p is the positive-return fraction, n is the sample count, and z is a configurable confidence coefficient. Include outcomes that mature on the current bar.
Long: Trend direction is bullish.
Short: Trend direction is bearish.
Long: Bullish flip occurred.
Short: Bearish flip occurred.
Long: Confirmed bullish flip occurred.
Short: Confirmed bearish flip occurred.
Long: Confirmed bullish flip occurred AND flip strength is greater than or equal to a configurable strong-flip threshold.
Short: Confirmed bearish flip occurred AND flip strength is greater than or equal to a configurable strong-flip threshold.
Long: Confirmed bullish flip occurred AND bullish recent history is backed.
Short: Confirmed bearish flip occurred AND bearish recent history is backed.
Long: Confirmed bullish flip occurred AND flip strength is greater than or equal to the strong-flip threshold AND bullish recent history is backed.
Short: Confirmed bearish flip occurred AND flip strength is greater than or equal to the strong-flip threshold AND bearish recent history is backed.
Long: Higher-timeframe trend direction on the last completed higher-timeframe bar is bullish.
Short: Higher-timeframe trend direction on the last completed higher-timeframe bar is bearish.