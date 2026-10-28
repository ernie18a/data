Calculation: Opening-range high = highest high among current-session bars in the first 15 minutes; use after that window completes
Calculation: Previous-day close and high = close and high of the last completed daily bar
Calculation: Daily 50-bar and 200-bar simple moving averages = averages of the respective lookbacks of daily closes, including the daily bar still forming
Calculation: Constructive moving-average condition = close is above either daily moving average or within the configured percentage threshold of either
Calculation: Checklist score = count of these seven true conditions: close above VWAP; close above previous-day close; opening range complete and close above its high; close at least the configured percentage threshold below previous-day high or above it; constructive moving-average condition; RSI below its limit; RSI moving average disabled, unavailable on the prior bar, or at least its prior-bar value
Long: During the regular session, checklist score >= 4