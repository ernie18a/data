Calculation: Accumulation = (highest high over the phase lookback − lowest low over the phase lookback) < configured range-to-ATR threshold × SMA of ATR over the phase lookback
Long: HTF close > HTF EMA (both from the current forming HTF bar) AND short-lookback EMA > longer-lookback EMA
Long: EMA crossover (short-lookback EMA is now above the longer-lookback EMA and was at or below it on the prior bar) AND HTF close > HTF EMA (both from the current forming HTF bar) AND NOT Accumulation
Long: close > open AND volume > configured multiplier × SMA(volume) AND abs(close − open) > configured threshold × ATR AND close > EMA
Long: prior bar close < prior bar open AND current close > current open AND current body size > configured threshold × prior bar ATR
Short: HTF close < HTF EMA (both from the current forming HTF bar) AND short-lookback EMA < longer-lookback EMA
Short: EMA crossunder (short-lookback EMA is now below the longer-lookback EMA and was at or above it on the prior bar) AND HTF close < HTF EMA (both from the current forming HTF bar) AND NOT Accumulation
Short: close < open AND volume > configured multiplier × SMA(volume) AND abs(close − open) > configured threshold × ATR AND close < EMA
Short: prior bar close > prior bar open AND current close < current open AND current body size > configured threshold × prior bar ATR