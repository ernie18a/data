Calculation: HTF = higher-timeframe bars than the chart (aggregated from chart data); each HTF value is taken from the still-forming HTF bar containing the current chart bar, using the current close. close = chart close.
Calculation: rsi = RSI of HTF close; fast = EMA of HTF close; slow = EMA of HTF close with a longer length than fast (if there is not enough history, use shorter fallback lengths; if a component still cannot be computed, drop it and renormalize the remaining weights); slowPrev = slow from a fixed number of HTF bars earlier.
Calculation: rsiScore = clamp((overbought - rsi) / (overbought - oversold) * 100, 0, 100), where oversold < overbought.
Calculation: trendScore = 50*(fast > slow) + 25*(close > slow) + 25*(slow > slowPrev).
Calculation: asym(d, up, down) = if d >= 0 then max(0, 100 - d/up*100) else max(0, 100 + d/down*100); distF = (close - fast)/fast*100; distS = (close - slow)/slow*100.
Calculation: s50 = asym(distF, upF, downF); s200 = asym(distS, upS, downS) * cap/100, with cap < 100.
Calculation: support = max(s50, s200); if NOT (fast > slow) then support = min(support, notUpCap), where notUpCap is a low cap.
Calculation: score = (wRsi*rsiScore + wTrend*trendScore + wSupport*support) / (wRsi + wTrend + wSupport), with wRsi and wSupport both larger than wTrend.
Long: score crosses above a threshold level (score > level AND previous-bar score <= level)