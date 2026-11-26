Calculation: zone(S) = top and bottom of the stored box with S among its tags, count >= confluence minimum, and highest count (latest created on ties); each snapshot-S bar creates a box spanning the highest high and lowest low of the last window bars, which merges into the first stored box it overlaps (new top >= stored bottom - overlap tolerance AND new bottom <= stored top + overlap tolerance; merged top = max of tops, merged bottom = min of bottoms, merged count + 1, tags accumulate with S), otherwise is stored with count 1 and tag S
Long: close > top of zone(first snapshot) + confirm buffer
Long: close > top of zone(second snapshot) + confirm buffer
Long: close > top of zone(late snapshot) + confirm buffer
Short: close < bottom of zone(first snapshot) - confirm buffer
Short: close < bottom of zone(second snapshot) - confirm buffer
Short: close < bottom of zone(late snapshot) - confirm buffer