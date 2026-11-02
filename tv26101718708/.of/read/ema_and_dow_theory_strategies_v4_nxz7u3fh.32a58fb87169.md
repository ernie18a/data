Calculation: Swing levels = the latest high and low, respectively, whose value N bars ago equals the highest high or lowest low over the most recent 2N+1 bars, including the current bar; retain each level until replaced.
Calculation: Dow trend = initially neutral; set to up when close > the latest swing high, then set to down when close < the latest swing low; otherwise retain the previous state. Apply the down update last if both comparisons hold.
Calculation: Higher-timeframe trend = apply the same persistent trend updates to the last completed higher-timeframe close and the latest confirmed higher-timeframe pivot high and low. A pivot has N bars on each side and is taken from the last completed higher-timeframe bar; retain the latest nonmissing pivot levels.
Calculation: Target distance = ATR multiplied by a factor, fixed on the entry-signal bar. Set three targets at the entry-signal close plus, for a long, or minus, for a short, successive integer multiples of that distance. Each target can trigger once per trade.
Calculation: Long break-even state = enabled AND, since entry, (close - entry price) / entry price >= profit threshold; retain this state until the position closes.
Calculation: Short break-even state = enabled AND, since entry, (entry price - close) / entry price >= profit threshold; retain this state until the position closes.
Long: EMA of close > previous-bar EMA of close
Short: EMA of close <= previous-bar EMA of close
Long: Dow trend = up
Short: Dow trend = down
Long: higher-timeframe trend = up AND higher-timeframe swing low exists
Short: higher-timeframe trend = down AND higher-timeframe swing high exists
Long: position is flat AND EMA of close > previous-bar EMA of close AND Dow trend = up AND ADX > threshold
Short: position is flat AND EMA of close < previous-bar EMA of close AND Dow trend = down AND ADX > threshold
Exit: long, (close - entry price) / entry price < loss threshold
Exit: short, (entry price - close) / entry price < loss threshold
Exit: long, long break-even state = active AND low <= entry price × (1 + fee buffer)
Exit: short, short break-even state = active AND high >= entry price × (1 - fee buffer)
Exit: long, Dow trend = down
Exit: short, Dow trend = up
Exit: long, high > an untriggered long target; close a fixed fraction of the current position for each target reached
Exit: short, low < an untriggered short target; close a fixed fraction of the current position for each target reached