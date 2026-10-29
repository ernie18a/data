Calculation: Laguerre filter = On the higher-timeframe bar still forming, set P=(high+low)/2; recursively calculate L0=(1−γ)P+γ·previous L0, L1=−γL0+previous L0+γ·previous L1, L2=−γL1+previous L1+γ·previous L2, L3=−γL2+previous L2+γ·previous L3; output (L0+2L1+2L2+L3)/6. Initialize all states to the first P.
Calculation: 4-bar FIR = On the higher-timeframe bar still forming, (P+2·previous P+2·P from two bars ago+P from three bars ago)/6, where P=(high+low)/2.
Long: Laguerre filter < 4-bar FIR
Short: Laguerre filter > 4-bar FIR