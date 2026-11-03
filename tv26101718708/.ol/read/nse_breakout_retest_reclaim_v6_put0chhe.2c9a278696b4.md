Calculation: Previous day high = high of the last completed daily bar, where daily bars are higher timeframe than the chart timeframe
Calculation: 10-day high = highest high of the 10 completed daily bars before the current day, where daily bars are higher timeframe than the chart timeframe
Calculation: First 5-bar high = highest high of the first 5 chart-timeframe bars of the current day
Calculation: First 15-bar high = highest high of the first 15 chart-timeframe bars of the current day
Calculation: Gap % = (current day's open on the higher-timeframe daily bar still forming − previous completed daily close) / previous completed daily close × 100
Calculation: Zone low = breakout level − ATR × zone buffer
Calculation: Zone high = breakout level + ATR × zone buffer
Calculation: Bar RVOL = current bar volume / moving average of volume over a longer lookback
Calculation: Day-pace RVOL = cumulative volume so far today / average cumulative volume at the same bar-of-day index across prior sessions
Long: Close crosses above any enabled previous day high, first 5-bar high, first 15-bar high, or 10-day high AND current bar is in session AND bars today > skipped-bar count AND gap % is within the configured minimum and maximum AND close > VWAP AND VWAP > prior bar VWAP AND bar RVOL ≥ minimum breakout RVOL AND (day-pace filter disabled OR day-pace RVOL ≥ minimum day-pace RVOL) AND high − low ≤ ATR × maximum breakout ATR multiple AND no setup is active
Long: An active setup has not yet had a retest AND current bar's range intersects the zone AND close ≥ zone low AND close ≥ VWAP
Long: An active setup has had a retest AND 1 to maximum retest bars have elapsed since the retest AND close > zone high AND close > retest-bar high AND bar RVOL ≥ minimum reclaim RVOL AND close > VWAP
Short: 
Exit: