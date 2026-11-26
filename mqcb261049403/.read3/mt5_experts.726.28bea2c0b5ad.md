Calculation: EUR-equivalent position volume = position volume if the base currency is EUR, otherwise position volume divided by the EUR/base-currency ask
Calculation: Currency exposure(C) = sum of EUR-equivalent position volumes, positive for long base or short quote positions and negative for short base or long quote positions
Calculation: Initial target distance = initial target multiplier × max(take-profit factor × entry price, 2 × minimum stop distance, spread + minimum price increment)
Calculation: Long target price = entry price + initial target distance
Calculation: Short target price = entry price - initial target distance
Calculation: Grid step = max(take-profit factor × position target price, 2 × minimum stop distance, spread + minimum price increment)
Long: flat AND configured direction is long AND base-currency exposure < maximum currency exposure
Short: flat AND configured direction is short AND quote-currency exposure < maximum currency exposure
Long: long position AND close <= long target price - (position volume / minimum lot + 1) × grid step AND position volume + minimum lot < maximum position volume AND base-currency exposure - quote-currency exposure <= exposure imbalance limit AND base-currency exposure < maximum currency exposure
Short: short position AND close >= short target price + (position volume / minimum lot + 1) × grid step AND position volume + minimum lot < maximum position volume AND quote-currency exposure - base-currency exposure <= exposure imbalance limit AND quote-currency exposure < maximum currency exposure
Exit: long, close > long target price - (position volume / minimum lot - 1) × grid step
Exit: short, close < short target price + (position volume / minimum lot - 1) × grid step
Exit: long, manage-loss enabled AND position profit < 0 AND position volume > minimum lot
Exit: short, manage-loss enabled AND position profit < 0 AND position volume > minimum lot
Exit: long, manage-take-profit enabled AND (maximum open-position profit > absolute minimum open-position profit OR account profit > 0)
Exit: short, manage-take-profit enabled AND (maximum open-position profit > absolute minimum open-position profit OR account profit > 0)