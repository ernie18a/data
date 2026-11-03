Calculation: Average volume = simple moving average of volume over a lookback
Calculation: Prior range high = highest high over a lookback, excluding the current bar
Calculation: Prior range low = lowest low over a lookback, excluding the current bar
Long: Position is flat AND volume > average volume × volume surge multiplier AND high > prior range high
Long: Position is long AND open-trade profit > scale-in trigger × minimum tick size
Short: Position is flat AND volume > average volume × volume surge multiplier AND low < prior range low
Exit: Long, (close > entry price + scale-in trigger × minimum tick size AND (low ≤ entry price OR high ≥ entry price + take-profit ticks × minimum tick size)) OR (close ≤ entry price + scale-in trigger × minimum tick size AND low ≤ entry price − initial stop-loss ticks × minimum tick size)
Exit: Short, (close < entry price − scale-in trigger × minimum tick size AND (high ≥ entry price OR low ≤ entry price − take-profit ticks × minimum tick size)) OR (close ≥ entry price − scale-in trigger × minimum tick size AND high ≥ entry price + initial stop-loss ticks × minimum tick size)