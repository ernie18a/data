Calculation: Bullish sweep = confirmed chart bar with low below and close above the same enabled, displayed rail: the prior completed low of T1 (PDL), T2 (PWL), or T3 (PML); a stored confirmed T4 swing low within the lookback window; or an enabled session low.
Calculation: Bearish sweep = confirmed chart bar with high above and close below the same enabled, displayed rail: the prior completed high of T1 (PDH), T2 (PWH), or T3 (PMH); a stored confirmed T4 swing high within the lookback window; or an enabled session high.
Calculation: T4 swing rails = PIVOTHIGH(high, pivot lookback, pivot lookback, T4) and PIVOTLOW(low, pivot lookback, pivot lookback, T4), evaluated on T4 bars and mapped to chart bars; retain confirmed pivots within the lookback window.
Calculation: EMA bias(Tn) = close > EMA(close, bias lookback, Tn), evaluated on Tn bars and mapped to chart bars using the last completed bar historically and the forming bar in real time.
Calculation: Displayed FVG threshold = 0 when automatic threshold is disabled; otherwise 2*CUMSUM(abs(new T7 bar ? (close[1]-open[1])/(open[1]*100) : 0))/max(chart bar index, denominator floor), calculated on chart bars using T7 values.
Calculation: Bullish T5 FVG event = enabled detector and a new T5 bar with low > high[FVG separation], evaluated on the forming T5 bar and mapped to chart bars; emit once per T5 bar.
Calculation: Bearish T5 FVG event = enabled detector and a new T5 bar with high < low[FVG separation], evaluated on the forming T5 bar and mapped to chart bars; emit once per T5 bar.
Calculation: Bullish T6 FVG event = enabled detector and a new T6 bar with low > high[FVG separation], evaluated on the forming T6 bar and mapped to chart bars; emit once per T6 bar.
Calculation: Bearish T6 FVG event = enabled detector and a new T6 bar with high < low[FVG separation], evaluated on the forming T6 bar and mapped to chart bars; emit once per T6 bar.
Calculation: Golden-block swing(len) = high[len] when high[len] > HIGHEST(high, len) and the prior state is not 0; low[len] when low[len] < LOWEST(low, len) and the prior state is not 1; state becomes 0 on the high condition, 1 on the low condition, otherwise persists. Use separate longer swing and shorter internal lookbacks.
Calculation: Golden-block buffer(top,bottom,session high,session low) = max(abs(top-bottom)*OB-height multiplier, abs(session high-session low)*session-range multiplier, ATR(ATR lookback)*ATR multiplier), with ATR calculated on chart bars.
Calculation: Golden-block overlap(top,bottom,rail,buffer) = rail exists AND bottom <= rail+buffer AND top >= rail-buffer.
Calculation: Golden-block mitigation(side,top,bottom,bar) = high >= bottom AND low <= top in wick-touch mode; close <= top AND close >= bottom in close-into-zone mode; low < bottom for a bullish zone or high > top for a bearish zone in full-invalidation mode.
Calculation: Golden-block zones = on a close crossover above an internal or swing high, scan candles from its corresponding last low to the break; on a close crossunder below an internal or swing low, scan from its corresponding last high. A bearish candle is a bullish candidate and a bullish candle is a bearish candidate. Require a gap: strict mode uses the FVG-separation offset after the candidate; session-owned mode uses the first gap found from that offset through the FVG-window parameter. A bullish gap has low > high[FVG separation]; a bearish gap has high < low[FVG separation]. Strict mode also requires a later local low for a bullish candidate or local high for a bearish candidate, with a subsequent close beyond the break level. Session-owned mode requires overlap with a corresponding session rail and, when the target requirement is enabled, an opposite session high above a bullish zone or session low below a bearish zone. Reject candidates mitigated after the gap forms through the current bar.
Long: Bullish sweep.
Short: Bearish sweep.
Long: Bullish sweep AND Bullish T5 FVG event occurs at or before the sweep time plus the confirmation-window parameter, with the sweep-to-FVG engine enabled.
Short: Bearish sweep AND Bearish T5 FVG event occurs at or before the sweep time plus the confirmation-window parameter, with the sweep-to-FVG engine enabled.
Long: Bullish T5 FVG event.
Short: Bearish T5 FVG event.
Long: Bullish T6 FVG event.
Short: Bearish T6 FVG event.
Long: FVG display enabled AND a new T7 bar has low > high[FVG separation] AND close[1] > high[FVG separation] AND (close[1]-open[1])/(open[1]*100) > Displayed FVG threshold; use the forming T7 high and low and prior completed T7 open and close, evaluated on chart bars.
Short: FVG display enabled AND a new T7 bar has high < low[FVG separation] AND close[1] < low[FVG separation] AND -(close[1]-open[1])/(open[1]*100) > Displayed FVG threshold; use the forming T7 high and low and prior completed T7 open and close, evaluated on chart bars.
Long: Tap engine enabled AND a chart bar after formation overlaps an existing bullish displayed FVG zone (high >= its bottom AND low <= its top) AND the zone has not already been tapped when once-per-FVG mode is enabled; a deleted zone cannot tap again.
Short: Tap engine enabled AND a chart bar after formation overlaps an existing bearish displayed FVG zone (high >= its bottom AND low <= its top) AND the zone has not already been tapped when once-per-FVG mode is enabled; a deleted zone cannot tap again.
Long: First chart-bar overlap of an unexpired bullish T6 FVG zone after its T6 bar completes AND the bullish EMA table condition.
Short: First chart-bar overlap of an unexpired bearish T6 FVG zone after its T6 bar completes AND the bearish EMA table condition.
Long: EMA bias(Tn), separately for each of the five configured table timeframes T8–T12.
Short: NOT EMA bias(Tn), separately for each of the five configured table timeframes T8–T12.
Long: At least the bullish-vote threshold of EMA bias(T8), EMA bias(T9), EMA bias(T10), EMA bias(T11), and EMA bias(T12).
Short: At most the bearish-vote maximum of EMA bias(T8), EMA bias(T9), EMA bias(T10), EMA bias(T11), and EMA bias(T12).
Long: Golden-block detection enabled AND the current chart bar mitigates an unmitigated bullish golden-block zone AND the zone overlaps a session low using the golden-block buffer AND, when required, a session high is above the zone top.
Short: Golden-block detection enabled AND the current chart bar mitigates an unmitigated bearish golden-block zone AND the zone overlaps a session high using the golden-block buffer AND, when required, a session low is below the zone bottom.