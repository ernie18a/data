Calculation: bar delta = per chart bar, sum T1 intrabar buy volume minus sell volume, classifying close > open as buy, close < open as sell, and equal close and open as half of each; use T2 intrabars if T1 is empty, then chart-bar OHLCV if T2 is empty; use all available intrabars, including a still-forming intrabar in real time; when realtime tick mode is selected and tick volume exists, use incremental tick volume (current volume minus prior observed volume, floored at zero), classifying upticks as buy, downticks as sell, and unchanged or first observed prices as half of each
Calculation: delta ratio = bar delta / nz(volume) when nz(volume) > 0, else 0
Calculation: CVD = cumulative sum of bar delta, reset at the selected anchor interval
Long: confirmed pivot low(low, divergence pivot lookback) is lower than the previous confirmed pivot low AND CVD at the current pivot is higher than CVD at the previous pivot
Short: confirmed pivot high(high, divergence pivot lookback) is higher than the previous confirmed pivot high AND CVD at the current pivot is lower than CVD at the previous pivot
Long: delta ratio > imbalance threshold
Short: delta ratio < -imbalance threshold
Long: current consecutive bullish imbalance run length equals stacked count
Short: current consecutive bearish imbalance run length equals stacked count
Long: SMA(volume, volume-average lookback) > 0 AND volume > SMA(volume, volume-average lookback) × absorption volume multiplier AND ATR(ATR lookback) > 0 AND high - low < ATR(ATR lookback) × absorption range multiplier AND a confirmed pivot low(low, swing pivot lookback) exists AND absolute value of low minus the most recent confirmed pivot low is <= ATR(ATR lookback)
Short: SMA(volume, volume-average lookback) > 0 AND volume > SMA(volume, volume-average lookback) × absorption volume multiplier AND ATR(ATR lookback) > 0 AND high - low < ATR(ATR lookback) × absorption range multiplier AND a confirmed pivot high(high, swing pivot lookback) exists AND absolute value of high minus the most recent confirmed pivot high is <= ATR(ATR lookback)
Long: confirmed pivot low(low, swing pivot lookback) AND bar delta at the pivot > 0
Short: confirmed pivot high(high, swing pivot lookback) AND bar delta at the pivot < 0