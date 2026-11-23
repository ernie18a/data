Calculation: MA = EMA(MA source, MA length) if MA type is EMA, else SMA(MA source, MA length)
Calculation: Slope% = ABS(MA - MA[1]) / MA[1] * 100
Calculation: d = ATR(ATR length) / close * 100 * ATR multiplier if adaptive deviation switch is on, else fixed deviation %
Calculation: Ext high = HA high if wick switch is on, else HA close
Calculation: Ext low = HA low if wick switch is on, else HA close
Calculation: Leg = +1 or -1 for the ZigZag leg in progress; initially set by the first d% move from the first pivot; flips after each Leg turn bar
Calculation: Leg turn = bars since Pivot bar >= depth bars AND ((Leg = +1 AND Ext low <= Leg extreme * (1 - d / 100)) OR (Leg = -1 AND Ext high >= Leg extreme * (1 + d / 100)))
Calculation: Leg extreme = running max of Ext high while Leg = +1, or running min of Ext low while Leg = -1, since the latest Leg turn bar, starting at HA close of that bar
Calculation: Pivot = Leg extreme at the latest earlier Leg turn bar; Pivot bar = bar where that extreme occurred
Calculation: Live% = ABS(Leg extreme - Pivot) / ABS(Leg extreme - Pivot, evaluated at the latest earlier Leg turn bar) * 100
Calculation: Correction = (Leg = +1 AND HA close < MA) OR (Leg = -1 AND HA close > MA)
Calculation: Correction start = Correction AND (NOT Correction[1] OR Leg turn[1])
Calculation: Correction start price = Pivot at the latest Correction start
Calculation: Correction extreme = Leg extreme at the latest Correction start; afterwards max(Correction extreme[1], Leg extreme) while HA close < MA, or min(Correction extreme[1], Leg extreme) while HA close > MA
Calculation: Signal limit = green threshold if signal tier is Green only, orange threshold if signal tier is Green+Orange, red threshold if signal tier is Green+Orange+Red
Calculation: Fire limit = green threshold if fire tier is Green only, orange threshold if fire tier is Green+Orange, red threshold if fire tier is Green+Orange+Red
Calculation: Long gate = MA > MA[1] AND (SMA filter off OR (MA > SMA(close, long SMA length) AND close > SMA(close, long SMA length))) AND (HTF filter off OR close > EMA(close, MA length, T1, last completed bar)) AND (ADX filter off OR ADX(ADX length) >= ADX minimum), where long SMA length is longer than MA length
Calculation: Short gate = MA < MA[1] AND (SMA filter off OR (MA < SMA(close, long SMA length) AND close < SMA(close, long SMA length))) AND (HTF filter off OR close < EMA(close, MA length, T1, last completed bar)) AND (ADX filter off OR ADX(ADX length) >= ADX minimum)
Calculation: Red core = Correction start AND Live% < Signal limit AND (slope-only-green switch on OR Slope% >= slope threshold)
Calculation: Orange core = Correction AND Leg turn AND Live% < Signal limit AND (slope-only-green switch on OR Slope% >= slope threshold)
Calculation: Flags kept = NOT Green[1] AND NOT Correction start
Calculation: Red seen = (Red core AND (Long gate OR Short gate)) OR (Red seen[1] AND Flags kept)
Calculation: Orange seen = (Orange core AND (Long gate OR Short gate)) OR (Orange seen[1] AND Flags kept)
Calculation: Magenta seen = (Magenta core AND (Long gate OR Short gate)) OR (Magenta seen[1] AND Flags kept)
Calculation: Magenta core = Correction AND Red seen AND NOT (Orange seen[1] AND Flags kept) AND NOT (Magenta seen[1] AND Flags kept) AND low <= MA AND high >= MA AND Live% < Signal limit AND (slope-only-green switch on OR Slope% >= slope threshold)
Calculation: Green = Red seen AND Orange seen AND Slope% >= slope threshold AND (Long gate OR Short gate) AND ((early-break method is pivot AND ((HA close < MA AND (close if confirm-close switch is on, else low) < regular low of the Pivot bar latched at the latest Correction start) OR (HA close > MA AND (close if confirm-close switch is on, else high) > regular high of the Pivot bar latched at the latest Correction start))) OR (early-break method is N-bar AND Correction AND ((HA close < MA AND HA close < lowest HA close over the N bars before this bar) OR (HA close > MA AND HA close > highest HA close over the N bars before this bar))) OR (early-break method is percent AND Correction AND ((HA close < MA AND Correction extreme > Correction start price AND HA close <= Correction extreme - early-break percent / 100 * (Correction extreme - Correction start price)) OR (HA close > MA AND Correction start price > Correction extreme AND HA close >= Correction extreme + early-break percent / 100 * (Correction start price - Correction extreme))))
Long: Red core AND Long gate
Short: Red core AND Short gate
Long: Magenta core AND Long gate
Short: Magenta core AND Short gate
Long: Orange core AND Long gate
Short: Orange core AND Short gate
Long: Green AND Long gate
Short: Green AND Short gate
Long: Red core AND Long gate AND Live% < Fire limit
Short: Red core AND Short gate AND Live% < Fire limit
Long: Magenta core AND Long gate AND Live% < Fire limit
Short: Magenta core AND Short gate AND Live% < Fire limit
Long: Orange core AND Long gate AND Live% < Fire limit
Short: Orange core AND Short gate AND Live% < Fire limit