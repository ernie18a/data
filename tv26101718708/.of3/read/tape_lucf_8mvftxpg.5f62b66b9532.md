Calculation: BarUp = close > open OR (close = open AND (close > close[1] OR (close = close[1] AND BarUp[1])))
Calculation: DeltaVolume = volume if BarUp, else -volume
Long: DeltaVolume[1] > 0 AND DeltaVolume > DeltaVolume[1] AND (NOT Alternate OR no prior Long or Short decision exists OR the latest prior Long or Short decision was Short)
Long: DeltaVolume > DeltaThreshold AND (NOT Alternate OR no prior Long or Short decision exists OR the latest prior Long or Short decision was Short)
Long: volume > TapeVolumeThreshold AND BarUp AND (NOT Alternate OR no prior Long or Short decision exists OR the latest prior Long or Short decision was Short)
Short: DeltaVolume[1] < 0 AND DeltaVolume < DeltaVolume[1] AND (NOT Alternate OR no prior Long or Short decision exists OR the latest prior Long or Short decision was Long)
Short: DeltaVolume < -DeltaThreshold AND (NOT Alternate OR no prior Long or Short decision exists OR the latest prior Long or Short decision was Long)
Short: volume > TapeVolumeThreshold AND NOT BarUp AND (NOT Alternate OR no prior Long or Short decision exists OR the latest prior Long or Short decision was Long)