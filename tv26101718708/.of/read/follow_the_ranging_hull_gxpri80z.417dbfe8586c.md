Calculation: Range filter = for source x, set range to multiplier × EMA(EMA(abs(x − previous x), sampling period), 2 × sampling period − 1). Starting with previous filter value zero, if x > previous filter, set filter to max(previous filter, x − range); otherwise set it to min(previous filter, x + range). Its direction is up after an increase and down after a decrease, retaining its previous direction while unchanged. Calculate fast and slow versions with shorter and longer sampling periods respectively, using OHLC4 by default and independently selectable sources and multipliers.
Calculation: Hull = selectable Hull variant applied to the fast range filter's source. HMA is WMA(2 × WMA(source, length/2) − WMA(source, length), round(sqrt(length))); exponential Hull replaces each WMA with EMA; triple Hull is WMA(3 × WMA(source, length/3) − WMA(source, length/2) − WMA(source, length), length), evaluated with half the selected Hull length. Integer moving-average lengths follow Pine's truncation rules.
Calculation: Following-line direction = compare close with Bollinger Bands. Above the upper band, set the line to max(previous line, low − ATR); below the lower band, set it to min(previous line, high + ATR); otherwise retain the previous line. If the ATR filter is disabled, use low and high without the ATR adjustment. The direction becomes up when the line increases and down when it decreases, retaining its previous direction while unchanged.
Long: Fast range filter direction changes from down to up AND Hull > Hull two bars earlier.
Short: Fast range filter direction changes from up to down AND Hull < Hull two bars earlier.
Long: Following-line entries enabled AND following line selected AND following-line direction changes from down to up AND Hull > Hull two bars earlier.
Short: Following-line entries enabled AND following line selected AND following-line direction changes from up to down AND Hull < Hull two bars earlier.
Long: Following-line entries enabled AND slow range filter selected AND slow range filter direction changes from down to up AND Hull > Hull two bars earlier.
Short: Following-line entries enabled AND slow range filter selected AND slow range filter direction changes from up to down AND Hull < Hull two bars earlier.
Exit: long, Hull exit selected AND Hull > Hull two bars earlier.
Exit: short, Hull exit selected AND Hull > Hull two bars earlier.
Exit: long, range-filter exit selected AND fast range filter direction two bars earlier was up AND current direction is down.
Exit: short, range-filter exit selected AND fast range filter direction changes from down to up.
Exit: long, following/slow-range-filter exit selected AND following line selected AND fast range filter direction two bars earlier was up AND current direction is down.
Exit: short, following/slow-range-filter exit selected AND following line selected AND following-line direction changes from down to up.
Exit: short, following/slow-range-filter exit selected AND slow range filter selected AND fast range filter direction two bars earlier was down AND current direction is up.
Exit: long, profit target enabled AND long was entered by a range filter AND high >= entry price + target distance.
Exit: short, profit target enabled AND short was entered by a range filter AND low <= entry price − target distance.
Exit: long, profit target enabled AND long was entered by the following line AND following-line direction has changed from up to down since entry AND high >= entry price + target distance after that change.
Exit: short, profit target enabled AND short was entered by the following line AND following-line direction has changed from down to up since entry AND low <= entry price − target distance after that change.