Calculation: Prior high and prior low = high and low of the last completed higher-timeframe bar; update at each higher-timeframe boundary.
Calculation: Average range = mean high minus low over a lookback of completed higher-timeframe bars, including the last completed bar.
Calculation: Upper and lower sweep levels = prior high plus, and prior low minus, average range multiplied by the sweep offset. Upper and lower acceptance levels use the same construction with a separate acceptance offset.
Calculation: High-side and low-side states = independently reset to intact at each higher-timeframe boundary. On each chart bar, set the respective state to accepted if close is beyond its acceptance level; otherwise set an accepted state to failed if close returns inside its prior high or low; otherwise set an intact state to swept if its sweep condition occurs. Keep the state unchanged otherwise.
Long: Low-side state was intact AND low <= lower sweep level AND close > prior low AND close >= lower acceptance level.
Long: High-side state was not accepted AND close > upper acceptance level.
Long: Low-side state was accepted AND close > prior low.
Short: High-side state was intact AND high >= upper sweep level AND close < prior high AND close <= upper acceptance level.
Short: Low-side state was not accepted AND close < lower acceptance level.
Short: High-side state was accepted AND close < prior high.
Exit: long, close < lower acceptance level OR high-side state was accepted AND close < prior high.
Exit: short, close > upper acceptance level OR low-side state was accepted AND close > prior low.