Calculation: Open and close averages = the same selected moving-average type and period applied separately to open and close, each delayed by the same configurable number of source bars. Select SMA, EMA, DEMA, TEMA, WMA, VWMA, SMMA, Hull MA, linear-regression MA, ALMA, SMA of SMA, or SuperSmoother. SuperSmoother is y = c1*(source + previous source, replacing missing previous source with zero)/2 + c2*previous y + c3*y two bars ago, replacing missing y values with zero; a = exp(-1.414*pi/period), c2 = 2*a*cos(1.414*pi/period), c3 = -a*a, c1 = 1-c2-c3.
Calculation: Alternate averages = the open and close averages calculated on the chart timeframe or, when alternate resolution is enabled, on the selected higher or lower timeframe. For historical higher-timeframe bars, use the final completed higher-timeframe value from the start of that bar, including values from its later chart bars. For a lower timeframe, use the first intrabar value within each chart bar. Carry the last available value across gaps.
Calculation: ADX threshold = a configurable fixed threshold or the linearly interpolated median of chart-timeframe ADX over a configurable lookback; ADX uses the same period for directional movement and ADX smoothing.
Calculation: Long stop = entry price times one minus the fixed-stop fraction until chart-bar high first exceeds entry price times one plus the activation fraction; thereafter the maximum of the previous long stop and chart-bar high times one minus the trailing fraction. Initialize the previous stop to the fixed stop on entry and reset on a flat position.
Calculation: Short stop = entry price times one plus the fixed-stop fraction until chart-bar low first falls below entry price times one minus the activation fraction; thereafter the minimum of the previous short stop and chart-bar low times one plus the trailing fraction. Initialize the previous stop to the fixed stop on entry and reset on a flat position.
Long: Alternate close average crosses above alternate open average AND long trading is enabled AND (ADX filter is disabled OR chart-timeframe ADX > ADX threshold).
Short: Alternate close average crosses below alternate open average AND short trading is enabled AND (ADX filter is disabled OR chart-timeframe ADX > ADX threshold).
Long: Alternate close average > alternate open average.
Short: Alternate close average <= alternate open average.
Long: Chart-timeframe close average > alternate open average.
Short: Chart-timeframe close average <= alternate open average.
Exit: long, alternate close average crosses below alternate open average AND trading is long-only.
Exit: short, alternate close average crosses above alternate open average AND trading is short-only.
Exit: long, stop orders are enabled AND price reaches the previously submitted long stop.
Exit: short, stop orders are enabled AND price reaches the previously submitted short stop.
Exit: long, take profit is enabled AND price reaches entry price times one plus the take-profit fraction.
Exit: short, take profit is enabled AND price reaches entry price times one minus the take-profit fraction.