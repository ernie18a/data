Calculation: Rolling log return = log(close / close at a configurable lookback).
Calculation: Bull and bear boundaries = either separate fixed positive thresholds or the same adaptive threshold, calculated as a multiplier times the standard deviation of one-bar log returns over a configurable window times the square root of the rolling-return lookback.
Calculation: Regime = bull when rolling log return > bull boundary; bear when rolling log return < negative bear boundary; sideways otherwise. The regime is unavailable until its inputs are available.
Calculation: Last confirmed signal regime = initially unavailable; update it to the current regime whenever the current regime has persisted for the configurable minimum hold and differs from the last confirmed signal regime. The first such update produces no entry signal.
Long: Current regime = bull.
Short: Current regime = bear.
Long: Current regime = sideways AND rolling log return / bull boundary >= a configurable pending fraction.
Short: Current regime = sideways AND negative rolling log return / bear boundary >= a configurable pending fraction.
Long: Current regime = bull AND it has persisted for the minimum hold AND last confirmed signal regime is available AND last confirmed signal regime != bull, evaluated before updating the last confirmed signal regime.
Short: Current regime = bear AND it has persisted for the minimum hold AND last confirmed signal regime is available AND last confirmed signal regime != bear, evaluated before updating the last confirmed signal regime.
Long: Previous bar's regime = bull AND the regime two bars ago != bull.
Exit: long, previous bar's regime != bull AND the regime two bars ago = bull.