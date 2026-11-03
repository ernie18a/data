Calculation: Anchor EMAs = short- and long-period EMAs calculated on chart bars from the repeated close of the last completed higher-timeframe bar; their EMA periods are each multiplied by a shared scaling parameter.
Calculation: Long anchor = on every chart bar in an inclusive lookback ending at the current bar, low > long-period anchor EMA AND short-period anchor EMA > long-period anchor EMA.
Calculation: Short anchor = on every chart bar in an inclusive lookback ending at the current bar, high < long-period anchor EMA AND short-period anchor EMA < long-period anchor EMA.
Calculation: Long signal = position is flat AND previous bar's long window is false AND short-period chart-close EMA >= long-period chart-close EMA AND long anchor is true AND close >= short-period chart-close EMA AND low <= short-period chart-close EMA.
Calculation: Short signal = position is flat AND previous bar's short window is false AND short-period chart-close EMA <= long-period chart-close EMA AND short anchor is true AND close <= short-period chart-close EMA AND high >= short-period chart-close EMA.
Calculation: Long window = bars since the latest long signal <= validity limit AND the latest long signal is not older than the latest short signal AND close >= short-period anchor EMA AND long anchor is true AND short-period chart-close EMA >= long-period chart-close EMA; treat comparisons involving an unavailable signal age as false in the corresponding window-closing tests.
Calculation: Short window = bars since the latest short signal <= validity limit AND the latest short signal is not older than the latest long signal AND close <= short-period anchor EMA AND short anchor is true AND short-period chart-close EMA <= long-period chart-close EMA; treat comparisons involving an unavailable signal age as false in the corresponding window-closing tests.
Calculation: Long entry level = highest high over a lookback ending at the latest long signal bar plus a price offset; short entry level = lowest low over the same-length lookback ending at the latest short signal bar minus the offset.
Calculation: Long stop = low of the latest long signal bar minus the price offset; short stop = high of the latest short signal bar plus the price offset.
Calculation: Long target = long entry level + reward multiple * (long entry level - long stop); short target = short entry level - reward multiple * (short stop - short entry level). Recalculate levels from the latest corresponding signal.
Calculation: Trigger price = open of the last completed lower-timeframe bar within each chart bar.
Long: short-period anchor EMA >= long-period anchor EMA.
Short: short-period anchor EMA < long-period anchor EMA.
Long: long window is true.
Short: short window is true.
Long: long window is true AND trigger price > long entry level AND previous chart bar's trigger price <= previous chart bar's long entry level AND datetime is within the configured backtest date range.
Short: short window is true AND trigger price < short entry level AND previous chart bar's trigger price >= previous chart bar's short entry level AND datetime is within the configured backtest date range.
Exit: long, low <= long stop OR high >= long target.
Exit: short, high >= short stop OR low <= short target.