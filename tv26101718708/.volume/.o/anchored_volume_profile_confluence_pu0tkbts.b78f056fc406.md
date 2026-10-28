Calculation: Anchored POC = midpoint of the price bin with the greatest volume in the volume profile accumulated since the selected anchor; distribute each bar’s volume equally across bins spanning its low to high.
Calculation: Fast value = midpoint of the decayed profile’s value area (or its POC if configured for raw POC); decay prior bin volumes exponentially by the configured half-life, add the current bar’s volume using the same binning, and calculate the POC and value area from the resulting profile.
Long: Fast value crosses above Anchored POC
Short: Fast value crosses below Anchored POC