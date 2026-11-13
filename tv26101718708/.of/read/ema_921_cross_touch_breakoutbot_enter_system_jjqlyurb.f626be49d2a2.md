Calculation: Cross-up = fast EMA(close) crosses above slow EMA(close) (fast has the shorter period); Cross-down = fast EMA crosses below slow EMA. Each cross starts a new setup for that side and discards any earlier setup. Setups are evaluated on the chart timeframe only.
Calculation: Touch bar = first bar, from the cross bar onward, with low <= fast EMA AND high >= fast EMA; TouchHigh and TouchLow are that bar's high and low.
Calculation: SwingHigh = highest high of the N bars before the cross bar (cross bar excluded), frozen at the cross bar; SwingLow = lowest low of the N bars before the cross bar (cross bar excluded), frozen at the cross bar.
Long: Cross-up
Long: long setup has a Touch bar AND on a bar after the Touch bar, high > TouchHigh (BOT; first occurrence per setup)
Long: long setup has had BOT AND on the BOT bar or later, close > SwingHigh (ENTER; at most once per setup)
Short: Cross-down
Short: short setup has a Touch bar AND on a bar after the Touch bar, low < TouchLow (BOT; first occurrence per setup)
Short: short setup has had BOT AND on the BOT bar or later, close < SwingLow (ENTER; at most once per setup)