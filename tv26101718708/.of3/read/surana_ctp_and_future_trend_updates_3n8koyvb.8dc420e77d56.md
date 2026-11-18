Calculation: SignedVolume = close > open ? volume : -volume
Calculation: BlockDelta(k) = SUM(SignedVolume[k×P through (k+1)×P−1 bars ago])
Calculation: ProjectionDelta = AVG(AVG(SignedVolume[i], SignedVolume[i+P], SignedVolume[i+2P]) for i = 0 through P)
Long: BlockDelta(0) > 0
Short: BlockDelta(0) <= 0
Long: BlockDelta(1) > 0
Short: BlockDelta(1) <= 0
Long: BlockDelta(2) > 0
Short: BlockDelta(2) <= 0
Long: ProjectionDelta > 0
Short: ProjectionDelta <= 0