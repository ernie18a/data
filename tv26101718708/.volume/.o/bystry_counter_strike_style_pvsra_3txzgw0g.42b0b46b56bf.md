Calculation: Long breakout level = highest high over the lookback bars before the current bar + current-bar ATR × entry buffer
Calculation: Short breakout level = lowest low over the lookback bars before the current bar − current-bar ATR × entry buffer
Calculation: Channel width = long breakout level − short breakout level
Calculation: Volatility score = current-bar ATR ÷ 100-bar simple moving average of ATR
Calculation: Long target distance = maximum of current-bar ATR × minimum target multiple, channel width × 0.25, and minimum price increment
Calculation: Short target distance = long target distance
Calculation: Long stop distance = maximum of current-bar ATR × minimum stop multiple, channel width × 0.14, and minimum price increment
Calculation: Short stop distance = long stop distance
Calculation: Long target = long breakout level + long target distance
Calculation: Short target = short breakout level − short target distance
Calculation: Long stop = long breakout level − long stop distance
Calculation: Short stop = short breakout level + short stop distance
Long: no position is open AND channel width exceeds minimum price increment AND long trading is allowed AND (EMA filter disabled OR close > current-bar EMA) AND selected volatility filter passes AND (selected trigger is confirmed close and current close ≥ current long breakout level and previous close < previous long breakout level OR selected trigger is wick touch and current high ≥ current long breakout level and previous high < previous long breakout level)
Short: no position is open AND channel width exceeds minimum price increment AND short trading is allowed AND (EMA filter disabled OR close < current-bar EMA) AND selected volatility filter passes AND (selected trigger is confirmed close and current close ≤ current short breakout level and previous close > previous short breakout level OR selected trigger is wick touch and current low ≤ current short breakout level and previous low > previous short breakout level)
Exit: long, after the entry bar, low ≤ long stop OR high ≥ long target; on a bar touching both before target was hit, use the stop first when conservative same-bar handling is selected. At target, exit half; if trailing is enabled, raise the stop to the maximum of its prior value and current close − current long stop distance, then exit the remainder when low ≤ stop.
Exit: short, after the entry bar, high ≥ short stop OR low ≤ short target; on a bar touching both before target was hit, use the stop first when conservative same-bar handling is selected. At target, exit half; if trailing is enabled, lower the stop to the minimum of its prior value and current close + current short stop distance, then exit the remainder when high ≥ stop.