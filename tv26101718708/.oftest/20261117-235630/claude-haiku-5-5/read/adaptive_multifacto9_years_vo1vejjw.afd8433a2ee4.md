Calculation: Stoch = 100 * (high - lowest(close, stoch length)) / (highest(low, stoch length) - lowest(close, stoch length))
Calculation: StochSig = SMA(Stoch, stoch signal length)
Calculation: Fisher = 0.5 * ln(v / (1 - v)), where v = max(min(x, 0.999), 0.001), and x = (close - lowest(close, Fisher length)) / (highest(close, Fisher length) - lowest(close, Fisher length)) if highest(close, Fisher length) is not equal to lowest(close, Fisher length), else x = 0.5
Calculation: FisherSig = SMA(Fisher, Fisher signal length)
Calculation: Chop = ADX(DMI length, DMI length) < ADX danger level AND ATR(ATR length) > SMA(ATR(ATR length), ATR average length)
Calculation: Composite = sum of (+1 if X else -1) over X in: MACD(close, shorter length, longer length) > EMA(MACD(close, shorter length, longer length), signal length); Stoch > StochSig; MOM(close, momentum length) > 0; RSI(close, RSI length) > 50; VI+(vortex length) > VI-(vortex length); +DI(DMI length, DMI length) > -DI(DMI length, DMI length); MFI(MFI length) > 50; Fisher > FisherSig
Long: Composite >= long entry threshold AND SAR(SAR start, SAR step, SAR maximum) < close AND RSI(close, RSI length) < long RSI limit AND NOT Chop[i] for all i from 0 to cooldown length
Short: Composite <= short entry threshold AND SAR(SAR start, SAR step, SAR maximum) > close AND RSI(close, RSI length) > short RSI limit AND NOT Chop[i] for all i from 0 to cooldown length
Exit: long, Composite <= long exit threshold OR SAR(SAR start, SAR step, SAR maximum) > close
Exit: short, Composite >= short exit threshold OR SAR(SAR start, SAR step, SAR maximum) < close