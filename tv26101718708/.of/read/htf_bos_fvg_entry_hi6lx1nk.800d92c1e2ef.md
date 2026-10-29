Calculation: Previous completed higher-timeframe bar = the last completed bar aggregated from chart bars at a timeframe higher than the chart timeframe
Calculation: Bullish fair value gap = current low > high two chart bars earlier; gap zone is from that earlier high to current low
Calculation: Bearish fair value gap = current high < low two chart bars earlier; gap zone is from current high to that earlier low
Calculation: Candle body-to-range ratio = abs(close - open) / (high - low), or 1 when high = low
Calculation: Entry confirmation distance = confirmation-tick parameter × minimum price tick
Long: close crosses above the previous completed higher-timeframe bar high
Short: close crosses below the previous completed higher-timeframe bar low
Long: bullish fair value gap forms after a bullish BOS while it remains active
Short: bearish fair value gap forms after a bearish BOS while it remains active
Long: bullish fair value gap is active and not invalidated by a close below its lower boundary; after the gap bar, a bar overlaps the gap zone, closes at or below its upper boundary, and has a body-to-range ratio below the pin-bar threshold; on a later bar, close >= touch-bar close + entry confirmation distance
Short: bearish fair value gap is active and not invalidated by a close above its upper boundary; after the gap bar, a bar overlaps the gap zone, closes at or above its lower boundary, and has a body-to-range ratio below the pin-bar threshold; on a later bar, close <= touch-bar close - entry confirmation distance