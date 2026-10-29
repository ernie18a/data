Calculation: Fast and slow EVWMA = ((rolling sum of volume over the lookback, including the current bar − current volume) × previous EVWMA + current volume × close) / rolling sum of volume over the lookback; initialize the previous EVWMA as the previous close. Fast uses a shorter lookback than slow.
Long: Fast EVWMA > slow EVWMA AND previous fast EVWMA ≤ previous slow EVWMA
Short: Fast EVWMA < slow EVWMA AND previous fast EVWMA ≥ previous slow EVWMA
Exit: long, fast EVWMA < slow EVWMA AND previous fast EVWMA ≥ previous slow EVWMA
Exit: short, fast EVWMA > slow EVWMA AND previous fast EVWMA ≤ previous slow EVWMA