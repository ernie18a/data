Calculation: Buffer = confirm buffer ticks * minimum price increment
Calculation: Zone(snapshot) = (top, bottom) of the zone with the highest count among zones whose snapshot tags include snapshot and whose count >= confluence minimum, ties going to the latest-created zone; zones are built per snapshot candidate range, merged into the first existing zone where candidate top >= zone bottom - overlap tolerance AND candidate bottom <= zone top + overlap tolerance (merged top = max of tops, merged bottom = min of bottoms, count + 1, tags + snapshot), otherwise a new zone with count 1 and tag snapshot
Long: close > top of Zone(first snapshot) + Buffer
Long: close > top of Zone(second snapshot) + Buffer
Long: close > top of Zone(late snapshot) + Buffer
Short: close < bottom of Zone(first snapshot) - Buffer
Short: close < bottom of Zone(second snapshot) - Buffer
Short: close < bottom of Zone(late snapshot) - Buffer