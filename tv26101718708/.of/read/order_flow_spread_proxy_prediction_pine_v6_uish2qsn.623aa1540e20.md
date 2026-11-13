Calculation: range = max(high - low, small positive floor)
Calculation: clv = clip(((close - low) / range - 0.5) * 2, -1, 1)
Calculation: pressure = clip(0.65 * sign(close - open) * abs(close - open) / range + 0.35 * clv, -1, 1)
Calculation: delta = volume * pressure
Calculation: ofi = pressure if volume > 0 else 0
Calculation: z(x) = (x - SMA(x, Lz)) / stdev(x, Lz), 0 if stdev is 0 (Lz is a long lookback)
Calculation: cvd = cumulative sum of delta; cvdScore = clip(z(slope of linear regression of cvd over a medium lookback) / 3, -1, 1)
Calculation: vwapScore = clip(((close - session-anchored VWAP of hlc3) / ATR) / 3, -1, 1), 0 if ATR is 0
Calculation: liqScore = clip(z(volume / range) / 3, -1, 1)
Calculation: spreadRisk = max(z(range / close), 0)
Calculation: amihudRisk = max(z(abs(ln(close / previous close)) / max(volume * close, 1)), 0)
Calculation: vpinRisk = max(z(SMA(abs(delta), Lv) / max(SMA(volume, Lv), 1)), 0) (Lv is shorter than Lz)
Calculation: dir = positive-weighted sum of ofi, cvdScore, clv, vwapScore; then dir = dir + positive weight * sign(dir) * max(liqScore, 0)
Calculation: score = short-lookback EMA of dir / (1 + positive weights * (spreadRisk, vpinRisk, amihudRisk) summed)
Calculation: probUp = 100 / (1 + exp(-score * positive sensitivity))
Calculation: emaFast, emaSlow = EMA of close with shorter and longer lookback respectively
Long: probUp > upper threshold (above 50) AND score > positive minimum AND emaFast > emaSlow AND NOT (these same three conditions all held on the previous bar)
Short: probUp < lower threshold (below 50, mirror of the upper threshold) AND score < -(positive minimum) AND emaFast < emaSlow AND NOT (these same three conditions all held on the previous bar)