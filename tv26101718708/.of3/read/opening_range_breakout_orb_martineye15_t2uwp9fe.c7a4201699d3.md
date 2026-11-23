Calculation: OR high = highest high of bars inside the OR session window of the latest OR session
Calculation: OR low = lowest low of bars inside the OR session window of the latest OR session
Calculation: OR range = OR high - OR low
Calculation: OR size = OR range / tick size if size unit is ticks, else OR range / ((OR high + OR low) / 2) * 100
Calculation: OR closed = bar is after the latest OR session window ended
Calculation: long breakout = close > OR high if confirmation is close, else high > OR high
Calculation: short breakout = close < OR low if confirmation is close, else low < OR low
Calculation: side sign = +1 for long, -1 for short
Calculation: ATR risk unit = ATR(ATR length) * ATR multiple, evaluated on the entry bar
Calculation: stop level = (OR low for long, OR high for short) if stop method is opposite OR boundary; (OR high + OR low) / 2 if stop method is OR midpoint; entry price - side sign * ATR risk unit if stop method is ATR; entry price - side sign * fixed stop ticks * tick size if stop method is fixed ticks; entry price * (1 - side sign * stop percent / 100) if stop method is percent
Calculation: target distance = (|entry price - stop level| if target method is risk multiple; OR range if target method is OR range multiple; ATR risk unit if target method is ATR; tick size if target method is fixed ticks; entry price / 100 if target method is percent) * target value whose index equals number of targets
Calculation: final target level = entry price + side sign * target distance
Calculation: long broken = (OR closed AND long breakout) if retest is off and signal mode is all; (OR closed AND (long broken[1] OR long breakout)) if retest is off and signal mode is first; (OR closed AND (long broken[1] OR long breakout) AND NOT (signal mode is all AND long signal)) if retest is on
Calculation: long retested = OR closed AND (long retested[1] OR (long broken[1] AND low <= OR high)) AND NOT (signal mode is all AND long signal)
Calculation: long signal = (long breakout AND NOT long broken[1] if retest is off; long broken[1] AND long retested[1] AND long breakout if retest is on) AND (signal mode is all OR no long entry earlier in latest OR session)
Calculation: short broken = (OR closed AND short breakout) if retest is off and signal mode is all; (OR closed AND (short broken[1] OR short breakout)) if retest is off and signal mode is first; (OR closed AND (short broken[1] OR short breakout) AND NOT (signal mode is all AND short signal)) if retest is on
Calculation: short retested = OR closed AND (short retested[1] OR (short broken[1] AND high >= OR low)) AND NOT (signal mode is all AND short signal)
Calculation: short signal = (short breakout AND NOT short broken[1] if retest is off; short broken[1] AND short retested[1] AND short breakout if retest is on) AND (signal mode is all OR no short entry earlier in latest OR session)
Long: OR closed AND day of latest OR session is an active weekday AND OR size >= min OR size AND (max OR size is off OR OR size <= max OR size) AND OR range > 0 AND position is flat AND (one-trade-per-day is off OR no entry earlier in latest OR session) AND (volume filter is off OR volume > SMA(volume, volume MA length)) AND long signal
Short: OR closed AND day of latest OR session is an active weekday AND OR size >= min OR size AND (max OR size is off OR OR size <= max OR size) AND OR range > 0 AND position is flat AND (one-trade-per-day is off OR no entry earlier in latest OR session) AND (volume filter is off OR volume > SMA(volume, volume MA length)) AND short signal AND NOT long signal
Exit: long, low <= stop level OR high >= final target level OR (inside OR session window AND NOT inside OR session window[1])
Exit: short, high >= stop level OR low <= final target level OR (inside OR session window AND NOT inside OR session window[1])