Calculation: LSMA angle state on each completed T1 bar = 0 if LSMA_Angle(T1, last completed bar) < -threshold and lower than LSMA_Angle(T1, preceding bar); 1 if below -threshold and higher than LSMA_Angle(T1, preceding bar); 3 if above threshold and lower than LSMA_Angle(T1, preceding bar); 4 if above threshold and higher than LSMA_Angle(T1, preceding bar); 2 otherwise
Long: LSMA angle state on the preceding completed T1 bar = 4 AND LSMA angle state on the latest completed T1 bar < 4
Short: LSMA angle state on the preceding completed T1 bar = 0 AND LSMA angle state on the latest completed T1 bar > 0
Exit: long, LSMA angle state on the preceding completed T1 bar < 2
Exit: short, LSMA angle state on the preceding completed T1 bar > 1