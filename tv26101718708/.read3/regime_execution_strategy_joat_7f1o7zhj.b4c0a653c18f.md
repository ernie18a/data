Calculation: adaptive forecast and residual variance = on each chart bar, x=max(0,(bar index−base bar)/max(1,forecast horizon)); mean=intercept+slope*x; error=source−mean; update residual variance=lambda*prior variance+(1−lambda)*error²; let u=p00+p01*x, v=p01+p11*x, d=lambda+u+x*v, k0=u/d, k1=v/d; update intercept+=k0*error, slope+=k1*error, p00=(p00−k0*u)/lambda, p01=(p01−k0*v)/lambda, p11=(p11−k1*v)/lambda; initialize intercept=source, slope=0, p00=p11=covariance seed, p01=0, variance=0, base bar=current bar index
Calculation: forecast band spread = max(price increment, sqrt(max(residual variance,0))*band multiplier+ATR(ATR lookback)*ATR blend)
Calculation: persistent channel = initialize upper and lower levels to the first bar's high and low and state to neutral; on a new upper extreme (high>=prior upper level), set the upper level to high and state bullish if prior state is neutral or bearish, otherwise blend the prior upper level toward high by reset alpha; on a new lower extreme (low<=prior lower level), set the lower level to low and state bearish if prior state is neutral or bullish, otherwise blend the prior lower level toward low by reset alpha; on a confirmed new lower extreme with close above the midpoint and close above open, set state bullish; on a confirmed new upper extreme with close below the midpoint and close below open, set state bearish
Calculation: channel midpoint = (upper channel level+lower channel level)/2
Calculation: channel range = max(price increment,upper channel level−lower channel level)
Calculation: channel bias = 1 if channel state is bullish, −1 if channel state is bearish, otherwise tanh((close−channel midpoint)/channel range)
Calculation: forecast bias = tanh((close−adaptive forecast mean)/forecast band spread)
Calculation: pressure bias = tanh((tanh(ROC(close,pressure lookback)/max(StDev(ROC(close,pressure lookback),pressure lookback) with missing values replaced by a seed,price increment))+(2*(close−Lowest(low,pressure lookback))/max(price increment,Highest(high,pressure lookback)−Lowest(low,pressure lookback))−1))/2)
Calculation: relative volume = volume/max(SMA(volume,relative-volume lookback),volume floor)
Calculation: regime score = forecast bias*forecast weight+channel bias*channel weight+pressure bias*pressure weight+(1 if EMA(close,faster lookback)>=EMA(close,slower lookback), otherwise −1)*structure weight; faster lookback is shorter than slower lookback
Calculation: bullish votes = (forecast bias>0)+(channel bias>0)+(pressure bias>pressure threshold)
Calculation: bearish votes = (forecast bias<0)+(channel bias<0)+(pressure bias<−pressure threshold)
Long: regime score>regime boundary AND relative volume>=minimum relative volume
Short: regime score<−regime boundary AND relative volume>=minimum relative volume
Long: regime score>=0
Short: regime score<0
Long: pressure bias>=0
Short: pressure bias<0
Long: bullish votes>=bearish votes
Short: bullish votes<bearish votes
Long: confirmed bar AND bullish votes>=minimum votes AND regime score>regime boundary AND relative volume>=minimum relative volume AND ((close crosses above adaptive forecast mean AND close>channel midpoint AND pressure bias>pressure threshold) OR (close crosses above adaptive forecast mean−forecast band spread AND channel bias>=0 AND pressure bias>0))
Short: confirmed bar AND bearish votes>=minimum votes AND regime score<−regime boundary AND relative volume>=minimum relative volume AND ((close crosses below adaptive forecast mean AND close<channel midpoint AND pressure bias<−pressure threshold) OR (close crosses below adaptive forecast mean+forecast band spread AND channel bias<=0 AND pressure bias<0))
Exit: long, low<=min(max(entry price−ATR(ATR lookback)*stop multiple,lower channel level−price increment),entry price−price increment) OR high>=entry price+ATR(ATR lookback)*target multiple OR confirmed bar AND bearish votes>=minimum votes AND regime score<−bias-flip threshold
Exit: short, high>=max(min(entry price+ATR(ATR lookback)*stop multiple,upper channel level+price increment),entry price+price increment) OR low<=entry price−ATR(ATR lookback)*target multiple OR confirmed bar AND bullish votes>=minimum votes AND regime score>bias-flip threshold