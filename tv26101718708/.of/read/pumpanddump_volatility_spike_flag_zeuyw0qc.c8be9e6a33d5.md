Calculation: Spike = (true range incl. gaps / ATR) >= range multiple AND (volume / SMA of volume) >= volume multiple AND bars since the previous accepted Spike >= cooldown; evaluated on completed bars only
Calculation: PumpSpike = Spike AND close > open; DumpSpike = Spike AND close < open
Calculation: PumpFaded = on a completed bar 1 or more bars after a PumpSpike, and no more than a fade-window number of bars after it, close < that PumpSpike's open; each spike fires at most once (first qualifying bar) and is dropped once faded or once the window expires; only the most recent few spikes are tracked (oldest dropped first)
Calculation: DumpFaded = same as PumpFaded but for a DumpSpike, with close > that DumpSpike's open
Long: PumpSpike OR DumpFaded
Short: DumpSpike OR PumpFaded