Calculation: SourceClose = close(T1, last completed bar)
Calculation: SourceHigh = high(T1, last completed bar)
Calculation: SourceLow = low(T1, last completed bar)
Calculation: SourceVolume = volume(T1, last completed bar)
Calculation: RSIValue = RSI(close, RSI length, T1, last completed bar)
Calculation: SlowEMA = EMA(close, longer EMA length, T1, last completed bar)
Calculation: FastEMA = EMA(close, shorter EMA length, T1, last completed bar)
Calculation: StopDistance = trail ATR multiplier * ATR(ATR length, T1, last completed bar)
Calculation: ATRStop = max(ATRStop[1], SourceClose[1] - StopDistance) if SourceClose[1] > ATRStop[1], else min(ATRStop[1], SourceClose[1] + StopDistance) if SourceClose[1] < ATRStop[1], else SourceClose[1] + StopDistance
Calculation: StopDirection = 1 if SourceClose[1] > ATRStop, else -1 if SourceClose[1] < ATRStop, else StopDirection[1]
Calculation: BandDirection = 1 if SourceClose > SMA(SourceHigh, cloud length), else -1 if SourceClose < SMA(SourceLow, cloud length), else BandDirection[1]
Calculation: PulseOsc = LinReg(SourceClose - SMA(SourceClose, pulse length), pulse length)
Calculation: LowPivot = PivotLow(SourceLow, pivot lookback, pivot lookback)
Calculation: HighPivot = PivotHigh(SourceHigh, pivot lookback, pivot lookback)
Calculation: BarsSinceLowPivot = bars since the most recent earlier bar on which LowPivot is not NA
Calculation: BarsSinceHighPivot = bars since the most recent earlier bar on which HighPivot is not NA
Calculation: BarsSinceEntry = bars since the most recent bar on which either side's entry condition was true
Long: (SourceClose crosses above ATRStop AND ADX(ADX length) > ADX threshold AND SourceVolume > SMA(SourceVolume, volume average length) AND RSIValue > RSI threshold AND SourceClose > SlowEMA AND SourceClose > FastEMA)[1] AND BarsSinceEntry > signal cooldown
Short: (SourceClose crosses below ATRStop AND ADX(ADX length) > ADX threshold AND SourceVolume > SMA(SourceVolume, volume average length) AND RSIValue < RSI threshold AND SourceClose < SlowEMA AND SourceClose < FastEMA)[1] AND BarsSinceEntry > signal cooldown
Long: BandDirection == 1 AND BandDirection[1] == -1
Short: BandDirection == -1 AND BandDirection[1] == 1
Long: BandDirection == 1
Short: BandDirection == -1
Long: StopDirection == 1
Short: StopDirection == -1
Long: PulseOsc > 0
Short: PulseOsc < 0
Long: SourceClose > FastEMA
Short: SourceClose < FastEMA
Long: (100 * (close - low(T2, last completed bar)) / (high(T2, last completed bar) - low(T2, last completed bar)) + RSIValue) / 2 >= power threshold
Short: (100 * (close - low(T2, last completed bar)) / (high(T2, last completed bar) - low(T2, last completed bar)) + RSIValue) / 2 < power threshold
Long: LowPivot < ValueWhen(LowPivot is not NA, LowPivot, 1)[1] AND PulseOsc[pivot lookback] > ValueWhen(LowPivot is not NA, PulseOsc[pivot lookback], 1)[1] AND BarsSinceLowPivot <= divergence max bars
Short: HighPivot > ValueWhen(HighPivot is not NA, HighPivot, 1)[1] AND PulseOsc[pivot lookback] < ValueWhen(HighPivot is not NA, PulseOsc[pivot lookback], 1)[1] AND BarsSinceHighPivot <= divergence max bars