Calculation: ATR = average true range over a lookback.
Calculation: Pivot low/high = a low/high lower/higher than the configured number of bars on both sides; confirm after the configured right-side bars complete.
Calculation: RSI = relative strength index of close.
Calculation: Volume baseline = moving average of volume; relative volume = volume / volume baseline.
Calculation: Mean stretch = (close − moving average of close) / standard deviation of close over a lookback.
Calculation: Bollinger bands = moving average of close ± configured standard-deviation multiple × standard deviation of close.
Calculation: Buy pressure = 100 × sum(volume × (close − low) / (high − low)) / sum(volume) over a lookback; when high = low, use half of volume for each side.
Calculation: Pivot conviction = weighted average, scaled to 0–10, of seven factors normalized to 0–1: oversold RSI at a low / overbought RSI at a high; bullish divergence when a lower pivot low has higher RSI than the prior pivot low / bearish divergence when a higher pivot high has lower RSI than the prior pivot high; rejection-wick fraction; relative-volume excess; mean-stretch in the pivot direction; buy pressure above 50% at a low / below 50% at a high; and pivot wick penetration beyond the corresponding Bollinger band in ATR units.
Calculation: Buy-dip zone = ATR-sized zone centered on a confirmed pivot low whose conviction meets the minimum; sell-rip zone = ATR-sized zone centered on a confirmed pivot high whose conviction meets the minimum. Suppress overlapping zones when configured.
Calculation: Zone break = close beyond the far zone border by the configured ATR distance, or close beyond that border once the reclaim window has elapsed after a sweep.
Long: A buy-dip zone is swept when low < its lower border − minimum sweep depth × ATR, then within the reclaim window close > the configured reclaim level (lower border, midpoint, or upper border); enter at that close.
Short: A sell-rip zone is swept when high > its upper border + minimum sweep depth × ATR, then within the reclaim window close < the configured reclaim level (upper border, midpoint, or lower border); enter at that close.
Long: On the first touch of an untested STRONG or ELITE buy-dip zone, fade long when price arrives over-extended into the zone.
Short: On the first touch of an untested STRONG or ELITE sell-rip zone, fade short when price arrives over-extended into the zone.
Exit: long, the associated buy-dip zone breaks (close < lower border − configured ATR distance, or reclaim window elapsed and close < lower border).
Exit: short, the associated sell-rip zone breaks (close > upper border + configured ATR distance, or reclaim window elapsed and close > upper border).