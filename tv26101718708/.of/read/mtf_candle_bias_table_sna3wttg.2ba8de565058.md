Long: On each configured timeframe (chart, higher, or lower; use its still-forming bar and preceding completed bar), high > preceding high AND low >= preceding low
Short: On each configured timeframe (chart, higher, or lower; use its still-forming bar and preceding completed bar), low < preceding low AND high <= preceding high
Long: On each configured timeframe, close >= open
Short: On each configured timeframe, close < open
Calculation: EMA = exponential moving average of close on the same configured timeframe
Long: On each configured timeframe, close >= its EMA
Short: On each configured timeframe, close < its EMA
Calculation: Session VWAP = volume-weighted average of hlc3 for the current session on the chart timeframe
Long: On each configured timeframe, its current close >= chart-timeframe session VWAP
Short: On each configured timeframe, its current close < chart-timeframe session VWAP
Calculation: Bull accuracy = fraction of prior completed bars in a given hour bucket (or across all buckets) where the preceding bar broke only its predecessor's high and the next bar closed >= open; bear accuracy = fraction where it broke only its predecessor's low and the next bar closed < open. Use completed 1-hour bars and the 8 AM–3 PM New York hour buckets.
Long: For any hour bucket or total, bull accuracy >= bear accuracy + edge threshold; OR bull accuracy is available and bear accuracy is unavailable
Short: For any hour bucket or total, bear accuracy >= bull accuracy + edge threshold; OR bear accuracy is available and bull accuracy is unavailable
Long: Number of visible configured timeframes with bullish bias > number with bearish bias
Short: Number of visible configured timeframes with bearish bias > number with bullish bias