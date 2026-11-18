Calculation: Smoothed OBV = MA(OBV, OBV lookback, selected type: EMA/SMA/VWMA/WMA)
Calculation: Smoothed OBV signal = MA(Smoothed OBV, separate signal lookback, same selected MA type)
Calculation: Top fractal = Smoothed OBV[4] < Smoothed OBV[2] AND Smoothed OBV[3] < Smoothed OBV[2] AND Smoothed OBV[2] > Smoothed OBV[1] AND Smoothed OBV[2] > Smoothed OBV
Calculation: Bottom fractal = Smoothed OBV[4] > Smoothed OBV[2] AND Smoothed OBV[3] > Smoothed OBV[2] AND Smoothed OBV[2] < Smoothed OBV[1] AND Smoothed OBV[2] < Smoothed OBV
Calculation: Prior top-fractal high = valuewhen(Top fractal, high[2], most recent occurrence)[2]
Calculation: Prior top-fractal Smoothed OBV = valuewhen(Top fractal, Smoothed OBV[2], most recent occurrence)[2]
Calculation: Prior bottom-fractal low = valuewhen(Bottom fractal, low[2], most recent occurrence)[2]
Calculation: Prior bottom-fractal Smoothed OBV = valuewhen(Bottom fractal, Smoothed OBV[2], most recent occurrence)[2]
Long: Smoothed OBV crosses above Smoothed OBV signal OR Bottom fractal AND ((low[2] < Prior bottom-fractal low AND Smoothed OBV[2] > Prior bottom-fractal Smoothed OBV) OR (low[2] > Prior bottom-fractal low AND Smoothed OBV[2] < Prior bottom-fractal Smoothed OBV))
Short: Smoothed OBV crosses below Smoothed OBV signal OR Top fractal AND ((high[2] > Prior top-fractal high AND Smoothed OBV[2] < Prior top-fractal Smoothed OBV) OR (high[2] < Prior top-fractal high AND Smoothed OBV[2] > Prior top-fractal Smoothed OBV))