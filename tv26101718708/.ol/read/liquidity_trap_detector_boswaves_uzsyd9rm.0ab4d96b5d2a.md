Calculation: DEMA baseline = DEMA of HLC3, optionally EMA-smoothed
Calculation: Trend state = initially bullish if close is at or above the DEMA baseline, otherwise bearish; switches from bearish to bullish when close is above the baseline plus a long-term ATR multiple and the baseline is rising, and from bullish to bearish when close is below the baseline minus that multiple and the baseline is falling
Calculation: Confirmed swing high/low = a bar's high/low is the extreme within the configured number of bars before and after it; use only after the bars following it have completed
Calculation: Bull trap = close above a confirmed swing high by more than a short-term ATR multiple, followed within the trap window by a close below that swing high
Calculation: Bear trap = close below a confirmed swing low by more than a short-term ATR multiple, followed within the trap window by a close above that swing low
Calculation: Armed zone retest = after price has traded entirely outside a trap zone on the side it returned from, a later bar touches the zone; the zone disarms until price again trades entirely outside it
Long: bearish-to-bullish trend switch OR bear trap confirmation OR armed bear trap zone retest while trend is bullish
Short: bullish-to-bearish trend switch OR bull trap confirmation OR armed bull trap zone retest while trend is bearish