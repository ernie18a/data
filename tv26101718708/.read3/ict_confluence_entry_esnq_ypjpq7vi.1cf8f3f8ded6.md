Calculation: bullish gap on Tk = low(Tk) > high(Tk)[2], for each Tk in T1, T2, T3 where T1 is shorter than T2 and T2 is shorter than T3; low(Tk) and high(Tk) are the last completed Tk bar read on chart bars, and [n] counts chart bars
Calculation: bearish gap on Tk = high(Tk) < low(Tk)[2], read the same way as bullish gap on Tk
Calculation: bullish HTF gap top = low(T3) if bullish gap on T3, else low(T2) if bullish gap on T2, else low(T1) if bullish gap on T1, else na
Calculation: bearish HTF gap bottom = high(T3) if bearish gap on T3, else high(T2) if bearish gap on T2, else high(T1) if bearish gap on T1, else na
Calculation: HTF rejection = (low <= bullish HTF gap top AND close > bullish HTF gap top) OR (high >= bearish HTF gap bottom AND close < bearish HTF gap bottom)
Calculation: recent HTF rejection = any of HTF rejection[0..HTF rejection window]
Calculation: prior low = Lowest(low, sweep lookback)[1]
Calculation: prior high = Highest(high, sweep lookback)[1]
Calculation: bullish sweep = low < prior low AND close > prior low AND prior low - low >= minimum sweep size AND trade bias permits long
Calculation: bearish sweep = high > prior high AND close < prior high AND high - prior high >= minimum sweep size AND trade bias permits short
Calculation: recent sweep = any of (bullish sweep OR bearish sweep)[0..sweep window]
Calculation: SMT bull = low == Lowest(low, SMT lookback) AND correlated instrument low > Lowest(correlated instrument low, SMT lookback) * (1 - SMT tolerance)
Calculation: SMT bear = high == Highest(high, SMT lookback) AND correlated instrument high < Highest(correlated instrument high, SMT lookback) * (1 + SMT tolerance)
Calculation: recent SMT = any of (SMT bull OR SMT bear)[0..SMT window]
Calculation: grade (ordered none < C < B < B+ < A < A+) = A+ if recent sweep AND recent HTF rejection AND recent SMT; A if recent sweep AND recent HTF rejection AND NOT recent SMT; B+ if recent HTF rejection AND recent SMT AND NOT recent sweep; B if exactly one of recent sweep, recent HTF rejection, recent SMT is true; C if none of them is true; none otherwise
Calculation: bullish gap = low > high[2] AND low - high[2] >= minimum gap size
Calculation: bearish gap = high < low[2] AND low[2] - high >= minimum gap size
Calculation: pending bearish gap top = low[2] if bearish gap; else na if long inversion[1]; else pending bearish gap top[1]
Calculation: pending bullish gap bottom = high[2] if bullish gap; else na if short inversion[1]; else pending bullish gap bottom[1]
Calculation: long inversion = close > pending bearish gap top
Calculation: short inversion = close < pending bullish gap bottom
Calculation: long signal = long inversion AND grade != none AND grade >= minimum grade AND (lower grades shown OR grade >= B+) AND (killzone-only off OR bar time (New York) in an enabled killzone session) AND trade bias permits long
Calculation: short signal = short inversion AND grade != none AND grade >= minimum grade AND (lower grades shown OR grade >= B+) AND (killzone-only off OR bar time (New York) in an enabled killzone session) AND trade bias permits short
Long: long inversion
Long: long signal
Long: long signal AND grade = A+
Long: long signal AND grade = A
Long: long signal AND grade = B+
Long: bullish sweep
Long: SMT bull
Short: short inversion
Short: short signal
Short: short signal AND grade = A+
Short: short signal AND grade = A
Short: short signal AND grade = B+
Short: bearish sweep
Short: SMT bear