Calculation: trend EMA = EMA(close, longer lookback) on T1 bars, last completed bar value, sampled on chart bars
Calculation: market up = market index close on T3 bars, last completed bar value > EMA(market index close, market lookback) on T3 bars, last completed bar value
Calculation: volume high = volume on T2 bars, last completed bar value > SMA(volume, volume lookback) on T2 bars, last completed bar value * volume multiplier
Calculation: slope flat or rising = trend EMA >= trend EMA[slope lookback chart bars]
Calculation: chop ok = number of chart bars among the last chop lookback chart bars where close crosses above or below trend EMA <= max crosses
Calculation: above short EMA = close > EMA(close, shorter lookback)
Calculation: retest = some bar after the most recent close crossing below trend EMA, up to and including the current bar, has high >= trend EMA * (1 - retest zone width) AND low <= trend EMA * (1 + retest zone width)
Calculation: setup = the most recent close crossing below trend EMA is at most break window chart bars ago AND no bullish signal occurred on any earlier bar after that crossing
Calculation: signal score = number of true conditions among: close > trend EMA; retest; slope flat or rising; volume high; market up; above short EMA; chop ok
Calculation: bullish signal = setup AND retest AND close > open AND close > high[1] AND close > trend EMA AND close on T1 bars, last completed bar value > trend EMA AND slope flat or rising AND volume high AND market up AND above short EMA AND chop ok
Long: bullish signal
Long: setup AND retest
Short: close crosses below trend EMA
Option: buy call, bullish signal AND signal score >= grade B threshold