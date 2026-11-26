Calculation: Level = zone index j × grid step
Calculation: Zone top = Level + zone half-width
Calculation: Zone bottom = Level − zone half-width
Calculation: Reversal distance = max(grid step × reversal grid fraction, ATR(T1, ATR length, last completed bar) × reversal ATR multiple, zone half-width + minimum price increment)
Calculation: Breakout buffer = ATR(T1, ATR length, last completed bar) × breakout ATR multiple
Calculation: Resolved tests = reversals + breakouts of the zone within the stats window, excluding stalled tests
Calculation: Reversal probability = (support-test reversals + resistance-test reversals) ÷ Resolved tests
Calculation: Support hold rate = support-test reversals ÷ (support-test reversals + downward breakouts)
Calculation: Resistance hold rate = resistance-test reversals ÷ (resistance-test reversals + upward breakouts)
Calculation: Fakeout rate = breakouts that closed back through the zone within their watch window ÷ breakouts whose watch window has ended
Calculation: Breakout follow-through = mean, over breakouts whose watch window has ended, of the largest excursion beyond the zone level within the watch window, in ATR units at the breakout
Calculation: Strength = 10 × Wilson lower bound (confidence z) of the dominant outcome's count ÷ Resolved tests, where the dominant outcome is reversals for a Reversal Zone and breakouts for a Breakout Zone
Calculation: Tier reversal rate = reversals ÷ Resolved tests, summed over all zones in the same tier, where tier is Major if the level index is a multiple of the major period, Mid if a multiple of the mid period, otherwise Minor
Calculation: Edge z-score = (Reversal probability − Tier reversal rate) ÷ sqrt(Tier reversal rate × (1 − Tier reversal rate) ÷ Resolved tests)
Calculation: Reversal Zone = Resolved tests ≥ minimum resolved tests AND Reversal probability ≥ bias threshold
Calculation: Breakout Zone = Resolved tests ≥ minimum resolved tests AND 1 − Reversal probability ≥ bias threshold
Calculation: Full window = T1 history starts no later than the stats window start plus partial-window tolerance
Calculation: Support test start = prior T1 close > Zone top AND T1 low ≤ Zone top AND no earlier test of the zone is still in progress
Calculation: Resistance test start = prior T1 close < Zone bottom AND T1 high ≥ Zone bottom AND no earlier test of the zone is still in progress
Calculation: Support test in progress = Support test start on this T1 bar or on one of the previous test-timeout T1 bars, with no reversal or breakout of that test on an earlier T1 bar
Calculation: Resistance test in progress = Resistance test start on this T1 bar or on one of the previous test-timeout T1 bars, with no reversal or breakout of that test on an earlier T1 bar
Long: Support test in progress AND T1 close ≥ Level + Reversal distance
Short: Resistance test in progress AND T1 close ≤ Level − Reversal distance
Long: Resistance test in progress AND T1 close > Zone top + Breakout buffer
Short: Support test in progress AND T1 close < Zone bottom − Breakout buffer
Long: Support test start AND Support hold rate ≥ high-probability threshold AND (support-test reversals + downward breakouts) ≥ minimum resolved tests
Short: Resistance test start AND Resistance hold rate ≥ high-probability threshold AND (resistance-test reversals + upward breakouts) ≥ minimum resolved tests
Long: Support test in progress AND Reversal Zone AND Full window AND Strength ≥ strength threshold AND |Edge z-score| ≥ confidence z AND Support hold rate ≥ high-probability threshold AND (T1 close ≥ Level + Reversal distance OR (T1 low ≤ Zone top AND T1 close > Zone top))
Short: Resistance test in progress AND Reversal Zone AND Full window AND Strength ≥ strength threshold AND |Edge z-score| ≥ confidence z AND Resistance hold rate ≥ high-probability threshold AND (T1 close ≤ Level − Reversal distance OR (T1 high ≥ Zone bottom AND T1 close < Zone bottom))
Long: Resistance test in progress AND Breakout Zone AND Full window AND Strength ≥ strength threshold AND |Edge z-score| ≥ confidence z AND 1 − Resistance hold rate ≥ high-probability threshold AND Fakeout rate ≤ fakeout threshold AND Breakout follow-through ≥ follow-through threshold AND T1 close > Zone top + Breakout buffer
Short: Support test in progress AND Breakout Zone AND Full window AND Strength ≥ strength threshold AND |Edge z-score| ≥ confidence z AND 1 − Support hold rate ≥ high-probability threshold AND Fakeout rate ≤ fakeout threshold AND Breakout follow-through ≥ follow-through threshold AND T1 close < Zone bottom − Breakout buffer
Exit: long, opening test is support AND T1 low < opening zone bottom
Exit: long, opening test is resistance AND T1 close ≤ opening zone top
Exit: long, opening test is support AND T1 high ≥ opening zone bottom + grid step
Exit: long, opening test is resistance AND T1 high ≥ opening zone bottom + breakout target zone count × grid step
Exit: short, opening test is resistance AND T1 high > opening zone top
Exit: short, opening test is support AND T1 close ≥ opening zone bottom
Exit: short, opening test is resistance AND T1 low ≤ opening zone top − grid step
Exit: short, opening test is support AND T1 low ≤ opening zone top − breakout target zone count × grid step