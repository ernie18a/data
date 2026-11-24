Calculation: Range(T) = initialize high and low from the first T bar with neutral direction; retain the bounds and direction until a T bar closes above the range high or below the range low, then reset the bounds to that bar’s high and low and set direction bullish or bearish respectively; T1 is the execution timeframe and T2 the higher context timeframe; on chart bars use the last completed T bar when T is higher than the chart timeframe, otherwise calculate on chart bars
Calculation: Execution midpoint = (Range(T1).high + Range(T1).low) / 2
Long: Range(T1) resets bullish
Short: Range(T1) resets bearish
Long: Range(T2) resets bullish
Short: Range(T2) resets bearish
Long: Range(T2).direction is bullish
Short: Range(T2).direction is bearish
Long: close > Range(T2).high
Short: close < Range(T2).low
Long: Range(T1).direction is bullish AND Range(T2).direction is bullish AND entry price = Execution midpoint
Short: Range(T1).direction is bearish AND Range(T2).direction is bearish AND entry price = Execution midpoint
Long: low < Range(T1).low AND close >= Range(T1).low AND no Range(T1) reset
Short: high > Range(T1).high AND close <= Range(T1).high AND no Range(T1) reset
Long: close crosses above Execution midpoint AND no Range(T1) reset
Short: close crosses below Execution midpoint AND no Range(T1) reset
Exit: long, Range(T1) resets bearish
Exit: short, Range(T1) resets bullish