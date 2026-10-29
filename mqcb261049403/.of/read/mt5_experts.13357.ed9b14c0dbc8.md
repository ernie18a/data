Calculation: Momentum = selected applied price minus its value one lookback earlier
Calculation: JMA-smoothed momentum = JMA smoothing of Momentum
Calculation: Rounded oscillator change = nearest-integer rounding of the change in JMA-smoothed momentum, with momentum scaled by point size
Long: Rounded oscillator change > 0 OR (oldest of the three selected indicator-timeframe bars' oscillator values > middle value AND newest value > middle value)
Short: Rounded oscillator change < 0 OR (oldest of the three selected indicator-timeframe bars' oscillator values < middle value AND newest value < middle value)
Exit: Long, newest selected indicator-timeframe bar's oscillator value < middle value
Exit: Short, newest selected indicator-timeframe bar's oscillator value > middle value