Calculation: Oriented high(I) = if asset inversion parameter I is enabled, 1 / low; otherwise high
Calculation: Oriented low(I) = if asset inversion parameter I is enabled, 1 / high; otherwise low
Calculation: Period high break(T) = on chart bars using T values, current forming T-bar oriented high > previous completed T-bar oriented high
Calculation: Period low break(T) = on chart bars using T values, current forming T-bar oriented low < previous completed T-bar oriented low
Calculation: Session = consecutive New York local time groups anchored at P1 and repeating every P2
Calculation: Subperiod = P3-duration groups partitioning each session from its start
Calculation: Microperiod = P4-duration groups partitioning each subperiod from its start
Calculation: Group high break(G) = on T3 bars, current G running oriented high > previous completed G high; chart bars use the returned value
Calculation: Group low break(G) = on T3 bars, current G running oriented low < previous completed G low; chart bars use the returned value
Calculation: Mixed(B) = at least one configured asset has B and at least one configured asset does not have B
Long: Mixed(Period low break(T1)) OR Mixed(Period low break(T2)) OR Mixed(Group low break(Session)) OR Mixed(Group low break(Subperiod)) OR Mixed(Group low break(Microperiod))
Short: Mixed(Period high break(T1)) OR Mixed(Period high break(T2)) OR Mixed(Group high break(Session)) OR Mixed(Group high break(Subperiod)) OR Mixed(Group high break(Microperiod))