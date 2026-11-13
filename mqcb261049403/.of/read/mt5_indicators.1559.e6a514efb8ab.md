Calculation: PrevDay = the last completed daily bar (a timeframe higher than the chart timeframe) before the day containing the current chart bar; on a Friday this is Thursday's bar; use its open and close
Long: current bar opens on a Friday at the entry time-of-day (minute 0) AND PrevDay open > PrevDay close (previous day fell)
Short: current bar opens on a Friday at the entry time-of-day (minute 0) AND PrevDay open < PrevDay close (previous day rose)
Exit: long, current bar opens on a Friday at the exit time-of-day (minute 0, later than the entry time-of-day) AND PrevDay open > PrevDay close; exit at this bar's close
Exit: short, current bar opens on a Friday at the exit time-of-day (minute 0, later than the entry time-of-day) AND PrevDay open < PrevDay close; exit at this bar's close