Calculation: Short EMA = exponential moving average of chart-timeframe closes with a shorter lookback than the medium EMA
Calculation: Medium EMA = exponential moving average of chart-timeframe closes with a longer lookback than the short EMA and shorter than the long EMA
Calculation: Long EMA = exponential moving average of chart-timeframe closes with a longer lookback than the medium EMA
Calculation: CPR bottom = (high + low) / 2 using the prior completed bar of a higher timeframe
Calculation: CPR top = 2 × ((high + low + close) / 3) − CPR bottom, using the prior completed bar of a higher timeframe
Calculation: Long stop = min(short EMA, CPR bottom) − one minimum price increment
Calculation: Short stop = max(short EMA, CPR bottom) + one minimum price increment
Calculation: Long target = entry price + absolute(entry price − long stop) × reward multiple
Calculation: Short target = entry price − absolute(entry price − short stop) × reward multiple
Long: short EMA crosses above medium EMA AND close > CPR top AND close > long EMA AND (short EMA − medium EMA) > (previous bar's short EMA − medium EMA) AND (short EMA − medium EMA) > minimum gap threshold AND long stop < close
Short: short EMA crosses below medium EMA AND close < CPR bottom AND close < long EMA AND (short EMA − medium EMA) < (previous bar's short EMA − medium EMA) AND (short EMA − medium EMA) < negative minimum gap threshold AND short stop > close
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target