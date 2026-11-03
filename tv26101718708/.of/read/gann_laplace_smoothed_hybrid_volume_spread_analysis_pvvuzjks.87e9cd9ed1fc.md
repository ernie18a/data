Calculation: The exact smoothed price and volume series cannot be reproduced from READ alone: the source imports Fourier and adaptive smoothing functions whose implementations are not provided.
Calculation: Volume-weighted spread = (dynamic-length EMA of close source − dynamic-length EMA of open source) × volume ratio. Each price source is either raw price or the imported Fourier transform. The volume ratio is either volume / previous volume or volume / imported smoothed Fourier volume. The EMA length depends on the Gann position and its changes.
Calculation: Spread average = EMA of volume-weighted spread.
Long: Volume-weighted spread > 0 AND spread average > 0
Short: Volume-weighted spread < 0 AND spread average < 0
Exit: long, volume-weighted spread < 0 AND spread average < 0
Exit: short, volume-weighted spread > 0 AND spread average > 0
Exit: long or short, NOT (volume-weighted spread > 0 AND spread average > 0) AND NOT (volume-weighted spread < 0 AND spread average < 0) AND close-all enabled AND (Gann position = 0 OR Gann-entry filter disabled)