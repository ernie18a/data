Calculation: IB = high/low range of the opening window of a trading session; IBH = highest high in the window, IBL = lowest low in the window, R = IBH - IBL; use the latest completed session's IB, valid only after the window has closed
Calculation: HTF level(k) = HTF high - k * (HTF high - HTF low), where HTF high/low are the highest high/lowest low over a lookback of bars of a timeframe higher than the chart, taken from the last completed higher-timeframe bar; HTF50 = HTF level(0.5); pivot levels = HTF level(0.382), HTF level(0.5), HTF level(0.618)
Calculation: LongZone = price band between IBH - 0.5R and IBH - 0.618R; ShortZone = price band between IBL + 0.5R and IBL + 0.618R
Calculation: ExtUp(n) = IBH + n*R; ExtDown(n) = IBL - n*R
Long: (close > HTF50 AND price has traded above IBH since the IB completed AND a pivot level lies inside LongZone AND low <= that pivot level, i.e. price pulls back to the confluence of LongZone and the pivot level) OR (failed IB: price has traded below IBL since the IB completed, its lowest low since then has not reached ExtDown(0.618), and close is back above IBL inside the box)
Short: (close < HTF50 AND price has traded below IBL since the IB completed AND a pivot level lies inside ShortZone AND high >= that pivot level, i.e. price pulls back to the confluence of ShortZone and the pivot level) OR (failed IB: price has traded above IBH since the IB completed, its highest high since then has not reached ExtUp(0.618), and close is back below IBH inside the box)
Exit: long, low < IBL - small fixed buffer (stop loss)
Exit: long, high has reached ExtUp(0.618) since entry AND price <= entry price (breakeven stop)
Exit: long, high >= ExtUp(1.272) (close the majority of the position)
Exit: long, high >= ExtUp(1.618) (close the remainder)
Exit: long entered via failed IB, high >= IBH (opposite side of the box)
Exit: short, high > IBH + small fixed buffer (stop loss)
Exit: short, low has reached ExtDown(0.618) since entry AND price >= entry price (breakeven stop)
Exit: short, low <= ExtDown(1.272) (close the majority of the position)
Exit: short, low <= ExtDown(1.618) (close the remainder)
Exit: short entered via failed IB, low <= IBL (opposite side of the box)