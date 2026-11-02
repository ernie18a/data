Calculation: Safe division div(x,y,f) = x/y when y is nonzero and available; otherwise f. clamp(x,a,b) = min(max(x,a),b). Signed normalization N(x,y) = clamp(div(x,y,0),-L,L)/L, where L is the component normalization limit.
Calculation: Use a configurable price source S derived from the bar's OHLC fields. Let A = max(ATR, a positive minimum price increment), R = max(high-low, the same increment), B = abs(close-open)/R, D = sign(close-open)*B, C = clamp(0.55*D + 0.30*(2*close-low-high)/R + 0.15*(min(open,close)-low-high+max(open,close))/R,-1,1), and I = N(S-S[impulse lookback], A*sqrt(impulse lookback)).
Calculation: Relative volume V = div(volume,SMA(volume,volume lookback),1). Volume component = C/2 if volume or its SMA is unavailable; otherwise clamp(C*(0.40+0.60*clamp(V-1,0,L)/L),-1,1). Range component = clamp((0.60*C+0.40*I)*clamp(div(true range,SMA(true range,range lookback),1)-1,0,L)/L,-1,1).
Calculation: Trend component T = clamp((N(S-EMA(S,trend length),A)+N(EMA(S,trend length)-EMA(S,trend length)[slope lookback],A))/2,-1,1).
Calculation: Momentum component = clamp(0.65*clamp((RSI(S,momentum length)-50)/25,-1,1)+0.35*sign(S-S[efficiency lookback])*clamp(div(abs(S-S[efficiency lookback]),sum(abs(S-S[1]),efficiency lookback),0),0,1),-1,1).
Calculation: Energy E = EMA(clamp(100*(wI*I+wC*C+wV*volume component+wR*range component+wT*T+wM*momentum component)/max(wI+wC+wV+wR+wT+wM,1)+12*div(+DI--DI,+DI+-DI,0)*clamp(ADX/50,0,1),-100,100),energy smoothing length), with configurable nonnegative component weights and DMI and ADX lengths. Energy signal = EMA(E,signal smoothing length). Energy acceleration = EMA(E-E[acceleration lookback],acceleration smoothing length).
Calculation: A crossover means the current value is above the level and its previous value was at or below the level; a crossunder means the current value is below the level and its previous value was at or above the level. Each entry, release, and exhaustion type has its own cooldown: no earlier event of that type exists OR the number of bars since its last event is greater than the cooldown length.
Long: E crosses above the positive entry threshold AND E > energy signal AND energy acceleration >= minimum acceleration AND (trend filter disabled OR T > 0) AND (DMI filter disabled OR +DI > -DI) AND (ADX filter disabled OR ADX >= ADX threshold) AND (volume filter disabled OR V >= minimum relative volume) AND (candle filter disabled OR (close > open AND B >= minimum body ratio)) AND entry cooldown passes.
Short: E crosses below the negative entry threshold AND E < energy signal AND energy acceleration <= -minimum acceleration AND (trend filter disabled OR T < 0) AND (DMI filter disabled OR -DI > +DI) AND (ADX filter disabled OR ADX >= ADX threshold) AND (volume filter disabled OR V >= minimum relative volume) AND (candle filter disabled OR (close < open AND B >= minimum body ratio)) AND entry cooldown passes.
Long: lowest abs(E) over the compression lookback including the current bar <= compression threshold AND E crosses above the positive active threshold AND energy acceleration > minimum acceleration AND (trend filter disabled OR T > 0) AND release cooldown passes.
Short: lowest abs(E) over the compression lookback including the current bar <= compression threshold AND E crosses below the negative active threshold AND energy acceleration < -minimum acceleration AND (trend filter disabled OR T < 0) AND release cooldown passes.
Exit: long, highest E over the exhaustion lookback including the current bar >= extreme threshold AND highest E over that lookback - E >= exhaustion drop AND energy acceleration < 0 AND (close < open OR close < previous close) AND exhaustion cooldown passes.
Exit: short, lowest E over the exhaustion lookback including the current bar <= -extreme threshold AND E - lowest E over that lookback >= exhaustion drop AND energy acceleration > 0 AND (close > open OR close > previous close) AND exhaustion cooldown passes.
Long: E crosses above zero.
Short: E crosses below zero.
Long: E crosses above the positive strong threshold.
Short: E crosses below the negative strong threshold.
Long: E >= 0.
Short: E < 0.
Long: E >= energy signal.
Short: E < energy signal.
Long: abs(E) > compression threshold AND E >= positive active threshold.
Short: abs(E) > compression threshold AND E <= negative active threshold.
Long: energy acceleration > 0.
Short: energy acceleration < 0.
Long: any of I, C, volume component, range component, T, or momentum component > the component display threshold.
Short: any of I, C, volume component, range component, T, or momentum component < -the component display threshold.