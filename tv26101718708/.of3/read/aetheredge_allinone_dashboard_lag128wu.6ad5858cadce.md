Calculation: Rolling range percentile = percentile scale × (x − Lowest(x, lookback)) / (Highest(x, lookback) − Lowest(x, lookback))
Calculation: Directional trend blend = 0 when trend analysis is disabled; otherwise EMA stack score × trend EMA weight + price position score × trend price weight + ADX directional score × trend ADX weight; EMA stack score = full stack score when EMA(close, shorter lookback) > EMA(close, middle lookback) > EMA(close, longer lookback), −full stack score when reversed, otherwise partial pair score × sign(EMA shorter − EMA middle) + partial pair score × sign(EMA middle − EMA longer); price position score = full price score when close is above all three EMAs, −full price score when close is below all three, otherwise middle price score × sign(close − EMA middle); ADX directional score = min(ADX score cap, ADX / ADX strength threshold × ADX ratio scale) × (DI+ > DI− ? 1 : −1), using DI+, DI−, and ADX from DMI(high, low, close, the same lookback for DI and ADX smoothing)
Calculation: Momentum blend = 0 when momentum analysis is disabled; otherwise RSI weight × (RSI(close, RSI lookback) − oscillator midpoint) × oscillator score scale + MACD weight × clamp(MACD histogram / close × histogram normalization × MACD score scale, −MACD score cap, MACD score cap) × MACD direction multiplier + stochastic weight × (Stochastic %K(close, high, low, stochastic lookback) − oscillator midpoint) × oscillator score scale; MACD direction multiplier = 1 when MACD line > signal line and histogram > 0, −1 when MACD line < signal line and histogram < 0, otherwise the unconfirmed histogram multiplier when histogram > 0 and its negative otherwise; MACD uses separate fast, slow, and signal lookbacks, with the fast lookback shorter than the slow lookback
Calculation: Volume-flow blend = 0 when volume analysis is disabled; otherwise clamp(OBV comparison score × OBV weight + CMF(high, low, close, volume, CMF lookback) × CMF scale × CMF weight + (MFI(hlc3, MFI lookback) − oscillator midpoint) × oscillator score scale × MFI weight, −volume score cap, volume score cap); OBV comparison score = OBV score when OBV > EMA(OBV, OBV EMA lookback), otherwise −OBV score
Calculation: Weighted composite = (enabled trend blend × trend module weight + enabled momentum blend × momentum module weight + enabled volatility adjustment × volatility module weight + enabled volume-flow blend × volume module weight) / sum of enabled module weights, using 1 as the denominator when that sum is 0; volatility adjustment = 0 when volatility analysis is disabled, otherwise the squeeze bonus when the Bollinger-width rolling range percentile is below its squeeze threshold, else the volatility penalty when the ATR-percent rolling range percentile exceeds its high threshold, else the volatility bonus when that percentile exceeds its middle threshold, else the base volatility bonus; ATR percent = ATR(high, low, close, ATR lookback) / close × percentage scale; Bollinger-width rolling range percentile uses ((SMA(close, Bollinger lookback) + band multiplier × StdDev(close, Bollinger lookback)) − (SMA(close, Bollinger lookback) − band multiplier × StdDev(close, Bollinger lookback))) / SMA(close, Bollinger lookback) × percentage scale; both rolling percentiles use the same regime lookback
Calculation: Signal confidence = max(bull probability, bear probability) × (max(0, alignment ceiling − population standard deviation of enabled trend, momentum, and volume-flow blends) / alignment ceiling × alignment weight + base confidence weight); bull probability = clamp(probability midpoint + weighted composite × direction probability scale, probability floor, probability ceiling); bear probability = probability ceiling − bull probability
Long: Weighted composite > 0
Short: Weighted composite < 0
Long: Signal confidence ≥ recommendation probability threshold and weighted composite > 0
Short: Signal confidence ≥ recommendation probability threshold and weighted composite < 0
Long: Weighted composite crosses above 0 and signal confidence ≥ minimum signal probability
Short: Weighted composite crosses below 0 and signal confidence ≥ minimum signal probability
Long: Directional trend blend > positive trend label boundary
Short: Directional trend blend ≤ negative trend label boundary
Long: Directional trend blend crosses above positive trend alert boundary
Short: Directional trend blend crosses below negative trend alert boundary
Long: EMA(close, shorter lookback) > EMA(close, middle lookback) and EMA(close, middle lookback) > EMA(close, longer lookback)
Short: EMA(close, shorter lookback) < EMA(close, middle lookback) and EMA(close, middle lookback) < EMA(close, longer lookback)
Long: ADX(high, low, close, DMI lookback, same ADX smoothing lookback) > ADX strength threshold and DI+ > DI−
Short: ADX(high, low, close, DMI lookback, same ADX smoothing lookback) > ADX strength threshold and DI+ ≤ DI−
Long: Momentum blend > momentum bullish label boundary and Momentum blend ≤ momentum extreme boundary, or Momentum blend ≤ −momentum extreme boundary
Short: Momentum blend > momentum extreme boundary, or Momentum blend ≤ −momentum bullish label boundary and Momentum blend > −momentum extreme boundary
Long: MACD line > MACD signal line and MACD histogram > 0
Short: MACD line < MACD signal line and MACD histogram < 0
Long: Stochastic %K(close, high, low, stochastic lookback) crosses above SMA(Stochastic %K(close, high, low, stochastic lookback), stochastic smoothing lookback)
Short: Stochastic %K(close, high, low, stochastic lookback) crosses below SMA(Stochastic %K(close, high, low, stochastic lookback), stochastic smoothing lookback)
Long: Stochastic %K(close, high, low, stochastic lookback) < stochastic low boundary
Short: Stochastic %K(close, high, low, stochastic lookback) > stochastic high boundary
Long: RSI(close, RSI lookback) < RSI low boundary
Short: RSI(close, RSI lookback) > RSI high boundary
Long: Volume-flow blend > positive flow label boundary
Short: Volume-flow blend < negative flow label boundary
Long: OBV > EMA(OBV, OBV EMA lookback)
Short: OBV ≤ EMA(OBV, OBV EMA lookback)
Long: MFI(hlc3, MFI lookback) < MFI low boundary
Short: MFI(hlc3, MFI lookback) > MFI high boundary
Long: CMF(high, low, close, volume, CMF lookback) > CMF directional threshold
Short: CMF(high, low, close, volume, CMF lookback) < −CMF directional threshold
Long: Bollinger %B(close, Bollinger lookback, band multiplier) × percentage scale < Bollinger position low boundary
Short: Bollinger %B(close, Bollinger lookback, band multiplier) × percentage scale > Bollinger position high boundary
Long: Volume-flow blend > strong inflow boundary and Directional trend blend > strong bullish trend boundary
Long: MACD line > MACD signal line and MACD histogram > 0 and RSI(close, RSI lookback) is between the long setup RSI lower and upper boundaries and ADX(high, low, close, DMI lookback, same ADX smoothing lookback) > long setup ADX threshold