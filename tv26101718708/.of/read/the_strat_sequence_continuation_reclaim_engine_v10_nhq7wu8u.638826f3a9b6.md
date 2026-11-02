Calculation: Up bar = high > previous high AND low >= previous low; down bar = low < previous low AND high <= previous high; outside bar = high > previous high AND low < previous low.
Calculation: Regime return = 100 × (source / source from the regime lookback bars ago − 1), where source is a selected price derived from the input fields.
Calculation: Regime thresholds = either selected fixed bull and bear thresholds, or a symmetric positive and negative threshold equal to the standard deviation of one-bar percentage source returns over the volatility lookback × square root of the regime lookback × a multiplier, clamped between selected minimum and maximum thresholds.
Calculation: Regime = bull if regime return >= bull threshold; otherwise bear if regime return <= bear threshold; otherwise sideways.
Calculation: Transition matrix = proportions of consecutive historical regime transitions over the transition lookback, classifying all historical returns with the current bar's regime thresholds; each row is normalized by its source-regime transition count. A row with no observations is undefined.
Calculation: Horizon probabilities = the current regime's one-hot vector multiplied by the transition matrix repeatedly for each selected horizon; use a one-bar horizon and two longer, increasing horizons. A probability involving an undefined matrix row is undefined.
Calculation: Horizon edge = bull probability − bear probability at that horizon; average edge = mean of the edges at the three horizons. Sample count = transition count from the current regime.
Long: Up bar OR (down bar AND close > open).
Short: Down bar OR (up bar AND close < open).
Long: Previous bar is a down bar with close > open AND close > previous high.
Long: Previous bar is an up bar AND close > previous high.
Long: Previous bar is an outside bar AND high > previous high AND close > previous high.
Short: Previous bar is an up bar with close < open AND close < previous low.
Short: Previous bar is a down bar AND close < previous low.
Short: Previous bar is an outside bar AND low < previous low AND close < previous low.
Long: Regime return >= bull threshold.
Short: Regime return < bull threshold AND regime return <= bear threshold.
Long: One-bar bull probability >= one-bar sideways probability AND one-bar bull probability >= one-bar bear probability.
Short: One-bar bull probability < one-bar sideways probability OR one-bar bull probability < one-bar bear probability, AND one-bar bear probability >= one-bar bull probability AND one-bar bear probability >= one-bar sideways probability.
Long: One-bar horizon edge > 0.
Short: One-bar horizon edge < 0.
Long: Average edge >= strong threshold AND (sample count = 0 OR sample count >= minimum sample count).
Long: Average edge > weak threshold AND average edge < strong threshold AND (sample count = 0 OR sample count >= minimum sample count).
Short: Average edge <= negative strong threshold AND average edge <= weak threshold AND average edge < strong threshold AND (sample count = 0 OR sample count >= minimum sample count).
Short: Average edge < negative weak threshold AND average edge > negative strong threshold AND average edge <= weak threshold AND average edge < strong threshold AND (sample count = 0 OR sample count >= minimum sample count).
Long: Longest-horizon edge − one-bar edge >= momentum threshold.
Long: One-bar edge − longest-horizon edge >= momentum threshold AND one-bar edge > 0.
Short: One-bar edge − longest-horizon edge >= momentum threshold AND one-bar edge <= 0.