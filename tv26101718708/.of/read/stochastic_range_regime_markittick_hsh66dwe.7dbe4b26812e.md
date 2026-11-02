Calculation: Smoothed stochastic = SMA of 100 × (selected price source − lowest low) / (highest high − lowest low) over a stochastic lookback, optionally followed by an EMA, WMA, or RMA; undefined when the highest high equals the lowest low.
Calculation: Bullish regime = selected trend price source > its SMA AND smoothed stochastic >= the lower bullish range bound AND smoothed stochastic <= the upper bullish range bound on at least the required number of consecutive bars; sort the two bullish bounds before comparison.
Calculation: Bearish regime = selected trend price source < its SMA AND smoothed stochastic >= the lower bearish range bound AND smoothed stochastic <= the upper bearish range bound on at least the required number of consecutive bars; sort the two bearish bounds before comparison.
Calculation: Long signal = bullish regime on the closed chart bar AND bullish regime was absent on the preceding chart bar AND (higher-timeframe confirmation is disabled OR bullish regime on the last completed higher-timeframe bar) AND (ADX filter is disabled OR ADX >= its threshold) AND ATR × stop multiplier > minimum price increment AND close − ATR × stop multiplier > 0.
Calculation: Short signal = bearish regime on the closed chart bar AND bearish regime was absent on the preceding chart bar AND (higher-timeframe confirmation is disabled OR bearish regime on the last completed higher-timeframe bar) AND (ADX filter is disabled OR ADX >= its threshold) AND ATR × stop multiplier > minimum price increment AND close − ATR × farthest target multiplier > 0.
Calculation: Trade levels = entry price plus or minus ATR at entry multiplied by the stop multiplier or by each of three target multipliers, sorted from nearest to farthest; the stop is below a long entry and above a short entry, and targets are on the opposite side of entry.
Long: bullish regime is present.
Long: long signal is present.
Short: bearish regime is present.
Short: short signal is present.
Exit: long, a bar after entry has high >= a target level AND that target has not previously been hit; the nearest and middle targets are partial exits and the farthest target is a full exit.
Exit: short, a bar after entry has low <= a target level AND that target has not previously been hit; the nearest and middle targets are partial exits and the farthest target is a full exit.
Exit: long, a bar after entry closes < the stop level AND the farthest target has not been hit on that bar.
Exit: short, a bar after entry closes > the stop level AND the farthest target has not been hit on that bar.
Exit: long, long signal is present OR short signal is present.
Exit: short, long signal is present OR short signal is present.