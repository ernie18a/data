Calculation: BullishVolumeShare = SUM(volume where close > open) / SUM(volume), both summed from the first bar of the most recent enabled session start through the current bar, counting only bars inside an enabled session
Calculation: PlotWindow = no session is enabled OR bar is inside an enabled session
Long: bar is inside an enabled session AND BullishVolumeShare > neutral share
Short: bar is inside an enabled session AND BullishVolumeShare < neutral share
Long: PlotWindow AND close > open
Short: PlotWindow AND close <= open