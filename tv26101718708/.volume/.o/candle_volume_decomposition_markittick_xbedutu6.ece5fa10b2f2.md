Calculation: Upper-wick, body, and lower-wick volume = sum each lower-timeframe bar’s volume allocated in proportion to the overlap of its high-low range with each zone of the current chart bar; for a zero-range lower-timeframe bar, allocate all volume to the zone containing its midpoint.
Calculation: Total volume = upper-wick volume + body volume + lower-wick volume.
Calculation: Net signed volume = lower-wick volume + body volume when close >= open, otherwise lower-wick volume - body volume - upper-wick volume.
Long: Net signed volume >= 0
Long: Total volume on the last completed chart bar > total volume on the earlier completed chart bar at the divergence lookback, AND high on the last completed chart bar < high on that earlier bar
Short: Net signed volume < 0
Short: Total volume on the last completed chart bar < total volume on the earlier completed chart bar at the divergence lookback, AND high on the last completed chart bar > high on that earlier bar