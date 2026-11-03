Calculation: Smart Money Index = previous Smart Money Index − (current open − current close) + (open − close) of the last completed higher-timeframe bar; initialize to 1
Long: (SMA(Smart Money Index) > Smart Money Index AND reverse = false) OR (Smart Money Index > SMA(Smart Money Index) AND reverse = true)
Short: (Smart Money Index > SMA(Smart Money Index) AND reverse = false) OR (SMA(Smart Money Index) > Smart Money Index AND reverse = true)
Exit: Long, (Smart Money Index > SMA(Smart Money Index) AND reverse = false) OR (SMA(Smart Money Index) > Smart Money Index AND reverse = true)
Exit: Short, (SMA(Smart Money Index) > Smart Money Index AND reverse = false) OR (Smart Money Index > SMA(Smart Money Index) AND reverse = true)