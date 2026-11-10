Calculation: Pivot = (high + low + close) / 3 of the last completed higher-timeframe session, using a configurable session-start shift and excluding weekend quotes.
Calculation: Upper exit levels = pivot + (high - low) and 2 × pivot + high - 2 × low, using the same completed session as the pivot.
Calculation: Lower exit levels = pivot - (high - low) and 2 × pivot - 2 × high + low, using the same completed session as the pivot.
Long: Open of the still-forming higher-timeframe session > pivot.
Short: Open of the still-forming higher-timeframe session < pivot.
Exit: long, chart bar high >= either upper exit level.
Exit: short, chart bar low <= either lower exit level.