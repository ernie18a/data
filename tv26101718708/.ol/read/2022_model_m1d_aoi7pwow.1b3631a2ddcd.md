Calculation: Confirmed swing pool = a bar whose high (or low) is strictly greater (or lower) than the highs (or lows) of the immediately adjacent bars on both sides.
Calculation: True swing = a confirmed swing pool at a turn between a down-close and an up-close bar.
Calculation: Displacement threshold = configurable fixed price distance or configurable fraction of the previous completed day's high-low range.
Calculation: Average higher-timeframe range = mean high-low range of completed bars on that higher timeframe.
Long: On a completed chart bar, low < an unraided confirmed swing low and close > that swing low; then, within the configurable bar window, close - the lowest low since the sweep >= displacement threshold, with no intervening close below the swept level.
Short: On a completed chart bar, high > an unraided confirmed swing high and close < that swing high; then, within the configurable bar window, the highest high since the sweep - close >= displacement threshold, with no intervening close above the swept level.
Long: On a completed bar of any configured higher timeframe, low < a confirmed swing low and close > that swing low, with no intervening bar taking that low.
Short: On a completed bar of any configured higher timeframe, high > a confirmed swing high and close < that swing high, with no intervening bar taking that high.
Long: On a completed bar of any configured higher timeframe, its low > the high two bars earlier, the gap height >= configurable minimum times average higher-timeframe range, and the intervening bar closes up with body size >= configurable displacement multiple times average higher-timeframe range.
Short: On a completed bar of any configured higher timeframe, its high < the low two bars earlier, the gap height >= configurable minimum times average higher-timeframe range, and the intervening bar closes down with body size >= configurable displacement multiple times average higher-timeframe range.
Long: On a completed bar of any configured higher timeframe, close > the high of a true swing; this is the first close beyond that swing level.
Short: On a completed bar of any configured higher timeframe, close < the low of a true swing; this is the first close beyond that swing level.
Long: Close >= current day's open.
Short: Close < current day's open.