Calculation: First chart-timeframe bar of day = the chart bar where the daily bar changes; use its high and low.
Calculation: Long entry level = first-bar high plus an offset.
Calculation: Long stop level = first-bar low minus an offset.
Calculation: Long target level = long entry level plus an offset.
Calculation: Short entry level = first-bar low minus an offset.
Calculation: Short target level = short entry level minus an offset.
Calculation: Short stop level = first-bar high plus an offset.
Long: high crosses above long entry level AND date filtering is disabled OR bar time is within the configured date range.
Long: low crosses below short entry level AND date filtering is disabled OR bar time is within the configured date range.
Exit: Long, high crosses above long target level AND date filtering is disabled OR bar time is within the configured date range.
Exit: Long, low crosses below long stop level AND date filtering is disabled OR bar time is within the configured date range.
Exit: Long, hour is 15 AND minute is greater than 25.
Exit: Long, current bar is outside the configured session (session membership checked using one-minute bars).
Exit: Long, low crosses below short target level AND date filtering is disabled OR bar time is within the configured date range.
Exit: Long, high crosses above short stop level AND date filtering is disabled OR bar time is within the configured date range.