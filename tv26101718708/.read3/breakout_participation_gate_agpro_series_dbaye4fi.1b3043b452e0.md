Calculation: Upper Gate = Highest(high[1], gate lookback)
Calculation: Lower Gate = Lowest(low[1], gate lookback)
Calculation: Bar Range = max(high - low, tick size)
Calculation: Safe ATR = max(ATR(atr length) if available else True Range, tick size)
Calculation: Up Break = close > Upper Gate + Safe ATR * break buffer
Calculation: Down Break = close < Lower Gate - Safe ATR * break buffer
Calculation: Relative Volume = volume / SMA(volume, volume length) if SMA(volume, volume length) > 0 else 1
Calculation: Volume Score = clamp(Relative Volume / minimum relative volume * 100, 0, volume score cap)
Calculation: Body Score = clamp(abs(close - open) / Bar Range * 100 / minimum body commitment * 100, 0, body score cap)
Calculation: Close Position = (close - low) / Bar Range * 100
Calculation: Location Score = Close Position for an up break, or 100 - Close Position for a down break
Calculation: Range Score = clamp(Bar Range / Safe ATR * range scale, 0, range score cap)
Calculation: Trend Score = 100 if close is beyond EMA(close, trend length) in the break direction, else trend fail score
Calculation: Gate Quality = clamp(volume weight * Volume Score + body weight * Body Score + location weight * Location Score + range weight * Range Score + trend weight * Trend Score, 0, 100), on a bar where Up Break or Down Break is true
Calculation: Bars Since Break = bars since the most recent bar where Up Break or Down Break is true, 0 on that bar
Calculation: Active Direction = up if Up Break[Bars Since Break], else down
Calculation: Active Gate = Upper Gate[Bars Since Break] if Active Direction is up, else Lower Gate[Bars Since Break]
Calculation: Retest Shelf = Safe ATR[Bars Since Break] * retest shelf width
Calculation: Retest Window = 1 <= Bars Since Break <= retest window length
Calculation: Retest Quality = clamp(retest gate weight * Gate Quality[Bars Since Break] + retest volume weight * Volume Score + retest body weight * Body Score + recency weight * (100 - min(Bars Since Break / retest window length * 100, 100)), 0, 100)
Calculation: Retest Hold Event = Retest Window AND low <= Active Gate + Retest Shelf AND high >= Active Gate - Retest Shelf AND Retest Quality >= minimum retest quality AND (close > Active Gate AND close > open if Active Direction is up, or close < Active Gate AND close < open if down) AND no earlier Retest Hold Event since the later of the most recent break bar and the most recent Fakeout Event
Calculation: Fakeout Event = Retest Window AND (close < Active Gate - Safe ATR * fakeout buffer if Active Direction is up, or close > Active Gate + Safe ATR * fakeout buffer if down) AND no earlier Fakeout Event since the most recent break bar
Calculation: Expansion Event = Retest Window AND (close > Active Gate + Safe ATR * expansion buffer if Active Direction is up, or close < Active Gate - Safe ATR * expansion buffer if down) AND Relative Volume >= expansion volume fraction * minimum relative volume AND no earlier Expansion Event since the most recent break bar
Long: Up Break AND Gate Quality >= gate quality threshold
Long: Retest Hold Event AND Active Direction is up
Long: Expansion Event AND Active Direction is up
Short: Down Break AND Gate Quality >= gate quality threshold
Short: Retest Hold Event AND Active Direction is down
Short: Expansion Event AND Active Direction is down
Exit: long, Fakeout Event AND Active Direction is up
Exit: short, Fakeout Event AND Active Direction is down