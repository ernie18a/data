Calculation: First smoothed price = a selected OHLC-derived price smoothed by the first selected smoothing method and lookback.
Calculation: Second smoothed price = the first smoothed price smoothed by the second selected smoothing method and lookback.
Long: On the indicator timeframe (higher or lower than the chart timeframe as configured), the latest completed bar has first smoothed price > second smoothed price AND the preceding completed bar has first smoothed price <= second smoothed price.
Short: On the indicator timeframe (higher or lower than the chart timeframe as configured), the latest completed bar has first smoothed price < second smoothed price AND the preceding completed bar has first smoothed price >= second smoothed price.
Exit: Long, on the latest completed indicator-timeframe bar, first smoothed price < second smoothed price.
Exit: Short, on the latest completed indicator-timeframe bar, first smoothed price > second smoothed price.