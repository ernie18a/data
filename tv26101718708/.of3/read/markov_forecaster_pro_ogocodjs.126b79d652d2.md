Calculation: rolling log return = ln(close / close[return lookback])
Calculation: adaptive threshold = adaptive multiplier × StDev(ln(close / close[1]), volatility lookback) × sqrt(return lookback)
Calculation: bull threshold = adaptive threshold in adaptive mode, otherwise fixed bull threshold
Calculation: bear threshold = adaptive threshold in adaptive mode, otherwise fixed bear threshold
Calculation: regime = Bull if rolling log return > bull threshold, Bear if rolling log return < −bear threshold, otherwise Sideways
Long: regime becomes Bull and first persists for the minimum-hold parameter bars, and the last regime-entry signal was not Bull
Short: regime becomes Bear and first persists for the minimum-hold parameter bars, and the last regime-entry signal was not Bear
Exit: Long, regime becomes Sideways and first persists for the minimum-hold parameter bars, and the last regime-entry signal was not Sideways
Exit: Short, regime becomes Sideways and first persists for the minimum-hold parameter bars, and the last regime-entry signal was not Sideways
Long: regime is Bull and rolling log return ≥ high-confidence multiplier × bull threshold
Short: regime is Bear and rolling log return ≤ −(high-confidence multiplier × bear threshold)
Long: regime is Sideways, rolling log return > 0, and rolling log return / bull threshold ≥ pending fraction
Short: regime is Sideways, rolling log return < 0, and −rolling log return / bear threshold ≥ pending fraction
Long: previous chart bar's confirmed regime is Bull
Exit: Long, previous chart bar's confirmed regime is not Bull