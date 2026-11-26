Calculation: S ORB high = highest high of chart bars within the S ORB window of the current day
Calculation: S ORB low = lowest low of chart bars within the S ORB window of the current day
Calculation: S ORB mid = (S ORB high + S ORB low) / 2
Calculation: S trade window = bar time >= S ORB end AND bar time < S session end
Calculation: S long risk = |entry price - S ORB mid| if S stop method is Midpoint, |entry price - S ORB low| if S stop method is Opposite Side, S stop points if S stop method is Fixed Points
Calculation: S short risk = |entry price - S ORB mid| if S stop method is Midpoint, |entry price - S ORB high| if S stop method is Opposite Side, S stop points if S stop method is Fixed Points
Calculation: S long stop = entry price - S long risk if staircase stop is off for S; otherwise, if highest high since entry >= entry price + S long risk * S TP3 RR then entry price + S long risk * S TP2 RR; else if highest high since entry >= entry price + S long risk * S TP2 RR then entry price + S long risk * S TP1 RR; else if highest high since entry >= entry price + S long risk * S TP1 RR then entry price; else entry price - S long risk
Calculation: S short stop = entry price + S short risk if staircase stop is off for S; otherwise, if lowest low since entry <= entry price - S short risk * S TP3 RR then entry price - S short risk * S TP2 RR; else if lowest low since entry <= entry price - S short risk * S TP2 RR then entry price - S short risk * S TP1 RR; else if lowest low since entry <= entry price - S short risk * S TP1 RR then entry price; else entry price + S short risk
Long: S trade window AND close crosses above S ORB high + S buffer AND S enabled AND weekday of bar is enabled for S AND S direction allows long AND bar not in flat window AND position side is flat AND (EMA filter off for S OR close > EMA(close, EMA length, T1, last completed bar))
Short: S trade window AND close crosses below S ORB low - S buffer AND S enabled AND weekday of bar is enabled for S AND S direction allows short AND bar not in flat window AND position side is flat AND (EMA filter off for S OR close < EMA(close, EMA length, T1, last completed bar))
Exit: long, S trade window AND low <= S long stop
Exit: long, S trade window AND high >= entry price + S long risk * S TP1 RR
Exit: long, S trade window AND high >= entry price + S long risk * S TP2 RR
Exit: long, S trade window AND high >= entry price + S long risk * S TP3 RR
Exit: short, S trade window AND high >= S short stop
Exit: short, S trade window AND low <= entry price - S short risk * S TP1 RR
Exit: short, S trade window AND low <= entry price - S short risk * S TP2 RR
Exit: short, S trade window AND low <= entry price - S short risk * S TP3 RR
Exit: long, bar in flat window
Exit: short, bar in flat window
Exit: long, bar outside trade window of every session
Exit: short, bar outside trade window of every session