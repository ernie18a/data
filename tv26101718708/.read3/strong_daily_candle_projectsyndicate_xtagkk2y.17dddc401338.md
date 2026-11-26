Calculation: CandleDirection = sign(close - open)
Calculation: TradeDirection = mode sign * CandleDirection
Calculation: BodySize = abs(close - open)
Calculation: RangeToATR = (high - low) / ATR(high, low, close, ATR length)
Calculation: OppositeWick = high - max(open, close) if CandleDirection > 0, else min(open, close) - low
Calculation: DailyStrength = min(score ceiling, BodyScore + CloseScore + RangeScore + OppositeWickScore + VolumeScore), where each score is the highest band points among its bands whose threshold its measure meets, else its floor points; BodyScore measure = BodySize / (high - low) against >= thresholds; CloseScore measure = (close - low if CandleDirection > 0, else high - close) / (high - low) against >= thresholds; RangeScore measure = RangeToATR against >= thresholds; OppositeWickScore measure = OppositeWick / BodySize against <= thresholds; VolumeScore measure = volume / SMA(volume, volume average length) against >= thresholds
Calculation: StopPrice = low - stop buffer for a long position, or high + stop buffer for a short position, using the bar where that position's decision fired
Calculation: StopDistance = abs(entry price - StopPrice)
Long: TradeDirection(T1, last completed bar) > 0 AND DailyStrength(T1, last completed bar) >= strength gate AND DailyStrength(T1, last completed bar) >= minimum tier score AND RangeToATR(T1, last completed bar) >= minimum range multiple AND (NOT rejection filter flag OR OppositeWick(T1, last completed bar) <= BodySize(T1, last completed bar)) AND (NOT EMA filter flag OR sign(close - EMA(close, EMA length, T1, last completed bar)) = CandleDirection(T1, last completed bar))
Long: TradeDirection(T1, forming bar) > 0 AND DailyStrength(T1, forming bar) >= strength gate AND DailyStrength(T1, forming bar) >= minimum tier score AND RangeToATR(T1, forming bar) >= minimum range multiple AND (NOT rejection filter flag OR OppositeWick(T1, forming bar) <= BodySize(T1, forming bar)) AND (NOT EMA filter flag OR sign(close - EMA(close, EMA length, T1, forming bar)) = CandleDirection(T1, forming bar))
Short: TradeDirection(T1, last completed bar) < 0 AND DailyStrength(T1, last completed bar) >= strength gate AND DailyStrength(T1, last completed bar) >= minimum tier score AND RangeToATR(T1, last completed bar) >= minimum range multiple AND (NOT rejection filter flag OR OppositeWick(T1, last completed bar) <= BodySize(T1, last completed bar)) AND (NOT EMA filter flag OR sign(close - EMA(close, EMA length, T1, last completed bar)) = CandleDirection(T1, last completed bar))
Short: TradeDirection(T1, forming bar) < 0 AND DailyStrength(T1, forming bar) >= strength gate AND DailyStrength(T1, forming bar) >= minimum tier score AND RangeToATR(T1, forming bar) >= minimum range multiple AND (NOT rejection filter flag OR OppositeWick(T1, forming bar) <= BodySize(T1, forming bar)) AND (NOT EMA filter flag OR sign(close - EMA(close, EMA length, T1, forming bar)) = CandleDirection(T1, forming bar))
Exit: long, low <= StopPrice
Exit: long, high >= entry price + TP1 multiple * StopDistance
Exit: long, high >= entry price + TP3 multiple * StopDistance
Exit: short, high >= StopPrice
Exit: short, low <= entry price - TP1 multiple * StopDistance
Exit: short, low <= entry price - TP3 multiple * StopDistance