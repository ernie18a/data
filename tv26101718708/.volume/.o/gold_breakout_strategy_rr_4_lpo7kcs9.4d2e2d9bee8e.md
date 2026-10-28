Calculation: Current Donchian upper = highest high over the configured lookback, including the current bar
Calculation: Previous Donchian upper = highest high over the same lookback ending at the previous completed bar
Calculation: Current Donchian lower = lowest low over the configured lookback, including the current bar
Calculation: Previous Donchian lower = lowest low over the same lookback ending at the previous completed bar
Calculation: LWTI = weighted moving average of one-bar close changes
Calculation: Smoothed LWTI = simple moving average of LWTI, using a shorter lookback than the LWTI weighted moving average
Long: no trade has been taken on the current day AND time is within the configured session AND close > previous Donchian upper AND current Donchian upper > previous Donchian upper AND volume > volume simple moving average AND LWTI > smoothed LWTI
Short: no trade has been taken on the current day AND time is within the configured session AND close < previous Donchian lower AND current Donchian lower < previous Donchian lower AND volume > volume simple moving average AND LWTI < smoothed LWTI
Exit: Long, low <= low of the long-entry bar OR high >= close of the long-entry bar + reward-to-risk multiple × (close of the long-entry bar − low of the long-entry bar)
Exit: Short, high >= high of the short-entry bar OR low <= close of the short-entry bar − reward-to-risk multiple × (high of the short-entry bar − close of the short-entry bar)