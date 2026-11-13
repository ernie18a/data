Calculation: Prior HTF range = high and low of the last completed bar of a timeframe higher than the chart timeframe
Calculation: FVG zone = bullish zone formed when low > high 2 bars earlier (top = low, bottom = high 2 bars earlier); bearish zone formed when high < low 2 bars earlier (top = low 2 bars earlier, bottom = high); optionally require gap size >= a minimum; a zone stays tracked until it is removed or a set number of trading days have passed since formation; each zone has an inverted flag, initially false
Long: low < Prior HTF range low AND close > Prior HTF range low
Long: a bullish FVG zone forms on this bar
Long: close > top of a tracked bearish FVG zone whose inverted flag is false (the zone then becomes inverted)
Short: high > Prior HTF range high AND close < Prior HTF range high
Short: a bearish FVG zone forms on this bar
Short: close < bottom of a tracked bullish FVG zone whose inverted flag is false (the zone then becomes inverted)
Exit: Short, close > top of a tracked inverted bullish-origin FVG zone
Exit: Long, close < bottom of a tracked inverted bearish-origin FVG zone