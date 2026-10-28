Calculation: jaw = EMA of (high + low) / 2 using the longest lookback
Calculation: teeth = EMA of (high + low) / 2 using a shorter lookback than jaw and longer than lips
Calculation: lips = EMA of (high + low) / 2 using the shortest lookback
Calculation: average volume = SMA of volume over the volume lookback
Calculation: recent range = highest high minus lowest low over the range lookback
Calculation: average range = SMA of recent range over the same range lookback
Long: lips < teeth AND teeth < jaw AND jaw > its prior-bar value by more than the slope threshold AND teeth > its prior-bar value by more than the slope threshold AND lips > its prior-bar value by more than the slope threshold AND average volume > 0 AND volume > average volume × volume multiplier AND average range > 0 AND recent range > average range × range multiplier
Short: lips > teeth AND teeth > jaw AND jaw < its prior-bar value by more than the slope threshold AND teeth < its prior-bar value by more than the slope threshold AND lips < its prior-bar value by more than the slope threshold AND average volume > 0 AND volume > average volume × volume multiplier AND average range > 0 AND recent range > average range × range multiplier