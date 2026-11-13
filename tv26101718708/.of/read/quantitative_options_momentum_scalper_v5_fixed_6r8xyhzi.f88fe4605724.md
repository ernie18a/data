Calculation: VWAP = daily-reset cumulative sum(typical price * volume) / cumulative sum(volume), typical price = (high+low+close)/3; equals typical price when cumulative volume is 0
Calculation: StochK = SMA(Stochastic oscillator of RSI(close), short smoothing); StochD = SMA(StochK, short smoothing)
Calculation: Squeeze = Bollinger upper band < Keltner upper band AND Bollinger lower band > Keltner lower band (Bollinger = SMA(close) +/- multiple of stdev(close); Keltner = SMA(close) +/- multiple of ATR)
Calculation: RVOLpass = volume == 0 OR volume / SMA(volume) >= minimum threshold
Calculation: LongStop = on long entry bar: min(low, previous bar low) - ATR*multiple; on each later bar while long: max(previous LongStop, previous bar low - ATR*multiple)
Calculation: ShortStop = on short entry bar: max(high, previous bar high) + ATR*multiple; on each later bar while short: min(previous ShortStop, previous bar high + ATR*multiple)
Long: position is flat or short (a short is reversed into long) AND close > VWAP AND fast EMA(close) > slow EMA(close) (fast shorter than slow) AND StochK crosses above StochD on this bar AND StochK < overbought threshold (state variant: StochK > StochD instead of crossing) AND NOT Squeeze AND RVOLpass
Short: position is flat or long (a long is reversed into short) AND close < VWAP AND fast EMA(close) < slow EMA(close) AND StochK crosses below StochD on this bar AND StochK > oversold threshold (state variant: StochK < StochD instead of crossing) AND NOT Squeeze AND RVOLpass
Exit: long, close < LongStop (updated on this bar; not checked on the entry bar or on a bar that triggers a Short)
Exit: short, close > ShortStop (updated on this bar; not checked on the entry bar or on a bar that triggers a Long)