Calculation: Hull Butterfly value(source, length) = sum[k=0..N-1] w[k]*(source[k]-source[N-1-k]); let N=length, H=floor(N/2), R=floor(sqrt(N)), D(q)=q*(q+1)/2, b[j]=2*max(H-N+1+j,0)/D(H)-(j+1)/D(N) for j<N and 0 otherwise, i=N+R-1-k, and w[k]=sum[j=i-R..i-1](b[j]*(i-j))/D(R).
Calculation: Hull Butterfly band = cumulative sum(abs(Hull Butterfly value))/bar_index * multiplier.
Calculation: Hull Butterfly state = 0 when Hull Butterfly value crosses Hull Butterfly band or crosses its negative; otherwise -1 when Hull Butterfly value < Hull Butterfly value[1] AND Hull Butterfly value > Hull Butterfly band; otherwise 1 when Hull Butterfly value > Hull Butterfly value[1] AND Hull Butterfly value < -Hull Butterfly band; otherwise its prior value, initially 0.
Calculation: Masanakamura ADX(length) = SMA(100*abs(DIPlus(length)-DIMinus(length))/(DIPlus(length)+DIMinus(length)), length), using Wilder-smoothed directional movement and true range for DIPlus and DIMinus.
Calculation: Selected ADX = ADX(DI lookback, ADX smoothing) or Masanakamura ADX(DI lookback), according to the selected ADX variant.
Calculation: Profit target price(entry price, target percentage, position side) = entry price + direction(position side)*round(target percentage*entry price/(100*minimum price increment))*minimum price increment, where direction is 1 for long and -1 for short.
Long: Hull Butterfly value > 0
Short: Hull Butterfly value <= 0
Long: Hull Butterfly state > Hull Butterfly state[1] AND Hull Butterfly state = 1
Short: Hull Butterfly state < Hull Butterfly state[1] AND Hull Butterfly state = -1
Long: HalfTrend up-arrow event(amplitude)
Short: HalfTrend down-arrow event(amplitude)
Long: Hull Butterfly value > 0 AND HalfTrend up-arrow event(amplitude)
Short: Hull Butterfly value <= 0 AND HalfTrend down-arrow event(amplitude)
Long: HalfTrend up-arrow event(amplitude) AND bars since Hull Butterfly up-arrow <= maximum bars between triggers AND (EMA filter disabled OR selected EMA source > EMA(selected EMA source, EMA length)) AND (ADX filter disabled OR Selected ADX > ADX threshold) AND long entries permitted AND position side is not long
Short: HalfTrend down-arrow event(amplitude) AND bars since Hull Butterfly down-arrow <= maximum bars between triggers AND (EMA filter disabled OR selected EMA source < EMA(selected EMA source, EMA length)) AND (ADX filter disabled OR Selected ADX > ADX threshold) AND short entries permitted AND position side is not short
Exit: long, close < entry price*(1-stop-loss percentage) OR high >= Profit target price(entry price, target 1 percentage, long) OR high >= Profit target price(entry price, target 2 percentage, long) OR high >= Profit target price(entry price, target 3 percentage, long) OR high >= Profit target price(entry price, target 4 percentage, long)
Exit: short, close > entry price*(1+stop-loss percentage) OR low <= Profit target price(entry price, target 1 percentage, short) OR low <= Profit target price(entry price, target 2 percentage, short) OR low <= Profit target price(entry price, target 3 percentage, short) OR low <= Profit target price(entry price, target 4 percentage, short)