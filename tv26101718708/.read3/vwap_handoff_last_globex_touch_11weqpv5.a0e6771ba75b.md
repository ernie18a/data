Calculation: Handoff VWAP = AVWAP(source, volume, latest bar in the current day whose low <= VWAP(ohlc4, volume, current Globex session) <= high)
Long: close >= Handoff VWAP
Short: close < Handoff VWAP