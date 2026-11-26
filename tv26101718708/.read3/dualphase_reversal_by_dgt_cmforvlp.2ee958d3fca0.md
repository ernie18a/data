Calculation: BuyCount = if close < close[lookback] then (if BuyCount[1] is 0 or phase length then (1 if close[1] > close[lookback+1] else 0) else BuyCount[1] + 1) else 0
Calculation: SellCount = if close > close[lookback] then (if SellCount[1] is 0 or phase length then (1 if close[1] < close[lookback+1] else 0) else SellCount[1] + 1) else 0
Calculation: BuyLowest = if BuyCount == 1 then low else if BuyCount > 0 then min(low, BuyLowest[1]) else BuyLowest[1]
Calculation: BuyHighAtLow = if BuyCount > 0 AND low == BuyLowest then high else BuyHighAtLow[1]
Calculation: BuyStop = if BuyCount == phase length then 2 * BuyLowest - BuyHighAtLow else if close < BuyStop[1] then 0 else BuyStop[1]
Calculation: BuyRes = if BuyCount == phase length then Highest(high, window) else if close > BuyRes[1] then 0 else BuyRes[1]
Calculation: SellHighest = if SellCount == 1 then high else if SellCount > 0 then max(high, SellHighest[1]) else SellHighest[1]
Calculation: SellLowAtHigh = if SellCount > 0 AND high == SellHighest then low else SellLowAtHigh[1]
Calculation: SellStop = if SellCount == phase length then 2 * SellHighest - SellLowAtHigh else if close > SellStop[1] then 0 else SellStop[1]
Calculation: SellSup = if SellCount == phase length then Lowest(low, window) else if close < SellSup[1] then 0 else SellSup[1]
Calculation: TBuyStart = if BuyCount == phase length AND TBuyCount[1] == 0 then true else if SellCount == phase length OR TBuyCount[1] == terminal length OR close > BuyRes then false else TBuyStart[1]
Calculation: TBuyRef = if TBuyCount == reference step AND TBuyCount != TBuyCount[1] then close else TBuyRef[1]
Calculation: TBuyFail = close <= low[terminal lag] AND low >= TBuyRef[1]
Calculation: TBuyCount = X - 1 if X == terminal length AND TBuyFail, else X, where X = if TBuyStart then (if BuyCount == phase length then (1 if close <= low[terminal lag] else 0) else (TBuyCount[1] + 1 if close <= low[terminal lag] else TBuyCount[1])) else 0
Calculation: TBuyHighest = if TBuyCount == 1 then high else if TBuyStart then max(high, TBuyHighest[1]) else TBuyHighest[1]
Calculation: TBuyLowest = if TBuyCount == 1 then low else if TBuyStart then min(low, TBuyLowest[1]) else TBuyLowest[1]
Calculation: TBuyLowAtHigh = if TBuyStart AND high == TBuyHighest then low else TBuyLowAtHigh[1]
Calculation: TBuyHighAtLow = if TBuyStart AND low == TBuyLowest then high else TBuyHighAtLow[1]
Calculation: TBuyTarget = if TBuyCount == terminal length then 2 * TBuyHighest - TBuyLowAtHigh else if close > TBuyTarget[1] OR (TBuyStop[1] == 0 AND TSellCount[1] == terminal length) then 0 else TBuyTarget[1]
Calculation: TBuyStop = if TBuyCount == terminal length then 2 * TBuyLowest - TBuyHighAtLow else if close < TBuyStop[1] OR (TBuyTarget == 0 AND TSellCount[1] == terminal length) then 0 else TBuyStop[1]
Calculation: TSellStart = if SellCount == phase length AND TSellCount[1] == 0 then true else if BuyCount == phase length OR TSellCount[1] == terminal length OR close < SellSup then false else TSellStart[1]
Calculation: TSellRef = if TSellCount == reference step AND TSellCount != TSellCount[1] then close else TSellRef[1]
Calculation: TSellFail = close >= high[terminal lag] AND high <= TSellRef[1]
Calculation: TSellCount = X - 1 if X == terminal length AND TSellFail, else X, where X = if TSellStart then (if SellCount == phase length then (1 if close >= high[terminal lag] else 0) else (TSellCount[1] + 1 if close >= high[terminal lag] else TSellCount[1])) else 0
Calculation: TSellHighest = if TSellCount == 1 then high else if TSellStart then max(high, TSellHighest[1]) else TSellHighest[1]
Calculation: TSellLowest = if TSellCount == 1 then low else if TSellStart then min(low, TSellLowest[1]) else TSellLowest[1]
Calculation: TSellLowAtHigh = if TSellStart AND high == TSellHighest then low else TSellLowAtHigh[1]
Calculation: TSellHighAtLow = if TSellStart AND low == TSellLowest then high else TSellHighAtLow[1]
Calculation: TSellStop = if TSellCount == terminal length then 2 * TSellHighest - TSellLowAtHigh else if close > TSellStop[1] OR (TSellTarget[1] == 0 AND TBuyCount == terminal length) then 0 else TSellStop[1]
Calculation: TSellTarget = if TSellCount == terminal length then 2 * TSellLowest - TSellHighAtLow else if close < TSellTarget[1] OR (TSellStop == 0 AND TBuyCount == terminal length) then 0 else TSellTarget[1]
Long: BuyCount > 0
Long: TBuyCount != TBuyCount[1] AND TBuyCount > 0
Long: TBuyCount == terminal length minus 1 AND TBuyCount == TBuyCount[1] AND TBuyFail
Long: BuyRes strictly between close[1] and close
Short: SellCount > 0
Short: TSellCount != TSellCount[1] AND TSellCount > 0
Short: TSellCount == terminal length minus 1 AND TSellCount == TSellCount[1] AND TSellFail
Short: SellSup strictly between close[1] and close
Exit: long, BuyStop strictly between close[1] and close OR TBuyStop strictly between close[1] and close
Exit: short, SellStop strictly between close[1] and close OR TSellStop strictly between close[1] and close