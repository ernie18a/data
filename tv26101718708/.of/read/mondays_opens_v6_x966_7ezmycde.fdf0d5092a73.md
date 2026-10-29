Calculation: Monday High = highest high of the current week's Monday bars
Calculation: Monday Low = lowest low of the current week's Monday bars
Long: After Monday, confirmed bar close, low < Monday Low, close >= Monday Low, and (latching disabled OR no low sweep has been marked since a bar's low was above Monday Low)
Short: After Monday, confirmed bar close, high > Monday High, close <= Monday High, and (latching disabled OR no high sweep has been marked since a bar's high was below Monday High)
Long: After Monday, confirmed bar close > Monday High, and (latching disabled OR no upper acceptance has been marked since a confirmed close returned inside the Monday range)
Short: After Monday, confirmed bar close < Monday Low, and (latching disabled OR no lower acceptance has been marked since a confirmed close returned inside the Monday range)