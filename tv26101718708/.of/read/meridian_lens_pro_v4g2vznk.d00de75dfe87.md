Calculation: Fast, medium, and slow lines = independently configured Nadaraya–Watson kernel regressions of a price source, with respectively shorter, intermediate, and longer bandwidths. Each may use a raw, double-smoothed, or zero-lag filter and a phase offset. The imported library's exact kernel weights, window lengths, phase handling, filtering, and missing-value rules are not provided in READ, so these lines cannot be reproduced exactly from READ alone.
Long: Fast, medium, or slow line > its previous-bar value
Short: Fast or slow line < its previous-bar value OR medium line <= its previous-bar value
Long: Fast line > slow line AND previous-bar fast line <= previous-bar slow line
Short: Fast line < slow line AND previous-bar fast line >= previous-bar slow line