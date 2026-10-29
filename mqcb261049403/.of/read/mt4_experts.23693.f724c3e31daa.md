Long: chart-bar timestamp changes AND open-position count = 0
Short: chart-bar timestamp changes AND open-position count = 0
Long: Bid <= lowest entry price among open long positions - adverse-step distance
Short: Ask >= highest entry price among open short positions + adverse-step distance
Exit: long, price <= entry price + take-profit distance OR price <= trailing stop
Exit: short, price >= entry price - take-profit distance OR price >= trailing stop