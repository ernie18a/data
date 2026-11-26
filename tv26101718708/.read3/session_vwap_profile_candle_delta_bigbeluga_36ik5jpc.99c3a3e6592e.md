Calculation: SessionVWAP(x) = VWAP(x, volume) restarted when the T1 bar still forming changes
Calculation: SessionVWSD = sqrt(max(0, SessionVWAP(close^2) - SessionVWAP(close)^2))
Calculation: LowerVWAPBand = SessionVWAP(close) - band multiplier * SessionVWSD
Calculation: UpperVWAPBand = SessionVWAP(close) + band multiplier * SessionVWSD
Calculation: LowerReentry = low < LowerVWAPBand AND close > LowerVWAPBand
Calculation: UpperReentry = high > UpperVWAPBand AND close < UpperVWAPBand
Calculation: BandSignal = (LowerReentry OR UpperReentry) AND BandSignal[n] is false for all n from 1 to minimum spacing - 1
Long: LowerReentry AND BandSignal
Long: SessionVWAP(close) >= SessionVWAP(close)[1]
Short: UpperReentry AND BandSignal
Short: SessionVWAP(close) < SessionVWAP(close)[1]