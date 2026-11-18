Calculation: Power(C) = sum over the seven pairs p containing currency C of sign(p,C) × close(p) ÷ scale(p), where sign(p,C) = +1 if C is the base currency of p and −1 if C is the quote currency of p, and scale(p) = K if p is quoted in JPY, otherwise 1
Calculation: Average(C) = EMA of Power(C) over period P
Long: Power(base currency) > Average(base currency) AND Power(profit currency) < Average(profit currency) AND trend mode selected
Short: Power(base currency) < Average(base currency) AND Power(profit currency) > Average(profit currency) AND trend mode selected