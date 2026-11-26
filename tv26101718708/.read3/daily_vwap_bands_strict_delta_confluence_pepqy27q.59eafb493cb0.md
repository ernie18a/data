Calculation: VWAP SD = sqrt(sum(volume × source²) / sum(volume) − VWAP(source, chart bars since each T1 boundary)²)
Calculation: Lower band = VWAP(source, chart bars since each T1 boundary) − band multiplier × VWAP SD, calculated on chart bars since each T1 boundary
Calculation: Upper band = VWAP(source, chart bars since each T1 boundary) + band multiplier × VWAP SD, calculated on chart bars since each T1 boundary
Calculation: CVD = Cumulative Volume Delta(volume, chart bars since each T1 boundary)
Long: low <= Lower band AND close > Lower band AND close > open AND CVD > 0 AND CVD >= CVD[1] AND low[1] > Lower band[1]
Short: high >= Upper band AND close < Upper band AND close < open AND CVD < 0 AND CVD <= CVD[1] AND high[1] < Upper band[1]