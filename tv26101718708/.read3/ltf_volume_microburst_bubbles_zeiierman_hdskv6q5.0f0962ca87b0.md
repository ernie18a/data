Calculation: VolumeRatio_j = volume_j / EMA(volume, baseline lookback, T1 bars up to j) if no session window is enabled; otherwise the maximum over enabled session windows w containing T1 bar j of volume_j / EMA(volume, baseline lookback, T1 bars inside w up to j), or 0 if no enabled window contains j
Calculation: BodyEfficiency_j = (close_j - open_j) / (high_j - low_j), or 0 if high_j = low_j
Calculation: SpikeFlag_j = VolumeRatio_j >= spike threshold AND abs(BodyEfficiency_j) >= minimum body efficiency
Calculation: SpikeEnergy_j = if SpikeFlag_j then (energy offset + max(VolumeRatio_j - spike threshold, 0)) * abs(BodyEfficiency_j), else 0
Calculation: SpikeCount = number of T1 bars j in the current chart bar, including the forming T1 bar, with SpikeFlag_j
Calculation: EnergyTotal = sum of SpikeEnergy_j over T1 bars j in the current chart bar, including the forming T1 bar
Calculation: EnergySquareTotal = sum of SpikeEnergy_j^2 over T1 bars j in the current chart bar, including the forming T1 bar
Calculation: DirectionBias = (sum of sign(BodyEfficiency_j) * SpikeEnergy_j over T1 bars j in the current chart bar, including the forming T1 bar) / EnergyTotal, or 0 if EnergyTotal = 0
Calculation: ConcentrationIndex = 1 if SpikeCount = 1; 0 if EnergyTotal = 0; otherwise (EnergySquareTotal / EnergyTotal^2 - 1 / SpikeCount) / (1 - 1 / SpikeCount)
Calculation: BurstScore = DirectionBias * sqrt((1 - exp(-EnergyTotal / saturation constant)) * ((1 - concentration weight) + concentration weight * ConcentrationIndex))
Long: BurstScore > 0
Long: BurstScore >= signal threshold
Short: BurstScore < 0
Short: BurstScore <= -signal threshold