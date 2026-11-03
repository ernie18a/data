Calculation: Opening range = highest high and lowest low of chart bars whose New York local time is within the configured opening window; reset on each new exchange day and freeze after the window ends.
Calculation: Session VWAP = cumulative sum of typical price times volume divided by cumulative volume, reset at each exchange-day boundary.
Calculation: Range filter = opening-range high minus opening-range low <= a configurable multiple of ATR on the higher timeframe, using the last completed higher-timeframe bar when the opening range is first frozen; retain the result for the exchange day.
Calculation: Breakout state = after the opening range is frozen, record the first bar each exchange day with high > opening-range high plus a configured price buffer and the first bar with low < opening-range low minus the buffer; update both records before evaluating entries.
Calculation: Trailing stop = after a confirmed bar reaches entry price plus the trailing distance for a long, or entry price minus the trailing distance for a short, trail the highest subsequent price for a long or lowest subsequent price for a short by the trailing distance rounded to the nearest tick; retain activation state and activation price until the next exchange-day reset.
Long: Close > session VWAP AND VWAP display is enabled.
Short: Close <= session VWAP AND VWAP display is enabled.
Long: First upside breakout bar AND close < session VWAP AND VWAP filter is enabled.
Short: First downside breakout bar AND close > session VWAP AND VWAP filter is enabled.
Long: First upside breakout bar AND no downside breakout has occurred this exchange day AND no entry signal has fired this exchange day AND bar time is within the configured entry window after the opening range AND (range filter is disabled OR range filter passes) AND (VWAP filter is disabled OR close > session VWAP) AND long direction is permitted; submit a buy stop at opening-range high plus buffer.
Short: First downside breakout bar AND no upside breakout has occurred this exchange day AND no entry signal has fired this exchange day AND bar time is within the configured entry window after the opening range AND (range filter is disabled OR range filter passes) AND (VWAP filter is disabled OR close < session VWAP) AND short direction is permitted; submit a sell stop at opening-range low minus buffer.
Exit: long, high >= entry price plus profit-target distance OR low <= entry price minus stop-loss distance.
Exit: short, low <= entry price minus profit-target distance OR high >= entry price plus stop-loss distance.
Exit: long, trailing stop is enabled AND activated AND low <= trailing stop.
Exit: short, trailing stop is enabled AND activated AND high >= trailing stop.
Exit: long, VWAP exit is enabled AND close < session VWAP AND previous close >= previous session VWAP.
Exit: short, VWAP exit is enabled AND close > session VWAP AND previous close <= previous session VWAP.