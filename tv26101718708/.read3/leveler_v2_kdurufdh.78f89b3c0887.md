Calculation: Range(m) = cumulative sum of true range / (n + 1) * m, evaluated on the current bar of the calling timeframe
Calculation: Open grid = round(source / Range(unit scale)) * Range(unit scale), evaluated on T1 bars using the still-forming T1 bar and mapped to chart bars
Calculation: High grid = round(1 + source / Range(unit scale)) * Range(unit scale), evaluated on T1 bars using the still-forming T1 bar and mapped to chart bars
Calculation: Low grid = round(source / Range(unit scale) - 1) * Range(unit scale), evaluated on T1 bars using the still-forming T1 bar and mapped to chart bars
Calculation: Buy open level = Open grid + Range(offset multiplier), evaluated on chart bars
Calculation: Sell open level = Open grid - Range(offset multiplier), evaluated on chart bars
Calculation: Buy high level = High grid + Range(offset multiplier), evaluated on chart bars
Calculation: Sell high level = High grid - Range(offset multiplier), evaluated on chart bars
Calculation: Buy low level = Low grid + Range(offset multiplier), evaluated on chart bars
Calculation: Sell low level = Low grid - Range(offset multiplier), evaluated on chart bars
Calculation: Upper band = if Sell low[1] > Upper band[1] then max(hl2 - factor * ATR(Pd), Upper band[1]) else hl2 - factor * ATR(Pd), evaluated on chart bars
Calculation: Lower band = if Sell low[1] < Lower band[1] then min(hl2 + factor * ATR(Pd), Lower band[1]) else hl2 + factor * ATR(Pd), evaluated on chart bars
Calculation: Direction = if Sell low > Lower band[1] then 1 else if Sell low < Upper band[1] then -1 else nz(Direction[1], 1)
Calculation: Active band = if Direction == 1 then Upper band else Lower band
Long: Direction == 1 OR Buy open level < Active band OR Buy low level < Active band OR Buy high level < Active band OR low crosses above Sell low level AND Direction == 1
Short: Direction != 1 OR Sell high level < Active band OR Sell open level < Active band OR Sell low level < Active band OR high crosses below High grid AND Direction == -1
Exit: long, close crosses above Buy open level AND (Direction != 1 OR Upper band == 0)
Exit: short, low crosses above Open grid AND (Direction != -1 OR Lower band == 0)