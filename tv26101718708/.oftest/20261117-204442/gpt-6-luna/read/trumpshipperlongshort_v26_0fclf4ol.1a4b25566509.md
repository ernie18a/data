Calculation: Return = (current still-forming higher-timeframe bar close - prior higher-timeframe bar close) / prior higher-timeframe bar close
Calculation: Prediction = true when Return > threshold, false when Return < -threshold, otherwise its prior value
Long: Return > threshold OR (-threshold <= Return AND Return <= threshold AND prior Prediction is true)
Short: Return < -threshold OR (-threshold <= Return AND Return <= threshold AND prior Prediction is false)
Exit: short, Return > threshold
Exit: long, Return < -threshold