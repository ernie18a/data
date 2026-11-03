Calculation: Session VWAP = cumulative sum(hlc3 × volume) / cumulative volume, reset at the start of each day
Calculation: Session standard deviation = sqrt(cumulative sum(hlc3² × volume) / cumulative volume − session VWAP²)
Calculation: Lower entry band = session VWAP − 2 × session standard deviation
Calculation: Upper entry band = session VWAP + 2 × session standard deviation
Calculation: Bull strength = (close − low) / (high − low), or 0 when high = low
Calculation: Bear strength = (high − close) / (high − low), or 0 when high = low
Calculation: Long target band = session VWAP + long target deviation × session standard deviation
Calculation: Short target band = session VWAP − short target deviation × session standard deviation
Calculation: Long stop = low of the long signal bar − stop buffer
Calculation: Short stop = high of the short signal bar + stop buffer
Long: position is flat AND open < lower entry band AND close > lower entry band AND bull strength ≥ minimum signal strength AND 2 × session standard deviation ≥ 3 × ATR AND long trades are allowed
Short: position is flat AND open > upper entry band AND close < upper entry band AND bear strength ≥ minimum signal strength AND 2 × session standard deviation ≥ 3 × ATR AND short trades are allowed
Exit: Long, low ≤ long stop
Exit: Short, high ≥ short stop
Exit: Long, high ≥ session VWAP when the long exit rule is VWAP OR high ≥ long target band when the long exit rule is Deviation Band
Exit: Short, low ≤ session VWAP when the short exit rule is VWAP OR low ≤ short target band when the short exit rule is Deviation Band
Exit: Long, safety exit is enabled AND the last configured number of bars are bearish (close < open)
Exit: Short, safety exit is enabled AND the last configured number of bars are bullish (close > open)