Calculation: Prior session low = lowest low of earlier bars in the current session timeframe, resetting at each new day
Calculation: Reference close = close of the most recent bar that made a new session low; reset at each new day and replace on each new session low
Calculation: Average daily volume = moving average of daily volume over completed daily bars, excluding the current day; daily bars are higher timeframe than the chart timeframe
Long: On a completed signal-timeframe bar (same or higher timeframe than the chart), during the regular session, low < prior session low OR (reference close is set AND low >= prior session low AND close > reference close AND average daily volume >= minimum)
Short: 
Exit: