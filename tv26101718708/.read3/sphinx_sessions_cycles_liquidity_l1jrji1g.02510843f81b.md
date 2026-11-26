Calculation: daily_bias_open = open of the daily bias-time chart bar
Long: close < daily_bias_open
Short: close > daily_bias_open
Long: close < daily_bias_open AND, since the calendar-date reset, low < the current cycle's running low before the bar
Short: close > daily_bias_open AND, since the calendar-date reset, high > the current cycle's running high before the bar
Long: On chart bars using the current T1 bar (forming in real time; last completed bar historically), a bullish fair value gap in retained history has an upper boundary below T1 close; select the most recent qualifying gap. Its formation condition is T1 low > T1 high[1] when the calendar date changes, otherwise T1 low > T1 high[2]
Short: On chart bars using the current T1 bar (forming in real time; last completed bar historically), a bearish fair value gap in retained history has a lower boundary above T1 close; select the most recent qualifying gap. Its formation condition is T1 high < T1 low[1] when the calendar date changes, otherwise T1 high < T1 low[2]