Calculation: Bar delta = buy volume − sell volume; classify each lower-timeframe bar within the current chart bar as buy volume if its close is above its open, sell volume if below, and split volume equally if unchanged. If no lower-timeframe data is available, apply the same classification to the chart bar.
Calculation: Cumulative volume delta = running sum of bar delta, reset at the selected session, day, or week boundary, or never reset, according to the selected anchor.
Long: At a confirmed price pivot low, the low is below the previous confirmed pivot low AND cumulative volume delta at this pivot is above cumulative volume delta at the previous pivot low.
Short: At a confirmed price pivot high, the high is above the previous confirmed pivot high AND cumulative volume delta at this pivot is below cumulative volume delta at the previous pivot high.
Long: Bar delta / volume > the selected imbalance threshold.
Short: Bar delta / volume < − the selected imbalance threshold.
Long: The selected number of consecutive chart bars each has bar delta / volume above the selected imbalance threshold.
Short: The selected number of consecutive chart bars each has bar delta / volume below − the selected imbalance threshold.
Long: Volume > average volume × selected multiplier AND high − low < ATR × selected multiplier AND the low is within one ATR of the latest confirmed swing low.
Short: Volume > average volume × selected multiplier AND high − low < ATR × selected multiplier AND the high is within one ATR of the latest confirmed swing high.
Long: A confirmed pivot low has positive bar delta.
Short: A confirmed pivot high has negative bar delta.