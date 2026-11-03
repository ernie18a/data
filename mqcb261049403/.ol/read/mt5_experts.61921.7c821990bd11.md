Calculation: AC0, AC1 = Accelerator Oscillator on the strategy timeframe, scaled by 40000; current forming bar and last completed bar, respectively
Calculation: AO0, AO1 = Awesome Oscillator on the strategy timeframe, scaled by 10000; current forming bar and last completed bar, respectively
Calculation: DeM0, DeM1 = DeMarker on the strategy timeframe, scaled by 100; current forming bar and last completed bar, respectively
Calculation: Force1, Force2 = Force Index on the strategy timeframe, scaled by 20; last completed bar and the preceding completed bar, respectively
Calculation: UpperBand, LowerBand = upper and lower Bollinger Bands on the strategy timeframe, on the last completed bar
Calculation: MACDMain0, MACDSignal0, MACDMain1, MACDSignal1 = MACD main and signal lines on the strategy timeframe; current forming bar (0) and last completed bar (1)
Calculation: StochK0, StochD0, StochK1, StochD1 = Stochastic %K and %D on the strategy timeframe; current forming bar (0) and last completed bar (1)
Long: AC0 < -openThreshold AND AC1 < -openThreshold AND AC0 < AC1
Short: AC0 > openThreshold AND AC1 > openThreshold AND AC0 > AC1
Exit: long, AC0 > closeThreshold AND AC1 > closeThreshold AND AC0 > AC1 OR price >= entryPrice + takeProfitDistance OR price <= entryPrice - stopLossDistance OR short-entry condition
Exit: short, AC0 < -closeThreshold AND AC1 < -closeThreshold AND AC0 < AC1 OR price <= entryPrice - takeProfitDistance OR price >= entryPrice + stopLossDistance OR long-entry condition
Long: ADX > openStrengthThreshold AND ADX > priorADX AND +DI < -DI AND -DI > openDirectionThreshold
Short: ADX > openStrengthThreshold AND ADX > priorADX AND +DI > -DI AND +DI > openDirectionThreshold
Exit: long, ADX > closeStrengthThreshold AND +DI < -DI AND -DI - ADX > closeDirectionThreshold OR price >= entryPrice + takeProfitDistance OR price <= entryPrice - stopLossDistance OR short-entry condition
Exit: short, ADX > closeStrengthThreshold AND +DI > -DI AND +DI - ADX > closeDirectionThreshold OR price <= entryPrice - takeProfitDistance OR price >= entryPrice + stopLossDistance OR long-entry condition
Long: AO0 < -openThreshold AND AO1 > -openThreshold AND AO0 < AO1
Short: AO0 > openThreshold AND AO1 < openThreshold AND AO0 > AO1
Exit: long, AO0 > -closeThreshold AND AO1 < -closeThreshold AND AO0 > AO1 OR price >= entryPrice + takeProfitDistance OR price <= entryPrice - stopLossDistance OR short-entry condition
Exit: short, AO0 < closeThreshold AND AO1 > closeThreshold AND AO0 < AO1 OR price <= entryPrice - takeProfitDistance OR price >= entryPrice + stopLossDistance OR long-entry condition
Long: DeM0 < 100 - openThreshold AND DeM1 > 100 - openThreshold
Short: DeM0 > openThreshold AND DeM1 < openThreshold
Exit: long, DeM0 > 100 - closeThreshold AND DeM1 < 100 - closeThreshold OR price >= entryPrice + takeProfitDistance OR price <= entryPrice - stopLossDistance OR short-entry condition
Exit: short, DeM0 < closeThreshold AND DeM1 > closeThreshold OR price <= entryPrice - takeProfitDistance OR price >= entryPrice + stopLossDistance OR long-entry condition
Long: High of last completed bar < LowerBand AND Force1 > -openForceThreshold AND Force2 < -openForceThreshold AND Force1 > Force2
Short: Low of last completed bar > UpperBand AND Force1 < openForceThreshold AND Force2 > openForceThreshold AND Force1 < Force2
Exit: long, (band width > closeBandThreshold AND High of last completed bar < LowerBand) OR Force1 < closeForceThreshold AND Force2 > closeForceThreshold AND Force1 < Force2 OR price >= entryPrice + takeProfitDistance OR price <= entryPrice - stopLossDistance OR short-entry condition
Exit: short, (band width > closeBandThreshold AND Low of last completed bar > UpperBand) OR Force1 > -closeForceThreshold AND Force2 < -closeForceThreshold AND Force1 > Force2 OR price <= entryPrice - takeProfitDistance OR price >= entryPrice + stopLossDistance OR long-entry condition
Long: MFI < 100 - openThreshold AND prior MFI > 100 - openThreshold
Short: MFI > openThreshold AND prior MFI < openThreshold
Exit: long, MFI > 100 - closeThreshold AND prior MFI < 100 - closeThreshold OR price >= entryPrice + takeProfitDistance OR price <= entryPrice - stopLossDistance OR short-entry condition
Exit: short, MFI < closeThreshold AND prior MFI > closeThreshold OR price <= entryPrice - takeProfitDistance OR price >= entryPrice + stopLossDistance OR long-entry condition
Long: MACDMain0 < -openMACDThreshold AND MACDMain1 < -openMACDThreshold AND MACDMain0 > MACDSignal0 AND MACDMain0 > MACDMain1 AND MACDSignal0 < MACDSignal1 AND StochK0 < 100 - openStochasticThreshold AND StochK1 < 100 - openStochasticThreshold AND StochK0 < StochD0 AND StochK0 < StochK1 AND StochD0 < StochD1
Short: MACDMain0 > openMACDThreshold AND MACDMain1 > openMACDThreshold AND MACDMain0 < MACDSignal0 AND MACDMain0 < MACDMain1 AND MACDSignal0 > MACDSignal1 AND StochK0 > openStochasticThreshold AND StochK1 > openStochasticThreshold AND StochK0 > StochD0 AND StochK0 > StochK1 AND StochD0 > StochD1
Exit: long, (MACDMain0 < -closeMACDThreshold AND MACDMain1 < -closeMACDThreshold AND MACDMain0 < MACDSignal0 AND MACDMain0 < MACDMain1 AND MACDSignal0 < MACDSignal1) OR (StochK0 < closeStochasticThreshold AND StochK1 > closeStochasticThreshold AND StochK0 < StochD0 AND StochK0 < StochK1 AND StochD0 > StochD1) OR price >= entryPrice + takeProfitDistance OR price <= entryPrice - stopLossDistance OR short-entry condition
Exit: short, (MACDMain0 > closeMACDThreshold AND MACDMain1 > closeMACDThreshold AND MACDMain0 > MACDSignal0 AND MACDMain0 > MACDMain1 AND MACDSignal0 > MACDSignal1) OR (StochK0 > 100 - closeStochasticThreshold AND StochK1 < 100 - closeStochasticThreshold AND StochK0 > StochD0 AND StochK0 > StochK1 AND StochD0 < StochD1) OR price <= entryPrice - takeProfitDistance OR price >= entryPrice + stopLossDistance OR long-entry condition