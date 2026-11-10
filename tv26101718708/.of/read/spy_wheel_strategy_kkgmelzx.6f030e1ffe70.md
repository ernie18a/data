Long: Position is flat AND current bar datetime >= start datetime AND previous bar datetime < start datetime
Long: Position is flat AND the last exit was a regime exit AND close > long-term SMA of close AND datetime >= start datetime
Long: Instant re-entry mode is enabled AND position is flat AND no regime exit is active AND an initial entry has occurred on an earlier bar AND datetime >= start datetime
Exit: Long, close < long-term SMA of close for at least the configured number of consecutive bars while holding the position