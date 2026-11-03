Calculation: Volume-weighted CCI = moving average of (CCI of the selected bar price × volume); calculate on the chart timeframe for indicator markings and on a higher timeframe for the trading decisions, using the last completed higher-timeframe bar by default or the forming bar when selected.
Calculation: Volume-scaled levels = each of two upper thresholds and two lower thresholds multiplied by the moving average of volume, using the same method and lookback as the volume-weighted CCI; the outer upper threshold is greater than the inner upper threshold, and the outer lower threshold is less than the inner lower threshold.
Long: Volume-weighted CCI > inner upper level AND volume-weighted CCI <= outer upper level
Long: Volume-weighted CCI > outer upper level
Long: Previous higher-timeframe volume-weighted CCI <= inner upper level AND current higher-timeframe volume-weighted CCI > inner upper level AND current higher-timeframe volume-weighted CCI <= outer upper level
Long: Previous higher-timeframe volume-weighted CCI <= outer upper level AND current higher-timeframe volume-weighted CCI > outer upper level
Short: Volume-weighted CCI < inner lower level AND volume-weighted CCI >= outer lower level
Short: Volume-weighted CCI < outer lower level
Short: Previous higher-timeframe volume-weighted CCI >= inner lower level AND current higher-timeframe volume-weighted CCI < inner lower level AND current higher-timeframe volume-weighted CCI >= outer lower level
Short: Previous higher-timeframe volume-weighted CCI >= outer lower level AND current higher-timeframe volume-weighted CCI < outer lower level
Exit: long, higher-timeframe volume-weighted CCI < inner lower level OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, higher-timeframe volume-weighted CCI > inner upper level OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance