Calculation: ATR = ATR(ATR length)
Calculation: Pivots = list of (bar, price, kind), updated when PivotHigh(high, pivot strength, pivot strength) or PivotLow(low, pivot strength, pivot strength) returns a value at bar t, the pivot bar being t - pivot strength: if the list is empty or its newest kind differs from the new pivot kind, append the new pivot; otherwise replace the newest entry only if the new price is at least as high (highs) or at most as low (lows); then remove entries with bar < t - lookback
Calculation: n = count of Pivots
Calculation: P(k) = price of the k-th newest entry of Pivots (k = 1 is newest)
Calculation: B(k) = bar of the k-th newest entry of Pivots
Calculation: K(k) = kind (high or low) of the k-th newest entry of Pivots
Calculation: HighNew = newest entry of Pivots with kind high
Calculation: HighOld = entry of Pivots with kind high immediately before HighNew
Calculation: LowNew = newest entry of Pivots with kind low
Calculation: LowOld = entry of Pivots with kind low immediately before LowNew
Calculation: near(a, b, t) = abs(a - b) <= t * max(abs(a), abs(b))
Calculation: Upper slope = (price(HighNew) - price(HighOld)) / (bar(HighNew) - bar(HighOld))
Calculation: Lower slope = (price(LowNew) - price(LowOld)) / (bar(LowNew) - bar(LowOld))
Calculation: Highs flat = near(price(HighNew), price(HighOld), matching tolerance)
Calculation: Lows flat = near(price(LowNew), price(LowOld), matching tolerance)
Calculation: Highs rising = price(HighNew) > price(HighOld) AND Upper slope > ATR * slope floor
Calculation: Highs falling = price(HighNew) < price(HighOld) AND Upper slope < -ATR * slope floor
Calculation: Lows rising = price(LowNew) > price(LowOld) AND Lower slope > ATR * slope floor
Calculation: Lows falling = price(LowNew) < price(LowOld) AND Lower slope < -ATR * slope floor
Calculation: Enough height = max(P(1), P(2), P(3)) - min(P(1), P(2), P(3)) >= ATR * minimum pattern height
Calculation: Five pivots ending high = n >= 5 AND K(1) = high
Calculation: Five pivots ending low = n >= 5 AND K(1) = low
Calculation: Strong up impulse = n >= 6 AND P(4) - P(6) >= ATR * impulse size
Calculation: Strong down impulse = n >= 6 AND P(4) - P(6) <= -ATR * impulse size
Calculation: Symmetrical Triangle shape = Highs falling AND Lows rising AND Enough height
Calculation: Cup and Handle shape = Five pivots ending high AND near(P(5), P(3), matching tolerance * cup tolerance factor) AND P(4) < min(P(5), P(3)) - ATR * minimum pattern height AND P(2) > P(4) + (min(P(5), P(3)) - P(4)) * cup depth fraction AND P(2) < min(P(5), P(3)) AND P(1) >= P(3) - ATR * cup handle limit
Calculation: Inverted Cup and Handle shape = Five pivots ending low AND near(P(5), P(3), matching tolerance * cup tolerance factor) AND P(4) > max(P(5), P(3)) + ATR * minimum pattern height AND P(2) < P(4) - (P(4) - max(P(5), P(3))) * cup depth fraction AND P(2) > max(P(5), P(3)) AND P(1) <= P(3) + ATR * cup handle limit
Calculation: Head and Shoulders shape = Five pivots ending high AND P(3) > P(5) + ATR * shoulder height AND P(3) > P(1) + ATR * shoulder height AND near(P(5), P(1), matching tolerance * shoulder tolerance factor) AND near(P(4), P(2), matching tolerance * shoulder tolerance factor)
Calculation: Inverse Head and Shoulders shape = Five pivots ending low AND P(3) < P(5) - ATR * shoulder height AND P(3) < P(1) - ATR * shoulder height AND near(P(5), P(1), matching tolerance * shoulder tolerance factor) AND near(P(4), P(2), matching tolerance * shoulder tolerance factor)
Calculation: Triple Top shape = Five pivots ending high AND near(P(5), P(3), matching tolerance) AND near(P(3), P(1), matching tolerance)
Calculation: Triple Bottom shape = Five pivots ending low AND near(P(5), P(3), matching tolerance) AND near(P(3), P(1), matching tolerance)
Calculation: Double Top shape = K(1) = high AND near(P(3), P(1), matching tolerance) AND P(2) <= min(P(3), P(1)) - ATR * minimum pattern height
Calculation: Double Bottom shape = K(1) = low AND near(P(3), P(1), matching tolerance) AND P(2) >= max(P(3), P(1)) + ATR * minimum pattern height
Calculation: Bullish Pennant shape = Strong up impulse AND Symmetrical Triangle shape
Calculation: Bearish Pennant shape = Strong down impulse AND Symmetrical Triangle shape
Calculation: Bullish Flag shape = Strong up impulse AND Highs falling AND Lows falling AND abs(Upper slope - Lower slope) <= ATR * flag parallelism
Calculation: Bearish Flag shape = Strong down impulse AND Highs rising AND Lows rising AND abs(Upper slope - Lower slope) <= ATR * flag parallelism
Calculation: Rising Wedge shape = Highs rising AND Lows rising AND Lower slope > Upper slope AND Enough height
Calculation: Falling Wedge shape = Highs falling AND Lows falling AND Upper slope < Lower slope AND Enough height
Calculation: Ascending Triangle shape = Highs flat AND Lows rising AND Enough height
Calculation: Descending Triangle shape = Highs falling AND Lows flat AND Enough height
Calculation: Rectangle shape = Highs flat AND Lows flat AND Enough height
Calculation: Pattern = first of Cup and Handle, Inverted Cup and Handle, Head and Shoulders, Inverse Head and Shoulders, Triple Top, Triple Bottom, Double Top, Double Bottom, Bullish Pennant, Bearish Pennant, Bullish Flag, Bearish Flag, Rising Wedge, Falling Wedge, Ascending Triangle, Descending Triangle, Symmetrical Triangle, Rectangle whose shape holds, else none; none if n < 4
Calculation: Bias = Bullish if Pattern is Cup and Handle, Inverse Head and Shoulders, Triple Bottom, Double Bottom, Bullish Pennant, Bullish Flag, Falling Wedge or Ascending Triangle; Bearish if Pattern is Inverted Cup and Handle, Head and Shoulders, Triple Top, Double Top, Bearish Pennant, Bearish Flag, Rising Wedge or Descending Triangle; if Pattern is Symmetrical Triangle or Rectangle, Bullish if close >= (price(HighNew) + price(LowNew)) / 2, else Bearish; Neutral if Pattern is none
Calculation: SwingHi1 = newest non-na value of PivotHigh(high, pivot strength, pivot strength)
Calculation: SwingHi2 = the non-na value of PivotHigh(high, pivot strength, pivot strength) before SwingHi1
Calculation: SwingLo1 = newest non-na value of PivotLow(low, pivot strength, pivot strength)
Calculation: SwingLo2 = the non-na value of PivotLow(low, pivot strength, pivot strength) before SwingLo1
Calculation: Bull FVG level = high[2] at the most recent bar where low > high[2]
Calculation: Bear FVG level = low[2] at the most recent bar where high < low[2]
Calculation: Bull OB level = low[1] at the most recent bar where close > open AND close - open > displacement size * ATR AND close > high[1] AND close[1] < open[1]
Calculation: Bear OB level = high[1] at the most recent bar where close < open AND open - close > displacement size * ATR AND close < low[1] AND close[1] > open[1]
Calculation: Volume confirmed = volume >= volume multiplier * SMA(volume, volume length)
Calculation: HTF agrees = (Bias = Bullish AND close(T1, last completed bar) > EMA(close, HTF fast length, T1, last completed bar) AND EMA(close, HTF fast length, T1, last completed bar) > EMA(close, HTF slow length, T1, last completed bar)) OR (Bias = Bearish AND close(T1, last completed bar) < EMA(close, HTF fast length, T1, last completed bar) AND EMA(close, HTF fast length, T1, last completed bar) < EMA(close, HTF slow length, T1, last completed bar))
Calculation: Structure agrees = (Bias = Bullish AND ((SwingHi1 > SwingHi2 AND SwingLo1 > SwingLo2) OR close > SwingHi1)) OR (Bias = Bearish AND ((SwingHi1 < SwingHi2 AND SwingLo1 < SwingLo2) OR close < SwingLo1))
Calculation: FVG agrees = (Bias = Bullish AND close >= Bull FVG level) OR (Bias = Bearish AND close <= Bear FVG level)
Calculation: OB agrees = (Bias = Bullish AND close >= Bull OB level) OR (Bias = Bearish AND close <= Bear OB level)
Calculation: Score = base score of Pattern + (HTF term enabled ? (HTF agrees ? HTF-aligned points : HTF-misaligned points) : 0) + (volume term enabled ? (Volume confirmed ? volume-confirmed points : volume-unconfirmed points) : 0) + (structure term enabled ? (Structure agrees ? structure-aligned points : structure-misaligned points) : 0) + (FVG term enabled ? (FVG agrees ? FVG points : 0) : 0) + (OB term enabled ? (OB agrees ? OB points : 0) : 0)
Long: Bias = Bullish AND Score >= minimum score
Short: Bias = Bearish AND Score >= minimum score