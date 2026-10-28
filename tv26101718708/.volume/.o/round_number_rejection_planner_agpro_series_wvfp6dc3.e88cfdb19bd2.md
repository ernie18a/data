Calculation: Round level = nearest multiple of the selected round-number step; the step may be manual or adapt to price
Calculation: ATR = average true range
Calculation: Round band = round level ± ATR-based band width
Calculation: Bullish rejection = bar intersects round band, closes above round level plus a band-width margin, and lower wick / bar range ≥ a threshold
Calculation: Bearish rejection = bar intersects round band, closes below round level minus a band-width margin, and upper wick / bar range ≥ a threshold
Calculation: Rejection score = 0–100 score combining rejection wick strength, close distance from the level, proximity to the level, recent round-band interactions, relative volume, and round-step-to-ATR fit
Calculation: Failure risk = 0–100 score combining magnet context, a close crossing the round level beyond an ATR-based buffer, low close-distance score, and recent interaction count
Long: current bar is confirmed AND bullish rejection AND rejection score ≥ required score AND failure risk < risk threshold AND previous bar was not ready
Short: current bar is confirmed AND bearish rejection AND rejection score ≥ required score AND failure risk < risk threshold AND previous bar was not ready