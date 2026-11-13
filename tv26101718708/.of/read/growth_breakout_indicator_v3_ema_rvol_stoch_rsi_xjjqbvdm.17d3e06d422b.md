Calculation: EMA fast/slow = exponential moving averages of close on the chart timeframe; fast uses a shorter length than slow
Calculation: High52 = highest high over a long lookback (about one year of chart bars), including the current bar
Calculation: PriorHigh = highest high of the previous N bars, excluding the current bar
Calculation: RVOL = current volume / simple moving average of volume over a lookback (current bar included)
Calculation: StochRSI = RSI of close; raw = 100*(RSI - lowest RSI over n bars)/(highest RSI over n bars - lowest RSI over n bars), 0 if highest equals lowest; K = SMA(raw); D = SMA(K)
Long: abs(close - fast EMA)/close*100 <= small percentage threshold AND close >= High52*(1 - small percentage threshold) AND close > PriorHigh AND RVOL >= threshold AND (fast EMA crosses above slow EMA on this bar OR close > fast EMA) AND StochRSI K > StochRSI D AND StochRSI K < overbought threshold
Exit: long, close crosses below slow EMA (previous close >= previous slow EMA and current close < current slow EMA) OR close crosses below fast EMA (previous close >= previous fast EMA and current close < current fast EMA)