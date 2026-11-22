Calculation: Window high(window) = highest high of the bars inside the window, from the window start through the current bar
Calculation: Window low(window) = lowest low of the bars inside the window, from the window start through the current bar
Calculation: Window close(window) = close of the latest bar inside the window, through the current bar
Calculation: London move = Window close(London window) - open of the first bar inside the London window
Calculation: Asia range = Window high(Asia window) - Window low(Asia window)
Calculation: Range high = Window high(range window), where range window is the NY opening range window, the Asia window, or the London window, as chosen by the range source parameter
Calculation: Range low = Window low(range window), where range window is the NY opening range window, the Asia window, or the London window, as chosen by the range source parameter
Calculation: Long break level = Range high + breakout buffer
Calculation: Short break level = Range low - breakout buffer
Calculation: Entry window = current bar inside the trade window AND current bar after the range window has ended AND (range size filter off OR (Range high - Range low >= min range AND Range high - Range low <= max range))
Calculation: Regime pass = volatility switch off OR ((count of true among: Asia range / SMA(Asia range, compression lookback) <= max compression ratio; abs(London move) / Asia range >= min London move ratio; (Window high(London window) - Window low(London window)) / Asia range <= max London range ratio) >= min regime score)
Calculation: Bull bias = bias switch off OR (Regime pass AND London move > 0 AND London move > Asia range * dominance threshold AND (close-outside switch off OR Window close(London window) > Window high(Asia window)))
Calculation: Bear bias = bias switch off OR (Regime pass AND London move < 0 AND abs(London move) > Asia range * dominance threshold AND (close-outside switch off OR Window close(London window) < Window low(Asia window)))
Calculation: Long bias gate = Bull bias OR (NOT Bear bias AND long-without-bias switch on)
Calculation: Short bias gate = Bear bias OR (NOT Bull bias AND short-without-bias switch on)
Calculation: Swept below = some bar inside the entry window, up to and including the current bar, has low < Range low
Calculation: Swept above = some bar inside the entry window, up to and including the current bar, has high > Range high
Calculation: Long retested = some bar inside the entry window has high > Long break level, and some bar inside the entry window from the first such bar through the current bar has low <= Range high + retest tolerance
Calculation: Short retested = some bar inside the entry window has low < Short break level, and some bar inside the entry window from the first such bar through the current bar has high >= Range low - retest tolerance
Calculation: Long stop reference = the level selected by the stop reference parameter: Range low, (Range high + Range low) / 2, Window low(London window), Window low(Asia window), or entry price - fixed stop distance
Calculation: Long risk = entry price - Long stop reference
Calculation: Long TP1 = entry price + (TP1 R * Long risk if target mode is R-multiple, otherwise TP1 points)
Calculation: Long TP2 = entry price + (TP2 R * Long risk if target mode is R-multiple, otherwise TP2 points)
Calculation: Long TP3 = entry price + (TP3 R * Long risk if target mode is R-multiple, otherwise TP3 points)
Calculation: Long stop = entry price if BE switch on AND some bar after entry has high >= Long TP1, otherwise Long stop reference
Calculation: Short stop reference = the level selected by the stop reference parameter: Range high, (Range high + Range low) / 2, Window high(London window), Window high(Asia window), or entry price + fixed stop distance
Calculation: Short risk = Short stop reference - entry price
Calculation: Short TP1 = entry price - (TP1 R * Short risk if target mode is R-multiple, otherwise TP1 points)
Calculation: Short TP2 = entry price - (TP2 R * Short risk if target mode is R-multiple, otherwise TP2 points)
Calculation: Short TP3 = entry price - (TP3 R * Short risk if target mode is R-multiple, otherwise TP3 points)
Calculation: Short stop = entry price if BE switch on AND some bar after entry has low <= Short TP1, otherwise Short stop reference
Long: entry mode is direct break AND Entry window AND Long bias gate AND high > Long break level AND (VWAP filter off OR close > VWAP(hlc3)) AND no position open AND (one-trade switch off OR no entry earlier on the current day)
Long: entry mode is retest break AND Entry window AND Long bias gate AND Long retested AND high > Long break level AND (VWAP filter off OR close > VWAP(hlc3)) AND no position open AND (one-trade switch off OR no entry earlier on the current day)
Long: entry mode is sweep then break AND Entry window AND Long bias gate AND Swept below AND high > Long break level AND (VWAP filter off OR close > VWAP(hlc3)) AND no position open AND (one-trade switch off OR no entry earlier on the current day)
Short: entry mode is direct break AND Entry window AND Short bias gate AND low < Short break level AND (VWAP filter off OR close < VWAP(hlc3)) AND no position open AND (one-trade switch off OR no entry earlier on the current day)
Short: entry mode is retest break AND Entry window AND Short bias gate AND Short retested AND low < Short break level AND (VWAP filter off OR close < VWAP(hlc3)) AND no position open AND (one-trade switch off OR no entry earlier on the current day)
Short: entry mode is sweep then break AND Entry window AND Short bias gate AND Swept above AND low < Short break level AND (VWAP filter off OR close < VWAP(hlc3)) AND no position open AND (one-trade switch off OR no entry earlier on the current day)
Exit: long, low <= Long stop AND scale-out switch on AND stop switch on AND Long risk > 0
Exit: long, high >= Long TP1 AND scale-out switch on AND Long risk > 0
Exit: long, high >= Long TP2 AND scale-out switch on AND Long risk > 0
Exit: long, high >= Long TP3 AND scale-out switch on AND Long risk > 0
Exit: long, bar time equals flat time AND force-flat switch on
Exit: short, high >= Short stop AND scale-out switch on AND stop switch on AND Short risk > 0
Exit: short, low <= Short TP1 AND scale-out switch on AND Short risk > 0
Exit: short, low <= Short TP2 AND scale-out switch on AND Short risk > 0
Exit: short, low <= Short TP3 AND scale-out switch on AND Short risk > 0
Exit: short, bar time equals flat time AND force-flat switch on