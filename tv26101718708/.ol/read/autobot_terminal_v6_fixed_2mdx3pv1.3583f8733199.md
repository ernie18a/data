Calculation: Daily 200 SMA = 200-period simple moving average of daily closes, using the still-forming higher-timeframe bar
Calculation: Previous day high/low = high/low of the last completed higher-timeframe daily bar
Calculation: 4H support/resistance = latest confirmed pivot low/high on a higher timeframe, with equal left and right lookbacks
Calculation: Previous completed 1H candle = open and close of the last completed higher-timeframe 1H bar
Calculation: Support zone = current close is at or above 4H support and at or below support plus a configurable percentage, OR at or above previous day low and at or below that low plus a configurable percentage
Calculation: Resistance zone = current close is at or below 4H resistance and at or above resistance minus a configurable percentage, OR at or below previous day high and at or above that high minus a configurable percentage
Calculation: Active support = 4H support if available, otherwise previous day low if available, otherwise entry price
Calculation: Active resistance = 4H resistance if available, otherwise previous day high if available, otherwise entry price
Calculation: Long stop = active support minus a configurable percentage; long target 2 = entry price plus (entry price minus long stop) times a configurable risk multiple
Calculation: Short stop = active resistance plus a configurable percentage; short target 2 = entry price minus (short stop minus entry price) times a configurable risk multiple
Long: position is flat AND current bar is within the configured session AND support zone AND close crosses above VWAP AND ((close > Daily 200 SMA AND (previous completed 1H close > open OR previous completed 1H close > 4H support)) OR close < Daily 200 SMA)
Short: position is flat AND current bar is within the configured session AND close < Daily 200 SMA AND resistance zone AND (previous completed 1H close < open OR previous completed 1H close < previous day low) AND close crosses below VWAP
Exit: long, high >= long target 2 OR low <= long stop
Exit: short, low <= short target 2 OR high >= short stop