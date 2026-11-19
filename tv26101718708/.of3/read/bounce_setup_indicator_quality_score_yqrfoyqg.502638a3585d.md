Calculation: Selected-timeframe indicators = calculated on chart bars when the chart timeframe is selected, or on T1 bars and carried onto chart bars when T1 is selected (last completed T1 bar historically; still-forming T1 bar in real time)
Calculation: Bullish retracement = SMA(Stochastic(close, high, low, lookback), smoothing lookback, selected timeframe) <= bullish threshold
Calculation: Bearish retracement = SMA(Stochastic(close, high, low, lookback), smoothing lookback, selected timeframe) >= bearish threshold
Calculation: ADX strength = ADX(lookback, selected timeframe) >= minimum threshold
Calculation: Near chart average = at least one of EMA(close, the three shortest EMA lookbacks, chart bars) or SMA(close, the shorter of the two SMA lookbacks, chart bars) satisfies 100 * abs(close - average) / close <= proximity percentage
Calculation: Bullish warning clear = warning filter disabled OR NOT ((abs(close - open) > ATR(lookback, chart bars) * large-candle multiplier AND close < open) OR open < low[1] - ATR(lookback, chart bars) * gap multiplier)
Calculation: Bearish warning clear = warning filter disabled OR NOT ((abs(close - open) > ATR(lookback, chart bars) * large-candle multiplier AND close > open) OR open > high[1] + ATR(lookback, chart bars) * gap multiplier)
Calculation: Bullish bounce setup = EMA(close, five progressively longer lookbacks, selected timeframe) values strictly descend AND bullish retracement AND ADX strength AND near chart average AND bullish warning clear
Calculation: Bearish bounce setup = EMA(close, five progressively longer lookbacks, selected timeframe) values strictly ascend AND bearish retracement AND ADX strength AND near chart average AND bearish warning clear
Calculation: Bullish 200 bounce setup = high >= SMA(close, longer SMA lookback, chart bars) AND low <= SMA(close, longer SMA lookback, chart bars) AND SMA(close, shorter SMA lookback, selected timeframe) > SMA(close, longer SMA lookback, selected timeframe) AND bullish retracement AND bullish warning clear
Calculation: Bearish 200 bounce setup = high >= SMA(close, longer SMA lookback, chart bars) AND low <= SMA(close, longer SMA lookback, chart bars) AND SMA(close, shorter SMA lookback, selected timeframe) < SMA(close, longer SMA lookback, selected timeframe) AND bearish retracement AND bearish warning clear
Calculation: Bullish entry trigger = close > high of the latest chart bar on which bullish retracement held AND close[1] <= that high OR RSI trigger enabled AND the chart-bar series of RSI(close, lookback, selected timeframe) crosses above its trigger level
Calculation: Bearish entry trigger = close < low of the latest chart bar on which bearish retracement held AND close[1] >= that low
Long: bullish bounce setup
Long: bullish bounce setup AND bullish entry trigger
Long: bullish 200 bounce setup
Long: bullish 200 bounce setup AND bullish entry trigger
Short: bearish bounce setup
Short: bearish bounce setup AND bearish entry trigger
Short: bearish 200 bounce setup
Short: bearish 200 bounce setup AND bearish entry trigger