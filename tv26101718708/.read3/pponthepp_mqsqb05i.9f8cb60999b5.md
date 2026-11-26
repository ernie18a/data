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
Calculation: Adjusted period high = external symbol's period high when its inversion setting is off, otherwise 1 divided by its period low
Calculation: Adjusted period low = external symbol's period low when its inversion setting is off, otherwise 1 divided by its period high
Calculation: High break = current adjusted period high > previous adjusted period high
Calculation: Low break = current adjusted period low < previous adjusted period low
Long: At least one of the eight configured external symbols has a T1 low break AND at least one has no T1 low break
Short: At least one of the eight configured external symbols has a T1 high break AND at least one has no T1 high break
Long: At least one of the eight configured external symbols has a T2 low break AND at least one has no T2 low break
Short: At least one of the eight configured external symbols has a T2 high break AND at least one has no T2 high break
Long: At least one of the eight configured external symbols has a T3 low break AND at least one has no T3 low break
Short: At least one of the eight configured external symbols has a T3 high break AND at least one has no T3 high break
Long: At least one of the eight configured external symbols has a T4 low break AND at least one has no T4 low break
Short: At least one of the eight configured external symbols has a T4 high break AND at least one has no T4 high break
Long: At least one of the eight configured external symbols has a T5 low break AND at least one has no T5 low break
Short: At least one of the eight configured external symbols has a T5 high break AND at least one has no T5 high break