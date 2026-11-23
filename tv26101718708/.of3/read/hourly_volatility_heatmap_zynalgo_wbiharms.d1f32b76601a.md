Calculation: Slot(bar) = index of the T2 bar containing the bar within its T1 bar, in the time zone
Calculation: SlotRange(s) = average of (High - Low) over chart bars with Slot s, over the last lookback completed T1 bars
Calculation: SlotReversal(s) = 100 * (number of last lookback completed T1 bars whose high was set in slot s + number of last lookback completed T1 bars whose low was set in slot s) / (2 * number of those T1 bars)
Calculation: SlotHotScore(s) = (100 * SlotRange(s) / max of SlotRange over all slots + 100 * SlotReversal(s) / max of SlotReversal over all slots) / 2
Calculation: SlotHotRank(s) = rank of SlotHotScore(s) among all slots, descending, 1 = highest
Calculation: SlotBullBias(s) = 100 * (number of T2 bars with Slot s and Close > Open) / (number of T2 bars with Slot s and Close != Open), over the last lookback completed T1 bars
Calculation: SweepLowAge = number of bars back to the bar with the lowest Low among the last swing length bars before the current bar
Calculation: SweepHighAge = number of bars back to the bar with the highest High among the last swing length bars before the current bar
Long: SlotHotRank(Slot(current bar)) <= hot-slot count AND Low <= Lowest(Low, swing length)[1] AND Close > Open AND SlotBullBias(Slot(current bar)) >= bias threshold AND RSI(Close, RSI length) > RSI(Close, RSI length)[SweepLowAge]
Short: SlotHotRank(Slot(current bar)) <= hot-slot count AND High >= Highest(High, swing length)[1] AND Close < Open AND SlotBullBias(Slot(current bar)) <= bias threshold AND RSI(Close, RSI length) < RSI(Close, RSI length)[SweepHighAge]