Calculation: Opening-range high = highest high from the session open through the opening-range period
Calculation: Opening-range low = lowest low from the session open through the opening-range period
Long: Close crosses above the configured bullish trigger AND close > 9-period EMA AND 9-period EMA >= 21-period EMA AND close >= VWAP AND VIX < bearish-confirmation threshold AND close >= opening-range low
Long: Close crosses above the configured bullish confirmation level AND close > 9-period EMA AND 9-period EMA >= 21-period EMA AND close >= VWAP AND VIX < bearish-confirmation threshold AND close >= opening-range low
Long: Low <= configured pullback level AND close > that level AND close > 9-period EMA AND VIX < bearish-confirmation threshold
Long: Opening-range period is complete AND close crosses above opening-range high AND close > pivot AND close > 9-period EMA AND 9-period EMA >= 21-period EMA AND close >= VWAP AND VIX < bearish-confirmation threshold
Short: Close crosses below configured bearish-warning level AND VIX >= bearish-confirmation threshold
Short: Close crosses below configured bearish trigger AND close < 9-period EMA AND 9-period EMA <= 21-period EMA AND close <= VWAP AND VIX >= bearish-confirmation threshold AND close <= opening-range high
Short: High exceeds configured bullish-confirmation level AND close < configured failure level AND VIX >= bearish-confirmation threshold
Short: High exceeds pivot AND close < pivot AND VIX >= bearish-confirmation threshold
Short: Opening-range period is complete AND close crosses below opening-range low AND close < pivot AND close < 9-period EMA AND 9-period EMA <= 21-period EMA AND close <= VWAP AND VIX >= bearish-confirmation threshold
Exit: Long, close < configured long invalidation level
Exit: Short, close > configured short invalidation level