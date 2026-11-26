Calculation: RawMomentum = ROC(Close, momentum lookback) if momentum type is rate of change; Momentum(Close, momentum lookback) if momentum type is price momentum; ln(Close / Close[momentum lookback]) * 100 if momentum type is log returns
Calculation: Drawdown = (Highest(Close, bars so far) - Close) / Highest(Close, bars so far)
Calculation: Volatility = StDev(Close, volatility lookback) / SMA(Close, volatility lookback)
Calculation: DrawdownAlpha = if adaptive smoothing enabled then drawdown min alpha + (drawdown max alpha - drawdown min alpha) * PercentRank(Volatility, percent-rank lookback) / 100 else 2 / (drawdown smoothing lookback + 1)
Calculation: SignalAlpha = if adaptive smoothing enabled then signal min alpha + (signal max alpha - signal min alpha) * PercentRank(Volatility, percent-rank lookback) / 100 else 2 / (signal lookback + 1)
Calculation: Smooth(x, a) = Smooth(x, a)[1] + a * (x - Smooth(x, a)[1]), where Smooth(x, a) = x on the first bar
Calculation: SmoothedDrawdown = Smooth(Drawdown, DrawdownAlpha)
Calculation: SmoothedMaxDrawdown = Smooth(Highest(Drawdown, max-drawdown lookback), DrawdownAlpha)
Calculation: RiskAdjustedMomentum = RawMomentum * max(1 - SmoothedDrawdown / SmoothedMaxDrawdown * risk scaling, minimum risk factor)
Calculation: Acceleration = EMA(RiskAdjustedMomentum - RiskAdjustedMomentum[acceleration lookback], acceleration lookback)
Calculation: Projection = LinReg(RiskAdjustedMomentum, regression lookback, 0) + LinRegSlope(RiskAdjustedMomentum, regression lookback) * projection offset
Calculation: LongExhaustion = leading mode enabled AND RiskAdjustedMomentum < -exhaustion threshold AND Volume < SMA(Volume, volume lookback)
Calculation: ShortExhaustion = leading mode enabled AND RiskAdjustedMomentum > exhaustion threshold AND Volume < SMA(Volume, volume lookback)
Calculation: FinalMomentum = (if leading mode enabled then RiskAdjustedMomentum * risk-adjusted weight + Projection * projection weight + Acceleration * acceleration weight else RiskAdjustedMomentum) * (if LongExhaustion then bullish exhaustion multiplier else if ShortExhaustion then bearish exhaustion multiplier else 1)
Calculation: Oscillator = min(z limit, max(-z limit, (FinalMomentum - SMA(FinalMomentum, normalization lookback)) / StDev(FinalMomentum, normalization lookback)))
Calculation: Signal = Smooth(Oscillator, SignalAlpha)
Calculation: UpperThreshold = if dynamic thresholds enabled then SMA(Oscillator, normalization lookback) + threshold multiplier * StDev(Oscillator, normalization lookback) else static upper
Calculation: LowerThreshold = if dynamic thresholds enabled then SMA(Oscillator, normalization lookback) - threshold multiplier * StDev(Oscillator, normalization lookback) else static lower
Calculation: BullishTrend = Oscillator > Signal AND Oscillator > LowerThreshold
Calculation: BearishTrend = Oscillator < Signal AND Oscillator < UpperThreshold
Long: Oscillator > LowerThreshold AND (crossover(Oscillator, Signal) OR (leading mode enabled AND Acceleration > 0 AND Oscillator < Signal AND Oscillator > Oscillator[1])) AND SmoothedDrawdown < high-risk fraction * SmoothedMaxDrawdown
Short: Oscillator < UpperThreshold AND (crossunder(Oscillator, Signal) OR (leading mode enabled AND Acceleration < 0 AND Oscillator > Signal AND Oscillator < Oscillator[1]))
Exit: long, Oscillator > UpperThreshold
Exit: short, Oscillator < LowerThreshold OR (crossover(Oscillator, Signal) AND SmoothedDrawdown >= high-risk fraction * SmoothedMaxDrawdown)
Long: Oscillator < LowerThreshold AND Oscillator < Oscillator[1]
Long: (Low < Low[1] AND Low[1] < Low[2] AND Oscillator > Oscillator[1] AND Oscillator[1] > Oscillator[2]) OR (leading mode enabled AND LinRegSlope(RiskAdjustedMomentum, regression lookback) > 0 AND Close < Close[1])
Long: leading mode enabled AND Acceleration > 0 AND Acceleration[1] <= 0
Long: LongExhaustion
Long: BullishTrend AND NOT BullishTrend[1]
Long: Oscillator <= -color level
Long: Oscillator >= Signal
Short: Oscillator > UpperThreshold AND Oscillator > Oscillator[1]
Short: (High > High[1] AND High[1] > High[2] AND Oscillator < Oscillator[1] AND Oscillator[1] < Oscillator[2]) OR (leading mode enabled AND LinRegSlope(RiskAdjustedMomentum, regression lookback) < 0 AND Close > Close[1])
Short: leading mode enabled AND Acceleration < 0 AND Acceleration[1] >= 0
Short: ShortExhaustion
Short: BearishTrend AND NOT BearishTrend[1]
Short: Oscillator >= color level
Short: Oscillator < Signal