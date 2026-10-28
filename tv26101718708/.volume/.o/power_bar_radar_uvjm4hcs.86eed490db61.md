Calculation: Net change = current close minus previous close
Calculation: Move z-score = net change divided by the standard deviation of recent net changes
Calculation: Candle range = high minus low
Calculation: Close location = (close minus low) divided by candle range; use 0.5 when range is zero
Calculation: Average range = average candle range over the same lookback used for the move z-score
Long: move z-score >= threshold AND close location >= threshold AND candle range > average range * expansion factor AND (volume filter disabled OR current volume is valid and > average volume over its lookback * volume factor) AND (structure filter disabled OR current high > highest high of the previous structure lookback bars)
Short: move z-score <= -threshold AND close location <= 1 - threshold AND candle range > average range * expansion factor AND (volume filter disabled OR current volume is valid and > average volume over its lookback * volume factor) AND (structure filter disabled OR current low < lowest low of the previous structure lookback bars)