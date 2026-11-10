Calculation: Previous-day high and low = highest high and lowest low of chart bars in the last completed trading day, including extended hours.
Calculation: Premarket high and low = highest high and lowest low of chart bars in the most recently completed premarket session; update at the start of the regular market session and retain until the next update.
Long: Previous-day high and low are available AND close >= previous-day high.
Long: Premarket high and low are available AND close >= premarket high.
Long: Close >= previous-day high AND close >= premarket high.
Short: Previous-day high and low are available AND close <= previous-day low.
Short: Premarket high and low are available AND close <= premarket low.
Short: Close <= previous-day low AND close <= premarket low AND (close < previous-day high OR close < premarket high).