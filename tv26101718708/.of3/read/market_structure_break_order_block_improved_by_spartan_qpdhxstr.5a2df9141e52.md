Calculation: Bullish swing range = abs(previous confirmed ZigZag swing high − latest confirmed ZigZag swing low)
Calculation: Bearish swing range = abs(latest confirmed ZigZag swing high − previous confirmed ZigZag swing low)
Calculation: Bullish OB zone = high and low of the latest bearish candle from the previous confirmed ZigZag swing high through the latest confirmed ZigZag swing low at a bullish MSB; valid until close < zone low
Calculation: Bearish OB zone = high and low of the latest bullish candle from the previous confirmed ZigZag swing low through the latest confirmed ZigZag swing high at a bearish MSB; valid until close > zone high
Calculation: Bullish BB/MB zone = high and low of the latest bullish candle from (previous confirmed ZigZag swing low index − ZigZag lookback) through the previous confirmed ZigZag swing high at a bullish MSB; valid until close > zone high
Calculation: Bearish BB/MB zone = high and low of the latest bearish candle from (previous confirmed ZigZag swing high index − ZigZag lookback) through the previous confirmed ZigZag swing low at a bearish MSB; valid until close < zone low
Calculation: Zone ranges overlap = lower bound of first zone <= upper bound of second zone AND lower bound of second zone <= upper bound of first zone
Long: on confirmed bar close, market direction before the bar is bearish AND latest confirmed ZigZag swing high > previous confirmed ZigZag swing high + Bullish swing range × Fib Factor AND latest confirmed ZigZag swing high and low both differ from their corresponding values at the previous market-direction change
Short: on confirmed bar close, market direction before the bar is bullish AND latest confirmed ZigZag swing low < previous confirmed ZigZag swing low − Bearish swing range × Fib Factor AND latest confirmed ZigZag swing high and low both differ from their corresponding values at the previous market-direction change
Short: the first bar within Failed MSB lookback bars after a bullish MSB, excluding the MSB bar, where close < the bullish MSB level AND bullish MSB level − close >= Bullish swing range at the MSB × Failed MSB minimum reversal fraction
Long: the first bar within Failed MSB lookback bars after a bearish MSB, excluding the MSB bar, where close > the bearish MSB level AND close − bearish MSB level >= Bearish swing range at the MSB × Failed MSB minimum reversal fraction
Long: on a bar after creation, close enters an active bullish OB zone from outside it for the first time
Long: on a bar after creation, close enters an active bullish BB/MB zone from outside it for the first time
Short: on a bar after creation, close enters an active bearish OB zone from outside it for the first time
Short: on a bar after creation, close enters an active bearish BB/MB zone from outside it for the first time
Long: on confirmed bar close, an active bullish OB zone overlaps an active bullish BB/MB zone and that OB zone has not previously produced a confluence marker
Short: on confirmed bar close, an active bearish OB zone overlaps an active bearish BB/MB zone and that OB zone has not previously produced a confluence marker