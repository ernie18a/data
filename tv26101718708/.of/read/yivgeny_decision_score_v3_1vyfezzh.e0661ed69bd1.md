Calculation: x[n] = value of x n completed bars before the current bar (all calculations use chart-timeframe bars)
Calculation: body = |close-open|; upperWick = high-max(open,close); lowerWick = min(open,close)-low; bodyRatio = body/(high-low), 0 if high=low
Calculation: SMA_long = SMA(close, long length); MA_mid = SMA(close, medium length), with a length much shorter than SMA_long; VolMA = SMA(volume, N)
Calculation: trendUp = SMA_long > SMA_long[k]; MA_mid_up = MA_mid > MA_mid[m], with m < k
Calculation: confirmCandle = close>open AND close>high[1] AND volume >= c1*VolMA
Calculation: priorHigh = highest high of the previous N_break bars, excluding the current bar; yearHigh = highest high of the previous N_year bars, excluding the current bar, with N_year approximately equal to N_break
Long (bounce off long MA): low <= SMA_long*(1+tol1) AND close > SMA_long AND confirmCandle
Long (pullback to mid MA): low <= MA_mid*(1-dip) AND close > MA_mid AND confirmCandle AND trendUp AND MA_mid_up
Long (breakout): close > priorHigh AND close > open AND volume >= c2*VolMA AND close >= f_near*yearHigh, with f_near < 1 and close to 1
Long (bullish engulfing): close>open AND open[1]>close[1] AND close>open[1] AND open<close[1]
Long (hammer): lowerWick >= a*body AND upperWick <= b*body AND bodyRatio < r1, with a>1, b<1, r1<0.5
Long (morning star): open[2]>close[2] AND |close[1]-open[1]| < g*|close[2]-open[2]| AND close>open AND close > (open[2]+close[2])/2, with g<1
Long (bullish marubozu): close>open AND upperWick <= s*body AND lowerWick <= s*body AND bodyRatio >= r2, with s near 0 and r2 near 1
Long (inside bar breakout): high[1]<high[2] AND low[1]>low[2] AND close>high[1] AND close>open
Short (bearish engulfing): open>close AND close[1]>open[1] AND open>close[1] AND close<open[1]
Short (shooting star): upperWick >= a*body AND lowerWick <= b*body AND bodyRatio < r1
Short (evening star): close[2]>open[2] AND |close[1]-open[1]| < g*|close[2]-open[2]| AND open>close AND close < (open[2]+close[2])/2
Short (bearish marubozu): open>close AND upperWick <= s*body AND lowerWick <= s*body AND bodyRatio >= r2