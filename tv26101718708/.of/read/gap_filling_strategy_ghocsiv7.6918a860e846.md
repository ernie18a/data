Calculation: Up gap = open > previous bar high AND min(open, close) > max(previous bar open, previous bar close)
Calculation: Down gap = open < previous bar low AND min(previous bar open, previous bar close) > max(open, close)
Calculation: Gap fill level = for the latest new-session gap, max(previous bar open, previous bar close) if it is an up gap, otherwise min(previous bar open, previous bar close)
Long: new daily session AND ((inversion enabled AND Up gap) OR (inversion disabled AND Down gap))
Short: new daily session AND ((inversion enabled AND Down gap) OR (inversion disabled AND Up gap))
Exit: long, high >= Gap fill level when inversion is disabled OR low <= Gap fill level when inversion is enabled
Exit: short, low <= Gap fill level when inversion is disabled OR high >= Gap fill level when inversion is enabled
Exit: long, new daily session when the close setting is New Session OR new daily session AND (Up gap OR Down gap) when the close setting is New Gap
Exit: short, new daily session when the close setting is New Session OR new daily session AND (Up gap OR Down gap) when the close setting is New Gap