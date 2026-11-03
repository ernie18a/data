Calculation: Weekly SMA = simple moving average of weekly closes; use the last completed weekly bar.
Calculation: Prior-range high = highest weekly high over the longer lookback, starting two weekly bars before the current bar; use completed bars.
Calculation: Prior-range low = lowest weekly low over the same lookback, starting two weekly bars before the current bar; use completed bars.
Long: Day of week = Monday AND (prior-range high < last completed weekly close OR (prior-range high >= last completed weekly close AND prior-range low <= last completed weekly close AND weekly SMA > current weekly open))
Short: Day of week = Monday AND (prior-range low > last completed weekly close OR (prior-range high >= last completed weekly close AND prior-range low <= last completed weekly close AND weekly SMA < current weekly open))
Exit: long, elapsed time since entry > one week
Exit: short, elapsed time since entry > one week