Calculation: JMA slope = change in the JMA-smoothed selected price from the preceding bar, divided by point size; calculated on the configured indicator timeframe (higher or lower than the chart timeframe), using completed bars.
Long: JMA slope > 0 OR (previous JMA slope <= 0 AND current JMA slope > 0) OR (the middle of three consecutive JMA slopes is lower than both outer slopes)
Short: JMA slope < 0 OR (previous JMA slope >= 0 AND current JMA slope < 0) OR (the middle of three consecutive JMA slopes is higher than both outer slopes)
Exit: long, JMA slope < 0 OR (the preceding JMA slope is lower than the current JMA slope)
Exit: short, JMA slope > 0 OR (the preceding JMA slope is higher than the current JMA slope)