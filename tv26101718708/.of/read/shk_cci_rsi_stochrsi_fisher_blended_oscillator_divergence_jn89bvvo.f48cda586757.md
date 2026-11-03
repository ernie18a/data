Calculation: Stochastic RSI K = SMA of 100 × (RSI of close − lowest RSI) / (highest RSI − lowest RSI) over the stochastic lookback; use 50 when the denominator is zero. Stochastic RSI D is an SMA of K.
Calculation: Fisher = 0.5 × ln((1 + x) / (1 − x)) + 0.5 × previous Fisher, initialized with previous Fisher equal to zero; x is 2 × (close − lowest low) / (highest high − lowest low) − 1 over the Fisher lookback, clamped to [−0.999, 0.999], or zero when the range is zero.
Calculation: Blended oscillator = weighted average of CCI and the enabled, available normalized components; CCI has weight 1. Normalized RSI = (RSI − 50) × upper level / (RSI overbought level − 50); normalized Stochastic RSI K = (K − 50) × upper level / 50; normalized Fisher = Fisher × upper level / Fisher overbought level.
Calculation: Signal average = selected SMA, EMA, WMA, RMA, HMA, VWMA, SWMA, DEMA, TEMA, LSMA, or ALMA of the blended oscillator.
Calculation: Confirmed oscillator pivot = a pivot high or low with equal left and right lookbacks, recognized only after the right lookback has completed. Associate its high or low price with the oscillator pivot bar; compare it with the price associated with the preceding confirmed pivot of the same type for the same oscillator.
Long: Blended oscillator >= signal average.
Short: Blended oscillator < signal average.
Long: Blended oscillator > 0.
Short: Blended oscillator <= 0.
Long: Heikin Ashi close >= Heikin Ashi open.
Short: Heikin Ashi close < Heikin Ashi open.
Long: Blended oscillator crosses above zero OR crosses above the upper level.
Short: Blended oscillator crosses below zero OR crosses below the lower level.
Long: RSI is enabled AND RSI crosses above its midpoint.
Short: RSI is enabled AND RSI crosses below its midpoint.
Long: Stochastic RSI is enabled AND K crosses above its oversold level OR K crosses above D.
Short: Stochastic RSI is enabled AND K crosses below its overbought level OR K crosses below D.
Long: Fisher is enabled AND Fisher crosses above its oversold level OR Fisher crosses above zero.
Short: Fisher is enabled AND Fisher crosses below its overbought level OR Fisher crosses below zero.
Long: Blended oscillator >= signal average AND ((zero-cross trigger is enabled AND blended oscillator crosses above zero) OR (RSI is enabled AND RSI crosses above its oversold level) OR (Stochastic RSI is enabled AND K crosses above its oversold level) OR (Fisher is enabled AND Fisher crosses above its oversold level)).
Short: Blended oscillator < signal average AND ((zero-cross trigger is enabled AND blended oscillator crosses below zero) OR (RSI is enabled AND RSI crosses below its overbought level) OR (Stochastic RSI is enabled AND K crosses below its overbought level) OR (Fisher is enabled AND Fisher crosses below its overbought level)).
Long: A blended-oscillator pivot low is confirmed AND its associated low price is below the preceding associated low price AND its oscillator value exceeds the preceding pivot low by more than the blended-oscillator divergence threshold.
Short: A blended-oscillator pivot high is confirmed AND its associated high price is above the preceding associated high price AND its oscillator value is below the preceding pivot high by more than the blended-oscillator divergence threshold.
Long: RSI is enabled AND an RSI pivot low is confirmed AND its associated low price is below the preceding associated low price AND its RSI value exceeds the preceding pivot low by more than the RSI divergence threshold.
Short: RSI is enabled AND an RSI pivot high is confirmed AND its associated high price is above the preceding associated high price AND its RSI value is below the preceding pivot high by more than the RSI divergence threshold.