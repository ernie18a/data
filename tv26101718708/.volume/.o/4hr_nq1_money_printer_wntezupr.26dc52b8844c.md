Calculation: Prior-bar rolling high = highest high over the range lookback, ending on the previous bar
Calculation: Prior-bar rolling low = lowest low over the range lookback, ending on the previous bar
Long: flat AND volume > its longer-lookback simple moving average × volume surge multiplier AND high > prior-bar rolling high
Long: long position AND open-trade profit > scale-in trigger × tick size
Short: flat AND volume > its longer-lookback simple moving average × volume surge multiplier AND low < prior-bar rolling low
Exit: Long, close > entry price + scale-in trigger × tick size AND (low <= entry price OR high >= entry price + take-profit ticks × tick size) OR close <= entry price + scale-in trigger × tick size AND low <= entry price − initial stop-loss ticks × tick size
Exit: Short, close < entry price − scale-in trigger × tick size AND (high >= entry price OR low <= entry price − take-profit ticks × tick size) OR close >= entry price − scale-in trigger × tick size AND high >= entry price + initial stop-loss ticks × tick size