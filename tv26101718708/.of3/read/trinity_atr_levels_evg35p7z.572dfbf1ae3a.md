Calculation: RefClose = close on T1 bars of the level session, last completed bar
Calculation: UpperLevel(s) = RefClose + s * ATR(ATR length) on T1 bars of the level session, last completed bar
Calculation: LowerLevel(s) = RefClose - s * ATR(ATR length) on T1 bars of the level session, last completed bar
Calculation: T2Close(n) = close on T2 bars, n completed bars back
Calculation: SignalBar = (timeframe restriction is off OR chart timeframe is T0) AND bar is in signal session window
Calculation: PriorClose = close of previous signal-session bar if gap-safe is on, otherwise close[1]
Calculation: LongGateReached = a close >= UpperLevel(gate-open share) has occurred since the last long trigger entry
Calculation: ShortGateReached = a close <= LowerLevel(gate-open share) has occurred since the last short trigger entry
Calculation: LongTriggerPullback = SignalBar AND position side is long AND LongGateReached AND low <= UpperLevel(trigger share) AND close > UpperLevel(trigger share)
Calculation: ShortTriggerPullback = SignalBar AND position side is short AND ShortGateReached AND high >= LowerLevel(trigger share) AND close < LowerLevel(trigger share)
Calculation: LongEMAPullback = SignalBar AND chart timeframe is at most T2 AND position side is long AND LongGateReached AND close <= UpperLevel(gate-target share) AND low <= EMA(close, EMA length) on T2 bars, last completed bar AND close > EMA(close, EMA length) on T2 bars, last completed bar
Calculation: ShortEMAPullback = SignalBar AND chart timeframe is at most T2 AND position side is short AND ShortGateReached AND close >= LowerLevel(gate-target share) AND high >= EMA(close, EMA length) on T2 bars, last completed bar AND close < EMA(close, EMA length) on T2 bars, last completed bar
Long: SignalBar AND close > UpperLevel(trigger share + entry buffer share) AND PriorClose <= UpperLevel(trigger share + entry buffer share) AND position side is not long AND (max entries is zero OR long trigger entries this session < max entries) AND (no long exit this session OR signal bars since last long exit >= cooldown bars)
Long: SignalBar AND position side is long AND close >= UpperLevel(gate-open share) AND close[1] < UpperLevel(gate-open share)
Long: LongTriggerPullback AND (debounce is off OR LongTriggerPullback[1] is false), where gate-open share > trigger share
Long: LongEMAPullback AND (debounce is off OR LongEMAPullback[1] is false), where gate-target share > gate-open share
Long: chart timeframe is at most T2 AND chart bar opens a new T2 bar AND bar is within first-hour length of signal session start AND T2Close(1) > RefClose AND T2Close(2) <= RefClose AND T2Close(2) >= LowerLevel(trigger share)
Short: SignalBar AND close < LowerLevel(trigger share + entry buffer share) AND PriorClose >= LowerLevel(trigger share + entry buffer share) AND position side is not short AND (max entries is zero OR short trigger entries this session < max entries) AND (no short exit this session OR signal bars since last short exit >= cooldown bars)
Short: SignalBar AND position side is short AND close <= LowerLevel(gate-open share) AND close[1] > LowerLevel(gate-open share)
Short: ShortTriggerPullback AND (debounce is off OR ShortTriggerPullback[1] is false), where gate-open share > trigger share
Short: ShortEMAPullback AND (debounce is off OR ShortEMAPullback[1] is false), where gate-target share > gate-open share
Short: chart timeframe is at most T2 AND chart bar opens a new T2 bar AND bar is within first-hour length of signal session start AND T2Close(1) < RefClose AND T2Close(2) >= RefClose AND T2Close(2) <= UpperLevel(trigger share)
Exit: long, SignalBar AND close < UpperLevel(trigger share)
Exit: short, SignalBar AND close > LowerLevel(trigger share)