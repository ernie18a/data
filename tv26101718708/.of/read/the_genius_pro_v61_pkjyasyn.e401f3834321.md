Calculation: EMA = exponential moving average of close on the chart timeframe
Calculation: Bias(tf) = sign(close - EMA of close), computed on timeframe tf using the bar still forming at that timeframe. Bias15 uses a timeframe higher than the chart, Bias1h uses a timeframe higher than Bias15, and BiasD uses the daily timeframe, higher than Bias1h.
Calculation: Tol = tolerance factor * ATR on daily bars (forming bar included)
Calculation: DailyResistance = over the previous N completed daily bars, take as candidates every daily high that is above the current price (close of the forming daily bar). Touches(candidate) = number of those N bars with abs(high - candidate) <= Tol AND close < candidate. Keep candidates with Touches >= MinTouches and select the one closest to current price. If none qualifies, it is undefined.
Calculation: DailySupport = mirror of DailyResistance: candidates are daily lows below current price. Touches(candidate) = number of those N bars with abs(low - candidate) <= Tol AND close > candidate. Keep candidates with Touches >= MinTouches and select the one closest to current price. If none qualifies, it is undefined.
Calculation: BullBreak = DailyResistance is defined AND close > DailyResistance (evaluated on completed chart bars)
Calculation: BearBreak = DailySupport is defined AND close < DailySupport (evaluated on completed chart bars)
Calculation: BuyScore = sum of weights for: (close > EMA) weight wE; BullBreak weight wB; (close > open) weight wC; (Bias15 = +1), (Bias1h = +1), (BiasD = +1) each weight wT. Weights: wB > wE = wC > wT.
Calculation: SellScore = same weights applied to the mirrored conditions: close < EMA; BearBreak; close < open; Bias15 = -1; Bias1h = -1; BiasD = -1.
Long: BuyScore > SellScore AND max(BuyScore, SellScore) >= MinScore
Long: close > EMA AND BullBreak AND max(BuyScore, SellScore) >= MinScore
Short: SellScore > BuyScore AND max(BuyScore, SellScore) >= MinScore
Short: close < EMA AND BearBreak AND max(BuyScore, SellScore) >= MinScore