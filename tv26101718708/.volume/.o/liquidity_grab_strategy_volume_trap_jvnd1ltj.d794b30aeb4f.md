Calculation: long limit entry = low two bars before the signal bar
Calculation: volume-flat condition = abs(current volume - its moving average) / its moving average < threshold
Calculation: long stop loss = low two bars before the signal bar - (previous bar high - low two bars before the signal bar)
Calculation: long take profit = previous bar high
Long: previous bar close > close two bars before the signal bar AND current close < previous bar close AND current close < previous bar low AND previous bar close < close two bars before the signal bar AND volume-flat condition AND close two bars before the signal bar < previous bar open AND current close > previous bar high
Exit: long, current low <= long stop loss OR current high >= long take profit