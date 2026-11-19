Calculation: Adjusted high(asset, bar) = if that asset's inversion setting is enabled, 1 / low; otherwise high
Calculation: Adjusted low(asset, bar) = if that asset's inversion setting is enabled, 1 / high; otherwise low
Calculation: Period high break(asset, T) = on chart bars, adjusted high of the current forming T bar > adjusted high of the preceding completed T bar
Calculation: Period low break(asset, T) = on chart bars, adjusted low of the current forming T bar < adjusted low of the preceding completed T bar
Calculation: NY session bucket(P1, P2) = consecutive New York time intervals of duration P1, anchored at P2
Calculation: NY subperiod bucket(P3) = consecutive intervals of duration P3 within each NY session bucket, starting at the session boundary; P3 divides P1
Calculation: NY microperiod bucket(P4) = consecutive intervals of duration P4 within each NY subperiod bucket, starting at the subperiod boundary; P4 divides P3
Calculation: NY bucket high break(asset, bucket) = on T3 bars, the current bucket's running adjusted high > the preceding completed bucket's adjusted high; chart bars use returned T3 values
Calculation: NY bucket low break(asset, bucket) = on T3 bars, the current bucket's running adjusted low < the preceding completed bucket's adjusted low; chart bars use returned T3 values
Calculation: Mixed(break) = at least one configured asset has the break and at least one configured asset does not
Long: Mixed(Period low break(asset, longer timeframe T1)) OR Mixed(Period low break(asset, shorter timeframe T2)) OR Mixed(NY bucket low break(asset, NY session bucket(P1, P2))) OR Mixed(NY bucket low break(asset, NY subperiod bucket(P3))) OR Mixed(NY bucket low break(asset, NY microperiod bucket(P4)))
Short: Mixed(Period high break(asset, longer timeframe T1)) OR Mixed(Period high break(asset, shorter timeframe T2)) OR Mixed(NY bucket high break(asset, NY session bucket(P1, P2))) OR Mixed(NY bucket high break(asset, NY subperiod bucket(P3))) OR Mixed(NY bucket high break(asset, NY microperiod bucket(P4)))