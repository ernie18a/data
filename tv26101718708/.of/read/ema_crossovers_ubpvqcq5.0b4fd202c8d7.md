Calculation: EMA = exponential moving average of close; Fast EMA has a shorter lookback than Slow EMA, both on chart timeframe
Calculation: VWAP = session-anchored cumulative sum(close*volume) / cumulative sum(volume), reset at each session start
Calculation: FirstTouch(L) = (low <= L AND high >= L on the current bar) AND NOT (low[1] <= L[1] AND high[1] >= L[1])
Long: Fast EMA crosses above Slow EMA (Fast EMA > Slow EMA on the current bar AND Fast EMA <= Slow EMA on the previous bar) AND volume > simple moving average of volume
Short: Fast EMA crosses below Slow EMA (Fast EMA < Slow EMA on the current bar AND Fast EMA >= Slow EMA on the previous bar) AND volume > simple moving average of volume
Long: FirstTouch(Fast EMA) AND close[1] <= Fast EMA[1]
Short: FirstTouch(Fast EMA) AND close[1] > Fast EMA[1]
Long: FirstTouch(Slow EMA) AND close[1] <= Slow EMA[1]
Short: FirstTouch(Slow EMA) AND close[1] > Slow EMA[1]
Long: FirstTouch(VWAP) AND close[1] <= VWAP[1]
Short: FirstTouch(VWAP) AND close[1] > VWAP[1]