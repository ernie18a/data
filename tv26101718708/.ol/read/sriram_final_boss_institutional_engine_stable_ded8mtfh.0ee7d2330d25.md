Calculation: Short EMA = exponential moving average of close with a shorter lookback
Calculation: Long EMA = exponential moving average of close with a longer lookback
Calculation: EMA spread = absolute difference between Short EMA and Long EMA
Calculation: Strong trend = EMA spread > longer-lookback average of EMA spread × a threshold
Calculation: Volume spike = volume > longer-lookback average volume × a threshold
Long: Position is flat or short AND close > VWAP AND Short EMA > Long EMA AND EMA spread > a threshold AND Strong trend AND Volume spike AND close > previous bar high AND close > open AND close > previous close
Short: Position is flat or long AND close < VWAP AND Short EMA < Long EMA AND EMA spread > a threshold AND Strong trend AND Volume spike AND close < previous bar low AND close < open AND close < previous close
Exit: long, close < Short EMA OR close < VWAP
Exit: short, close > Short EMA OR close > VWAP