Calculation: RSI = relative strength index of close
Calculation: RSI moving average = simple moving average of RSI
Calculation: BBWP = 100 × count of prior lookback bars whose Bollinger Band width is greater than or equal to current width, divided by lookback; Bollinger Band width = 2 × standard deviation of close / moving average of close
Calculation: BBWP moving average = moving average of BBWP, using a shorter lookback than the BBWP percentile lookback
Calculation: Trend moving average = selected moving average of close
Calculation: Upward momentum trigger = RSI exceeds its moving average by the crossover threshold after an upward crossover and a retest within the retest threshold; cancel the pending crossover if RSI falls below its moving average by more than the retest threshold; also trigger when RSI exceeds its moving average by the instant threshold
Calculation: Downward momentum trigger = mirror of the upward momentum trigger; also trigger when the RSI moving average exceeds RSI by the instant threshold
Calculation: RSI buy zone = upward momentum trigger or prior RSI buy zone, unless a downward momentum trigger occurs; RSI sell zone = downward momentum trigger or prior RSI sell zone, unless an upward momentum trigger occurs
Calculation: RSI buy signal = RSI buy zone begins after the prior bar was in the RSI sell zone; RSI sell signal = RSI sell zone begins after the prior bar was in the RSI buy zone
Calculation: Forward buy confirmation = prior forward buy confirmation persists until an RSI sell signal, or RSI is at or below the oversold level; forward sell confirmation = prior forward sell confirmation persists until an RSI buy signal, or RSI is at or above the overbought level
Calculation: BBWP confirmation = BBWP minus its moving average exceeds the confirmation threshold
Calculation: Allowed buy = RSI > RSI moving average AND RSI moving average > oversold level; allowed sell = RSI < RSI moving average AND RSI moving average < overbought level
Calculation: Confirmed buy zone = prior confirmed buy zone or full buy condition, unless full sell condition occurs; confirmed sell zone = prior confirmed sell zone or full sell condition, unless full buy condition occurs
Calculation: Full buy condition = RSI buy zone AND (forward buy confirmation OR BBWP confirmation) AND allowed buy; full sell condition = RSI sell zone AND (forward sell confirmation OR BBWP confirmation) AND allowed sell
Calculation: Trend-confirmed buy zone = confirmed buy zone AND close > trend moving average; trend-confirmed sell zone = confirmed sell zone AND close < trend moving average
Calculation: Fully confirmed buy signal = trend-confirmed buy zone begins; fully confirmed sell signal = trend-confirmed sell zone begins
Long: RSI buy signal
Long: confirmed buy zone begins after the prior bar was in the confirmed sell zone
Long: fully confirmed buy signal
Short: RSI sell signal
Short: confirmed sell zone begins after the prior bar was in the confirmed buy zone
Short: fully confirmed sell signal
Exit: Long, fully confirmed sell signal OR low <= entry price × (1 − stop loss) OR high >= entry price × (1 + take profit)
Exit: Short, fully confirmed buy signal OR high >= entry price × (1 + stop loss) OR low <= entry price × (1 − take profit)