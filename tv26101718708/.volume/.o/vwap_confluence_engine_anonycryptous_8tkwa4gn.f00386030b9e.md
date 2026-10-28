Calculation: Anchored VWAP = cumulative typical price × volume divided by cumulative volume, reset at the selected anchor period, using current-timeframe bars.
Calculation: Volume-weighted RSI = RSI of close changes weighted by each bar’s volume divided by its simple moving average of volume; smooth weighted gains and losses with the same RSI lookback.
Calculation: Pivot divergence = use equal left and right pivot lookbacks on volume-weighted RSI and price; compare each confirmed pivot with the previous pivot of the same kind.
Long: Close > anchored VWAP AND volume-weighted RSI > its midline AND (MFI > its midline when enabled) AND (higher-timeframe filter disabled OR higher-timeframe VWAP > 0 AND current-timeframe close > higher-timeframe VWAP AND higher-timeframe volume-weighted RSI > its midline).
Short: Close < anchored VWAP AND volume-weighted RSI < its midline AND (MFI < its midline when enabled) AND (higher-timeframe filter disabled OR higher-timeframe VWAP > 0 AND current-timeframe close < higher-timeframe VWAP AND higher-timeframe volume-weighted RSI < its midline).
Long: On each of six selected timeframes, that timeframe’s close > its anchored VWAP AND its volume-weighted RSI > 50.
Short: On each of six selected timeframes, that timeframe’s close < its anchored VWAP AND its volume-weighted RSI < 50.
Long: On the selected dashboard timeframe, current-timeframe close > that timeframe’s VWAP AND its volume-weighted RSI > its midline.
Short: On the selected dashboard timeframe, current-timeframe close < that timeframe’s VWAP AND its volume-weighted RSI < its midline.
Long: A confirmed volume-weighted RSI pivot low is higher than the previous volume-weighted RSI pivot low AND its corresponding price low is lower than the previous price pivot low.
Short: A confirmed volume-weighted RSI pivot high is lower than the previous volume-weighted RSI pivot high AND its corresponding price high is higher than the previous price pivot high.