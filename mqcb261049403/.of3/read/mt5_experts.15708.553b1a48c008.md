Calculation: quote midpoint(X/Y) = round((bid(X/Y) + ask(X/Y)) / 2, quote precision)
Calculation: synthetic midpoint(A/B) = round(quote midpoint(A/C) / quote midpoint(B/C), quote precision)
Calculation: synthetic midpoint(A/C) = round(quote midpoint(A/B) × quote midpoint(B/C), quote precision)
Calculation: synthetic midpoint(B/C) = round(quote midpoint(A/C) / quote midpoint(A/B), quote precision)
Calculation: synthetic deviation(X/Y) = round(synthetic midpoint(X/Y) - quote midpoint(X/Y), quote precision)
Calculation: synthetic quote delay(X/Y) = later timestamp of the two input pair quotes used for synthetic midpoint(X/Y) - timestamp of quote(X/Y)
Calculation: required margin(X/Y) = contract value parameter × margin fraction parameter × bid(X/Y) / account leverage
Long: synthetic deviation(X/Y) > spread parameter × point-price conversion parameter AND synthetic quote delay(X/Y) > delay parameter AND free margin > required margin(X/Y) AND no open position in X/Y
Short: synthetic deviation(X/Y) < -(spread parameter × point-price conversion parameter) AND synthetic quote delay(X/Y) < -delay parameter AND free margin > required margin(X/Y) AND no open position in X/Y
Exit: short, synthetic deviation(X/Y) > 0 AND position profit plus commission > 0 AND free margin > required margin(X/Y)
Exit: long, synthetic deviation(X/Y) < 0 AND position profit plus commission > 0 AND free margin > required margin(X/Y)