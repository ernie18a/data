Calculation: Historical weekly up-close rate = percentage of prior weekly bars for the same calendar week whose close is above the preceding weekly close, using the selected Bernstein lookback.
Calculation: Seasonal weekly up-close rate = percentage of all available weekly bars for the same calendar week whose close is above the preceding weekly close.
Calculation: Trading-day up-close rate = percentage of prior daily bars for the same trading day number whose close is above their open, using the selected year lookback and either the current calendar month or all months. The daily bars are lower timeframe than the weekly chart; use the latest available daily bar to identify the current trading day number.
Long: Selected weekly up-close rate (Bernstein or seasonal) >= 52%
Short: Selected weekly up-close rate (Bernstein or seasonal) <= 48%
Long: Trading-day up-close rate >= 52% AND sample count >= required sample count
Short: Trading-day up-close rate <= 48% AND sample count >= required sample count
