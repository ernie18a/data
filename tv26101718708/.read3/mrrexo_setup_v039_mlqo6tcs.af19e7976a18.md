Calculation: BandMid(band lookback) = (MA(high, band lookback, band MA type) + MA(low, band lookback, band MA type)) / 2
Calculation: BandSeparation = max(MA(low, shorter band lookback, band MA type) - MA(high, longer band lookback, band MA type), MA(low, longer band lookback, band MA type) - MA(high, shorter band lookback, band MA type))
Calculation: UpTrend = BandMid(shorter band lookback) > BandMid(longer band lookback) AND BandMid(shorter band lookback) > BandMid(shorter band lookback)[trend lookback] AND BandMid(longer band lookback) > BandMid(longer band lookback)[trend lookback]
Calculation: DownTrend = BandMid(shorter band lookback) < BandMid(longer band lookback) AND BandMid(shorter band lookback) < BandMid(shorter band lookback)[trend lookback] AND BandMid(longer band lookback) < BandMid(longer band lookback)[trend lookback]
Calculation: EntryOpen = no long or short cross, return, or bounce entry fired less than min entry spacing minutes before this bar AND BandSeparation > 0 AND BandSeparation >= min band gap
Calculation: UpCross(band lookback) = close > MA(high, band lookback, band MA type) AND on some bar within the last max cross bars close < MA(low, band lookback, band MA type) AND on every bar after that bar and before this bar, MA(low, band lookback, band MA type) <= close <= MA(high, band lookback, band MA type)
Calculation: DownCross(band lookback) = close < MA(low, band lookback, band MA type) AND on some bar within the last max cross bars close > MA(high, band lookback, band MA type) AND on every bar after that bar and before this bar, MA(low, band lookback, band MA type) <= close <= MA(high, band lookback, band MA type)
Calculation: UpReturn(band lookback) = low <= MA(high, band lookback, band MA type) AND close >= MA(low, band lookback, band MA type) AND on some earlier bar within the last max return bars UpCross(band lookback) is true AND no bar after that bar and before this bar had low <= MA(high, band lookback, band MA type) and close >= MA(low, band lookback, band MA type)
Calculation: DownReturn(band lookback) = high >= MA(low, band lookback, band MA type) AND close <= MA(high, band lookback, band MA type) AND on some earlier bar within the last max return bars DownCross(band lookback) is true AND no bar after that bar and before this bar had high >= MA(low, band lookback, band MA type) and close <= MA(high, band lookback, band MA type)
Calculation: OpenPivotHigh = price of the most recent pivot high(high, pivot length, pivot length) confirmed up to this bar, unless close crossed above that price on an earlier bar since it was confirmed
Calculation: OpenPivotLow = price of the most recent pivot low(low, pivot length, pivot length) confirmed up to this bar, unless close crossed below that price on an earlier bar since it was confirmed
Long: UpCross(shorter band lookback) AND UpTrend AND EntryOpen
Long: UpCross(longer band lookback) AND UpTrend AND EntryOpen
Long: UpReturn(shorter band lookback) AND UpTrend AND EntryOpen
Long: UpReturn(longer band lookback) AND UpTrend AND EntryOpen
Long: low <= MA(high, shorter band lookback, band MA type) AND close > MA(high, shorter band lookback, band MA type) AND UpTrend AND EntryOpen
Long: low <= MA(high, longer band lookback, band MA type) AND close > MA(high, longer band lookback, band MA type) AND UpTrend AND EntryOpen
Long: close crosses above OpenPivotHigh
Long: low > high[2] AND low - high[2] >= min FVG size
Long: open > close[1] AND open - close[1] >= min GAP size
Long: MA(close, shorter bias lookback, bias MA type, T1, last completed bar) > MA(close, longer bias lookback, bias MA type, T1, last completed bar)
Long: MA(close, shorter bias lookback, bias MA type, T2, last completed bar) > MA(close, longer bias lookback, bias MA type, T2, last completed bar)
Long: MA(close, shorter bias lookback, bias MA type, T3, last completed bar) > MA(close, longer bias lookback, bias MA type, T3, last completed bar)
Short: DownCross(shorter band lookback) AND DownTrend AND EntryOpen
Short: DownCross(longer band lookback) AND DownTrend AND EntryOpen
Short: DownReturn(shorter band lookback) AND DownTrend AND EntryOpen
Short: DownReturn(longer band lookback) AND DownTrend AND EntryOpen
Short: high >= MA(low, shorter band lookback, band MA type) AND close < MA(low, shorter band lookback, band MA type) AND DownTrend AND EntryOpen
Short: high >= MA(low, longer band lookback, band MA type) AND close < MA(low, longer band lookback, band MA type) AND DownTrend AND EntryOpen
Short: close crosses below OpenPivotLow
Short: high < low[2] AND low[2] - high >= min FVG size
Short: open < close[1] AND close[1] - open >= min GAP size
Short: MA(close, shorter bias lookback, bias MA type, T1, last completed bar) < MA(close, longer bias lookback, bias MA type, T1, last completed bar)
Short: MA(close, shorter bias lookback, bias MA type, T2, last completed bar) < MA(close, longer bias lookback, bias MA type, T2, last completed bar)
Short: MA(close, shorter bias lookback, bias MA type, T3, last completed bar) < MA(close, longer bias lookback, bias MA type, T3, last completed bar)