Long: execution is Buy or BuyAndCloseSell AND indicator X is not empty
Long: execution is Buy or BuyAndCloseSell AND indicator X > 0
Long: execution is Buy or BuyAndCloseSell AND indicator X < indicator Y AND previous indicator X >= previous indicator Y
Long: execution is Buy or BuyAndCloseSell AND indicator X > indicator Y AND previous indicator X <= previous indicator Y
Long: execution is Buy or BuyAndCloseSell AND indicator X < level AND previous indicator X >= level
Long: execution is Buy or BuyAndCloseSell AND indicator X > level AND previous indicator X <= level
Long: execution is Buy or BuyAndCloseSell AND indicator X > indicator Y
Long: execution is Buy or BuyAndCloseSell AND indicator X < indicator Y
Long: execution is Buy or BuyAndCloseSell AND indicator X = indicator Y
Long: execution is Buy or BuyAndCloseSell AND indicator X > level
Long: execution is Buy or BuyAndCloseSell AND indicator X < level
Long: execution is Buy or BuyAndCloseSell AND indicator X = level
Long: execution is Buy or BuyAndCloseSell AND indicator X != level
Long: execution is Buy or BuyAndCloseSell AND expression result > 0
Long: execution is Buy or BuyAndCloseSell AND expression result != 0
Short: execution is Sell or SellAndCloseBuy AND indicator X is not empty
Short: execution is Sell or SellAndCloseBuy AND indicator X > 0
Short: execution is Sell or SellAndCloseBuy AND indicator X < 0
Short: execution is Sell or SellAndCloseBuy AND indicator X < indicator Y AND previous indicator X >= previous indicator Y
Short: execution is Sell or SellAndCloseBuy AND indicator X > indicator Y AND previous indicator X <= previous indicator Y
Short: execution is Sell or SellAndCloseBuy AND indicator X < level AND previous indicator X >= level
Short: execution is Sell or SellAndCloseBuy AND indicator X > level AND previous indicator X <= level
Short: execution is Sell or SellAndCloseBuy AND indicator X > indicator Y
Short: execution is Sell or SellAndCloseBuy AND indicator X < indicator Y
Short: execution is Sell or SellAndCloseBuy AND indicator X = indicator Y
Short: execution is Sell or SellAndCloseBuy AND indicator X > level
Short: execution is Sell or SellAndCloseBuy AND indicator X < level
Short: execution is Sell or SellAndCloseBuy AND indicator X = level
Short: execution is Sell or SellAndCloseBuy AND indicator X != level
Short: execution is Sell or SellAndCloseBuy AND expression result > 0
Short: execution is Sell or SellAndCloseBuy AND expression result != 0
Exit: long, execution is CloseBuy or CloseAll or SellAndCloseBuy AND signal condition is true
Exit: short, execution is CloseSell or CloseAll or BuyAndCloseSell AND signal condition is true