Calculation: Configured moving average = selected EMA, SMA, RMA, or WMA of its source over its lookback
Calculation: MA 2 = its configured moving average type and lookback applied to MA 1's source
Calculation: Bollinger Band width = (upper band − lower band) / middle band, using the selected source, lookback, and multiplier
Calculation: Momentum = selected source − its value one lookback ago
Long: datetime >= configured start time AND datetime <= configured end time AND (the configured AND/OR combination of enabled long rules; each rule compares a selected indicator (ATR, MA 1, MA 2, RSI, CCI, Bollinger Band width, ADX, MFI, or Momentum) with another selected indicator or a configured numeric value using >, <, >=, <=, =, !=, cross above, or cross below)
Short: datetime >= configured start time AND datetime <= configured end time AND (the configured AND/OR combination of enabled short rules, using the same rule form as long rules)
Exit: long position, low <= the active stop level OR high >= the configured take-profit level; the stop is the configured trailing stop when enabled, otherwise the configured fixed stop when enabled
Exit: short position, high >= the active stop level OR low <= the configured take-profit level; the stop is the configured trailing stop when enabled, otherwise the configured fixed stop when enabled
Exit: long position, the configured short-rule combination is true and market mode is spot
Calculation: Long trailing stop = maximum of the previous long trailing stop and the current low adjusted downward by the configured percentage or absolute amount; reset to zero when not in a long position
Calculation: Short trailing stop = minimum of the previous short trailing stop and the current high adjusted upward by the configured percentage or absolute amount; reset to a high sentinel when not in a short position