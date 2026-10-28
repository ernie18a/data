Calculation: Candle body size = absolute value of close − open
Calculation: Average body size = simple moving average of candle body size using the medium lookback
Long: Candle body size ≥ configured Ignite multiple × average body size AND close > open
Long: close < open AND previous bar meets the Ignite condition AND candle body size < configured maximum pullback fraction × previous bar body size AND high > previous bar close AND low < previous bar close
Long: close > open AND previous bar meets the Pullback condition AND candle body size > configured minimum confirmation fraction × body size two bars earlier AND open > previous bar close
Long: flat position AND current bar completes the Ignite, Pullback, Confirmation sequence AND long-term SMA > medium-term SMA > short-term SMA on the Ignite bar AND Ignite bar close < short-term SMA on the Ignite bar
Exit: Long, low ≤ Ignite bar low OR high ≥ entry-bar open + configured risk/reward multiple × (entry-bar open − Ignite bar low)