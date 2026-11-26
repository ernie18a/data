Calculation: KF(x, g) = KF(x, g)[1] + (x - KF(x, g)[1]) * sqrt(2 * g / 10000) + Vel(x, g)
Calculation: Vel(x, g) = Vel(x, g)[1] + g / 10000 * (x - KF(x, g)[1])
Calculation: HullClose = WMA(3 * WMA(close, Lookback / 6) - WMA(close, Lookback / 4) - WMA(close, Lookback / 2), Lookback / 2)
Calculation: KalmanHMA = KF(HMA(HullSource, Lookback), Gain)
Calculation: KalmanHullClose = KF(HullClose, Gain)
Calculation: LongWT = WaveTrend(LongSource, LongChannel, LongAverage)
Calculation: LongWTSignal = SMA(LongWT, SignalLength)
Calculation: ShortWT = WaveTrend(ShortSource, ShortChannel, ShortAverage)
Calculation: ShortWTSignal = SMA(ShortWT, SignalLength)
Calculation: StochK = SMA(StochRSI(RSISource, RSILength, StochLength), SmoothK)
Calculation: StochD = SMA(StochK, SmoothD)
Calculation: VolThr = (SMA(volume, VolSMALength) + VWMA(volume, VolVWMALength) + WMA(volume, VolWMALength)) / 3 * VolMultiplier
Calculation: LongTP1 = entry price * (1 + TP1Long)
Calculation: LongTP2 = entry price * (1 + TP2Long)
Calculation: LongPosCheck = entry price * (1 + TP1Long / LongSens)
Calculation: LongStop = if high >= LongTP1 OR high[1] >= LongTP1 then max(close * (1 - TrailLong), LongStop[1]) else entry price * (1 - SLLong)
Calculation: ShortTP1 = entry price * (1 - TP1Short)
Calculation: ShortTP2 = entry price * (1 - TP2Short)
Calculation: ShortPosCheck = entry price * (1 - TP1Short / ShortSens)
Calculation: ShortStop = if low <= ShortTP1 OR low[1] <= ShortTP1 then min(close * (1 + TrailShort), ShortStop[1]) else entry price * (1 + SLShort)
Long: position side is not short AND KalmanHullClose crosses above KalmanHMA AND (LongWT crosses above LongWTSignal OR LongWT[1] crosses above LongWTSignal[1] OR LongWT[2] crosses above LongWTSignal) AND StochK > StochD AND volume > VolThr AND ADX(DILength, ADXSmoothing) > ADXLevel AND bar time is in LongSession on LongDays
Short: position side is not long AND KalmanHMA crosses above KalmanHullClose AND ShortWT crosses below ShortWTSignal AND StochK < StochD AND volume > VolThr AND ADX(DILength, ADXSmoothing) > ADXLevel AND bar time is in ShortSession on ShortDays
Exit: long, high >= LongTP1
Exit: long, high >= LongTP1 AND TP1SourceLong <= LongTP1
Exit: long, high >= LongTP2
Exit: long, high >= LongTP2 AND TP2SourceLong <= LongTP2
Exit: long, high >= LongTP2 AND KalmanHMA > KalmanHullClose
Exit: long, high >= entry price * (1 + TP3Long)
Exit: long, low <= LongStop
Exit: long, (high <= entry price OR high >= LongPosCheck) AND KalmanHMA crosses above KalmanHullClose AND ShortWT crosses below ShortWTSignal AND StochK < StochD
Exit: long, high >= LongPosCheck AND CheckSourceLong < LongPosCheck AND (LongWT crosses below LongWTSignal OR ShortWT crosses below ShortWTSignal OR KalmanHMA crosses above KalmanHullClose OR (KalmanHMA > KalmanHullClose AND (LongWT < LongWTSignal OR ShortWT < ShortWTSignal) AND volume <= VolThr))
Exit: short, low <= ShortTP1
Exit: short, low <= ShortTP1 AND TP1SourceShort >= ShortTP1
Exit: short, low <= ShortTP2
Exit: short, low <= ShortTP2 AND TP2SourceShort >= ShortTP2
Exit: short, low <= ShortTP2 AND KalmanHMA < KalmanHullClose
Exit: short, low <= entry price * (1 - TP3Short)
Exit: short, high >= ShortStop
Exit: short, (low >= entry price OR low <= ShortPosCheck) AND KalmanHullClose crosses above KalmanHMA AND (LongWT crosses above LongWTSignal OR LongWT[1] crosses above LongWTSignal[1] OR LongWT[2] crosses above LongWTSignal) AND StochK > StochD
Exit: short, low <= ShortPosCheck AND CheckSourceShort > ShortPosCheck AND (ShortWT crosses above ShortWTSignal OR LongWT crosses above LongWTSignal OR KalmanHullClose crosses above KalmanHMA OR (KalmanHMA < KalmanHullClose AND (ShortWT > ShortWTSignal OR LongWT > LongWTSignal) AND volume <= VolThr))