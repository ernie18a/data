Calculation: sell share = aggressor sell volume (volume traded at the bid) / (aggressor buy volume + aggressor sell volume) * 100
Calculation: buy share = aggressor buy volume (volume traded at the ask) / (aggressor buy volume + aggressor sell volume) * 100
Calculation: high volume = total bar volume > multiplier * simple moving average of total bar volume
Calculation: higher-timeframe open = open of the higher-timeframe bar that contains the current bar (the still-forming bar)
Calculation: higher-timeframe high/low = high/low of that same still-forming higher-timeframe bar
Calculation: R = entry price - low of entry bar (long); high of entry bar - entry price (short)
Long: previous bar low < low of the bar before it AND previous bar low < current bar low
Short: previous bar high > high of the bar before it AND previous bar high > current bar high
Long: high volume AND sell share >= threshold AND (close - low) > (high - close) AND close >= open
Short: high volume AND buy share >= threshold AND (high - close) > (close - low) AND close <= open
Long: high volume AND sell share >= threshold AND (close - low) > (high - close) AND close >= open AND close > higher-timeframe open (entry at close)
Short: high volume AND buy share >= threshold AND (high - close) > (close - low) AND close <= open AND close < higher-timeframe open (entry at close)
Exit: long, low <= low of entry bar OR high >= max(entry price + 2*R, higher-timeframe high) - R
Exit: short, high >= high of entry bar OR low <= min(entry price - 2*R, higher-timeframe low) + R