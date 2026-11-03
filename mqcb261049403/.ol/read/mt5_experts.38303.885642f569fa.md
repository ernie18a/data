Calculation: Grid level = on initialization, if chart-bar close is below the EMA, use the first lower grid level whose price is below the close, or the lowest grid level if none; otherwise use the first upper grid level whose price is above the close, or the highest grid level if none. Grid levels are spaced by a configured distance from the EMA.
Calculation: EMA = exponential moving average of close on a higher timeframe, using the last completed bar.
Long: On initialization, chart-bar close < EMA OR chart-bar close >= EMA; open the startup allocation of long positions determined by the grid level.
Long: Chart-bar close <= lower grid price AND short positions are held.
Short: On initialization, chart-bar close < EMA OR chart-bar close >= EMA; open the startup allocation of short positions determined by the grid level.
Short: Chart-bar close >= upper grid price AND long positions are held.
Exit: long, chart-bar close >= upper grid price.
Exit: short, chart-bar close <= lower grid price.