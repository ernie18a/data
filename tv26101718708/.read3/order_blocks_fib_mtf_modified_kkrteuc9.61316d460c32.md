Calculation: Demand proximal boundary = proximal edge of the latest demand order block, refined when order-block refinement is enabled and otherwise the order-block bar's high
Calculation: Supply proximal boundary = proximal edge of the latest supply order block, refined when order-block refinement is enabled and otherwise the order-block bar's low
Calculation: Demand alert lock = 0 initially; retain its prior value, set to 1 if the long condition fires, then reset to 0 if the demand proximal boundary differs from its prior-bar value
Calculation: Supply alert lock = 0 initially; retain its prior value, set to 1 if the short condition fires, then reset to 0 if the supply proximal boundary differs from its prior-bar value
Long: low <= demand proximal boundary AND low[1] > demand proximal boundary AND demand alert lock = 0
Short: high >= supply proximal boundary AND high[1] < supply proximal boundary AND supply alert lock = 0