Calculation: POC(p) = price level with the greatest volume in the volume-at-price profile p
Calculation: VAH(p) = upper edge of the value area of p, the smallest band around POC(p) holding value-area percent of p's volume, grown toward the side with more volume
Calculation: VAL(p) = lower edge of the value area of p, the same band as VAH(p)
Calculation: Upper(R) = VAH(R) if band mode is value area, else POC(R) + band percent * range(R); range(R) = high - low of R's bars, or VAH(R) - VAL(R) when R is a window
Calculation: Lower(R) = VAL(R) if band mode is value area, else POC(R) - band percent * range(R); range(R) as in Upper(R)
Calculation: POC migration = POC(window of T3 window count bars ending at last completed T3 bar) - POC(window of the same length ending migration lag T3 bars earlier)
Calculation: Live delta = sum of bar delta over the forming T1 candle, including the current bar
Calculation: Imbalance = (1 - w) * (T1 buy volume - T1 sell volume) / (T1 buy volume + T1 sell volume) + w * (bar buy volume - bar sell volume) / (bar buy volume + bar sell volume), with T1 volumes summed over the forming T1 candle including the current bar and w = current-bar weight
Calculation: VWAP = volume-weighted average of hlc3 over the last T1 window count T1 candles, run on chart bars including the current bar
Calculation: Exhaustion = abs(close - VWAP) >= exhaustion sigma * VWSD AND ((close > VWAP AND bar delta < 0) OR (close < VWAP AND bar delta > 0)); VWSD = sqrt(max(0, volume-weighted mean of hlc3 squared - VWAP squared)) over the same window
Calculation: Participation = max(PercentRank(EMA(volume, participation EMA length), participation lookback), PercentRank(volume, participation lookback))
Calculation: Fuel = min(1, Bell * Agreement * EMA factor); Bell = 1 if Participation >= bell peak, else exp(-(bell peak - Participation)^2 / (2 * bell width^2)); Agreement = agreement penalty if sign(bar delta) differs from sign(close - open), else 1; EMA factor = 1 + EMA boost if sign(bar delta) = sign(close - Trend EMA), else 1 - EMA boost
Calculation: Trend EMA = EMA(EMA(close, EMA length), EMA smoothing length)
Calculation: Pivot high level(TF) = high of the latest pivot high of TF with pivot length bars on each side, held from the bar it is confirmed (pivot length bars after its own bar) until the next confirmed pivot high; for a higher TF, read at its last completed bar
Calculation: Pivot low level(TF) = low of the latest pivot low of TF, confirmed and held as in Pivot high level(TF)
Calculation: Trend state(TF) = +1 when TF close > Pivot high level(TF), -1 when TF close < Pivot low level(TF), otherwise unchanged; 0 before the first break; for a higher TF, evaluated on its own bars and read at its last completed bar
Calculation: Accept vote(now, earlier) = +1 if (now - earlier) / ATR(ATR length) > accept dead band, -1 if < -accept dead band, else 0; ATR on the same bars as now and earlier
Calculation: Flow vote(series, window, dead zone) = +1 if the recency-weighted mean of series over window / mean absolute series over window > dead zone, -1 if < -dead zone, else 0; recency weights rise linearly to the newest bar
Calculation: Bias score(chart) = bias accept weight * Accept vote(POC of current bar's profile, POC of that profile bias lookback bars earlier) + bias trend weight * Trend state(chart) + bias flow weight * Flow vote(bar delta, bias lookback, bias flow dead zone)
Calculation: Bias score(T2) = bias accept weight * Accept vote(POC of window of T2 bias lookback bars ending at last completed T2 bar, POC of the same window T2 migration lag bars earlier) + bias trend weight * Trend state(T2) + bias flow weight * Flow vote(T2 polarity volume, T2 bias lookback, bias flow dead zone); T2 polarity volume = volume if close > open, -volume if close < open, else 0; all T2 values at last completed T2 bar
Calculation: Bear divergence = latched state: at each confirmed chart pivot high, true if that pivot high > previous pivot high AND RSI(close, RSI length) at that pivot bar < RSI at the previous pivot high bar, else false; at each confirmed chart pivot low where pivot low < previous pivot low AND RSI at that bar > RSI at the previous pivot low bar, false; otherwise unchanged
Calculation: Bull divergence = latched state: at each confirmed chart pivot low, true if that pivot low < previous pivot low AND RSI(close, RSI length) at that pivot bar > RSI at the previous pivot low bar, else false; at each confirmed chart pivot high where pivot high > previous pivot high AND RSI at that bar < RSI at the previous pivot high bar, false; otherwise unchanged
Calculation: Print = bar, closed only when confirm-on-close is on, inside the print session, that qualifies as an aggression print or an absorption print and whose score is at least the highest earlier score of its type in the session (scores reset each session when restart is on); aggression qualifies when modified z-score of bar delta (median and MAD) >= z threshold AND relative volume >= relative volume threshold AND abs(bar delta) >= minimum abs delta; absorption qualifies when relative volume >= relative volume threshold AND ((range effort ratio >= effort threshold AND range ratio <= range limit) OR (body effort ratio >= effort threshold AND body ratio <= range limit)); effort ratio = volume per tick of range (or of body) divided by its median; range ratio = ticks of range (or of body) divided by its median; relative volume = volume divided by its typical level for the same time of day; score = composite for aggression and effort ratio for absorption; composite = 0.4 * abs(bar delta) / median abs(bar delta) + 0.3 * anomaly ratio + 0.3 * (abs(bar delta) / volume) / its median, anomaly ratio = abs(bar delta) over its typical level for the time of day, else modified z-score; a Print is absorption if it qualifies only as absorption, or as both with effort ratio > composite
Calculation: Print vote tally = sum of votes over the last tally count Prints; for a Print with trend t = Trend state(chart) and aggressor side s = sign(bar delta) at its bar: vote = 0 if t = 0; -t * absorption tally weight if the Print is absorption; 0 if s = 0; t * counter-trend tally weight if s = -t; -t * with-trend tally weight if s = t
Calculation: Print read score = (print accept weight * sign(POC migration) + print trend weight * Trend state(chart) + print location weight * Loc + print flow weight * sign(Live delta) + print path weight * Path) * (print damp + (1 - print damp) * Spon); Loc = +1 if close > VAH(window of T4 window count bars ending at last completed T4 bar), -1 if close < VAL(same window), else 0; Path = +1 if (mean of midpoints of the newer half of the last path count Prints minus mean of the older half) / ATR(ATR length) >= path flat threshold, -1 if <= -path flat threshold, else 0; Path = 0 with fewer than minimum path prints (all Prints used if fewer than path count); Spon = max(0, min(1, (Participation / 100 + min(1, Fuel)) / 2))
Calculation: Release coil = squeeze OR absorption on this bar; squeeze = PercentRank(VAH(T3 window) - VAL(T3 window), squeeze lookback) <= squeeze percentile threshold; absorption = Fuel >= absorption fuel threshold AND abs(close - open) <= absorption body multiple * ATR(ATR length) AND bar delta != 0; a coil episode starts at a coil bar that follows more than release window bars without a coil bar
Long: Live delta > 0
Short: Live delta < 0
Long: close > Upper(profile of last completed chart bar)
Short: close < Lower(profile of last completed chart bar)
Long: close > Upper(profile of T1 window count T1 candles ending at last completed T1 bar)
Short: close < Lower(profile of T1 window count T1 candles ending at last completed T1 bar)
Long: Imbalance > 0
Short: Imbalance < 0
Long: POC migration > 0
Short: POC migration < 0
Long: close > VAH(profile of chart bars from session open through current bar)
Short: close < VAL(profile of chart bars from session open through current bar)
Long: bar delta > 0
Short: bar delta < 0
Long: close > Pivot high level(chart)
Short: close < Pivot low level(chart)
Long: close > Pivot high level(T1)
Short: close < Pivot low level(T1)
Long: Trend state(chart) > 0
Short: Trend state(chart) < 0
Long: close > Trend EMA
Short: close < Trend EMA
Long: close > high of last completed T5 bar
Short: close < low of last completed T5 bar
Long: close > high of the most recent Asian window, which includes the current bar while inside that window
Short: close < low of the most recent Asian window, which includes the current bar while inside that window
Long: (close > VWAP AND NOT Exhaustion) OR (close < VWAP AND Exhaustion)
Short: (close < VWAP AND NOT Exhaustion) OR (close > VWAP AND Exhaustion)
Long: close > open
Short: close < open
Long: (RSI(close, RSI length) > 50 AND NOT Bear divergence) OR Bull divergence
Short: (RSI(close, RSI length) < 50 AND NOT Bull divergence) OR Bear divergence
Long: close > VAH(window of T4 window count bars ending at last completed T4 bar)
Short: close < VAL(window of T4 window count bars ending at last completed T4 bar)
Long: close > VAH(window of T3 window count bars ending at last completed T3 bar) AND bar delta > 0 AND Release coil occurred within the last release window bars AND no release has fired earlier in the current coil episode
Short: close < VAL(window of T3 window count bars ending at last completed T3 bar) AND bar delta < 0 AND Release coil occurred within the last release window bars AND no release has fired earlier in the current coil episode
Long: Bias score(chart) >= bias threshold
Short: Bias score(chart) <= -bias threshold
Long: Bias score(T2) >= bias threshold
Short: Bias score(T2) <= -bias threshold
Long: Print AND bar delta > 0
Short: Print AND bar delta < 0
Long: Print read score >= print read threshold
Short: Print read score <= -print read threshold
Long: Print vote tally >= tally threshold AND prints in tally >= minimum tally count
Short: Print vote tally <= -tally threshold AND prints in tally >= minimum tally count