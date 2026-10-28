Calculation: short EMA = exponential moving average of close with a shorter lookback than each of the medium and long EMAs
Calculation: medium EMA = exponential moving average of close
Calculation: long EMA = exponential moving average of close
Calculation: UT buy trail = recursively update from the prior buy trail (use 0 if unavailable): if current and prior close are both above the prior trail, take the maximum of the prior trail and current close minus buy key × buy ATR; if both are below, take the minimum of the prior trail and current close plus buy key × buy ATR; otherwise, use current close minus buy key × buy ATR when current close is above prior trail, and current close plus buy key × buy ATR otherwise
Calculation: UT sell trail = same recursive rule as the UT buy trail, using the sell key and sell ATR
Long: (short EMA crossed above medium EMA OR short EMA crossed above long EMA) on the prior bar AND prior close < prior open AND current high > prior high AND current close > current open OR UT buy is enabled AND current close > UT buy trail AND current close crossed above UT buy trail
Short: (short EMA crossed below medium EMA OR short EMA crossed below long EMA) on the prior bar AND prior close > prior open AND current low < prior low AND current close < current open OR UT sell is enabled AND current close < UT sell trail AND UT sell trail crossed above current close
