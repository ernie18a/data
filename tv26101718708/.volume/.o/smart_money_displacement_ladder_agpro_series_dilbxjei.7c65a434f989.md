Calculation: ATR = average true range over a lookback
Calculation: Candle body = absolute difference between close and open
Calculation: Candle range = high minus low
Calculation: Close location = (close - low) / candle range × 100
Calculation: Bullish shelf = for a bullish displacement candle, top is the lower of its close and high minus ATR times shelf thickness; bottom is the higher of its open and low plus ATR times shelf thickness
Calculation: Bearish shelf = for a bearish displacement candle, top is the lower of its open and high minus ATR times shelf thickness; bottom is the higher of its close and low plus ATR times shelf thickness
Calculation: Active ladder level = high of the latest bullish displacement anchor or low of the latest bearish displacement anchor; after each ladder step, update it to that step's close
Long: bar is confirmed AND ((close > open AND candle body / ATR ≥ minimum body threshold AND candle range / ATR ≥ minimum range threshold AND close location ≥ minimum close strength) OR (active displacement is bullish AND shelf has not failed AND close > active ladder level))
Short: bar is confirmed AND ((close < open AND candle body / ATR ≥ minimum body threshold AND candle range / ATR ≥ minimum range threshold AND 100 - close location ≥ minimum close strength) OR (active displacement is bearish AND shelf has not failed AND close < active ladder level))
Exit: Long, active displacement is bullish AND shelf has not failed AND bars since displacement anchor ≤ failure window AND close < bullish shelf bottom
Exit: Short, active displacement is bearish AND shelf has not failed AND bars since displacement anchor ≤ failure window AND close > bearish shelf top