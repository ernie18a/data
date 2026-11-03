Calculation: RVOL = current volume divided by the moving average of volume over a lookback
Calculation: Body quality = absolute difference between close and open divided by high minus low
Long: Close >= previous bar close AND ((RVOL >= confirmation threshold AND body quality >= minimum body quality) OR RVOL >= extreme threshold)
Short: Close < previous bar close AND ((RVOL >= confirmation threshold AND body quality >= minimum body quality) OR RVOL >= extreme threshold)