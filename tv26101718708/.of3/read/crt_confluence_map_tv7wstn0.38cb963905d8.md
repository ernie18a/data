Calculation: Estimated buy volume = if high > low then volume × (close − low) / (high − low), otherwise flat-bar buy allocation × volume
Calculation: Estimated sell volume = volume − estimated buy volume
Calculation: Volume delta = estimated buy volume − estimated sell volume
Calculation: Buying share = if SUM(volume, pressure-meter lookback) > 0 then 100 × SUM(estimated buy volume, pressure-meter lookback) / SUM(volume, pressure-meter lookback), otherwise zero-volume fallback share
Calculation: AtKey(price) = absolute distance from price to any active prior-completed-T2 high, low, or midpoint; active CRT high, low, or midpoint; active-T1 high, low, or midpoint; preceding-completed-T1 high or low; or active opening-range high, low, or midpoint is at most the key-level tolerance; evaluate on chart bars using completed T1 and T2 values
Calculation: Active buy zones = zones created on strong-buy bars when zone display is enabled and the zone does not overlap an active buy zone; bottom = low and top = max(min(open, close), low + zone fraction × (high − low)); remove when close < bottom
Calculation: Active sell zones = zones created on strong-sell bars when zone display is enabled and the zone does not overlap an active sell zone; top = high and bottom = min(max(open, close), high − zone fraction × (high − low)); remove when close > top
Long: the first low < CRT range low and close > CRT range low while the CRT range is active and the bar is in its configured projection session
Short: the first high > CRT range high and close < CRT range high while the CRT range is active and the bar is in its configured projection session
Long: the first low < high/low range low of the last completed T1 bar and close > that low; evaluate on chart bars using the last completed T1 bar
Short: the first high > high/low range high of the last completed T1 bar and close < that high; evaluate on chart bars using the last completed T1 bar
Long: the first low < high/low range low of the last completed T2 bar and close > that low; evaluate on chart bars using the last completed T2 bar
Short: the first high > high/low range high of the last completed T2 bar and close < that high; evaluate on chart bars using the last completed T2 bar
Long: the first close > opening-range high within the configured signal window after the opening range completes
Short: the first close < opening-range low within the configured signal window after the opening range completes
Long: high of the last completed T1 bar > high of the preceding completed T1 bar AND low of the last completed T1 bar > low of the preceding completed T1 bar; evaluate on chart bars using completed T1 values
Short: high of the last completed T1 bar < high of the preceding completed T1 bar AND low of the last completed T1 bar < low of the preceding completed T1 bar; evaluate on chart bars using completed T1 values
Long: high of the last completed T2 bar > high of the preceding completed T2 bar AND low of the last completed T2 bar > low of the preceding completed T2 bar; evaluate on chart bars using completed T2 values
Short: high of the last completed T2 bar < high of the preceding completed T2 bar AND low of the last completed T2 bar < low of the preceding completed T2 bar; evaluate on chart bars using completed T2 values
Long: a newly confirmed PivotHigh(high, swing strength, swing strength) is greater than the preceding confirmed pivot high OR a newly confirmed PivotLow(low, swing strength, swing strength) is greater than the preceding confirmed pivot low
Short: a newly confirmed PivotHigh(high, swing strength, swing strength) is less than or equal to the preceding confirmed pivot high OR a newly confirmed PivotLow(low, swing strength, swing strength) is less than or equal to the preceding confirmed pivot low
Long: the latest confirmed pivot high is greater than the preceding confirmed pivot high AND the latest confirmed pivot low is greater than the preceding confirmed pivot low
Short: the latest confirmed pivot high is less than the preceding confirmed pivot high AND the latest confirmed pivot low is less than the preceding confirmed pivot low
Long: low < the latest unswept confirmed PivotLow(low, swing strength, swing strength) AND close > that pivot low AND (session-only filtering is disabled OR the bar is in the configured reversal session) AND (key-level-only filtering is disabled OR AtKey(that pivot low))
Short: high > the latest unswept confirmed PivotHigh(high, swing strength, swing strength) AND close < that pivot high AND (session-only filtering is disabled OR the bar is in the configured reversal session) AND (key-level-only filtering is disabled OR AtKey(that pivot high))
Long: a qualifying bullish SFP occurs at AtKey(the swept pivot low)
Short: a qualifying bearish SFP occurs at AtKey(the swept pivot high)
Long: after a qualifying bullish SFP, within the MSS window of chart bars, close > the swing high that was most recent at the SFP AND close has not fallen below the SFP bar low
Short: after a qualifying bearish SFP, within the MSS window of chart bars, close < the swing low that was most recent at the SFP AND close has not risen above the SFP bar high
Long: volume delta > SMA(abs(volume delta), pressure lookback) × pressure-strength multiplier AND close > open AND volume > SMA(volume, pressure lookback)
Short: volume delta < −SMA(abs(volume delta), pressure lookback) × pressure-strength multiplier AND close < open AND volume > SMA(volume, pressure lookback)
Long: buying share >= buyer-label threshold
Short: buying share < buyer-label threshold
Long: buying share >= bullish-color threshold
Short: buying share <= bearish-color threshold
Long: an active buy zone exists AND low <= its top AND low[1] > its top AND close >= its bottom
Short: an active sell zone exists AND high >= its bottom AND high[1] < its bottom AND close <= its top