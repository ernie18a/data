Calculation: K(Tf) = Slow Stochastic %K(close, high, low, stoch lookback, smoothing lookback) on Tf bars, last completed bar
Calculation: V(Tf) = K(Tf) - K(Tf)[1] on Tf bars, last completed bar
Calculation: TW = (tw(T1)*K(T1) + tw(T2)*K(T2) + tw(T3)*K(T3) + tw(T4)*K(T4)) / (tw(T1) + tw(T2) + tw(T3) + tw(T4))
Calculation: SW = (uw(T4)*K(T4) + uw(T5)*K(T5) + uw(T6)*K(T6)) / (uw(T4) + uw(T5) + uw(T6))
Calculation: Re(Tf) = (K(Tf) - midline) / SQRT((K(Tf) - midline)^2 + (phase gain*V(Tf))^2), 0 if the root is 0
Calculation: Im(Tf) = (phase gain*V(Tf)) / SQRT((K(Tf) - midline)^2 + (phase gain*V(Tf))^2), 0 if the root is 0
Calculation: COH = 100*SQRT(MRe^2 + MIm^2), where MRe = (tw(T1)*Re(T1) + tw(T2)*Re(T2) + tw(T3)*Re(T3) + tw(T4)*Re(T4)) / (tw(T1) + tw(T2) + tw(T3) + tw(T4)) and MIm = (tw(T1)*Im(T1) + tw(T2)*Im(T2) + tw(T3)*Im(T3) + tw(T4)*Im(T4)) / (tw(T1) + tw(T2) + tw(T3) + tw(T4))
Calculation: BullSync = TW > midline AND SW > midline AND TW > TW[1] AND SW >= SW[1] AND COH >= coherence floor
Calculation: BearSync = TW < midline AND SW < midline AND TW < TW[1] AND SW <= SW[1] AND COH >= coherence floor
Calculation: L = ROUND(pulse life minutes / chart bar minutes)
Calculation: LP = IF(TW crosses above SW AND LP[1] <= 0, L, MAX(LP[1] - 1, 0))
Calculation: SP = IF(TW crosses below SW AND SP[1] <= 0, L, MAX(SP[1] - 1, 0))
Long: BullSync
Long: BullSync AND NOT BullSync[1]
Long: TW crosses above lower turn level AND SW >= midline AND COH >= coherence floor
Long: TW crosses above SW AND LP[1] <= 0
Long: LP > 0
Exit: long, LP[1] > 0 AND LP <= 0
Short: BearSync
Short: BearSync AND NOT BearSync[1]
Short: TW crosses below upper turn level AND SW <= midline AND COH >= coherence floor
Short: TW crosses below SW AND SP[1] <= 0
Short: SP > 0
Exit: short, SP[1] > 0 AND SP <= 0