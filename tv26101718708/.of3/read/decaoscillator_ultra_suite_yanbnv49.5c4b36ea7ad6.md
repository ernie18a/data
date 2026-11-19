Calculation: Normalized CCI = 100*(CCI(close, CCI lookback)+CCI normalization bound)/(2*CCI normalization bound)
Calculation: Composite = WMA((RSI(close, RSI lookback)*RSI weight + MFI(close, MFI lookback)*MFI weight + Stochastic(close, high, low, Stochastic lookback)*Stochastic weight + Normalized CCI*CCI weight + (Williams %R(high, low, close, Williams %R lookback)+100)*Williams %R weight + 100*(ROC(close, ROC lookback)+ROC normalization bound)/(2*ROC normalization bound)*ROC weight + 100*(high+low-2*EMA(close, BBP lookback)+BBP ATR multiple*ATR(BBP lookback))/(2*BBP ATR multiple*ATR(BBP lookback))*BBP weight + 100*(AO(hl2, short AO lookback, long AO lookback)+AO ATR multiple*ATR(long AO lookback))/(2*AO ATR multiple*ATR(long AO lookback))*AO weight + 100*(MOM(close, MOM lookback)+MOM ATR multiple*ATR(MOM lookback))/(2*MOM ATR multiple*ATR(MOM lookback))*MOM weight + 100*(Fisher Transform(hl2, Fisher lookback)+Fisher normalization bound)/(2*Fisher normalization bound)*Fisher weight)/(RSI weight+MFI weight+Stochastic weight+CCI weight+Williams %R weight+ROC weight+BBP weight+AO weight+MOM weight+Fisher weight), Composite smoothing lookback)
Long: Composite crosses above EMA(Composite, signal lookback) AND Composite < oversold threshold AND (HTF filter disabled OR Composite calculated on T1 bars from the still-forming T1 bar and sampled on chart bars > midpoint) AND at least the consensus threshold of RSI(close, RSI lookback), MFI(close, MFI lookback), Stochastic(close, high, low, Stochastic lookback), and Normalized CCI are > midpoint
Short: Composite crosses below EMA(Composite, signal lookback) AND Composite > overbought threshold AND (HTF filter disabled OR Composite calculated on T1 bars from the still-forming T1 bar and sampled on chart bars < midpoint) AND at least the consensus threshold of RSI(close, RSI lookback), MFI(close, MFI lookback), Stochastic(close, high, low, Stochastic lookback), and Normalized CCI are < midpoint
Long: For each positive offset j through pivot width, Composite[pivot lag] < Composite[pivot lag+j] AND Composite[pivot lag] <= Composite[pivot lag-j], AND there exists an integer i from divergence search start through divergence search end such that low[pivot lag] < low[pivot lag+i] AND Composite[pivot lag] > Composite[pivot lag+i]
Short: For each positive offset j through pivot width, Composite[pivot lag] > Composite[pivot lag+j] AND Composite[pivot lag] >= Composite[pivot lag-j], AND there exists an integer i from divergence search start through divergence search end such that high[pivot lag] > high[pivot lag+i] AND Composite[pivot lag] < Composite[pivot lag+i]
Long: Composite > EMA(Composite, signal lookback)
Short: Composite <= EMA(Composite, signal lookback)
Long: RSI(close, RSI lookback) > midpoint
Short: RSI(close, RSI lookback) <= midpoint
Long: MFI(close, MFI lookback) > midpoint
Short: MFI(close, MFI lookback) <= midpoint
Long: Stochastic(close, high, low, Stochastic lookback) > midpoint
Short: Stochastic(close, high, low, Stochastic lookback) <= midpoint
Long: Composite calculated on T1 bars from the still-forming T1 bar and sampled on chart bars > midpoint
Short: Composite calculated on T1 bars from the still-forming T1 bar and sampled on chart bars <= midpoint
Long: Composite > midpoint
Short: Composite <= midpoint
Long: At least the consensus threshold of RSI(close, RSI lookback), MFI(close, MFI lookback), Stochastic(close, high, low, Stochastic lookback), and Normalized CCI are > midpoint
Short: At least the consensus threshold of RSI(close, RSI lookback), MFI(close, MFI lookback), Stochastic(close, high, low, Stochastic lookback), and Normalized CCI are < midpoint