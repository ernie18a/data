Calculation: VolumeDelta = buy volume minus sell volume of T2 bars within the T1 bar still forming
Calculation: CVD = cumulative sum of VolumeDelta over chart bars
Calculation: MacdOscillator = MACD(CVD, shorter lookback, longer lookback)
Calculation: SignalEMA = EMA(MacdOscillator, signal lookback)
Calculation: MacdHistogram = MacdOscillator - SignalEMA
Long: MacdHistogram crosses above 0
Short: MacdHistogram crosses below 0
Long: MacdHistogram < 0 AND MacdHistogram >= MacdHistogram[1]
Short: MacdHistogram >= 0 AND MacdHistogram <= MacdHistogram[1]