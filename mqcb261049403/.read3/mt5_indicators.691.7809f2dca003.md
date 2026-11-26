Calculation: BT1 chart state = initialize neutral; carry the prior state, set bearish when Stochastic(high, low, close, BT1 Stochastic lookback) < BT1 lower threshold and abs(close - close[BT1 lag]) > ATR(BT1 ATR lookback) / BT1 divisor, then set bullish when Stochastic(high, low, close, BT1 Stochastic lookback) > BT1 upper threshold and abs(close - close[BT1 lag]) > ATR(BT1 ATR lookback) / BT1 divisor; the upper threshold is greater than the lower threshold.
Long: Stochastic(high, low, close, BT1 Stochastic lookback) > BT1 upper threshold AND (BT1 chart state is bullish OR neutral)
Short: Stochastic(high, low, close, BT1 Stochastic lookback) < BT1 lower threshold AND (BT1 chart state is bearish OR neutral)
Calculation: HTF BT1 state = the BT1 chart state calculation applied on T1 bars, including the T1 bar still forming, using separate HTF BT1 parameters.
Long: Stochastic(high, low, close, HTF BT1 Stochastic lookback, T1, bar still forming) > HTF BT1 upper threshold AND (HTF BT1 state is bullish OR neutral)
Short: Stochastic(high, low, close, HTF BT1 Stochastic lookback, T1, bar still forming) < HTF BT1 lower threshold AND (HTF BT1 state is bearish OR neutral)
Calculation: BT2 chart state = initialize the level to the prior close and the state to bullish if the current close is higher than the prior close, otherwise bearish; each chart bar, calculate width as BT2 multiplier times 2 times the sum of (BT2 ATR lookback minus i) times ATR(BT2 ATR lookback)[i], for i from zero to BT2 ATR lookback minus one, divided by BT2 normalizer times (BT2 normalizer plus one); switch bullish to bearish when low < level - width, or bearish to bullish when spread in price units + high > level + width; then set the level to low when bullish, or spread in price units + high when bearish.
Long: BT2 chart state is bullish
Short: BT2 chart state is bearish
Calculation: HTF BT2 state = the BT2 chart state calculation applied on T1 bars, including the T1 bar still forming, using separate HTF BT2 parameters.
Long: HTF BT2 state is bullish
Short: HTF BT2 state is bearish