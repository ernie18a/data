Calculation: Chart fast and slow EMAs = exponential moving averages of chart-timeframe close, with the fast EMA using a shorter lookback.
Calculation: Anchor fast and slow EMAs = chart-timeframe exponential moving averages of the higher-timeframe close series, with the fast EMA using a shorter lookback; use the last completed higher-timeframe bar historically and the forming bar in real time.
Calculation: Long setup = flat position AND previous-bar long window was false AND chart fast EMA >= chart slow EMA AND, on each chart bar from the current bar through the anchor lookback, low > anchor slow EMA and anchor fast EMA > anchor slow EMA AND close >= chart fast EMA AND low <= chart fast EMA.
Calculation: Short setup = flat position AND previous-bar short window was false AND chart fast EMA <= chart slow EMA AND, on each chart bar from the current bar through the anchor lookback, high < anchor slow EMA and anchor fast EMA < anchor slow EMA AND close <= chart fast EMA AND high >= chart fast EMA.
Calculation: Long window remains valid while the latest long setup is no older than its validity limit, no short setup is more recent, close >= anchor fast EMA, the long anchor condition holds, and chart fast EMA >= chart slow EMA.
Calculation: Short window remains valid while the latest short setup is no older than its validity limit, no long setup is more recent, close <= anchor fast EMA, the short anchor condition holds, and chart fast EMA <= chart slow EMA.
Calculation: Long entry level = highest chart-timeframe high over the signal bar and preceding entry lookback bars, plus a price buffer.
Calculation: Short entry level = lowest chart-timeframe low over the signal bar and preceding entry lookback bars, minus a price buffer.
Calculation: Long stop = signal-bar low minus a price buffer; short stop = signal-bar high plus a price buffer.
Calculation: Long target = long entry level + target multiple × (long entry level − long stop); short target = short entry level − target multiple × (short stop − short entry level).
Long: Long window valid AND lower-timeframe open crosses above the stored long entry level.
Short: Short window valid AND lower-timeframe open crosses below the stored short entry level.
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target