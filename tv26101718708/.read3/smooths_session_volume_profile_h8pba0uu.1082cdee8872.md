Calculation: BuyVolume = volume * (close - low) / (high - low)
Calculation: SellVolume = volume - BuyVolume
Calculation: BuyAt(p, bars, s) = sum over bars of BuyVolume * P(p - s/2 <= X <= p + s/2 | low <= X <= high), where X is normal with mean low + (close - low)/2 and standard deviation (high - low) / bell divisor
Calculation: SellAt(p, bars, s) = sum over bars of SellVolume * P(p - s/2 <= X <= p + s/2 | low <= X <= high), where X is normal with mean close + (high - close)/2 and standard deviation (high - low) / bell divisor
Calculation: WinBars = the latest window bar count bars, scanning back from the current bar, with volume > 0 and high >= current close - (view tick count + 0.5) * tick size and low <= current close + (view tick count + 0.5) * tick size
Calculation: ProfBars = the latest profile bar count bars scanning back from the current bar, or under session scaling the bars inside the included session windows (each window's current occurrence while forming, otherwise its last completed occurrence)
Calculation: FrameGrid = the levels current close + j * tick size for j from -view tick count to view tick count
Calculation: ChartGrid = the levels ProfLow + k * step for k from 0 to resolution, where ProfLow and ProfHigh are the lowest low and highest high of ProfBars and step = (ProfHigh - ProfLow) / resolution
Calculation: PointOfControl(bars, grid) = the level p of grid maximizing BuyAt(p, bars, s) + SellAt(p, bars, s), where s is the spacing between adjacent levels of grid
Calculation: BuyImb(p, bars, grid) = BuyAt(p, bars, s) > 0 AND BuyAt(p, bars, s) > imbalance ratio * SellAt(p - s, bars, s), where s is the spacing of grid and p - s is a level of grid
Calculation: SellImb(p, bars, grid) = SellAt(p, bars, s) > 0 AND SellAt(p, bars, s) > imbalance ratio * BuyAt(p + s, bars, s), where s is the spacing of grid and p + s is a level of grid
Calculation: UpImb(bars, grid) = the lowest level of grid above PointOfControl(bars, grid) for which BuyImb or SellImb holds
Calculation: DnImb(bars, grid) = the highest level of grid below PointOfControl(bars, grid) for which BuyImb or SellImb holds
Calculation: OverlappingCoefficient(ProfBars) = sum over levels p of ChartGrid of min(BuyAt(p, ProfBars, step) / sum of BuyVolume over ProfBars, SellAt(p, ProfBars, step) / sum of SellVolume over ProfBars)
Calculation: Tilt(ProfBars) = 100 * (sum of BuyVolume over ProfBars - sum of SellVolume over ProfBars) / (sum of BuyVolume over ProfBars + sum of SellVolume over ProfBars)
Long: volume > 0 AND BuyVolume >= SellVolume
Short: BuyVolume < SellVolume
Long: close >= close[1]
Short: close < close[1]
Long: close >= open
Short: close < open
Long: sum of (BuyVolume - SellVolume) over WinBars >= 0
Short: sum of (BuyVolume - SellVolume) over WinBars < 0
Long: BuyAt(PointOfControl(WinBars, FrameGrid), WinBars, tick size) > SellAt(PointOfControl(WinBars, FrameGrid), WinBars, tick size)
Short: SellAt(PointOfControl(WinBars, FrameGrid), WinBars, tick size) > BuyAt(PointOfControl(WinBars, FrameGrid), WinBars, tick size)
Long: BuyImb(UpImb(WinBars, FrameGrid), WinBars, FrameGrid)
Short: SellImb(UpImb(WinBars, FrameGrid), WinBars, FrameGrid) AND NOT BuyImb(UpImb(WinBars, FrameGrid), WinBars, FrameGrid)
Long: BuyImb(DnImb(WinBars, FrameGrid), WinBars, FrameGrid)
Short: SellImb(DnImb(WinBars, FrameGrid), WinBars, FrameGrid) AND NOT BuyImb(DnImb(WinBars, FrameGrid), WinBars, FrameGrid)
Long: BuyAt(PointOfControl(ProfBars, ChartGrid), ProfBars, tick size) > SellAt(PointOfControl(ProfBars, ChartGrid), ProfBars, tick size)
Short: SellAt(PointOfControl(ProfBars, ChartGrid), ProfBars, tick size) > BuyAt(PointOfControl(ProfBars, ChartGrid), ProfBars, tick size)
Long: BuyImb(UpImb(ProfBars, ChartGrid), ProfBars, ChartGrid)
Short: SellImb(UpImb(ProfBars, ChartGrid), ProfBars, ChartGrid) AND NOT BuyImb(UpImb(ProfBars, ChartGrid), ProfBars, ChartGrid)
Long: BuyImb(DnImb(ProfBars, ChartGrid), ProfBars, ChartGrid)
Short: SellImb(DnImb(ProfBars, ChartGrid), ProfBars, ChartGrid) AND NOT BuyImb(DnImb(ProfBars, ChartGrid), ProfBars, ChartGrid)
Long: OverlappingCoefficient(ProfBars) < balance threshold AND Tilt(ProfBars) >= tilt threshold
Short: OverlappingCoefficient(ProfBars) < balance threshold AND Tilt(ProfBars) <= -tilt threshold