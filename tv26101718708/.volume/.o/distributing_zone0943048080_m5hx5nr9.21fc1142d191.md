Calculation: Box close range = (highest close over the lookback bars before the current bar − lowest close over those bars) / lowest close × 100
Calculation: Minimum Bollinger Band width = lowest ((upper band − lower band) / close × 100) over the box lookback, using the current bar and prior bars
Calculation: EMA distance from box high = absolute value of (prior bar’s EMA − highest close over the lookback bars before the current bar) / that highest close × 100
Calculation: Recent volume average = average volume over the more recent half of the box lookback bars before the current bar; full volume average = average volume over the full box lookback before the current bar
Calculation: OBV change = current OBV − OBV from half a box lookback ago
Calculation: RSI change = current RSI − RSI from half a box lookback ago
Calculation: Lower highs = highest high in the more recent half of the box lookback bars before the current bar < highest high over the full box lookback before the current bar
Calculation: MACD falling = MACD line < signal line AND MACD line < MACD line from half a box lookback ago
Calculation: Upthrust present = highest high over the box lookback before the current bar > highest close over that lookback
Short: box close range is within its configured maximum AND minimum Bollinger Band width is below its configured maximum AND (EMA distance from box high is below its configured maximum, if enabled) AND (recent volume average < full volume average, if enabled) AND (OBV change < 0, if enabled) AND (RSI change < 0, if enabled) AND (MACD falling, if enabled) AND (lower highs, if enabled) AND (upthrust present, if enabled)