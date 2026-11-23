Calculation: SignedVolume = volume if source >= source[1], else -volume
Calculation: KVO = EMA(SignedVolume, shorter lookback) - EMA(SignedVolume, longer lookback)
Calculation: KVOMA = MA(KVO, smoothing lookback, smoothing type)
Calculation: KVOSignal = MA(KVOMA, signal lookback, signal type)
Calculation: Osc = KVOMA if smoothing, else KVO
Calculation: OscRef = KVOSignal if smoothing, else KVOMA
Calculation: MidBand = SMA(Osc, band lookback) if band type is Bollinger, else (Highest(Osc, band lookback) + Lowest(Osc, band lookback)) / 2
Calculation: InnerBandUpper = upper inner band of Osc for band type, with band lookback, band multiplier, and band thickness
Calculation: InnerBandLower = lower inner band of Osc for band type, with band lookback, band multiplier, and band thickness
Calculation: PivotLowFound = PivotLow(Osc, left lookback, right lookback) is not NA
Calculation: PivotHighFound = PivotHigh(Osc, left lookback, right lookback) is not NA
Long: Osc crosses above OscRef
Short: Osc crosses below OscRef
Long: PivotLowFound AND Osc[right lookback] > ValueWhen(PivotLowFound, Osc[right lookback], 1) AND Low[right lookback] < ValueWhen(PivotLowFound, Low[right lookback], 1) AND minimum range <= BarsSince(PivotLowFound[1]) <= maximum range
Long: PivotLowFound AND Low[right lookback] > ValueWhen(PivotLowFound, Low[right lookback], 1) AND Osc[right lookback] < ValueWhen(PivotLowFound, Osc[right lookback], 1) AND minimum range <= BarsSince(PivotLowFound[1]) <= maximum range
Short: PivotHighFound AND High[right lookback] > ValueWhen(PivotHighFound, High[right lookback], 1) AND Osc[right lookback] < ValueWhen(PivotHighFound, Osc[right lookback], 1) AND minimum range <= BarsSince(PivotHighFound[1]) <= maximum range
Short: PivotHighFound AND High[right lookback] < ValueWhen(PivotHighFound, High[right lookback], 1) AND Osc[right lookback] > ValueWhen(PivotHighFound, Osc[right lookback], 1) AND minimum range <= BarsSince(PivotHighFound[1]) <= maximum range
Long: Osc > 0 (T1 bars, last completed bar)
Short: Osc < 0 (T1 bars, last completed bar)
Long: Osc > 0 AND Osc > OscRef (T1 bars, last completed bar)
Short: Osc < 0 AND Osc < OscRef (T1 bars, last completed bar)
Long: Osc > 0 AND Osc > MidBand (T1 bars, last completed bar)
Short: Osc < 0 AND Osc < MidBand (T1 bars, last completed bar)
Long: Osc > 0 AND InnerBandLower < Osc < InnerBandUpper (T1 bars, last completed bar)
Short: Osc < 0 AND InnerBandLower < Osc < InnerBandUpper (T1 bars, last completed bar)
Long: KVOSignal > KVOSignal[1] (T1 bars, last completed bar)
Short: KVOSignal <= KVOSignal[1] (T1 bars, last completed bar)
Long: not smoothing AND KVOMA > KVOMA[1] (T1 bars, last completed bar)
Short: not smoothing AND KVOMA <= KVOMA[1] (T1 bars, last completed bar)
Long: KVOMA > KVOSignal
Short: KVOMA <= KVOSignal