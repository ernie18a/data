Calculation: NormPrice = (close - lowest low over lookback N) / (highest high over N - lowest low over N)
Calculation: Vol = standard deviation of NormPrice over a lookback shorter than N
Calculation: Upper = 1 - (bars since the highest Vol within the last K+1 bars) / K; Lower = 1 - (bars since the lowest Vol within the last K+1 bars) / K (K is a lookback shorter than N)
Calculation: Channel = created on a bar where Upper crosses above Lower AND the number of bars since Lower last crossed above Upper (minimum 1) is greater than a minimum bar count, AND (nesting is allowed OR the new range does not overlap any active channel's range). Top = highest high over those bars since Lower last crossed above Upper. Bottom = lowest low over the same bars. A channel stays active until a breakout removes it. Each bar, test every active channel, including one created on that same bar.
Calculation: BodyMid = (open + close) / 2 (the simpler option is to use close instead)
Long: BodyMid > top of an active Channel
Short: BodyMid < bottom of an active Channel