Calculation: Active zones = the most recent confirmed pivot highs and lows whose pivot bars are within the zone lookback; each zone is centered on its pivot price and has a height equal to current ATR multiplied by a zone-height factor. Zones exist only when ATR is positive.
Calculation: Zone volume = sum of volume over the zone lookback for bars whose (high + low + close) / 3 lies within the zone; use 1 for missing volume.
Long: A pivot low is confirmed.
Short: A pivot high is confirmed.
Long: At least one active zone exists AND the sum of demand-zone volumes is greater than or equal to the sum of supply-zone volumes.
Short: At least one active zone exists AND the sum of demand-zone volumes is less than the sum of supply-zone volumes.
Long: Close is greater than or equal to open.
Short: Close is less than open.