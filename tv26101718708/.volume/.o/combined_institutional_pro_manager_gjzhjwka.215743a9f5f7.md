Calculation: bullish FVG = current low > high two bars earlier AND previous close > high two bars earlier
Calculation: bearish FVG = current high < low two bars earlier AND previous close < low two bars earlier
Calculation: bullish BOS = close crosses above the latest confirmed pivot high
Calculation: bearish BOS = close crosses below the latest confirmed pivot low
Calculation: long stop = entry price minus fixed stop distance until price reaches entry price plus initial risk × break-even ratio, then entry price
Calculation: short stop = entry price plus fixed stop distance until price reaches entry price minus initial risk × break-even ratio, then entry price
Calculation: long take profit = entry price plus initial risk × reward ratio
Calculation: short take profit = entry price minus initial risk × reward ratio
Long: flat AND close > long-term SMA(close) AND close > short-term EMA(close) AND close crosses above the latest confirmed pivot high AND a bullish FVG occurred within the recent-FVG lookback AND volume > 20-bar SMA(volume) × volume multiplier
Long: pending long limit order AND low <= entry price minus execution buffer AND pending age <= expiration limit
Short: flat AND close < long-term SMA(close) AND close < short-term EMA(close) AND close crosses below the latest confirmed pivot low AND a bearish FVG occurred within the recent-FVG lookback AND volume > 20-bar SMA(volume) × volume multiplier
Short: pending short limit order AND high >= entry price plus execution buffer AND pending age <= expiration limit
Exit: long, low <= long stop OR (high >= long take profit plus TP buffer AND low > long stop)
Exit: short, high >= short stop OR (low <= short take profit minus TP buffer AND high < short stop)