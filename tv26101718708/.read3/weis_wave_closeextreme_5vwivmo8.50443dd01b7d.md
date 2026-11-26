Calculation: Weis wave = set the anchor to the first close and remain undetermined until a close moves at least the active reversal amount minus tick tolerance from the anchor; in an up-wave, update the extreme on each close at or above it and reverse down when the close is at least the latched reversal amount minus tick tolerance below it; use the converse for a down-wave. On reversal, start the new wave at the prior extreme and run it through the current bar; latch the active reversal amount when each wave starts.
Calculation: Wave activity = TrueRange(high, low, close) when true range is selected or, in automatic mode, before volume is first available; otherwise volume.
Calculation: Wave volume = sum of wave activity through each new wave extreme; activity after the latest extreme is pending and is added to the current wave if it makes a new extreme, otherwise to the new wave on reversal.
Calculation: Shortening of thrust = across the SOT lookback of successive same-direction waves, each wave makes a new high (up-waves) or low (down-waves), and the latest gain is smaller than the preceding gain.
Long: Weis wave direction = up
Short: Weis wave direction = down
Long: A completed down-wave is marked for shortening of thrust.
Short: A completed up-wave is marked for shortening of thrust.
Long: A completed down-wave has greater wave volume than each of the prior N down-waves, greater wave volume per tick of close-to-close progress than each, and fewer progress ticks than the longest of them.
Short: A completed up-wave has greater wave volume than each of the prior N up-waves, greater wave volume per tick of close-to-close progress than each, and fewer progress ticks than the longest of them.