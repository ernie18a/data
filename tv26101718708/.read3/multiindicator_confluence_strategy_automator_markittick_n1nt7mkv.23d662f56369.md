Calculation: Baseline = HMA(close, baseline lookback) on chart bars
Calculation: ATR = ATR(ATR lookback) on chart bars
Calculation: Confirmation CCI = CCI(close, confirmation lookback) on chart bars
Calculation: Baseline distance integral = SUM(close[1] − Baseline[1], BDI lookback) on chart bars
Calculation: Momentum inflation ratio = (abs(close[1] − close[2]) / ATR[1]) / (RMA(abs(close − close[1]), momentum lookback)[1] / RMA(ATR, momentum lookback)[1]), with zero-denominator guards
Calculation: Lead-lag correlation = Pearson correlation(secondary asset close[lag + 1], close[1], correlation lookback) on chart bars using completed bars
Calculation: Decayed confluence score(direction) = count of directional baseline, DMI, and confirmation CCI conditions × max(0, 1 − prior consecutive full-confluence bars / decay window), where full confluence also requires volume confirmation
Long: close[1] > Baseline[1] + ATR[1] × ATR buffer
Short: close[1] < Baseline[1] − ATR[1] × ATR buffer
Long: ADX(DMI lookback, ADX smoothing)[1] > ADX trend threshold AND +DI(DMI lookback)[1] > −DI(DMI lookback)[1]
Short: ADX(DMI lookback, ADX smoothing)[1] > ADX trend threshold AND −DI(DMI lookback)[1] > +DI(DMI lookback)[1]
Long: Confirmation CCI[1] > CCI threshold
Short: Confirmation CCI[1] < −CCI threshold
Long: BDI enabled AND Baseline distance integral > 0
Short: BDI enabled AND Baseline distance integral < 0
Long: Lead-lag display enabled AND Lead-lag correlation > 0 AND abs(Lead-lag correlation) >= correlation threshold
Short: Lead-lag display enabled AND Lead-lag correlation < 0 AND abs(Lead-lag correlation) >= correlation threshold
Long: close[1] > Baseline[1] + ATR[1] × ATR buffer AND ADX(DMI lookback, ADX smoothing)[1] > ADX trend threshold AND +DI(DMI lookback)[1] > −DI(DMI lookback)[1] AND Confirmation CCI[1] > CCI threshold AND volume[1] > RMA(volume, volume lookback)[1] × volume multiplier AND (Hurst detector disabled OR Hurst exponent(close, Hurst lookback) > trending threshold) AND (decay disabled OR decayed confluence score(long) >= minimum confluence score) AND (lead-lag filter disabled OR abs(Lead-lag correlation) < correlation threshold OR (Lead-lag correlation > 0 AND abs(Lead-lag correlation) >= correlation threshold)) AND (momentum inflation filter disabled OR Momentum inflation ratio <= inflation threshold) AND the same long-entry condition was false on the previous chart bar AND at least the minimum signal gap in chart bars has elapsed since the previous long or short signal
Short: close[1] < Baseline[1] − ATR[1] × ATR buffer AND ADX(DMI lookback, ADX smoothing)[1] > ADX trend threshold AND −DI(DMI lookback)[1] > +DI(DMI lookback)[1] AND Confirmation CCI[1] < −CCI threshold AND volume[1] > RMA(volume, volume lookback)[1] × volume multiplier AND (Hurst detector disabled OR Hurst exponent(close, Hurst lookback) > trending threshold) AND (decay disabled OR decayed confluence score(short) >= minimum confluence score) AND (lead-lag filter disabled OR abs(Lead-lag correlation) < correlation threshold OR (Lead-lag correlation < 0 AND abs(Lead-lag correlation) >= correlation threshold)) AND (momentum inflation filter disabled OR Momentum inflation ratio <= inflation threshold) AND the same short-entry condition was false on the previous chart bar AND at least the minimum signal gap in chart bars has elapsed since the previous long or short signal
Exit: long, CCI(close, exit lookback)[1] < 0 AND CCI(close, exit lookback)[2] >= 0
Exit: short, CCI(close, exit lookback)[1] > 0 AND CCI(close, exit lookback)[2] <= 0