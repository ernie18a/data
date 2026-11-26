Calculation: Volatility = StDev(Stochastic K(high, low, close, normalization length), volatility length)
Calculation: Upper = (HighestBars(Volatility, box detection length + 1) + box detection length) / box detection length
Calculation: Lower = (LowestBars(Volatility, box detection length + 1) + box detection length) / box detection length
Calculation: Duration = Max(NZ(BarsSince(Lower crosses above Upper)), 1)
Calculation: Channel top = Highest(high, Duration)
Calculation: Channel bottom = Lowest(low, Duration)
Calculation: Channel range = Channel top - Channel bottom
Calculation: ATR = ATR(high, low, close, ATR length, T1, last completed bar)
Long: long enabled AND low <= Channel bottom + entry zone fraction * Channel range AND (no previous long entry OR bars since last long entry >= cooldown bars) AND (ATR filter disabled OR ATR >= minimum ATR value) AND position side is flat AND close <= Channel top + breakout tolerance ticks * tick size AND close >= Channel bottom - breakout tolerance ticks * tick size
Short: short enabled AND high >= Channel top - entry zone fraction * Channel range AND (no previous short entry OR bars since last short entry >= cooldown bars) AND (ATR filter disabled OR ATR >= minimum ATR value) AND position side is flat AND close <= Channel top + breakout tolerance ticks * tick size AND close >= Channel bottom - breakout tolerance ticks * tick size
Exit: long, (take-profit method is fixed points AND high >= entry price + take-profit ticks * tick size) OR (take-profit method is percent of channel AND high >= entry price + entry channel range * take-profit fraction) OR low <= entry channel bottom - stop offset ticks * tick size
Exit: short, (take-profit method is fixed points AND low <= entry price - take-profit ticks * tick size) OR (take-profit method is percent of channel AND low <= entry price - entry channel range * take-profit fraction) OR high >= entry channel top + stop offset ticks * tick size