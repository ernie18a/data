Calculation: Confirmed swing pivots = pivot highs and lows confirmed after the configured right-bar delay; retain alternating pivots only when the move from the prior retained pivot is at least the configured ATR multiple, replacing the latest pivot when a more extreme pivot of the same type appears
Calculation: Protected-swing trend = process retained pivots chronologically; turn bullish when a pivot high breaks the prior protected high and protect the low that launched the prior impulse; turn bearish when a pivot low breaks the prior protected low and protect the high that launched the prior impulse; otherwise retain the trend
Calculation: Impulse quality score = 100 × (0.5 × min(leg size / sum of absolute close-to-close changes during the leg, 1) + 0.5 × percentile rank of leg size divided by mean endpoint ATR among retained legs); leg size is the absolute difference between its endpoint pivots
Calculation: Qualified impulse = a leg aligned with the protected-swing trend whose impulse quality score meets the configured minimum
Calculation: Higher-timeframe structural bias = for each of the next available higher timeframes, calculate protected-swing trend using that timeframe's bars; use each timeframe's last completed bar; bias is the majority non-flat direction, or neutral on a tie
Calculation: Selected impulse = latest qualified impulse aligned with the higher-timeframe structural bias when non-neutral, otherwise with the chart-timeframe protected-swing trend; if both are neutral, select the latest qualified impulse
Long: A rising leg is a qualified impulse
Short: A falling leg is a qualified impulse
Long: The selected impulse is rising AND close is between its 0.382 and 0.618 retracement levels AND its setup has not hit the stop or first target
Short: The selected impulse is falling AND close is between its 0.382 and 0.618 retracement levels AND its setup has not hit the stop or first target
Exit: long, low <= 0.2 ATR below the selected impulse origin OR high >= 1.272 extension above its end
Exit: short, high >= 0.2 ATR above the selected impulse origin OR low <= 1.272 extension below its end