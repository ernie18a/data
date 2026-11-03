Calculation: Timeframe bar = a bar aggregated at each configured higher or lower timeframe relative to the chart; use its still-forming close and the last completed bar's open, high, low, close, and volume.
Calculation: Session statistics = for each configured UTC session, collect chart bars whose opening times fall inside the session; reset at each exchange-timezone day boundary. The session open is the first collected open, session close is the most recent collected close, session high and low are the extrema of all collected bars, and average session volume is total volume divided by bar count. Include the current chart bar when it belongs to the session.
Calculation: Confirmed pivot = a chart-bar high or low identified as a pivot using equal numbers of preceding and subsequent bars; evaluate it on the bar that confirms it.
Long: A timeframe bar's still-forming close > its last completed high.
Short: A timeframe bar's still-forming close < its last completed low.
Long: A timeframe bar's still-forming close > its last completed close multiplied by an upper momentum threshold.
Short: A timeframe bar's still-forming close < its last completed close multiplied by a lower momentum threshold.
Long: A timeframe bar's last completed close > its last completed open multiplied by an upper direction threshold.
Short: A timeframe bar's last completed close < its last completed open multiplied by a lower direction threshold.
Long: A timeframe bar's last completed close > its last completed open multiplied by the upper direction threshold AND its last completed volume > a multiple of the chart-bar simple moving average of the still-forming volume of a configured higher or lower benchmark timeframe.
Short: A timeframe bar's last completed close < its last completed open multiplied by the lower direction threshold AND its last completed volume > a multiple of the chart-bar simple moving average of the still-forming volume of a configured higher or lower benchmark timeframe.
Long: A confirmed pivot high exists AND a confirmed pivot low exists on the same chart bar.
Short: A confirmed pivot high exists AND a confirmed pivot low does not exist on the same chart bar.
Long: close > previous close AND (close - previous close) / (ATR + a small positive constant) > an impulse threshold.
Short: close < previous close AND (previous close - close) / (ATR + a small positive constant) > an impulse threshold.
Long: A session has at least one collected bar AND close > session high.
Short: A session has at least one collected bar AND close < session low.
Long: A session has at least one collected bar AND session close > session open.
Short: A session has at least one collected bar AND session close < session open.
Long: A session has at least one collected bar AND session close > session open AND average session volume > the chart-bar simple moving average of volume.
Short: A session has at least one collected bar AND session close < session open AND average session volume > the chart-bar simple moving average of volume.