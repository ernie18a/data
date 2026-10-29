Calculation: SMA of close = simple moving average of close
Calculation: VWAP of close = volume-weighted average price of close
Calculation: HMA of close = Hull moving average of close
Calculation: EMA of high = exponential moving average of bar high
Calculation: TEMA of close = triple exponential moving average of close
Calculation: Green zone = turns on when SMA crosses above VWAP and close > HMA; remains active until SMA < VWAP or close < HMA
Calculation: Profit lock = activates when close - entry price reaches the lock trigger distance; remains active until exit, with lock level at entry price + lock profit distance
Long: Green zone active AND green zone did not start this bar AND no entry has occurred in this zone AND flat AND low <= EMA of high AND close >= EMA of high
Exit: Long, green zone was active on the previous bar and is now inactive OR TEMA crosses below SMA OR profit lock active AND close <= lock level