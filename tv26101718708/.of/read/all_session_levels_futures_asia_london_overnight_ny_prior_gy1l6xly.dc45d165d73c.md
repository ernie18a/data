Calculation: Session high and low = the highest high and lowest low since the start of each configured session, updated during the session and retained until that session next starts.
Calculation: Average range = the simple moving average of high minus low over a configurable lookback, including the current bar.
Calculation: Demand zone = on a bar whose close > open, range > average range multiplied by an impulse parameter, close minus open > half its range, and previous bar's absolute close minus open < current average range multiplied by a base-size parameter, create a zone from the previous low to the greater of the previous open and close.
Calculation: Supply zone = on a bar whose close < open, range > average range multiplied by an impulse parameter, open minus close > half its range, and previous bar's absolute close minus open < current average range multiplied by a base-size parameter, create a zone from the lesser of the previous open and close to the previous high.
Calculation: Active zones = maintain separate demand and supply lists in creation order; after adding a zone, discard the oldest zone on that side if the list exceeds its configurable limit. Then remove every demand zone whose bottom is above the current close and every supply zone whose top is below the current close. The latest active zone is the most recently created remaining zone.
Long: Close crosses above the high of any configured session.
Short: Close crosses below the low of any configured session.
Long: A demand zone is created.
Short: A supply zone is created.
Long: A latest active demand zone exists AND low <= its top AND high >= its bottom.
Short: A latest active supply zone exists AND high >= its bottom AND low <= its top.