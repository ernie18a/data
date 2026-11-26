Calculation: Compression score = 100 - 100 * (Bollinger Band Width(close, band lookback, band deviation multiplier) - lowest(Bollinger Band Width(close, band lookback, band deviation multiplier), compression lookback)) / max(highest(Bollinger Band Width(close, band lookback, band deviation multiplier), compression lookback) - lowest(Bollinger Band Width(close, band lookback, band deviation multiplier), compression lookback), positive denominator floor)
Calculation: ROC change = Rate of Change(close, ROC lookback) - Rate of Change(close, ROC lookback)[ROC slope lookback]
Calculation: Momentum score = trend alignment score + RSI regime score + ROC momentum score; trend alignment score is positive strong score weight when EMA(close, shorter EMA lookback) > EMA(close, middle EMA lookback) > EMA(close, longer EMA lookback), negative strong score weight when the reverse holds, positive partial score weight when the shorter EMA is above the middle EMA, negative partial score weight when it is below, otherwise zero; RSI regime score is positive partial score weight above the upper RSI threshold, negative partial score weight below the lower RSI threshold, otherwise zero; ROC momentum score is positive strong score weight when Rate of Change(close, ROC lookback) > zero and ROC change > zero, positive partial score weight when Rate of Change(close, ROC lookback) > zero, negative strong score weight when both are below zero, negative partial score weight when Rate of Change(close, ROC lookback) < zero, otherwise zero
Calculation: Energy and volume condition = SMA(ATR(ATR lookback), ATR smoothing lookback) < SMA(ATR(ATR lookback), ATR smoothing lookback)[energy comparison lag] AND SMA(volume, volume MA lookback) > SMA(volume, volume MA lookback)[energy comparison lag]
Calculation: Upper trigger = (highest(high, Donchian lookback) + lowest(low, Donchian lookback)) / 2 + trigger buffer * ATR(ATR lookback)
Calculation: Lower trigger = (highest(high, Donchian lookback) + lowest(low, Donchian lookback)) / 2 - trigger buffer * ATR(ATR lookback)
Long: Compression score >= compression threshold AND Momentum score >= momentum trigger threshold AND Energy and volume condition AND these bullish setup conditions were false on the preceding bar
Short: Compression score >= compression threshold AND Momentum score <= -momentum trigger threshold AND Energy and volume condition AND these bearish setup conditions were false on the preceding bar
Long: Compression score >= compression threshold AND Momentum score >= momentum trigger threshold AND Energy and volume condition AND the long trigger was not armed on the preceding bar AND NOT (close crosses above Upper trigger AND volume > volume surge multiplier * SMA(volume, volume MA lookback))
Short: Compression score >= compression threshold AND Momentum score <= -momentum trigger threshold AND Energy and volume condition AND the short trigger was not armed on the preceding bar AND NOT (close crosses below Lower trigger AND volume > volume surge multiplier * SMA(volume, volume MA lookback))
Long: A bullish setup has armed the long trigger within the setup arm window, Momentum score has not fallen below zero since arming, and no earlier long entry has consumed the arm; close crosses above Upper trigger AND volume > volume surge multiplier * SMA(volume, volume MA lookback)
Short: A bearish setup has armed the short trigger within the setup arm window, Momentum score has not risen above zero since arming, and no earlier short entry has consumed the arm; close crosses below Lower trigger AND volume > volume surge multiplier * SMA(volume, volume MA lookback)
Long: The long trigger is armed OR (neither trigger is armed AND Momentum score > zero)
Short: The short trigger is armed AND the long trigger is not armed OR (neither trigger is armed AND Momentum score < zero)
Long: Momentum score >= momentum trigger threshold
Short: Momentum score <= -momentum trigger threshold
Exit: long, high >= entry price + target ATR multiple * ATR at entry OR low <= entry price - stop ATR multiple * ATR at entry OR Momentum score <= -momentum trigger threshold OR chart bars since entry >= time-stop bars
Exit: short, low <= entry price - target ATR multiple * ATR at entry OR high >= entry price + stop ATR multiple * ATR at entry OR Momentum score >= momentum trigger threshold OR chart bars since entry >= time-stop bars
Calculation: Volatility compression index = 100 − 100 × (Bollinger Band Width(close, P1, P2) − its lowest value over P3 bars) / max(its highest value over P3 bars − its lowest value over P3 bars, 10⁻¹⁰)
Calculation: Directional momentum score = trend score + RSI score + ROC score; trend score is +P14 if EMA(close, P5) > EMA(close, P6) > EMA(close, P7), −P14 if the reverse, +P15 if EMA(close, P5) > EMA(close, P6), −P15 if EMA(close, P5) < EMA(close, P6), otherwise 0; RSI score is +P15 if RSI(close, P8) > P9, −P15 if RSI(close, P8) < P10, otherwise 0; ROC score is +P14 if ROC(close, P11) > 0 and greater than its value P12 bars ago, +P15 if ROC(close, P11) > 0, −P14 if ROC(close, P11) < 0 and less than its value P12 bars ago, −P15 if ROC(close, P11) < 0, otherwise 0
Calculation: Energy buildup = SMA(ATR(P16), P19) < its value P20 bars ago AND SMA(volume, P17) > its value P20 bars ago
Calculation: Volume surge = volume > P18 × SMA(volume, P17)
Calculation: Bullish setup = volatility compression index ≥ P4 AND directional momentum score ≥ P13 AND energy buildup
Calculation: Bearish setup = volatility compression index ≥ P4 AND directional momentum score ≤ −P13 AND energy buildup
Calculation: Bullish armed state begins when bullish setup is true while inactive and remains active until directional momentum score < 0 or more than P26 bars have elapsed since arming
Calculation: Bearish armed state begins when bearish setup is true while inactive and remains active until directional momentum score > 0 or more than P26 bars have elapsed since arming
Long: bullish setup AND NOT bullish setup on the prior bar
Short: bearish setup AND NOT bearish setup on the prior bar
Long: bullish armed state AND NOT bullish armed state on the prior bar
Short: bearish armed state AND NOT bearish armed state on the prior bar
Long: bullish armed state
Short: bearish armed state
Long: directional momentum score > 0 AND neither armed state is active
Short: directional momentum score < 0 AND neither armed state is active
Option: buy call, bullish armed state AND close crosses above Donchian Channel midpoint(P21) + P22 × ATR(P16) AND volume surge
Option: buy put, bearish armed state AND close crosses below Donchian Channel midpoint(P21) − P22 × ATR(P16) AND volume surge
Exit: long call position, high ≥ entry price + P23 × ATR at entry OR low ≤ entry price − P24 × ATR at entry OR directional momentum score ≤ −P13 OR bars since entry ≥ P25
Exit: long put position, low ≤ entry price − P23 × ATR at entry OR high ≥ entry price + P24 × ATR at entry OR directional momentum score ≥ P13 OR bars since entry ≥ P25