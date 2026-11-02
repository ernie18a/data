Calculation: Long stop = minimum of signal-bar low and medium-period EMA of close minus signal-bar ATR multiplied by a stop multiplier; freeze at the long-entry signal.
Calculation: Short stop = maximum of signal-bar high and medium-period EMA of close plus signal-bar ATR multiplied by a stop multiplier; freeze at the short-entry signal.
Calculation: Long target = signal-bar close + (signal-bar close − long stop) × reward-to-risk multiplier; freeze at the long-entry signal.
Calculation: Short target = signal-bar close − (short stop − signal-bar close) × reward-to-risk multiplier; freeze at the short-entry signal.
Long: Close crosses above the short-period EMA of close AND short-period EMA > medium-period EMA > long-period EMA AND short-period EMA > its value a lookback number of bars ago.
Short: Close crosses below the short-period EMA of close AND short-period EMA < medium-period EMA AND short-period EMA < long-period EMA AND short-period EMA < its value a lookback number of bars ago.
Exit: Long, short-period EMA crosses below medium-period EMA OR low <= long stop OR high >= long target.
Exit: Short, short-period EMA crosses above medium-period EMA OR high >= short stop OR low <= short target.