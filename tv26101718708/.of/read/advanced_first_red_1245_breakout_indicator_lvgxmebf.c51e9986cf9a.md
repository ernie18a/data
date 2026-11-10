Calculation: Reference range = Reset at each new day. If enabled, capture the high and low of the first bearish chart bar in the session, provided no reference has been captured. If enabled, the chart bar opening at the configured session time replaces the reference and resets breakout bias. Optionally use max(open, close) and min(open, close) instead of high and low. Retain the range until replaced or reset.
Calculation: Breakout bias = Reset to neutral each new day and whenever the configured-time reference bar replaces the reference. Set to long after a reference-range long breakout and short after a reference-range short breakout; otherwise retain its value.
Calculation: Opening range = High and low of the bar opening at the configured opening time, on a timeframe that may be higher or lower than the chart timeframe. Use the last completed higher-timeframe bar or the last completed lower-timeframe bar within the chart bar; retain the latest captured range.
Calculation: First bearish midpoint = (high + low) / 2 of the first bearish bar of the day on a timeframe that may be higher or lower than the chart timeframe. Reset daily and retain the captured midpoint. Use the last completed higher-timeframe bar or the last completed lower-timeframe bar within the chart bar.
Calculation: Configured-time midpoint = (high + low) / 2 of the bar opening at the configured time on a timeframe that may be higher or lower than the chart timeframe. Reset daily and retain the captured midpoint. Use the last completed higher-timeframe bar or the last completed lower-timeframe bar within the chart bar.
Long: Reference range exists AND close crosses above reference high AND breakout bias is not long AND (EMA filter is disabled OR close > EMA).
Short: Reference range exists AND close crosses below reference low AND breakout bias is not short AND (EMA filter is disabled OR close < EMA).
Long: Opening range is enabled AND close crosses above opening-range high.
Short: Opening range is enabled AND close crosses below opening-range low.
Long: First bearish midpoint is enabled AND close > first bearish midpoint.
Short: First bearish midpoint is enabled AND close <= first bearish midpoint.
Long: Configured-time midpoint is enabled AND close > configured-time midpoint.
Short: Configured-time midpoint is enabled AND close <= configured-time midpoint.
Long: EMA filter is enabled AND close > EMA.
Short: EMA filter is enabled AND close < EMA.