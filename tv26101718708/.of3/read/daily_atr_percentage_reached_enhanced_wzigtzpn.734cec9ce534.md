Calculation: ATR range use % = 100 * (high(T1, bar still forming) - low(T1, bar still forming)) / ATR(T1, ATR lookback, bar still forming), calculated on T1 bars and carried to chart bars
Calculation: Average ATR range use % = SMA(ATR range use %, averaging lookback, T1, bar still forming), calculated on T1 bars and carried to chart bars
Calculation: Price fulfillment % = 100 * (close of chart bar - low(T1, bar still forming)) / ATR(T1, ATR lookback, bar still forming), calculated on chart bars using the chart close and current T1 values
Long: close(T1, bar still forming) > open(T1, bar still forming) AND ATR range use % > Average ATR range use % * multiplier
Short: close(T1, bar still forming) < open(T1, bar still forming) AND ATR range use % > Average ATR range use % * multiplier
Exit: long, Price fulfillment % > exit threshold
Exit: short, Price fulfillment % > exit threshold
Exit: long, ATR range use % > extreme ATR threshold
Exit: short, ATR range use % > extreme ATR threshold