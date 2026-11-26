Calculation: RSI = RSI(close, RSI lookback, on the still-forming T1 bar, mapped onto chart bars)
Calculation: Stoch RSI = Stoch RSI(RSI lookback, Stoch RSI lookback, smoothing, on the still-forming T1 bar, mapped onto chart bars)
Calculation: MFI = MFI((high + low + close) / 3, MFI lookback, on the still-forming T1 bar, mapped onto chart bars)
Calculation: Trend average = SMA(close, trend lookback, on the still-forming T1 bar, mapped onto chart bars)
Calculation: Long pressure score = count of RSI <= buy RSI threshold, Stoch RSI <= buy Stoch RSI threshold, MFI <= buy MFI threshold, and (fear/greed filter enabled AND manual fear/greed is Extreme Fear)
Calculation: Risk pressure score = count of RSI >= sell RSI threshold, Stoch RSI >= sell Stoch RSI threshold, MFI >= sell MFI threshold, and (fear/greed filter enabled AND manual fear/greed is Extreme Greed)
Calculation: Maximum possible score = number of enabled score conditions
Calculation: Required score = maximum possible score if strict mode is enabled; otherwise max(maximum possible score - score margin, minimum score)
Calculation: Accumulation pressure = long pressure score >= minimum score AND long pressure score > risk pressure score
Calculation: Below-trend accumulation = accumulation pressure AND chart-bar close < trend average
Calculation: Above-trend accumulation = accumulation pressure AND chart-bar close >= trend average
Calculation: Risk zone = risk pressure score >= minimum score AND risk pressure score > long pressure score
Long: long pressure score >= required score AND below-trend accumulation
Long: long pressure score >= required score AND above-trend accumulation
Long: below-trend accumulation AND NOT below-trend accumulation on the prior chart bar
Long: above-trend accumulation AND NOT above-trend accumulation on the prior chart bar
Exit: long, risk pressure score >= required score
Exit: long, risk zone
Exit: long, risk zone AND NOT risk zone on the prior chart bar