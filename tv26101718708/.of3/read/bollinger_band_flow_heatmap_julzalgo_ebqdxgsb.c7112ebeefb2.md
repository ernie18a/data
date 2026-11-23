Calculation: BandLevel(k) = SMA(band source, band length) + band deviation * StDev(band source, band length) * (2 * k / layer count - 1)
Calculation: LayerMid(i) = (BandLevel(i) + BandLevel(i + 1)) / 2
Calculation: LayerPressure(i) = absolute value of the pressure accumulated into layer i from bar data
Calculation: BelowPressure = sum of LayerPressure(i) over all layers i where LayerMid(i) < close
Calculation: AbovePressure = sum of LayerPressure(i) over all layers i where LayerMid(i) >= close
Calculation: TouchesBar(i) = clear switch is on AND (open, close, HL2, or HLC3 of the current bar lies between BandLevel(i) and BandLevel(i + 1))
Calculation: LayerRank(i) = if not TouchesBar(i) AND LayerPressure(i) > 0 then 1 + number of layers j where not TouchesBar(j) AND LayerPressure(j) > LayerPressure(i), otherwise infinity
Long: BelowPressure > AbovePressure
Long: for some layer i, LayerRank(i) <= top layer count AND LayerMid(i) < close
Short: AbovePressure > BelowPressure
Short: for some layer i, LayerRank(i) <= top layer count AND LayerMid(i) >= close