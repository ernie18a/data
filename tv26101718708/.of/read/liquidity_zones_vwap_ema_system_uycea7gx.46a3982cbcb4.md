Calculation: Anchored VWAP = cumulative sum of typical price times adjusted volume divided by cumulative adjusted volume, reset at the start of each selected session, week, or month; typical price = (high + low + close) / 3, and adjusted volume = volume if volume > 0, otherwise 1.
Long: close > anchored VWAP AND close > short-term close EMA AND close > medium-term close EMA
Short: close <= anchored VWAP AND close <= short-term close EMA AND close <= medium-term close EMA
Long: short-term close EMA crosses above medium-term close EMA
Short: short-term close EMA crosses below medium-term close EMA