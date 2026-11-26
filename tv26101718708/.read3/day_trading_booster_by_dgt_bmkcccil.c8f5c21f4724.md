Long: Pivot Low(low, equal left/right lookback) != na
Short: Pivot High(high, equal left/right lookback) != na
Long: Pivot Low(low, temporary equal left/right lookback) < previous temporary Pivot Low
Short: Pivot High(high, temporary equal left/right lookback) > previous temporary Pivot High
Long: close > latest confirmed Pivot High(high, equal left/right lookback) AND no earlier chart bar since its confirmation had close above it
Short: close < latest confirmed Pivot Low(low, equal left/right lookback) AND no earlier chart bar since its confirmation had close below it
Long: selected moving average(source 1, shorter lookback, type 1) crosses above selected moving average(source 2, longer lookback, type 2)
Short: selected moving average(source 1, shorter lookback, type 1) crosses below selected moving average(source 2, longer lookback, type 2)
Long: close crosses above selected moving average(source 2, longer lookback, type 2)
Short: close crosses below selected moving average(source 2, longer lookback, type 2)
Long: cumulative zero-filled volume > 0 AND close > open AND (zero-filled volume >= high-volume multiplier × SMA(zero-filled volume, volume lookback) OR zero-filled volume <= low-volume multiplier × SMA(zero-filled volume, volume lookback))
Short: cumulative zero-filled volume > 0 AND close <= open AND (zero-filled volume >= high-volume multiplier × SMA(zero-filled volume, volume lookback) OR zero-filled volume <= low-volume multiplier × SMA(zero-filled volume, volume lookback))