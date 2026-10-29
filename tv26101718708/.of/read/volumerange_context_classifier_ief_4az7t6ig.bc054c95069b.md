Calculation: Volume z-score = (current volume − its lookback mean) / its lookback standard deviation; use 0 if the standard deviation is not positive
Calculation: True-range z-score = (current true range − its lookback mean) / its lookback standard deviation; use 0 if the standard deviation is not positive
Calculation: Close location = (close − low) / max(high − low, minimum price increment)
Calculation: Prior structure high = highest high over the structure lookback, excluding the current bar
Calculation: Prior structure low = lowest low over the structure lookback, excluding the current bar
Long: bar is confirmed AND volume z-score >= unusual-volume threshold AND true-range z-score >= unusual-range threshold AND close location >= minimum directional close location AND close > prior structure high AND close >= EMA
Short: bar is confirmed AND volume z-score >= unusual-volume threshold AND true-range z-score >= unusual-range threshold AND close location <= 1 − minimum directional close location AND close < prior structure low AND close <= EMA