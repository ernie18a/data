Calculation: Bullish swing failure = low < the lowest low of the preceding lookback bars AND close > that lowest low
Calculation: Bearish swing failure = high > the highest high of the preceding lookback bars AND close < that highest high
Calculation: Volume anomaly = volume > volume average + volume standard deviation multiplier × volume standard deviation, using the same lookback
Calculation: Absorption = absolute(close − open) < candle range × body-size fraction
Calculation: Total open interest = sum of the available open-interest series
Calculation: Bullish macro condition = USDT dominance close < its moving average
Calculation: Bearish macro condition = USDT dominance close > its moving average
Calculation: Flushed open interest = total open interest ≤ its moving average
Calculation: Spiking open interest = total open interest > its moving average
Calculation: Valid bullish sweep = a bullish swing failure occurred within the signal-expiry lookback
Calculation: Valid bearish sweep = a bearish swing failure occurred within the signal-expiry lookback
Calculation: Volume confirmation = volume anomaly OR absorption
Long: valid bullish sweep AND volume confirmation AND bullish macro condition AND flushed open interest AND more than the signal-expiry lookback bars since the previous long signal AND (position is flat OR (position is long AND close < average entry price))
Short: valid bearish sweep AND volume confirmation AND bearish macro condition AND spiking open interest AND more than the signal-expiry lookback bars since the previous short signal AND (position is flat OR (position is short AND close > average entry price))
Calculation: Long ratchet stop = catastrophe stop below average entry price until price reaches the first profit tier, then the first tier stop; upgrade to the second tier stop when its higher profit tier is reached
Calculation: Short ratchet stop = catastrophe stop above average entry price until price reaches the first profit tier, then the first tier stop; upgrade to the second tier stop when its lower profit tier is reached
Calculation: Long recovery stop = average entry price + accumulated realized loss / absolute position size
Calculation: Short recovery stop = average entry price − accumulated realized loss / absolute position size
Exit: long, (profit percentage ≥ take-profit threshold AND close < short-term EMA) OR close ≤ average entry price × (1 − logical stop fraction) OR low ≤ long ratchet stop OR (recovery stop is defined AND high ≥ recovery stop) OR high ≥ average entry price × (1 + maximum take-profit fraction)
Exit: short, (profit percentage ≥ take-profit threshold AND close > short-term EMA) OR close ≥ average entry price × (1 + logical stop fraction) OR high ≥ short ratchet stop OR (recovery stop is defined AND low ≤ recovery stop) OR low ≤ average entry price × (1 − maximum take-profit fraction)