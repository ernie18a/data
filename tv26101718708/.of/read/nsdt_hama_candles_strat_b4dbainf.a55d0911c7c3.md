Calculation: EntryMA = moving average of close (EMA, SMA or WMA)
Calculation: ADX = Wilder ADX computed on the chart timeframe from the +DI/-DI directional movement
Calculation: HAMAOpen = moving average of the previous bar's (open+close)/2
Calculation: TrendMA = weighted moving average of close
Long: EntryMA > EntryMA[1] AND EntryMA[1] > EntryMA[2] AND ADX > threshold
Short: EntryMA < EntryMA[1] AND EntryMA[1] < EntryMA[2] AND ADX > threshold
Long: TrendMA > exponential moving average of TrendMA (shorter lookback than TrendMA) OR HAMAOpen > HAMAOpen[1]
Short: TrendMA < exponential moving average of TrendMA (shorter lookback than TrendMA) OR HAMAOpen < HAMAOpen[1]
Exit: long, EntryMA < EntryMA[1] AND EntryMA[1] < EntryMA[2] AND ADX > threshold (reverse to short)
Exit: short, EntryMA > EntryMA[1] AND EntryMA[1] > EntryMA[2] AND ADX > threshold (reverse to long)