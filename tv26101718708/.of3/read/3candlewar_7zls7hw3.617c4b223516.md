Calculation: Armed = NOT PendingBuy AND NOT PendingSell AND NOT (PendingBuy[1] AND BuyConfirm) AND NOT (PendingSell[1] AND SellConfirm)
Calculation: PendingBuy = Armed[1] AND low < low[1] AND high <= high[1] AND close >= low[1] AND close <= high[1]
Calculation: PendingSell = Armed[1] AND high > high[1] AND low >= low[1] AND close >= low[1] AND close <= high[1]
Calculation: BuyConfirm = low >= low[2] AND high >= high[2] AND close > high[2] - ATR(ATR lookback) * close tolerance AND (close > SMA(close, MA lookback, T1, last completed bar) OR (exists z in BullZones: close >= z.bottom - ATR(ATR lookback) * proximity multiplier AND close <= z.top + ATR(ATR lookback) * proximity multiplier) OR BullTouch[1] OR BullTouch[2])
Calculation: SellConfirm = high <= high[2] AND low <= low[2] AND close < low[2] + ATR(ATR lookback) * close tolerance AND (close < SMA(close, MA lookback, T1, last completed bar) OR (exists z in BearZones: close >= z.bottom - ATR(ATR lookback) * proximity multiplier AND close <= z.top + ATR(ATR lookback) * proximity multiplier) OR BearTouch[1] OR BearTouch[2])
Calculation: BullZones = newest(zone limit, {z in BullZones[1] : close >= z.bottom} plus zone(bottom=low[1], top=high[1]) if close[1] < open[1] AND close > high[1] AND close - open > ATR(ATR lookback) * displacement multiplier)
Calculation: BearZones = newest(zone limit, {z in BearZones[1] : close <= z.top} plus zone(bottom=low[1], top=high[1]) if close[1] > open[1] AND close < low[1] AND open - close > ATR(ATR lookback) * displacement multiplier)
Calculation: BullTouch = exists z in BullZones: high >= z.bottom - ATR(ATR lookback) * proximity multiplier AND low <= z.top + ATR(ATR lookback) * proximity multiplier
Calculation: BearTouch = exists z in BearZones: high >= z.bottom - ATR(ATR lookback) * proximity multiplier AND low <= z.top + ATR(ATR lookback) * proximity multiplier
Long: PendingBuy[1] AND BuyConfirm
Short: PendingSell[1] AND SellConfirm