Calculation: Supply zone = when abs(close − open) > ATR × displacement parameter and volume ≥ 20-bar SMA(volume) × volume parameter, use the previous bar’s high and low as the zone boundaries; create it on bearish or doji bars.
Calculation: Demand zone = under the same displacement and volume conditions, use the previous bar’s high and low as the zone boundaries; create it on bullish bars.
Calculation: Long stop = demand zone bottom − ATR × stop-buffer parameter; long target = entry price + (entry price − long stop) × reward parameter.
Calculation: Short stop = supply zone top + ATR × stop-buffer parameter; short target = entry price − (short stop − entry price) × reward parameter.
Long: an unmitigated demand zone has its first bar overlapping the zone (low ≤ zone top AND high ≥ zone bottom AND low ≥ zone bottom) AND close > EMA.
Short: an unmitigated supply zone has its first bar overlapping the zone (low ≤ zone top AND high ≥ zone bottom AND high ≤ zone top) AND close < EMA.
Exit: long, high ≥ long target OR low ≤ long stop.
Exit: short, low ≤ short target OR high ≥ short stop.