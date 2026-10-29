Calculation: Opening range high and low = highest high and lowest low during the first N minutes of the session
Calculation: Opening range direction = close of the first bar after the range ends compared with the session-opening bar's open
Calculation: Breakout stop = opposite opening-range edge, range midpoint, or entry price offset by ATR, according to the selected stop mode
Calculation: First target = breakout edge offset by a range multiple, or entry price offset by a multiple of risk to the breakout stop, according to the selected target mode
Calculation: ATR = average true range on the chart timeframe
Long: opening range is complete AND no earlier accepted break this session AND close > opening range high (and previous bar close > opening range high when confirmation is enabled) AND opening-range direction is up when direction-only filtering is enabled
Short: opening range is complete AND no earlier accepted break this session AND close < opening range low (and previous bar close < opening range low when confirmation is enabled) AND opening-range direction is down when direction-only filtering is enabled
Short: an accepted long break has not already failed this session AND close < opening range high
Long: an accepted short break has not already failed this session AND close > opening range low
Long: after a long break and before it fails, low <= opening range high AND close > opening range high
Short: after a short break and before it fails, high >= opening range low AND close < opening range low
Short: high exceeds prior-session high or prior-week high by at least a configured fraction of chart-timeframe ATR AND close is below that level; prior-week high is from the last completed higher-timeframe weekly bar
Long: low falls below prior-session low or prior-week low by at least a configured fraction of chart-timeframe ATR AND close is above that level; prior-week low is from the last completed higher-timeframe weekly bar
Exit: long, high >= first target OR low <= breakout stop
Exit: short, low <= first target OR high >= breakout stop
Exit: short, low <= opposite opening-range edge OR high >= the highest high since the failed long break
Exit: long, high >= opposite opening-range edge OR low <= the lowest low since the failed short break