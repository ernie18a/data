Calculation: Volume surge = volume / SMA(volume, volume baseline length)
Calculation: Bias = close(T1, last completed bar) − EMA(close, bias EMA length, T1, last completed bar)
Calculation: clamp01(x) = min(1, max(0, x))
Calculation: Pool low = most recent confirmed PivotLow(low, pivot length, pivot length)
Calculation: Pool high = most recent confirmed PivotHigh(high, pivot length, pivot length)
Calculation: Raid bar (long) = first bar after Pool low was set on which low < Pool low
Calculation: Raid bar (short) = first bar after Pool high was set on which high > Pool high
Calculation: Raid low = lowest low from Raid bar (long) through the current bar
Calculation: Raid high = highest high from Raid bar (short) through the current bar
Calculation: Extreme bar (long) = first bar from Raid bar (long) through the current bar whose low = Raid low
Calculation: Extreme bar (short) = first bar from Raid bar (short) through the current bar whose high = Raid high
Calculation: V width (long) = current bar − Extreme bar (long)
Calculation: V width (short) = current bar − Extreme bar (short)
Calculation: Depth (long) = (Pool low − Raid low) / ATR(ATR length)
Calculation: Depth (short) = (Raid high − Pool high) / ATR(ATR length)
Calculation: Displacement (long) = (close − Raid low) / ATR(ATR length)
Calculation: Displacement (short) = (Raid high − close) / ATR(ATR length)
Calculation: Sharpness (long) = Displacement (long) / max(V width (long), 1)
Calculation: Sharpness (short) = Displacement (short) / max(V width (short), 1)
Calculation: Wick (long) = (min(open, close) − low) / max(high − low, tick size) on Extreme bar (long)
Calculation: Wick (short) = (high − max(open, close)) / max(high − low, tick size) on Extreme bar (short)
Calculation: Upper draw levels = pivot highs of T2 bars with DOL swing length (last completed T2 bar), high of last completed T3 bar, high of last completed T4 bar, and chart pivot highs with pivot length, each if enabled, that no high has exceeded since they appeared
Calculation: Lower draw levels = pivot lows of T2 bars with DOL swing length (last completed T2 bar), low of last completed T3 bar, low of last completed T4 bar, and chart pivot lows with pivot length, each if enabled, that no low has undercut since they appeared
Calculation: DOL above(e, r) = lowest upper draw level v with e < v and max(min DOL R, TP2 R + DOL margin R) ≤ (v − e) / r ≤ max DOL R, or none
Calculation: DOL below(e, r) = highest lower draw level v with v < e and max(min DOL R, TP2 R + DOL margin R) ≤ (e − v) / r ≤ max DOL R, or none
Calculation: Raw risk (long) = close − (Raid low − SL buffer × ATR(ATR length))
Calculation: Raw risk (short) = (Raid high + SL buffer × ATR(ATR length)) − close
Calculation: Room (long) = TP3 R if DOL above(close, Raw risk (long)) is none, else (DOL above(close, Raw risk (long)) − close) / Raw risk (long)
Calculation: Room (short) = TP3 R if DOL below(close, Raw risk (short)) is none, else (close − DOL below(close, Raw risk (short))) / Raw risk (short)
Calculation: Score (long) = min(10, max(0, 10 × (depth weight × clamp01(Depth (long) / depth full credit) + displacement weight × clamp01(Displacement (long) / displacement full credit) + sharpness weight × clamp01(Sharpness (long) / sharpness full credit) + wick weight × clamp01(Wick (long)) + volume weight × clamp01((Volume surge on Extreme bar (long) − 1) / (volume reference − 1)) + room weight × clamp01(Room (long) / room full credit)) / sum of weights + bias adjustment)), with bias adjustment = (Bias > 0 ? bias score adjustment : −bias score adjustment) if bias mode is score-only, else 0
Calculation: Score (short) = min(10, max(0, 10 × (depth weight × clamp01(Depth (short) / depth full credit) + displacement weight × clamp01(Displacement (short) / displacement full credit) + sharpness weight × clamp01(Sharpness (short) / sharpness full credit) + wick weight × clamp01(Wick (short)) + volume weight × clamp01((Volume surge on Extreme bar (short) − 1) / (volume reference − 1)) + room weight × clamp01(Room (short) / room full credit)) / sum of weights + bias adjustment)), with bias adjustment = (Bias < 0 ? bias score adjustment : −bias score adjustment) if bias mode is score-only, else 0
Calculation: IFVG zone (long) = bearish three-bar FVG with the highest top among those with size ≥ min gap size × ATR at formation, whose first close above its top lies within the last inversion window bars, with no close below its bottom since that close, and with top ≤ close and bottom ≥ Raid low; bearish FVG at bar i: high(i) < low(i−2), top = low(i−2), bottom = high(i)
Calculation: FVG zone (long) = bullish three-bar FVG with the highest top among those with size ≥ min gap size × ATR at formation, formed at or after Extreme bar (long), with no close below its bottom since formation, and with top ≤ close and bottom ≥ Raid low; bullish FVG at bar i: low(i) > high(i−2), bottom = high(i−2), top = low(i)
Calculation: Zone (long) = IFVG zone (long) if IFVG zones are allowed and it exists, else FVG zone (long) if FVG zones are allowed and it exists, else none
Calculation: IFVG zone (short) = bullish three-bar FVG with the lowest bottom among those with size ≥ min gap size × ATR at formation, whose first close below its bottom lies within the last inversion window bars, with no close above its top since that close, and with bottom ≥ close and top ≤ Raid high; bullish FVG at bar i: low(i) > high(i−2), top = low(i), bottom = high(i−2)
Calculation: FVG zone (short) = bearish three-bar FVG with the lowest bottom among those with size ≥ min gap size × ATR at formation, formed at or after Extreme bar (short), with no close above its top since formation, and with bottom ≥ close and top ≤ Raid high; bearish FVG at bar i: high(i) < low(i−2), top = low(i−2), bottom = high(i)
Calculation: Zone (short) = IFVG zone (short) if IFVG zones are allowed and it exists, else FVG zone (short) if FVG zones are allowed and it exists, else none
Calculation: Long V = close > Pool low AND no close above Pool low from the bar after Raid bar (long) through the previous bar AND 1 ≤ bars since Raid bar (long) ≤ sweep window AND Depth (long) ≥ min sweep depth AND Displacement (long) ≥ min displacement AND Sharpness (long) ≥ min sharpness AND V width (long) ≤ max V width AND (bias filter off OR Bias > 0) AND (normalized risk on OR Raw risk (long) ≤ max risk × ATR(ATR length)) AND Score (long) ≥ min V-score
Calculation: Long arm = Long V AND Zone (long) exists AND retest entry mode
Calculation: Armed long = Long arm occurred on bar k with 1 ≤ current bar − k ≤ arm window, with no close below Raid low as of bar k through the current bar, and with no Long fill since bar k; Armed raid low = Raid low as of bar k; Armed zone top (long) = top of Zone (long) as of bar k
Calculation: Long fill = Armed long AND no position open AND low ≤ Armed zone top (long) AND min(Armed zone top (long), open) − (Armed raid low − SL buffer × ATR(ATR length)) > 0 AND (normalized risk on OR min(Armed zone top (long), open) − (Armed raid low − SL buffer × ATR(ATR length)) ≤ max risk × ATR(ATR length))
Calculation: Long entry = (Long V AND Zone (long) exists AND immediate entry mode) OR (Long V AND Zone (long) does not exist AND zone requirement off) OR Long fill
Calculation: Entry risk (long) = min(max(entry − (Setup raid low − SL buffer × ATR(ATR length)), min risk × ATR(ATR length)), max risk × ATR(ATR length)) if normalized risk on, else entry − (Setup raid low − SL buffer × ATR(ATR length)), evaluated on the entry bar; Setup raid low = Raid low on the setup's reclaim bar
Calculation: Long target = DOL above(entry, Entry risk (long)) if it is not none, else entry + TP3 R × Entry risk (long), evaluated on the entry bar
Calculation: Short V = close < Pool high AND no close below Pool high from the bar after Raid bar (short) through the previous bar AND 1 ≤ bars since Raid bar (short) ≤ sweep window AND Depth (short) ≥ min sweep depth AND Displacement (short) ≥ min displacement AND Sharpness (short) ≥ min sharpness AND V width (short) ≤ max V width AND (bias filter off OR Bias < 0) AND (normalized risk on OR Raw risk (short) ≤ max risk × ATR(ATR length)) AND Score (short) ≥ min V-score AND NOT Long entry
Calculation: Short arm = Short V AND Zone (short) exists AND retest entry mode
Calculation: Armed short = Short arm occurred on bar k with 1 ≤ current bar − k ≤ arm window, with no close above Raid high as of bar k through the current bar, and with no Short fill since bar k; Armed raid high = Raid high as of bar k; Armed zone bottom (short) = bottom of Zone (short) as of bar k
Calculation: Short fill = Armed short AND no position open AND high ≥ Armed zone bottom (short) AND NOT Long entry AND (Armed raid high + SL buffer × ATR(ATR length)) − max(Armed zone bottom (short), open) > 0 AND (normalized risk on OR (Armed raid high + SL buffer × ATR(ATR length)) − max(Armed zone bottom (short), open) ≤ max risk × ATR(ATR length))
Calculation: Entry risk (short) = min(max((Setup raid high + SL buffer × ATR(ATR length)) − entry, min risk × ATR(ATR length)), max risk × ATR(ATR length)) if normalized risk on, else (Setup raid high + SL buffer × ATR(ATR length)) − entry, evaluated on the entry bar; Setup raid high = Raid high on the setup's reclaim bar
Calculation: Short target = DOL below(entry, Entry risk (short)) if it is not none, else entry − TP3 R × Entry risk (short), evaluated on the entry bar
Long: Long V AND Zone (long) exists AND immediate entry mode
Long: Long V AND Zone (long) does not exist AND zone requirement off
Long: Long arm
Long: Long fill
Short: Short V AND Zone (short) exists AND immediate entry mode
Short: Short V AND Zone (short) does not exist AND zone requirement off
Short: Short arm
Short: Short fill
Exit: long, low ≤ entry − Entry risk (long) OR high ≥ Long target
Exit: short, high ≥ entry + Entry risk (short) OR low ≤ Short target