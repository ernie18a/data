Calculation: Buy volume = Sum the volume of lower-timeframe bars within the current chart bar whose close is greater than or equal to their open; if there are none, use the current chart bar's volume when its close is greater than or equal to its open, otherwise 0.
Calculation: Sell volume = Sum the volume of lower-timeframe bars within the current chart bar whose close is below their open; if there are none, use the current chart bar's volume when its close is below its open, otherwise 0.
Long: Buy volume >= Sell volume
Short: Sell volume > Buy volume