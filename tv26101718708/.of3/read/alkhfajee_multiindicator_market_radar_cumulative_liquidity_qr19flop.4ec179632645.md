Calculation: Intraday net dollar flow = sum, over chart bars since the current calendar day began, of (((close - low) / (high - low + epsilon parameter)) - ((high - close) / (high - low + epsilon parameter))) * volume * close
Calculation: Relative volume = volume / SMA(volume, relative volume lookback)
Calculation: RSI score = strong positive score parameter if RSI(close, RSI lookback) > upper RSI score threshold, else weak positive score parameter if RSI(close, RSI lookback) > middle RSI score threshold, else strong negative score parameter if RSI(close, RSI lookback) < lower RSI score threshold, else weak negative score parameter if RSI(close, RSI lookback) < middle RSI score threshold, else neutral score parameter
Calculation: MFI score = strong positive score parameter if MFI(close, MFI lookback) > upper MFI score threshold, else weak positive score parameter if MFI(close, MFI lookback) > middle MFI score threshold, else strong negative score parameter if MFI(close, MFI lookback) < lower MFI score threshold, else weak negative score parameter if MFI(close, MFI lookback) < middle MFI score threshold, else neutral score parameter
Calculation: CCI score = strong positive score parameter if CCI(close, CCI lookback) > upper CCI score threshold, else weak positive score parameter if CCI(close, CCI lookback) > zero threshold, else strong negative score parameter if CCI(close, CCI lookback) < lower CCI score threshold, else weak negative score parameter if CCI(close, CCI lookback) < zero threshold, else neutral score parameter
Calculation: MACD score = strong positive score parameter if MACD histogram(close, fast lookback, slower lookback, signal lookback) > zero threshold, else strong negative score parameter
Calculation: Stochastic score = weak positive score parameter if Stochastic %K(close, high, low, Stochastic lookback) > upper Stochastic score threshold, else strong positive score parameter if Stochastic %K(close, high, low, Stochastic lookback) > middle Stochastic score threshold, else weak negative score parameter if Stochastic %K(close, high, low, Stochastic lookback) < lower Stochastic score threshold, else strong negative score parameter if Stochastic %K(close, high, low, Stochastic lookback) < middle Stochastic score threshold, else neutral score parameter
Calculation: OBV score = strong positive score parameter if change in On-Balance Volume > zero threshold, else strong negative score parameter
Calculation: DMI score = strong positive score parameter if +DI(DMI lookback, ADX smoothing lookback) > -DI(DMI lookback, ADX smoothing lookback) and ADX(DMI lookback, ADX smoothing lookback) > ADX strength threshold, else weak positive score parameter if +DI(DMI lookback, ADX smoothing lookback) > -DI(DMI lookback, ADX smoothing lookback), else strong negative score parameter if -DI(DMI lookback, ADX smoothing lookback) > +DI(DMI lookback, ADX smoothing lookback) and ADX(DMI lookback, ADX smoothing lookback) > ADX strength threshold, else weak negative score parameter
Calculation: Relative volume score = strong positive score parameter if Relative volume >= relative volume threshold and +DI(DMI lookback, ADX smoothing lookback) > -DI(DMI lookback, ADX smoothing lookback), else strong negative score parameter if Relative volume >= relative volume threshold and -DI(DMI lookback, ADX smoothing lookback) > +DI(DMI lookback, ADX smoothing lookback), else neutral score parameter
Calculation: Liquidity score = strong positive score parameter if Intraday net dollar flow > zero threshold, else strong negative score parameter
Calculation: Total directional score = RSI score + MFI score + CCI score + MACD score + Stochastic score + OBV score + DMI score + Relative volume score + Liquidity score
Long: Intraday net dollar flow >= zero threshold
Short: Intraday net dollar flow < zero threshold
Long: RSI(close, RSI lookback) > RSI bullish threshold
Short: RSI(close, RSI lookback) < RSI bearish threshold
Long: MFI(close, MFI lookback) > MFI bullish threshold
Short: MFI(close, MFI lookback) < MFI bearish threshold
Long: CCI(close, CCI lookback) > CCI bullish threshold
Short: CCI(close, CCI lookback) < CCI bearish threshold
Long: MACD histogram(close, fast lookback, slower lookback, signal lookback) > zero threshold
Short: MACD histogram(close, fast lookback, slower lookback, signal lookback) <= zero threshold
Long: Stochastic %K(close, high, low, Stochastic lookback) > Stochastic direction threshold
Short: Stochastic %K(close, high, low, Stochastic lookback) <= Stochastic direction threshold
Long: change in On-Balance Volume > zero threshold
Short: change in On-Balance Volume <= zero threshold
Long: +DI(DMI lookback, ADX smoothing lookback) > -DI(DMI lookback, ADX smoothing lookback)
Short: -DI(DMI lookback, ADX smoothing lookback) > +DI(DMI lookback, ADX smoothing lookback)
Long: Total directional score >= buy bias threshold
Short: Total directional score < neutral-to-sell threshold
Long: EMA(close, shorter lookback) crosses above EMA(close, longer lookback) and RSI(close, RSI lookback) > long-entry RSI threshold
Short: EMA(close, shorter lookback) crosses below EMA(close, longer lookback) and RSI(close, RSI lookback) < short-entry RSI threshold