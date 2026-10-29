Calculation: Prior breakout high = highest close over the lookback period, excluding the current bar
Calculation: Trailing stop = highest high since entry minus an ATR multiple times ATR, ratcheted upward as the greater of this value and the previous stop; initialize on the first bar in the position
Long: Position is flat AND close > prior breakout high AND volume >= volume multiple × 50-bar average volume AND close > short-term SMA AND close > long-term SMA AND short-term SMA > long-term SMA
Exit: Long, low <= trailing stop