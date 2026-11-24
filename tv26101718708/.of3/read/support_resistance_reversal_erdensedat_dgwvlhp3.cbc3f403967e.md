Calculation: Real body = ABS(close - open)
Calculation: Bar range = high - low
Calculation: Lower wick = MIN(open, close) - low
Calculation: Upper wick = high - MAX(open, close)
Calculation: Active pivot low = a pivot low confirmed on bar t by Pivot Low(low, pivot left length, pivot right length), whose pivot bar is pivot right length bars before t, with solid level = low of the pivot bar and dashed level = low of the bar after the pivot bar, or MIN(open, close) of that bar if ABS(low of that bar - solid level) / solid level <= too-close tolerance; it is added on bar t only if low of the bar after the pivot bar >= solid level and ABS(solid level - X) / X > same-level tolerance for both solid and dashed level X of every Active pivot low on bar t-1; it is removed on the first bar from t onward that closes below its solid level
Calculation: Active pivot high = a pivot high confirmed on bar t by Pivot High(high, pivot left length, pivot right length), whose pivot bar is pivot right length bars before t, with solid level = high of the pivot bar and dashed level = high of the bar after the pivot bar, or MAX(open, close) of that bar if ABS(high of that bar - solid level) / solid level <= too-close tolerance; it is added on bar t only if high of the bar after the pivot bar <= solid level and ABS(solid level - X) / X > same-level tolerance for both solid and dashed level X of every Active pivot high on bar t-1; it is removed on the first bar from t onward that closes above its solid level
Calculation: Most recent pivot = the Active pivot low or Active pivot high added most recently
Calculation: Latest pivot low = Most recent pivot if it is an Active pivot low, else none
Calculation: Latest pivot high = Most recent pivot if it is an Active pivot high, else none
Calculation: Nearest pivot low = the Active pivot low other than Latest pivot low whose solid level has the smallest ABS(solid level - close)
Calculation: Nearest pivot high = the Active pivot high other than Latest pivot high whose solid level has the smallest ABS(solid level - close)
Calculation: Range top = the lower of the solid levels of Latest pivot high and Nearest pivot high, over whichever exist
Calculation: Range bottom = the higher of the solid levels of Latest pivot low and Nearest pivot low, over whichever exist
Calculation: Range top cross = close > Range top AND close[1] <= Range top
Calculation: Range bottom cross = close < Range bottom AND close[1] >= Range bottom
Calculation: Range age = bar index - range start bar, where range start bar = this bar if a range restart occurs on this bar, else the latest earlier bar on which Range top cross or Range bottom cross holds while Range age is at least spring minimum bars
Calculation: Pivot age(P) = bar index - pivot bar index of P
Calculation: Low breakout(P) = low < solid level of P AND close > dashed level of P AND close > open
Calculation: Low sweep(P) = low < solid level of P AND close > open AND close <= dashed level of P
Calculation: High breakout(P) = high > solid level of P AND close < dashed level of P AND close < open
Calculation: High sweep(P) = high > solid level of P AND close < open AND close >= dashed level of P
Calculation: Pending long level = dashed level of Nearest pivot low if it has low < solid level AND close > dashed level AND close <= open; else dashed level of Latest pivot low if it satisfies the same; else none
Calculation: Pending short level = dashed level of Nearest pivot high if it has high > solid level AND close < dashed level AND close >= open; else dashed level of Latest pivot high if it satisfies the same; else none
Calculation: Dashed low sweep(P) = low >= solid level of P AND low < dashed level of P AND close >= dashed level of P
Calculation: Dashed high sweep(P) = high <= solid level of P AND high > dashed level of P AND close <= dashed level of P
Calculation: Dashed sweep count(P) = on a bar where Dashed low sweep(P) holds for a pivot low P or Dashed high sweep(P) holds for a pivot high P: 1 with window start = this bar if no window start is set or bar index - window start > triple window; otherwise prior count + 1; where prior count is 0 after a bar on which the triple condition for P holds
Long: Low breakout(Latest pivot low) OR Low breakout(Nearest pivot low)
Long: close > Pending long level[1] AND close > open
Long: Low sweep(Latest pivot low) OR Low sweep(Nearest pivot low)
Long: (Low sweep(Latest pivot low) OR Low sweep(Nearest pivot low)) AND Lower wick >= wick ratio * Real body
Long: (Low breakout(Latest pivot low) AND Pivot age(Latest pivot low) > cold threshold) OR (Low breakout(Nearest pivot low) AND Pivot age(Nearest pivot low) > cold threshold)
Long: for some Active pivot low P, Dashed low sweep(P) AND Dashed sweep count(P) >= triple count AND Real body >= sweep body ratio * Bar range AND close > open
Long: Range top cross AND Range age >= spring minimum bars
Short: High breakout(Latest pivot high) OR High breakout(Nearest pivot high)
Short: close < Pending short level[1] AND close < open
Short: High sweep(Latest pivot high) OR High sweep(Nearest pivot high)
Short: (High sweep(Latest pivot high) OR High sweep(Nearest pivot high)) AND Upper wick >= wick ratio * Real body
Short: (High breakout(Latest pivot high) AND Pivot age(Latest pivot high) > cold threshold) OR (High breakout(Nearest pivot high) AND Pivot age(Nearest pivot high) > cold threshold)
Short: for some Active pivot high P, Dashed high sweep(P) AND Dashed sweep count(P) >= triple count AND Real body >= sweep body ratio * Bar range AND close < open
Short: Range bottom cross AND Range age >= spring minimum bars