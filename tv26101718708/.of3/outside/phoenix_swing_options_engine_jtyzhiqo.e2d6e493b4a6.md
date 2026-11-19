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