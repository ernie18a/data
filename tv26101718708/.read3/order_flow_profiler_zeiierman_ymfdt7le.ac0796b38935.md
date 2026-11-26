Calculation: BuyFraction(bar) = clamp(0.5 + shareGain × (closeWeight × (2 × closePos − 1) + bodyWeight × body + wickWeight × (lowerWick − upperWick)), minShare, maxShare), where range = high − low, closePos = clamp((close − low) ÷ range, 0, 1), body = clamp((close − open) ÷ range, −1, 1), upperWick = max(high − max(open, close), 0) ÷ range, lowerWick = max(min(open, close) − low, 0) ÷ range, and BuyFraction = 0.5 when range = 0
Calculation: Anchor(bar, extreme) = clamp(anchorClose × close + anchorExtreme × extreme + anchorOpen × open, low, high)
Calculation: CellShare(bar, cell, anchor) = overlap of bar range with cell ÷ bar range × (1 + curve gain × (1 − min(|cell midpoint − anchor| ÷ bar range, 1))^concentration), for bar range > 0; 0 when the cell does not overlap the bar range
Calculation: BuyVol(cell) = sum over window bars with positive volume of volume × BuyFraction(bar) × CellShare(bar, cell, Anchor(bar, high)) ÷ sum over all cells j of CellShare(bar, j, Anchor(bar, high)), where the window is the last window-length bars ending at the current bar, or at the prior bar when the current bar is excluded; cells are indexed 0 to cells − 1, have equal height, and span the window's lowest low to highest high; zero-range bars add volume × BuyFraction(bar) wholly to the cell containing close
Calculation: SellVol(cell) = same as BuyVol(cell) with 1 − BuyFraction(bar) in place of BuyFraction(bar) and Anchor(bar, low) in place of Anchor(bar, high)
Calculation: ControlCell = the cell maximizing BuyVol(cell) + SellVol(cell)
Calculation: ControlVol = BuyVol(ControlCell) + SellVol(ControlCell)
Calculation: BuyTest(cell) = cell > 0 AND SellVol(cell − 1) > 0 AND BuyVol(cell) + SellVol(cell) ≥ minActivity × ControlVol AND BuyVol(cell) > pressureRatio × SellVol(cell − 1)
Calculation: SellTest(cell) = cell < cells − 1 AND BuyVol(cell + 1) > 0 AND BuyVol(cell) + SellVol(cell) ≥ minActivity × ControlVol AND SellVol(cell) > pressureRatio × BuyVol(cell + 1)
Calculation: PressureSide(cell) = 0 if neither BuyTest(cell) nor SellTest(cell); otherwise 1 if BuyRatio(cell) ≥ SellRatio(cell), else −1; where BuyRatio(cell) = BuyVol(cell) ÷ SellVol(cell − 1) if BuyTest(cell), else 0, and SellRatio(cell) = SellVol(cell) ÷ BuyVol(cell + 1) if SellTest(cell), else 0
Calculation: UpperPressure = PressureSide of the nearest cell above ControlCell with nonzero PressureSide, or 0 if none
Calculation: LowerPressure = PressureSide of the nearest cell below ControlCell with nonzero PressureSide, or 0 if none
Calculation: BandBuy(band) = sum of BuyVol(cell) for cell from floor(band × cells ÷ bands) to max(floor((band + 1) × cells ÷ bands) − 1, floor(band × cells ÷ bands))
Calculation: BandSell(band) = same as BandBuy(band) with SellVol in place of BuyVol
Long: UpperPressure = 1 OR LowerPressure = 1
Long: BuyVol(ControlCell) > SellVol(ControlCell)
Long: BuyVol(cell) > SellVol(cell) for some cell
Long: BandBuy(band) ≥ balanceRatio × BandSell(band) AND BandBuy(band) > BandSell(band) for some band
Short: UpperPressure = −1 OR LowerPressure = −1
Short: SellVol(ControlCell) > BuyVol(ControlCell)
Short: SellVol(cell) > BuyVol(cell) for some cell
Short: BandSell(band) ≥ balanceRatio × BandBuy(band) AND BandSell(band) > BandBuy(band) for some band