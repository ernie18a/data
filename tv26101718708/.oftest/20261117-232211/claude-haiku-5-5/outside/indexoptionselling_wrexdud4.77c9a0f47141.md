Calculation: FastAvg = moving average of fast MA source with fast MA type over fast MA length
Calculation: SlowAvg = moving average of slow MA source with slow MA type over slow MA length
Short: FastAvg < SlowAvg AND FastAvg[1] >= SlowAvg[1] AND (NOT slope filter enabled OR ((FastAvg - FastAvg[slope lookback]) / slope lookback < -fast slope threshold AND (SlowAvg - SlowAvg[slope lookback]) / slope lookback < -slow slope threshold)) AND (NOT intraday filter enabled OR current bar time is within trading session)
Exit: short, FastAvg > SlowAvg AND FastAvg[1] <= SlowAvg[1]
Exit: short, intraday filter enabled AND close before session end enabled AND current bar time is not within trading session AND previous bar time is within trading session