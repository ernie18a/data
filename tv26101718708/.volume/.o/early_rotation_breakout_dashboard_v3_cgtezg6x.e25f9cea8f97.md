Calculation: All calculations use bars aggregated to the configured calculation timeframe, including the bar still forming.
Calculation: Relative strength vs. industry = (1 + stock return over the relative-strength lookback) / (1 + industry ETF return over the same lookback) - 1.
Calculation: Relative-strength change = current relative strength vs. industry minus its value five calculation-timeframe bars earlier.
Calculation: Upper aligned = industry ETF relative strength vs. sector ETF > 0 AND sector ETF relative strength vs. SPY > 0; each relative strength uses the relative-strength lookback.
Calculation: Upper building = both industry-vs-sector and sector-vs-SPY relative strengths are greater than their values five bars earlier AND both current relative strengths are greater than -3%.
Calculation: Early breakout level = highest high of the prior early-breakout-lookback bars, excluding the current bar.
Calculation: Major breakout level = highest high of the prior major-breakout-lookback bars, excluding the current bar; the major-breakout lookback is longer than the early-breakout lookback.
Calculation: Relative volume = current volume / its simple moving average over the volume lookback.
Calculation: Fast EMA rising = current fast EMA >= its value five bars earlier; trend SMA rising = current trend SMA >= its value five bars earlier.
Long: Close > early breakout level AND previous close <= highest high over the early-breakout-lookback bars ending one bar earlier AND relative-strength change > 0 AND (upper aligned OR upper building)
Long: Close > major breakout level AND previous close <= highest high over the major-breakout-lookback bars ending one bar earlier AND relative strength vs. industry > 0 AND (upper aligned OR upper building)
Long: Close > major breakout level AND previous close <= highest high over the major-breakout-lookback bars ending one bar earlier AND relative strength vs. industry > 0 AND relative volume >= breakout-volume threshold AND upper aligned
Long: Prior major breakout established an active trend AND trend age >= minimum secondary-base bars AND a higher base has previously formed AND a new early breakout occurs AND relative-strength change > 0 AND (upper aligned OR upper building)
Long: Setup condition occurred within the setup-memory-bar window AND no higher-priority state applies; setup condition = early-breakout distance is between 0% and the early-setup threshold AND relative-strength change > 0 AND close > trend SMA AND fast EMA rising AND trend SMA rising AND (upper aligned OR upper building)
Long: A higher base is current or was previously detected during the active trend AND early-breakout distance is between 0% and the early-setup threshold AND relative-strength change > 0 AND (upper aligned OR upper building) AND no higher-priority state applies
Exit: long, An active major-breakout trend exists AND close < original major breakout level × (1 − trend-failure tolerance) AND close < trend SMA