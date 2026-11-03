Calculation: POC = price bin with the greatest summed volume over a lookback window; assign each bar’s volume to the bin containing its high-low midpoint, with bins spanning the window’s lowest low to highest high.
Calculation: Confirmed pivot high/low = a high/low greater/less than the highs/lows of the configured number of bars before and after it; mark it on the confirmation bar.
Long: Fast EMA crosses above slow EMA AND (trade-session filter is disabled OR the chart/exchange time is within the configured trade session)
Short: Fast EMA crosses below slow EMA AND (trade-session filter is disabled OR the chart/exchange time is within the configured trade session)
Long: Fast EMA > slow EMA on a configured dashboard timeframe higher or lower than the chart timeframe, using that timeframe’s current bar, which may still be forming
Short: Fast EMA < slow EMA on a configured dashboard timeframe higher or lower than the chart timeframe, using that timeframe’s current bar, which may still be forming
Long: Chart close >= POC on a higher or lower POC timeframe, using that timeframe’s current bar, which may still be forming
Short: Chart close < POC on a higher or lower POC timeframe, using that timeframe’s current bar, which may still be forming
Long: Confirmed pivot low with the large-swing range threshold met OR confirmed pivot low that is not classified as a large or medium swing
Short: Confirmed pivot high with the large-swing range threshold met OR confirmed pivot high that is not classified as a large or medium swing
Long: Close >= a resistance level OR close > a support level
Short: Close < a resistance level OR close <= a support level