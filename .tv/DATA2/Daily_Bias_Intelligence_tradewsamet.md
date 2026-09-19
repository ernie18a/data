<!-- tradingview-pine-id: PUB;f579b1e811cb4bdb94767155fb6498a1 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Daily Bias Intelligence [tradewsamet]

Source: https://www.tradingview.com/script/P7KL9jsd-Daily-Bias-Intelligence-tradewsamet/

## Description

🎯 DAILY BIAS INTELLIGENCE [tradewsamet]

Daily Bias Intelligence [tradewsamet] is a statistical daily-context, historical-bias, range-analysis, intraday-state, calibration, and visualization indicator designed to help traders study how the current trading day compares with completed historical trading days.

The script is built around one central idea:

Daily bias should not be reduced to one weekday percentage or one directional signal.

A trading day develops inside several overlapping historical contexts. Today's weekday, yesterday's direction, the preceding three-day regime, recent market behavior, directional move skew, current time-of-day state, prior-day high/low interaction, range development, and session timing can all describe different parts of the same day.

Daily Bias Intelligence organizes these observations into one transparent analytical framework.

The script can:

• maintain a rolling history of completed trading days
• measure historical weekday directional behavior
• compare today's context with similar previous-day and three-day regimes
• measure recent completed-day directional behavior and Move Skew
• apply sample-size and statistical requirements before historical checks influence the main model
• combine qualified checks into a sample-weighted Daily Bias Score
• classify Strong Bullish / Strong Bearish historical-bias states
• calculate weekday P10 / P25 / P50 / P75 / P90 return distributions
• adjust historical movement for changing volatility regimes
• compare the developing day with historical days at approximately the same point in time
• track prior-day high / low behavior
• study where daily highs and lows historically formed
• measure current daily-range usage and directional streak behavior
• measure Asia / London / New York contribution by weekday
• audit strong-call and expected-range calibration
• display radar, statistics, weekday charts, day boxes, levels, and oscillator views
• provide TradingView alert conditions for important daily-context events

Daily Bias Intelligence is intended as a transparent statistical research and historical-review framework.

It is not a broker execution system, TradingView Strategy Tester, probability-of-profit model, or guarantee of future market direction.

━━━━━━━━━━━━━━━━━━━━━━
📸 CHART SNAPSHOT
━━━━━━━━━━━━━━━━━━━━━━

[image]https://www.tradingview.com/x/dLGcPnnK/[/image]

━━━━━━━━━━━━━━━━━━━━━━
📌 OVERVIEW
━━━━━━━━━━━━━━━━━━━━━━

Daily Bias Intelligence maintains a rolling database of completed trading days and uses that history to describe the statistical environment surrounding the current trading day.

The indicator separates three different types of information:

Observed historical statistics

Examples include weekday up-day rates, prior-day break rates, session contribution, and range behavior.

Modeled context

Examples include the Daily Bias Score and statistical-significance classifications.

Developing current-day information

Examples include today's return versus the prior close, current range, today's high/low, and NOW-state comparison.

The primary interface can display:

• five-factor Bullish / Bearish Radar
• Daily Bias Score
• Strong Bullish / Strong Bearish state
• four-card Statistics Panel
• weekday directional chart and ALL-days baseline
• calibration scorecard
• P10–P90 and P25–P75 expected ranges
• weekday median and expected absolute movement
• prior-day highs and lows with break markers
• daily range boxes and result labels
• live current-day percentage
• contextual candle coloring
• Waveform, Heat Stripes, or Bar Columns

The indicator is designed to provide context before independent trading decisions rather than creating automatic trade instructions.

━━━━━━━━━━━━━━━━━━━━━━
🧠 CORE IDEA
━━━━━━━━━━━━━━━━━━━━━━

A simple daily-bias model might ask only:

How often did Monday close higher?

Daily Bias Intelligence asks several additional questions.

• What direction did the previous trading day close?
• What was the net direction of the preceding three completed days?
• What has recent completed-day behavior looked like?
• Has historical movement on this weekday been concentrated more on the upside or downside?
• Is the supporting sample large enough?
• Is the observed difference statistically separated from 50%?
• What movement distribution historically belongs to this weekday?
• What happened historically when price was in today's current state at approximately this point in the day?
• How often are prior-day highs and lows broken?
• When do the final daily high and low typically form?
• How much of a normal daily range has already been used?

The workflow is:

completed trading days
→ historical context classification
→ sample validation
→ statistical filtering
→ weighted Daily Bias Score
→ optional strong-bias classification
→ weekday movement distribution
→ live intraday context
→ historical calibration

The indicator is designed to answer:

What does the completed historical dataset say about the type of trading day currently developing?

━━━━━━━━━━━━━━━━━━━━━━
🧩 WHY THIS SCRIPT IS NOT A SIMPLE DAILY BIAS INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

A basic daily-bias tool may calculate one historical percentage and convert it directly into a bullish or bearish label.

Daily Bias Intelligence uses a layered model instead.

Historical checks first require sufficient observations.

Directional rates are then evaluated relative to a neutral reference.

Eligible observations are combined through sample-aware weighting.

Strong classifications are separately gated.

Expected movement is calculated from a weekday-specific historical distribution.

Current intraday state is then studied independently from the opening historical-bias model.

Finally, previous strong classifications and range projections are evaluated after their corresponding trading days complete.

The structure is:

historical observations
→ sample quality
→ statistical evidence
→ modeled bias
→ live context
→ later calibration

A historical observation can exist without being statistically strong.

A Daily Bias Score can lean bullish or bearish without producing a Strong Bullish / Strong Bearish classification.

A strong historical bias can still fail.

A wide expected range says nothing by itself about direction.

The script keeps these concepts separate instead of forcing every statistic into one entry arrow.

━━━━━━━━━━━━━━━━━━━━━━
⚙️ HOW THE SCRIPT WORKS
━━━━━━━━━━━━━━━━━━━━━━

The engine stores completed trading-day information in aligned historical arrays.

A stored historical day can contain:

• raw daily return
• volatility-normalized return
• trading weekday
• previous-day direction known at that day's open
• prior three-day regime known at that day's open
• raw daily price change
• Asia / London / New York contribution
• prior-day high / low break state
• high / low break hold state
• session of the final high and low
• elapsed time until the final high and low
• intraday state relative to the prior close
• completed daily range
• directional streak entering the day

When the next trading day begins, the previous day is finalized and added to the historical dataset.

The model then rebuilds the current day's statistical context from completed observations.

This means the principal historical bias model does not require today's future closing result in order to calculate today's opening context.

━━━━━━━━━━━━━━━━━━━━━━
🔷 BULLISH / BEARISH RADAR
━━━━━━━━━━━━━━━━━━━━━━

The Bullish / Bearish Radar summarizes five historical checks.

WEEKDAY

The up-day rate of completed trading days sharing today's weekday.

PREV DAY

The up-day rate of historical days whose previous day moved in the same direction as yesterday.

3D REGIME

The up-day rate of historical days whose preceding three-day net move had the same directional sign as today's regime definition.

RECENT

The up-day rate across the most recent completed-day sample.

MOVE SKEW

The share of today's-weekday absolute historical movement that occurred in the positive direction.

Radar values represent historical observed shares, not probabilities.

The five checks also overlap, so they should not be interpreted as five independent forecasts.

━━━━━━━━━━━━━━━━━━━━━━
📐 SAMPLE DEPTH & STATISTICAL FILTERING
━━━━━━━━━━━━━━━━━━━━━━

Every historical percentage carries a sample size.

Minimum Sample controls how much historical depth is required before a check can influence the primary Daily Bias Score.

Directional-rate checks use a Wilson 95% interval.

A raw rate slightly above 50% is not automatically considered statistically bullish.

The check must:

• satisfy Minimum Sample
• have its Wilson interval fully above 50%

The equivalent bearish condition requires the interval to sit fully below 50%.

Move Skew uses a separate Student-t based test on the historical mean return.

These tests are historical evidence filters. They do not convert historical statistics into guaranteed future probabilities.

━━━━━━━━━━━━━━━━━━━━━━
📸 CODE EXAMPLE 1 — SAMPLE & WILSON FILTER
━━━━━━━━━━━━━━━━━━━━━━

[pine]setRateAxis(int i, float up, float n, float minN) =>
    array.set(axShare, i, n > 0 ? up / n * 100.0 : na)
    array.set(axN, i, n)
    array.set(axMinN, i, minN)

    [lo, hi] = wilson(up, n)

    int sig = 0
    if n >= minN
        sig := lo > 50.0 ? 1 : hi < 50.0 ? -1 : 0

    array.set(axSig, i, sig)[/pine]

The model keeps the observed percentage, supporting sample size, and statistical classification as separate pieces of information.

━━━━━━━━━━━━━━━━━━━━━━
🧠 DAILY BIAS SCORE
━━━━━━━━━━━━━━━━━━━━━━

Historical checks that satisfy their minimum sample requirement can contribute to the Daily Bias Score.

Each eligible check is measured relative to the neutral 50 level.

Its influence is weighted using the square root of its sample size.

This allows deeper samples to receive additional weight without allowing a very large sample to dominate the model linearly.

Conceptually:

validated historical share
→ distance from 50
→ √N sample weighting
→ weighted combination
→ Daily Bias Score

A score above 50 represents bullish historical context.

A score below 50 represents bearish historical context.

A score of 60 does not mean there is a 60% probability that price will close higher.

━━━━━━━━━━━━━━━━━━━━━━
📸 CODE EXAMPLE 2 — WEIGHTED BIAS MODEL
━━━━━━━━━━━━━━━━━━━━━━

[pine]float wSum = 0.0
float sSum = 0.0

for i = 0 to NAXES - 1
    float sh = array.get(axShare, i)
    float nn = array.get(axN, i)

    if not na(sh) and nn >= array.get(axMinN, i)
        wSum += math.sqrt(nn)
        sSum += math.sqrt(nn) * (sh - 50.0)

biasScore := wSum > 0 ? 50.0 + sSum / wSum : na[/pine]

━━━━━━━━━━━━━━━━━━━━━━
🔥 STRONG BULLISH / STRONG BEARISH DAYS
━━━━━━━━━━━━━━━━━━━━━━

A directional Daily Bias Score does not automatically become a strong classification.

Minimum Bias controls the required distance from the neutral 50 level.

When Require Significant Check is enabled, a Strong Bullish Day additionally requires:

• at least one statistically significant bullish check
• no statistically significant bearish checks

A Strong Bearish Day requires the opposite.

The engine also uses a warm-up requirement before strong classifications are allowed.

A strong classification should be interpreted as:

The historical conditions used by this model are unusually aligned in this direction.

It should not be interpreted as certainty about today's final close.

━━━━━━━━━━━━━━━━━━━━━━
📅 WEEKDAY INTELLIGENCE
━━━━━━━━━━━━━━━━━━━━━━

The weekday chart displays the directional history of available trading weekdays.

Each weekday can show:

• historical up-day rate
• completed sample size
• Wilson 95% interval
• average return
• average absolute move

Today's weekday is highlighted.

An optional ALL column displays the broader all-days directional baseline.

This comparison matters because an apparently strong weekday rate can be less meaningful when the instrument already has a similar unconditional directional drift.

Example:

Monday historical up-rate: 58%
All-days historical up-rate: 57%

The Monday number is above 50%, but its difference from the instrument's normal historical behavior is small.

━━━━━━━━━━━━━━━━━━━━━━
🎯 EXPECTED WEEKDAY RANGE
━━━━━━━━━━━━━━━━━━━━━━

When sufficient observations exist for today's weekday, the script builds a historical movement sample.

From this sample it calculates:

• P10
• P25
• P50
• P75
• P90

P10–P90 represents the broader historical distribution.

P25–P75 represents the central historical distribution.

P50 represents the historical median.

In Volatility-Adjusted mode, each historical return is normalized using the volatility available at that historical day's open and rescaled using today's volatility reference.

These ranges are empirical historical quantiles.

They are not guaranteed support/resistance boundaries or Take Profit levels.

━━━━━━━━━━━━━━━━━━━━━━
📸 CODE EXAMPLE 3 — WEEKDAY QUANTILES
━━━━━━━━━━━━━━━━━━━━━━

[pine]bool deep = array.size(samp) >= minSample

tP10 := deep ? array.percentile_linear_interpolation(samp, 10) : na
tP25 := deep ? array.percentile_linear_interpolation(samp, 25) : na
tP50 := deep ? array.percentile_linear_interpolation(samp, 50) : na
tP75 := deep ? array.percentile_linear_interpolation(samp, 75) : na
tP90 := deep ? array.percentile_linear_interpolation(samp, 90) : na[/pine]

━━━━━━━━━━━━━━━━━━━━━━
🕒 NOW — SAME-TIME-OF-DAY CONTEXT
━━━━━━━━━━━━━━━━━━━━━━

The NOW card studies the developing trading day from a different perspective.

During completed historical days, the script stores whether price was above or below the prior close at different stages of the trading day.

During today's developing session, it finds historical observations that were:

• at approximately the same stage of the trading day
• on the same side of their prior close

The model then measures how often those historical days eventually closed on that same side.

This distinguishes:

Price is currently above yesterday's close

from:

Historically, when price was already above yesterday's close around this point of the trading day, how often did it remain above into the final close?

The NOW card also compares this conditional result with the broader all-days baseline.

━━━━━━━━━━━━━━━━━━━━━━
📸 CODE EXAMPLE 4 — SAME-TIME-OF-DAY MATCHING
━━━━━━━━━━━━━━━━━━━━━━

[pine]if hasNow and math.floor(array.get(hMSeen, i) / pwNow) % 2 == 1
    bool wasUp = math.floor(array.get(hMUp, i) / pwNow) % 2 == 1

    if wasUp == nowUp
        lvN += 1.0
        lvK += up == nowUp ? 1.0 : 0.0[/pine]

Historical observations are completed days.

Today's live state remains provisional while the trading day develops.

━━━━━━━━━━━━━━━━━━━━━━
📍 PRIOR DAY HIGH / LOW
━━━━━━━━━━━━━━━━━━━━━━

Daily Bias Intelligence can extend completed prior-day highs and lows forward on the price chart.

Each level remains active until price trades through it on a confirmed chart bar.

When a break occurs:

• the level stops extending
• the line becomes visually muted
• the configured break marker is displayed

Historical statistics separately measure:

• prior-day high break rate
• prior-day low break rate
• both-side break rate
• neither-side / inside rate
• high-break hold rate
• low-break hold rate

A wick through the level counts as a break under the current model.

Prior-day highs and lows are analytical reference levels, not guaranteed support or resistance.

━━━━━━━━━━━━━━━━━━━━━━
⏱️ HIGH / LOW TIMING
━━━━━━━━━━━━━━━━━━━━━━

The indicator studies where and when completed trading days formed their final highs and lows.

For intraday charts, each completed high and low is associated with one of three fixed UTC windows:

• Asia — 21:00 to 08:00 UTC
• London — 08:00 to 13:00 UTC
• New York — 13:00 to 21:00 UTC

The HIGH / LOW TIMING card can display:

• the session that historically produced the most daily highs
• the session that historically produced the most daily lows
• how often the final high had already formed by the current point in the day
• how often the final low had already formed
• the session containing today's current high and low

Timing precision depends on the active chart timeframe.

━━━━━━━━━━━━━━━━━━━━━━
📏 STREAK & RANGE CONTEXT
━━━━━━━━━━━━━━━━━━━━━━

The STREAK & RANGE card combines two additional daily-context questions.

Directional streak

The script identifies consecutive positive or negative completed days entering the current trading day and studies historical days that followed a comparable streak.

Range development

The script calculates recent average daily high-low range and compares it with today's developing range.

The card can show:

• recent average range
• today's range so far
• percentage of normal range already used
• percentage of historical days that ultimately became wider than today's current range

This helps distinguish a relatively compressed day from one that has already consumed an unusually large share of its recent historical range.

━━━━━━━━━━━━━━━━━━━━━━
🌍 SESSION CONTRIBUTION
━━━━━━━━━━━━━━━━━━━━━━

Intraday price changes are attributed bar by bar to the fixed UTC session model.

For today's weekday, Daily Bias Intelligence calculates the historical average percentage contribution of:

• Asia
• London
• New York

Session contribution measures historical price movement.

It does not measure order flow or institutional activity.

The UTC windows do not dynamically adjust for daylight-saving changes.

━━━━━━━━━━━━━━━━━━━━━━
🧾 CALIBRATION SCORECARD
━━━━━━━━━━━━━━━━━━━━━━

Daily Bias Intelligence includes a calibration layer so important model outputs can be evaluated after the fact.

CALLS

Tracks completed Strong Bullish / Strong Bearish classifications and compares their directional hit rate with baseline drift.

RANGE HIT

Tracks how frequently completed trading days closed inside:

• P10–P90
• P25–P75

|MOVE|

Displays the historical average absolute movement for today's weekday and compares it with the all-days average.

SESSIONS

Displays historical average Asia, London, and New York contribution for today's weekday.

━━━━━━━━━━━━━━━━━━━━━━
📸 CODE EXAMPLE 5 — SEQUENTIAL CALIBRATION
━━━━━━━━━━━━━━━━━━━━━━

[pine]if todayStable and not na(tP10) and not na(tP90)
    calN    += 1.0
    calIn80 += (r >= tP10 and r <= tP90) ? 1.0 : 0.0
    calIn50 += (r >= tP25 and r <= tP75) ? 1.0 : 0.0

if callDir != 0 and allN > 0
    callN    += 1.0
    callHit  += ((r > 0) == (callDir > 0)) ? 1.0 : 0.0
    callBase += callDir > 0 ? allUp / allN : 1.0 - allUp / allN[/pine]

A projection is evaluated only after the corresponding trading day later completes.

The final result is not used to create the earlier projection being evaluated.

━━━━━━━━━━━━━━━━━━━━━━
📊 OSCILLATOR VIEWS
━━━━━━━━━━━━━━━━━━━━━━

The lower pane supports several presentation styles.

Off

Keeps the pane focused primarily on statistical panels.

Waveform

Displays the current day's running positive and negative excursion relative to the prior close.

Heat Stripes

Displays developing daily movement as a volatility-normalized background together with a rolling-return line.

Bar Columns

Displays the developing daily return as columns.

These views describe price behavior and do not independently determine the Daily Bias Score.

━━━━━━━━━━━━━━━━━━━━━━
📦 DAY BOXES & DAILY RESULTS
━━━━━━━━━━━━━━━━━━━━━━

The script can frame each trading day's high-low range with a Day Box.

A completed day's box receives its final contextual color after the day completes.

Today's live box remains dashed and updates as the high and low develop.

Completed daily-result labels can display the final daily percentage return.

Today's live percentage can also be displayed separately.

━━━━━━━━━━━━━━━━━━━━━━
🕯️ CANDLE COLORING
━━━━━━━━━━━━━━━━━━━━━━

Candle coloring can compare current price with the previous completed trading-day close.

Vs Prior Close

Price above the reference uses the bullish candle color.

Price below the reference uses the bearish candle color.

Because today's price is live, the contextual color can change throughout the session.

Off

Leaves the chart's native candle colors unchanged.

Candle coloring is visual context only.

━━━━━━━━━━━━━━━━━━━━━━
🚨 ALERT SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

Daily Bias Intelligence includes TradingView alert conditions for:

• Strong Bullish Day
• Strong Bearish Day
• Day Above Weekday P90
• Day Below Weekday P10
• Any Daily Bias Intelligence Alert

Strong-day alerts relate to the historical context generated for the new trading day.

P90 / P10 events trigger only after a confirmed chart bar closes beyond the corresponding weekday range level.

Alerts are monitoring tools and do not execute broker orders.

━━━━━━━━━━━━━━━━━━━━━━
🔔 HOW TO USE ALERTS
━━━━━━━━━━━━━━━━━━━━━━

For a specific alert:

1. Add Daily Bias Intelligence [tradewsamet] to the chart.
2. Open TradingView's Create Alert dialog.
3. Select Daily Bias Intelligence [tradewsamet].
4. Select the required alert event.
5. Choose the notification method.
6. Configure the alert frequency.
7. Test the alert before relying on it.

For a combined workflow:

1. Add the indicator to the chart.
2. Open Create Alert.
3. Select Daily Bias Intelligence [tradewsamet].
4. Select Any Daily Bias Intelligence Alert.
5. Configure the notification method.
6. Test the events on the intended symbol and timeframe.

If the script, symbol, timeframe, or important settings change materially, recreate the alert when necessary.

━━━━━━━━━━━━━━━━━━━━━━
🧪 HOW TO USE THE INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

A practical workflow:

1. Add Daily Bias Intelligence [tradewsamet] to a standard candlestick chart.
2. Make sure enough historical trading days are loaded for the selected Lookback and Minimum Sample.
3. Begin with Volatility-Adjusted Return Units if you want historical movement normalized across changing volatility regimes.
4. Review the Bullish / Bearish Radar.
5. Check the sample size behind each observation.
6. Review the Daily Bias Score and strong-state classification.
7. Compare today's weekday with the ALL baseline.
8. Review P10–P90, P25–P75, P50, and expected absolute movement.
9. Use NOW to compare today's developing state with similar completed historical days.
10. Review prior-day high / low behavior.
11. Review high / low timing.
12. Review streak and daily-range usage.
13. Review session contribution.
14. Use CALLS and RANGE HIT to judge calibration over meaningful samples.
15. Use alerts as monitoring assistance rather than automatic execution.

The indicator should be combined with independent market structure, liquidity, volatility, news, execution, position-sizing, and account-risk analysis.

━━━━━━━━━━━━━━━━━━━━━━
⚙️ SETTINGS REFERENCE
━━━━━━━━━━━━━━━━━━━━━━

⚙️ Statistics Engine

• Lookback Trading Days — number of completed trading days retained.
• Return Units — Volatility-Adjusted / Raw %.
• Volatility Length — completed-day volatility sample.
• Recent Window — completed days used by RECENT.
• Minimum Sample — minimum N required for qualified statistical use.

🧠 Bias Intelligence

• Minimum Bias — required Daily Bias Score displacement from 50.
• Require Significant Check — requires compatible statistical evidence.

📊 Oscillator & Statistics

• Statistics Panel
• Panel Position
• Panel Width / Height
• Text Size
• Plot Style
• Rolling Line
• Today's Expected Range
• Weekday Median
• Daily Result Labels
• Label Location
• Days Shown

📍 Prior Day High / Low

• Show Prior Day High / Low
• Days Kept
• Break Marker

📦 Day Boxes

• Show Day Boxes
• Box Fill Transparency

🧭 Weekday Chart & Scorecard

• Show Weekday Chart
• Show Scorecard
• Main Chart / Pane placement
• Position
• Width
• Bar Area Height
• Show All-Days Column

🔷 Bullish / Bearish Radar

• Show Radar
• Offset
• Radius Bars
• Radius σ

🕯️ Chart Candles

• Candle Colouring — Vs Prior Close / Off
• Bullish Candle Color
• Bearish Candle Color

🎨 Theme & Colours

• Auto
• Dark
• Light
• supporting visual accent controls

Visual and theme changes do not alter the underlying historical calculations.

━━━━━━━━━━━━━━━━━━━━━━
🧠 WHAT MAKES THIS SCRIPT ORIGINAL
━━━━━━━━━━━━━━━━━━━━━━

Daily returns, weekday statistics, volatility normalization, confidence intervals, quantiles, daily highs/lows, and prior-day levels are established analytical concepts.

Daily Bias Intelligence does not claim ownership of those individual concepts.

Its originality lies in how they are coordinated into one completed-day state model.

The implementation combines:

completed-day historical storage
→ weekday context
→ previous-day context
→ three-day regime
→ recent directional context
→ Move Skew
→ Minimum Sample validation
→ Wilson / Student-t statistical filtering
→ √N-weighted Daily Bias Score
→ strong-bias gating
→ volatility-adjusted weekday quantiles
→ same-time-of-day state matching
→ prior-day high / low behavior
→ daily high / low timing
→ streak and range intelligence
→ session contribution
→ sequential range and directional calibration

Distinctive implementation choices include:

• separating observed historical rates from modeled bias
• preventing thin samples from influencing the primary score
• applying statistical filters before strong classifications
• weighting eligible observations by square-root sample depth
• separating live current-day state from completed historical results
• storing historical intraday state for same-time-of-day comparison
• comparing strong-call results with baseline drift
• evaluating projected ranges only after their corresponding days complete

The modules serve one coordinated objective:

making the historical structure surrounding the current trading day visible, measurable, and reviewable.

━━━━━━━━━━━━━━━━━━━━━━
⚠️ IMPORTANT PRACTICAL NOTES
━━━━━━━━━━━━━━━━━━━━━━

Daily Bias Intelligence depends on available chart history.

Important points:

• Low intraday timeframes can contain fewer completed trading days within the same loaded-bar allowance.
• Every rate should be interpreted together with its sample size.
• Minimum Sample prevents thin observations from influencing key parts of the model.
• Expected weekday ranges require sufficient weekday history.
• Volatility-Adjusted mode changes movement normalization but not directional up/down classification.
• RECENT uses at least the Minimum Sample requirement when the configured Recent Window is smaller.
• Flat completed days are treated as not-up.
• Today's return, high, low, range, NOW state, and contextual candle colors remain live.
• Statistical significance is not certainty.
• Strong historical states and range projections can fail.
• Historical relationships can change as market regimes change.
• Changing important settings rebuilds the historical model under the new configuration.

━━━━━━━━━━━━━━━━━━━━━━
⚠️ LIMITATIONS AND SHORTCOMINGS
━━━━━━━━━━━━━━━━━━━━━━

This script has important limitations:

• Historical frequency is not future probability.
• A statistically significant historical observation does not guarantee today's result.
• The five radar checks overlap and are not independent evidence.
• Multiple comparisons create a risk of chance findings.
• The Daily Bias Score is modeled context, not expected return or probability.
• Strong Bullish / Strong Bearish classifications can be incorrect.
• Sample depth is limited by available chart history.
• Low-timeframe charts may contain relatively few completed trading days.
• Volatility adjustment can react slowly to sudden regime changes.
• Historical quantiles are not fixed future boundaries.
• Prior-day high / low breaks can fail after occurring.
• Session attribution uses fixed UTC hours and does not dynamically adjust for daylight-saving changes.
• Extended-hours data can influence calculations where available.
• High / low timing is limited by chart timeframe resolution.
• Holiday and shortened-session days are treated as normal completed trading days.
• Current-day values remain provisional until the trading day completes.
• Different feeds, symbols, chart history, and timeframes can produce different statistics.

The indicator should be treated as a statistical context tool rather than a standalone predictive system.

━━━━━━━━━━━━━━━━━━━━━━
👤 WHO THIS SCRIPT MAY BE USEFUL FOR
━━━━━━━━━━━━━━━━━━━━━━

Daily Bias Intelligence may be useful for traders who:

• want historical daily context before evaluating intraday setups
• study weekday tendencies
• want sample sizes beside historical percentages
• prefer statistical filtering over raw percentages alone
• study prior-day highs and lows
• monitor daily-range development
• study when final daily highs and lows tend to form
• compare the current stage of the day with completed historical observations
• want directional context without automatic trade entries
• want historical expected-range information
• value calibration and transparent statistical assumptions

It may be less suitable for users who require automatic entries, automatic SL/TP systems, broker execution, tick-level reconstruction, account-level Strategy Tester results, or guaranteed directional predictions.

━━━━━━━━━━━━━━━━━━━━━━
🧭 BEST PRACTICE SUGGESTIONS
━━━━━━━━━━━━━━━━━━━━━━

For normal use:

• start with sufficient completed-day history
• keep Minimum Sample high enough that thin observations do not dominate interpretation
• compare weekday percentages with the ALL baseline
• read the Daily Bias Score together with the individual radar checks
• distinguish directional lean from a Strong Bullish / Strong Bearish state
• interpret statistical significance as evidence strength, not certainty
• treat expected ranges as historical distributions rather than fixed price barriers
• use NOW as live context rather than a standalone signal
• combine prior-day level statistics with current price behavior
• review CALLS versus drift rather than raw hit rate alone
• wait for meaningful calibration samples before drawing conclusions
• compare symbols and timeframes independently

When testing inputs, change one major group at a time so the effect on sample size, bias classification, expected range, and calibration remains understandable.

━━━━━━━━━━━━━━━━━━━━━━
🔓 PUBLICATION NOTE
━━━━━━━━━━━━━━━━━━━━━━

Daily Bias Intelligence [tradewsamet] is published as an educational daily-statistics, historical-bias, intraday-context, expected-range, calibration, visualization, and alert indicator.

This description documents the main mechanics used by the script, including:

• completed-day historical storage
• weekday analysis
• previous-day and three-day context
• recent directional behavior
• Move Skew
• statistical filtering
• Daily Bias Score
• strong-bias classification
• expected weekday distributions
• volatility adjustment
• same-time-of-day analysis
• prior-day high / low behavior
• high / low timing
• streak and range analysis
• session attribution
• sequential calibration
• visualizations and alerts

These modules serve one coordinated purpose:

providing a transparent statistical description of the current trading day based primarily on completed historical observations.

The script does not promise profitable results, remove market risk, or replace independent analysis and personal risk management.

━━━━━━━━━━━━━━━━━━━━━━
🕒 DATA TIMING, REPAINTING, AND HISTORICAL PLACEMENT DISCLOSURE
━━━━━━━━━━━━━━━━━━━━━━

Daily Bias Intelligence v1.0 builds its principal historical model from completed trading days.

A trading day is finalized when the script detects the beginning of the next trading day.

The previous day's completed data is then added to the historical dataset.

The current day's:

• radar checks
• Daily Bias Score
• strong historical-bias classification
• weekday distributions
• expected range
• expected absolute movement
• historical session averages

are rebuilt from completed historical observations.

The v1.0 daily model does not use a higher-timeframe request.security() feed or future-data lookahead process for these calculations.

Some values are intentionally developing realtime values and can change while today's market develops:

• today's return versus the prior close
• today's high and low
• today's range and range usage
• NOW-card state
• today's high/low session labels
• live day box
• contextual candle coloring

This is normal current-day development and should not be confused with using future historical information.

Prior-day high / low breaks require a confirmed chart bar before they are finalized.

Completed daily-result labels are created only after the corresponding trading day completes.

High / low timing stores the first chart bar that produced the observed extreme, so precision depends on the active timeframe.

Historical calculations can legitimately change when the symbol, timeframe, data feed, available history, Lookback, Volatility Length, Recent Window, Minimum Sample, or Return Units change.

During historical warm-up, the model grows as completed trading days accumulate.

No strong daily classification is permitted until the required warm-up has been satisfied.

These controls reduce hindsight risk in the primary historical model but do not eliminate market uncertainty, regime change, sampling risk, statistical error, or data-feed differences.

━━━━━━━━━━━━━━━━━━━━━━
🛡️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━

Daily Bias Intelligence [tradewsamet] is provided for educational and informational purposes only.

It does not constitute financial, investment, trading, legal, accounting, or tax advice.

Historical rates, Wilson intervals, statistical classifications, Move Skew, Daily Bias Scores, Strong Bullish / Strong Bearish states, weekday ranges, expected movement, session statistics, prior-day levels, calibration results, visualizations, and alerts are analytical outputs only.

No indicator can guarantee future market direction or profitability.

Historical relationships can weaken, disappear, or reverse as volatility, liquidity, market structure, participation, macroeconomic conditions, market regimes, and data characteristics change.

Every user remains responsible for independent analysis, validation, symbol and timeframe selection, settings, position sizing, account risk, execution planning, broker execution, alert configuration, and applicable legal or tax obligations.

Use Daily Bias Intelligence as a transparent daily statistical-context and historical-review framework — not as a promise of profitability or a substitute for independent judgment.

---

## Source Code

````pine
//@version=6
// Version: v1.0 RELEASE

indicator("Daily Bias Intelligence [tradewsamet]",
     shorttitle          = "Daily Bias Intelligence [tradewsamet]",
     overlay             = false,
     max_bars_back       = 600,
     max_labels_count    = 500,
     max_lines_count     = 100,
     max_polylines_count = 20,
     max_boxes_count     = 500)

// ═══════════════════════════════════════════════════════════════════════════
// 1. USER SETTINGS

var string GENG = "⚙️ ENGINE"

lookbackDays = input.int(250, "🗃️ Lookback Days", minval = 40, maxval = 1000, step = 10,
     group = GENG, display = display.none,
     tooltip = "🗃️ LOOKBACK DAYS\n\nNumber of completed trading days kept in the statistical sample.\n\n• Higher values = smoother, more stable statistics.\n• Lower values = faster adaptation to recent market conditions.\n• The chart must contain enough history for the selected value.\n\n⚠️ Strong calls stay disabled until the warm-up requirement is satisfied.")

normMode = input.string("Volatility-Adjusted", "📐 Return Units",
     options = ["Volatility-Adjusted", "Raw %"], group = GENG, display = display.none,
     tooltip = "📐 RETURN UNITS\n\nControls how historical daily movement is normalised.\n\n• Volatility-Adjusted — historical returns are scaled by the volatility known at each day's open, then translated into today's volatility environment.\n• Raw % — uses plain percentage returns.\n\nAffects expected ranges, expected |move| and Move Skew. Directional up-rates are unchanged.")

volLen = input.int(20, "🌡️ Volatility Length", minval = 5, maxval = 100,
     group = GENG, display = display.none,
     tooltip = "🌡️ VOLATILITY LENGTH\n\nNumber of completed trading days used to estimate daily volatility.\n\nThis value is automatically capped by Lookback Days.")

recentLen = input.int(20, "🕒 Recent Window", minval = 5, maxval = 100,
     group = GENG, display = display.none,
     tooltip = "🕒 RECENT WINDOW\n\nNumber of most recent completed days used by the RECENT radar check.\n\nIf this value is below Minimum Sample, the engine automatically raises the effective window to Minimum Sample.")

minSample = input.int(20, "🧪 Minimum Sample", minval = 5, maxval = 200,
     group = GENG, display = display.none,
     tooltip = "🧪 MINIMUM SAMPLE\n\nMinimum historical sample required before a check is treated as statistically usable.\n\nBelow this N:\n• the check is marked as thin / limited,\n• it cannot become statistically significant,\n• weekday expected ranges are not produced.\n\nHigher values reduce noise but require more chart history.")

var string GBIA = "🧠 BIAS INTELLIGENCE"

biasMin = input.float(3.0, "🎯 Minimum Bias", minval = 0.5, maxval = 20.0, step = 0.5,
     group = GBIA, display = display.none,
     tooltip = "🎯 MINIMUM BIAS\n\nMinimum distance, in points, that the Bias Score must move away from 50 before the engine can classify the day as strongly bullish or bearish.\n\nHigher value = fewer but stricter strong calls.")

requireSig = input.bool(true, "✅ Require Significant Check",
     group = GBIA, display = display.none,
     tooltip = "✅ REQUIRE SIGNIFICANT CHECK\n\nON — at least one radar check must be statistically significant in the call direction, with no significant check opposing it.\n\nOFF — the Bias Score threshold alone can create a strong call.\n\nRecommended default: ON.")

var string GOSC = "📊 OSCILLATOR & STATISTICS"

showStats = input.bool(true, "📋 Statistics Panel",
     group = GOSC, display = display.none,
     tooltip = "📋 STATISTICS PANEL\n\nShows four live context cards:\n• NOW\n• PRIOR DAY HIGH / LOW\n• HIGH / LOW TIMING\n• STREAK & RANGE\n\n✓ = enough historical evidence and clearly away from 50/50.\n'few' = sample is below Minimum Sample.")

statPos = input.string("Middle Left", "📍 Panel Position",
     options = ["Top Left", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Right"],
     group = GOSC, display = display.none, active = showStats,
     tooltip = "📍 PANEL POSITION\n\nChoose where the four-card statistics panel appears inside the oscillator pane.")

statW = input.float(73.0, "↔️ Panel Width (%)", minval = 30.0, maxval = 100.0, step = 1.0,
     group = GOSC, display = display.none, active = showStats,
     tooltip = "↔️ PANEL WIDTH\n\nTotal width of the statistics panel as a percentage of the pane.\n\nFor a clean layout, keep Panel Width + Weekday Chart Width near or below 100%.")

statH = input.float(94.0, "↕️ Panel Height (%)", minval = 30.0, maxval = 100.0, step = 1.0,
     group = GOSC, display = display.none, active = showStats,
     tooltip = "↕️ PANEL HEIGHT\n\nControls the vertical size of the statistics cards inside the pane.")

statTxt = input.string("Normal", "🔠 Text Size",
     options = ["Small", "Normal", "Large"], group = GOSC, display = display.none,
     tooltip = "🔠 TEXT SIZE\n\nControls text size across all tables, dashboards and chart labels.\n\n• Small — compact screens.\n• Normal — recommended default.\n• Large — large monitors / presentations.")

oscStyle = input.string("Off", "📈 Plot Style",
     options = ["Off", "Waveform", "Heat Stripes", "Bar Columns"],
     group = GOSC, display = display.none,
     tooltip = "📈 PLOT STYLE\n\nChoose the oscillator visualisation.\n\n• Off — dashboard / statistics only.\n• Waveform — developing intraday stretch above and below the prior close.\n• Heat Stripes — one heat stripe per trading day plus rolling return.\n• Bar Columns — developing daily return as columns.\n\nAll realtime views are built bar by bar and do not backfill future information.")

rollDays = input.int(20, "🔄 Rolling Line", minval = 2, maxval = 250,
     group = GOSC, display = display.none, active = oscStyle == "Heat Stripes",
     tooltip = "🔄 ROLLING LINE\n\nUsed by Heat Stripes.\nShows the sum of the last N daily returns, including today's developing return.")

showBand = input.bool(true, "🎯 Today's Expected Range",
     group = GOSC, display = display.none, active = oscStyle != "Off",
     tooltip = "🎯 TODAY'S EXPECTED RANGE\n\nDisplays the historical weekday range projected for today.\n\n• Outer band: P10–P90.\n• Inner band: P25–P75.\n• Fixed from completed historical data at the start of the trading day.")

showMedian = input.bool(true, "➗ Weekday Median",
     group = GOSC, display = display.none, active = showBand and oscStyle != "Off",
     tooltip = "➗ WEEKDAY MEDIAN\n\nShows the historical median return for today's weekday inside the expected-range visual.")

showDayLbl = input.bool(true, "🏷️ Daily Result Labels",
     group = GOSC, display = display.none,
     tooltip = "🏷️ DAILY RESULT LABELS\n\nShows each completed day's final return, for example +1.60% or -2.00%.\n\nA historical label is created only after that trading day has completed.")

dayLblWhere = input.string("Main Chart", "📌 Label Location",
     options = ["Oscillator", "Main Chart"], group = GOSC, display = display.none, active = showDayLbl,
     tooltip = "📌 LABEL LOCATION\n\nChoose whether daily result labels appear on the main price chart or inside the oscillator pane.")

dayLblMax = input.int(60, "🗓️ Days Shown", minval = 5, maxval = 400,
     group = GOSC, display = display.none,
     tooltip = "🗓️ DAYS SHOWN\n\nMaximum number of completed daily result labels and day boxes retained on the chart.")

var string GPDL = "📍 PRIOR DAY HIGH / LOW"

showPDHL = input.bool(true, "📏 Show Prior Day H/L",
     group = GPDL, display = display.none,
     tooltip = "📏 PRIOR DAY HIGH / LOW\n\nDraws the completed day's high and low forward into future bars.\n\nEach level extends until price trades through it on a confirmed bar. The breaking bar receives the selected break marker.")

pdMax = input.int(5, "🧱 Days Kept", minval = 1, maxval = 20,
     group = GPDL, display = display.none, active = showPDHL,
     tooltip = "🧱 DAYS KEPT\n\nNumber of recent days whose prior-day high / low lines remain on the chart, whether broken or still active.")

brkMark = input.string("✕", "💥 Break Marker",
     group = GPDL, display = display.none, active = showPDHL,
     tooltip = "💥 BREAK MARKER\n\nText or emoji placed on the confirmed bar that breaks a prior-day level.\n\nExamples: ✕  ✖  💥  ⚡")

var string GBOX = "🗓️ DAY BOXES"

showDayBox = input.bool(true, "🧩 Show Day Boxes",
     group = GBOX, display = display.none,
     tooltip = "🧩 DAY BOXES\n\nFrames each trading day from its high to its low on the main chart.\n\n• Completed day = final directional colour.\n• Current day = dashed live box.\n• Retention follows Days Shown.")

dayBoxFill = input.int(92, "🌫️ Fill Transparency", minval = 70, maxval = 100,
     group = GBOX, display = display.none, active = showDayBox,
     tooltip = "🌫️ FILL TRANSPARENCY\n\nControls day-box background transparency.\n\nHigher value = lighter / more transparent fill.")

var string GMAP = "🧭 WEEKDAY INTELLIGENCE"

showMap = input.bool(true, "📅 Weekday Chart",
     group = GMAP, display = display.none,
     tooltip = "📅 WEEKDAY CHART\n\nDisplays the historical up-day rate for each trading weekday.\n\nHover a weekday for sample size, Wilson 95% interval, average return and average absolute move.")

showScore = input.bool(true, "🧾 Calibration Scorecard",
     group = GMAP, display = display.none, active = showMap,
     tooltip = "🧾 CALIBRATION SCORECARD\n\nAdds four validation rows below the weekday chart:\n• strong-call hit rate vs drift,\n• range hit rates,\n• today's expected |move|,\n• average session contribution.")

mapOnChart = input.bool(false, "🖥️ Show On Main Chart",
     group = GMAP, display = display.none, active = showMap,
     tooltip = "🖥️ SHOW ON MAIN CHART\n\nON — places the weekday table over the main price chart.\nOFF — keeps it inside the oscillator pane.")

mapPos = input.string("Bottom Right", "📍 Position",
     options = ["Top Left", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Right"],
     group = GMAP, display = display.none, active = showMap,
     tooltip = "📍 POSITION\n\nChoose the table location for the weekday chart and scorecard.")

mapW = input.float(24.0, "↔️ Width (%)", minval = 10.0, maxval = 60.0, step = 1.0,
     group = GMAP, display = display.none, active = showMap,
     tooltip = "↔️ WEEKDAY CHART WIDTH\n\nControls total weekday-chart width. Active weekday columns divide this width evenly.")

mapH = input.float(45.0, "↕️ Bar Area Height (%)", minval = 10.0, maxval = 90.0, step = 1.0,
     group = GMAP, display = display.none, active = showMap,
     tooltip = "↕️ BAR AREA HEIGHT\n\nControls the vertical area used by weekday columns.\n\nIncrease on tall panes, reduce on compact panes.")

showBaseRow = input.bool(true, "🌐 All-Days Baseline",
     group = GMAP, display = display.none, active = showMap,
     tooltip = "🌐 ALL-DAYS BASELINE\n\nAdds an ALL column so each weekday can be compared with the symbol's overall historical up-day rate.")

var string GRAD = "🔷 BULLISH / BEARISH RADAR"

showRadar = input.bool(true, "🔷 Show Radar",
     group = GRAD, display = display.none,
     tooltip = "🔷 BULLISH / BEARISH RADAR\n\nDraws five historical context checks to the right of price:\n• WEEKDAY\n• PREV DAY\n• 3D REGIME\n• RECENT\n• MOVE SKEW\n\nThe 50% ring is neutral. These are observed historical shares, not probabilities.")

radarOffset = input.int(8, "↔️ Offset (Bars)", minval = 2, maxval = 150,
     group = GRAD, display = display.none, active = showRadar,
     tooltip = "↔️ RADAR OFFSET\n\nHorizontal distance, in bars, between the last chart bar and the radar.")

radarWidth = input.int(14, "📐 Radius (Bars)", minval = 5, maxval = 150,
     group = GRAD, display = display.none, active = showRadar,
     tooltip = "📐 RADAR RADIUS\n\nControls the horizontal radius of the radar in bar units.")

radarHeight = input.float(0.8, "↕️ Radius (σ)", minval = 0.2, maxval = 6.0, step = 0.1,
     group = GRAD, display = display.none, active = showRadar,
     tooltip = "↕️ RADAR HEIGHT\n\nVertical radar radius expressed in daily-volatility units and translated into price space.\n\nUses a 1% fallback before volatility is available.")

var string GCHT = "🕯️ CHART CANDLES"

candleMode = input.string("Vs Prior Close", "🎨 Candle Colouring",
     options = ["Vs Prior Close", "Off"],
     group = GCHT, display = display.none,
     tooltip = "🎨 CANDLE COLOURING\n\n• Vs Prior Close — realtime context. Candles above the prior close use the bullish colour; candles below use the bearish colour. This can flip intraday.\n\n• Off — native chart colours.")

candleUp = input.color(#22D3EE, "🩵 Bullish Candle",
     group = GCHT, display = display.none, active = candleMode != "Off",
     tooltip = "🩵 BULLISH CANDLE\n\nColour used only for bullish chart candles.\n\nDefault restores the original Daily Bias Intelligence cyan candle style.")

candleDn = input.color(#F472B6, "🩷 Bearish Candle",
     group = GCHT, display = display.none, active = candleMode != "Off",
     tooltip = "🩷 BEARISH CANDLE\n\nColour used only for bearish chart candles.\n\nDefault restores the original Daily Bias Intelligence pink candle style.")

var string GCOL = "🎨 THEME & COLOURS"

theme = input.string("Auto", "🌓 Theme",
     options = ["Auto", "Dark", "Light"], group = GCOL, display = display.none,
     tooltip = "🌓 THEME\n\n• Auto — follows the chart background.\n• Dark — optimized for dark tradewsamet layouts.\n• Light — optimized for white backgrounds.\n\nAccent text is automatically adjusted for readability.")

colUp = input.color(#22C55E, "🟢 Bullish",
     group = GCOL, display = display.none,
     tooltip = "🟢 BULLISH COLOUR\n\nUsed for positive daily movement, bullish radar values, bullish day boxes and related highlights.")

colDn = input.color(#EF4444, "🔴 Bearish",
     group = GCOL, display = display.none,
     tooltip = "🔴 BEARISH COLOUR\n\nUsed for negative daily movement, bearish radar values, bearish day boxes and related highlights.")

colGrid = input.color(#E11D48, "🔺 Brand Accent",
     group = GCOL, display = display.none,
     tooltip = "🔺 BRAND ACCENT\n\nPrimary tradewsamet accent used for radar structure, prior-day context and selected highlights.")

colCoin = input.color(#F59E0B, "🟠 Warning / Neutral",
     group = GCOL, display = display.none,
     tooltip = "🟠 WARNING / NEUTRAL\n\nUsed for the radar's 50% neutral ring, timing context and attention states.")

colAcc = input.color(#94A3B8, "⚪ Secondary Accent",
     group = GCOL, display = display.none,
     tooltip = "⚪ SECONDARY ACCENT\n\nNeutral secondary accent used by supporting dashboard elements.")

// ═══════════════════════════════════════════════════════════════════════════
// 2. CORE CONSTANTS · THEME · HELPERS

int NSTRIP = 20      // weekday chart bar segments
int NAXES  = 5       // radar checks

bool volAdj    = normMode == "Volatility-Adjusted"
int  volLenEff = math.min(volLen, lookbackDays)
int  warmDays  = lookbackDays + (volAdj ? volLenEff : 3)
bool intraday  = timeframe.in_seconds(timeframe.period) < 86400

if timeframe.in_seconds(timeframe.period) > 86400
    runtime.error("Daily Bias Intelligence requires a daily or lower chart timeframe.")

bgLum    = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
isDark   = theme == "Dark" ? true : theme == "Light" ? false : bgLum < 128
cNeut    = isDark ? #C9CED8 : #3A4150
cPanelBg = isDark ? #0F1117 : #FFFFFF
cCard    = isDark ? #12151B : #F5F6F8     // card surface
cCard2   = isDark ? #1B1F28 : #E9ECF1     // empty bar track
cTxt     = isDark ? #E6E9EF : #1A1F2B
cMute    = isDark ? #8E97AB : #5E677A

fmtBI    = text.format_bold + text.format_italic

string uiSz  = statTxt == "Large" ? size.large  : statTxt == "Small" ? size.small : size.normal
string lblSz = statTxt == "Large" ? size.normal : statTxt == "Small" ? size.tiny  : size.small

dowName(int d) =>
    switch d
        dayofweek.monday    => "MON"
        dayofweek.tuesday   => "TUE"
        dayofweek.wednesday => "WED"
        dayofweek.thursday  => "THU"
        dayofweek.friday    => "FRI"
        dayofweek.saturday  => "SAT"
        dayofweek.sunday    => "SUN"
        => "—"

fPct(float v) =>
    na(v) ? "—" : (v > 0 ? "+" : "") + str.tostring(v, "0.00") + "%"

fRate(float v) =>
    na(v) ? "—" : str.tostring(v, "0.0") + "%"

fCount(float v) =>
    str.tostring(math.round(v))

sesOf(int hU) =>
    hU >= 8 and hU < 13 ? 1 : hU >= 13 and hU < 21 ? 2 : 0

darken(color c, float f) =>
    color.rgb(color.r(c) * f, color.g(c) * f, color.b(c) * f)

sesName(int s) =>
    s == 0 ? "ASIA" : s == 1 ? "LONDON" : s == 2 ? "NY" : "—"

ink(color c) =>
    isDark ? c : darken(c, 0.70)

cUpTxt = ink(colUp)
cDnTxt = ink(colDn)

tablePosition(string p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Middle Left"  => position.middle_left
        "Middle Right" => position.middle_right
        "Bottom Right" => position.bottom_right
        => position.bottom_left

wilson(float k, float n) =>
    float lo = na
    float hi = na
    if n > 0
        float z = 1.96
        float p = k / n
        float d = 1.0 + z * z / n
        float c = (p + z * z / (2.0 * n)) / d
        float h = z * math.sqrt(p * (1.0 - p) / n + z * z / (4.0 * n * n)) / d
        lo := (c - h) * 100.0
        hi := (c + h) * 100.0
    [lo, hi]

sigmaOfLast(array<float> a, int len) =>
    float s = na
    int n = array.size(a)
    if n >= len and len > 1
        float m = 0.0
        for i = n - len to n - 1
            m += array.get(a, i)
        m /= len
        float v = 0.0
        for i = n - len to n - 1
            float dv = array.get(a, i) - m
            v += dv * dv
        s := math.sqrt(v / (len - 1))
    s

// ═══════════════════════════════════════════════════════════════════════════
// 3. TRADING-DAY ENGINE

var array<float> hRet  = array.new<float>()   // raw % return
var array<float> hZ    = array.new<float>()   // return / σ known at that day's OPEN (na in warm-up)
var array<int>   hDow  = array.new<int>()     // trading weekday
var array<int>   hPrev = array.new<int>()     // prior-day direction known at that day's open: 1 / -1 / 0
var array<int>   hReg  = array.new<int>()     // prior 3-day net direction known at that day's open: 1 / -1 / 0
var array<float> hChg  = array.new<float>()   // raw price change of the completed day
var array<float> hAs   = array.new<float>()   // Asia contribution, % of reference
var array<float> hLd   = array.new<float>()   // London contribution
var array<float> hNy   = array.new<float>()   // New York contribution
var array<int>   hBrkH  = array.new<int>()    // day high traded above the prior day's high: 1 / 0 (−1 = no prior day)
var array<int>   hBrkL  = array.new<int>()    // day low traded below the prior day's low
var array<int>   hHeldH = array.new<int>()    // after a PDH break, closed above it: 1 / 0 (−1 = no break)
var array<int>   hHeldL = array.new<int>()    // after a PDL break, closed below it
var array<int>   hHiSes = array.new<int>()    // session where the day's high formed: 0 Asia · 1 London · 2 NY (−1 = daily chart)
var array<int>   hLoSes = array.new<int>()
var array<float> hHiEl  = array.new<float>()  // ms from the day's first bar to its high
var array<float> hLoEl  = array.new<float>()
var array<float> hMUp   = array.new<float>()  // bit h = above the prior close at the end of hour h of the day
var array<float> hMSeen = array.new<float>()  // bit h = the day had a bar in hour h
var array<float> hRng   = array.new<float>()  // high–low range, % of reference
var array<int>   hStk   = array.new<int>()    // signed streak of same-direction days before this day

var float dayRef      = na
var int   todayDow    = na
var int   todayPrev   = 0
var int   todayReg    = 0
var float todaySigma  = na
var float drawSigma   = na
var int   daysDone    = 0
var bool  todayStable = false
var int   dayStartBar = 0
var float baseSum     = na      // Σ of the last (Rolling Line − 1) completed returns
var float dayHi       = na
var float dayLo       = na
var float sAs         = 0.0     // today's running session attribution
var float sLd         = 0.0
var float sNy         = 0.0
var int   dayStartTime = na
var float prvHi       = na      // high / low of the last completed day
var float prvLo       = na
var float hiEl        = na      // today's high / low: ms after the day's first bar, and session
var float loEl        = na
var int   hiSes       = -1
var int   loSes       = -1
var int   todayStreak = 0
var array<int> dSign  = array.new<int>(24, -1)   // today: 1 above / 0 not above the prior close at the end of each hour

var array<float> wkN   = array.new<float>(7, 0.0)
var array<float> wkUp  = array.new<float>(7, 0.0)
var array<float> wkSum = array.new<float>(7, 0.0)
var array<float> wkAbs = array.new<float>(7, 0.0)
var float allN  = 0.0
var float allUp = 0.0

var array<float> axShare = array.new<float>(5, na)
var array<float> axN     = array.new<float>(5, 0.0)
var array<float> axMinN  = array.new<float>(5, 0.0)
var array<int>   axSig   = array.new<int>(5, 0)

var float biasScore = na
var int   callDir   = 0
var float tP10      = na
var float tP25      = na
var float tP50      = na
var float tP75      = na
var float tP90      = na
var float tExpAbs   = na     // expected |move| today, %
var float tVolRatio = na     // today's weekday mean |move| / all days
var float tAs       = na     // today's weekday average session contribution, %
var float tLd       = na
var float tNy       = na
var float tSesN     = 0.0

var float calN     = 0.0
var float calIn80  = 0.0
var float calIn50  = 0.0
var float callN    = 0.0
var float callHit  = 0.0
var float callBase = 0.0

var array<label> dayLabels = array.new<label>()
var array<box>   dayBoxes  = array.new<box>()

var array<line>  pdLines = array.new<line>()
var array<float> pdPrice = array.new<float>()
var array<bool>  pdIsHi  = array.new<bool>()
var array<bool>  pdAlive = array.new<bool>()
var array<label> pdMarks = array.new<label>()

setRateAxis(int i, float up, float n, float minN) =>
    array.set(axShare, i, n > 0 ? up / n * 100.0 : na)
    array.set(axN, i, n)
    array.set(axMinN, i, minN)
    [lo, hi] = wilson(up, n)
    int sig = 0
    if n >= minN
        sig := lo > 50.0 ? 1 : hi < 50.0 ? -1 : 0
    array.set(axSig, i, sig)

var float lastRegClose = na
var bool  regToday     = false
bool newDay = bar_index == 0 or time_tradingday != time_tradingday[1]

if newDay
    if bar_index > 0 and regToday and not na(dayRef) and dayRef != 0
        float r = (lastRegClose - dayRef) / math.abs(dayRef) * 100.0

        if showDayBox
            color bxC = r >= 0 ? colUp : colDn
            array.push(dayBoxes, box.new(dayStartBar, dayHi, bar_index - 1, dayLo, xloc = xloc.bar_index,
                 border_color = color.new(bxC, 35), border_width = 1, bgcolor = color.new(bxC, dayBoxFill), force_overlay = true))
            if array.size(dayBoxes) > dayLblMax
                box.delete(array.shift(dayBoxes))

        if showPDHL and not na(dayHi) and not na(dayLo)
            array.push(pdLines, line.new(bar_index - 1, dayHi, bar_index, dayHi, xloc = xloc.bar_index,
                 color = color.new(colUp, 15), width = 1, force_overlay = true))
            array.push(pdPrice, dayHi)
            array.push(pdIsHi, true)
            array.push(pdAlive, true)
            array.push(pdLines, line.new(bar_index - 1, dayLo, bar_index, dayLo, xloc = xloc.bar_index,
                 color = color.new(colDn, 15), width = 1, force_overlay = true))
            array.push(pdPrice, dayLo)
            array.push(pdIsHi, false)
            array.push(pdAlive, true)
            while array.size(pdLines) > pdMax * 2
                line.delete(array.shift(pdLines))
                array.shift(pdPrice)
                array.shift(pdIsHi)
                array.shift(pdAlive)

        if showDayLbl
            int    xMid    = int(math.round((dayStartBar + bar_index - 1) / 2.0))
            bool   isPos   = r >= 0
            bool   onChart = dayLblWhere == "Main Chart"
            float  yOsc    = oscStyle == "Heat Stripes" ? (na(baseSum) ? na : baseSum + r) : r
            float  yL      = onChart ? (isPos ? dayHi : dayLo) : yOsc
            string lSt     = isPos ? label.style_label_down : label.style_label_up
            color  lTx     = isPos ? cUpTxt : cDnTxt
            label  dl      = na
            if onChart
                dl := label.new(xMid, yL, fPct(r), xloc = xloc.bar_index, style = lSt, size = size.small,
                     color = color.new(cPanelBg, 100), textcolor = lTx, text_formatting = fmtBI, force_overlay = true)
            else
                dl := label.new(xMid, yL, fPct(r), xloc = xloc.bar_index, style = lSt, size = size.small,
                     color = color.new(cPanelBg, 100), textcolor = lTx, text_formatting = fmtBI, force_overlay = false)
            array.push(dayLabels, dl)
            if array.size(dayLabels) > dayLblMax
                label.delete(array.shift(dayLabels))

        if todayStable and not na(tP10) and not na(tP90)
            calN    += 1.0
            calIn80 += (r >= tP10 and r <= tP90) ? 1.0 : 0.0
            calIn50 += (r >= tP25 and r <= tP75) ? 1.0 : 0.0
        if callDir != 0 and allN > 0
            callN    += 1.0
            callHit  += ((r > 0) == (callDir > 0)) ? 1.0 : 0.0
            callBase += callDir > 0 ? allUp / allN : 1.0 - allUp / allN

        array.push(hRet,  r)
        array.push(hZ,    (na(todaySigma) or todaySigma <= 0) ? na : r / todaySigma)
        array.push(hDow,  todayDow)
        array.push(hPrev, todayPrev)
        array.push(hReg,  todayReg)
        array.push(hChg,  lastRegClose - dayRef)
        array.push(hAs,   sAs)
        array.push(hLd,   sLd)
        array.push(hNy,   sNy)

        bool hasPrv = not na(prvHi) and not na(prvLo)
        int  bH     = hasPrv ? (dayHi > prvHi ? 1 : 0) : -1
        int  bL     = hasPrv ? (dayLo < prvLo ? 1 : 0) : -1
        float mUp   = 0.0
        float mSeen = 0.0
        if intraday
            for b = 0 to 23
                int sb = array.get(dSign, b)
                if sb >= 0
                    float pw = math.pow(2, b)
                    mSeen += pw
                    mUp   += sb == 1 ? pw : 0.0
        array.push(hBrkH,  bH)
        array.push(hBrkL,  bL)
        array.push(hHeldH, bH == 1 ? (lastRegClose > prvHi ? 1 : 0) : -1)
        array.push(hHeldL, bL == 1 ? (lastRegClose < prvLo ? 1 : 0) : -1)
        array.push(hHiSes, intraday ? hiSes : -1)
        array.push(hLoSes, intraday ? loSes : -1)
        array.push(hHiEl,  intraday ? hiEl : na)
        array.push(hLoEl,  intraday ? loEl : na)
        array.push(hMUp,   mUp)
        array.push(hMSeen, mSeen)
        array.push(hRng,   (dayHi - dayLo) / math.abs(dayRef) * 100.0)
        array.push(hStk,   todayStreak)
        prvHi := dayHi
        prvLo := dayLo
        daysDone += 1
        while array.size(hRet) > lookbackDays
            array.shift(hRet)
            array.shift(hZ)
            array.shift(hDow)
            array.shift(hPrev)
            array.shift(hReg)
            array.shift(hChg)
            array.shift(hAs)
            array.shift(hLd)
            array.shift(hNy)
            array.shift(hBrkH)
            array.shift(hBrkL)
            array.shift(hHeldH)
            array.shift(hHeldL)
            array.shift(hHiSes)
            array.shift(hLoSes)
            array.shift(hHiEl)
            array.shift(hLoEl)
            array.shift(hMUp)
            array.shift(hMSeen)
            array.shift(hRng)
            array.shift(hStk)

    int nH = array.size(hRet)
    dayRef      := bar_index > 0 ? lastRegClose : na
    dayStartBar := bar_index
    dayStartTime := time
    array.fill(dSign, -1)
    int stk = 0
    if nH > 0
        bool lastUp = array.get(hRet, nH - 1) > 0
        for i = nH - 1 to 0
            if (array.get(hRet, i) > 0) != lastUp
                break
            stk += lastUp ? 1 : -1
    todayStreak := stk
    regToday    := false
    sAs         := 0.0
    sLd         := 0.0
    sNy         := 0.0
    todayDow    := dayofweek(time_tradingday, "UTC")
    todayPrev   := nH > 0 ? (array.get(hRet, nH - 1) > 0 ? 1 : -1) : 0
    if nH >= 3
        float g = 0.0
        for i = nH - 3 to nH - 1
            g += array.get(hChg, i)
        todayReg := g > 0.0 ? 1 : -1
    else
        todayReg := 0
    todaySigma := sigmaOfLast(hRet, volLenEff)
    drawSigma  := na(todaySigma) ? 1.0 : todaySigma
    if nH >= rollDays - 1
        float bs = 0.0
        for i = nH - (rollDays - 1) to nH - 1
            bs += array.get(hRet, i)
        baseSum := bs
    else
        baseSum := na
    todayStable := daysDone >= warmDays

    float toPct = volAdj ? todaySigma : 1.0
    array.fill(wkN,   0.0)
    array.fill(wkUp,  0.0)
    array.fill(wkSum, 0.0)
    array.fill(wkAbs, 0.0)
    allN  := 0.0
    allUp := 0.0
    float prevN  = 0.0
    float prevUp = 0.0
    float regN   = 0.0
    float regUp  = 0.0
    float skN    = 0.0
    float skSum  = 0.0
    float skSq   = 0.0
    float skAbs  = 0.0
    float skPos  = 0.0
    float uAbs   = 0.0     // Σ |return| over all days, in current units
    float uN     = 0.0
    float sumAs  = 0.0
    float sumLd  = 0.0
    float sumNy  = 0.0
    float sesN   = 0.0
    array<float> samp = array.new<float>()

    if nH > 0
        for i = 0 to nH - 1
            float rr = array.get(hRet, i)
            int   dw = array.get(hDow, i)
            int   pv = array.get(hPrev, i)
            int   rg = array.get(hReg, i)
            bool  up = rr > 0
            float v  = volAdj ? array.get(hZ, i) : rr

            array.set(wkN,   dw - 1, array.get(wkN, dw - 1) + 1.0)
            array.set(wkUp,  dw - 1, array.get(wkUp, dw - 1) + (up ? 1.0 : 0.0))
            array.set(wkSum, dw - 1, array.get(wkSum, dw - 1) + rr)
            array.set(wkAbs, dw - 1, array.get(wkAbs, dw - 1) + math.abs(rr))
            allN  += 1.0
            allUp += up ? 1.0 : 0.0
            if not na(v)
                uAbs += math.abs(v)
                uN   += 1.0

            if pv != 0 and pv == todayPrev
                prevN  += 1.0
                prevUp += up ? 1.0 : 0.0
            if rg != 0 and rg == todayReg
                regN  += 1.0
                regUp += up ? 1.0 : 0.0

            if dw == todayDow
                sumAs += array.get(hAs, i)
                sumLd += array.get(hLd, i)
                sumNy += array.get(hNy, i)
                sesN  += 1.0
                if not na(v) and not na(toPct)
                    array.push(samp, v * toPct)
                    skN   += 1.0
                    skSum += v
                    skSq  += v * v
                    skAbs += math.abs(v)
                    skPos += v > 0 ? v : 0.0

    float wn = na(todayDow) ? 0.0 : array.get(wkN, todayDow - 1)
    float wu = na(todayDow) ? 0.0 : array.get(wkUp, todayDow - 1)
    setRateAxis(0, wu, wn, float(minSample))
    setRateAxis(1, prevUp, prevN, float(minSample))
    setRateAxis(2, regUp, regN, float(minSample))

    float rcN   = 0.0
    float rcUp  = 0.0
    int   rcLen = math.max(recentLen, minSample)
    if nH > 0
        for i = math.max(0, nH - rcLen) to nH - 1
            rcN  += 1.0
            rcUp += array.get(hRet, i) > 0 ? 1.0 : 0.0
    setRateAxis(3, rcUp, rcN, float(minSample))

    int skSig = 0
    if skN >= minSample and skN > 1
        float mean = skSum / skN
        float sVar = (skSq - skN * mean * mean) / (skN - 1)
        if sVar > 0
            float tStat = mean / math.sqrt(sVar / skN)
            float df    = skN - 1.0
            float tCrit = 1.96 + 2.3724 / df + 2.8227 / (df * df) + 2.5561 / (df * df * df) + 1.5897 / (df * df * df * df)
            skSig := tStat > tCrit ? 1 : tStat < -tCrit ? -1 : 0
    array.set(axShare, 4, skAbs > 0 ? skPos / skAbs * 100.0 : na)
    array.set(axN, 4, skN)
    array.set(axMinN, 4, float(minSample))
    array.set(axSig, 4, skSig)

    float wSum    = 0.0
    float sSum    = 0.0
    int   sigBull = 0
    int   sigBear = 0
    for i = 0 to NAXES - 1
        float sh = array.get(axShare, i)
        float nn = array.get(axN, i)
        if not na(sh) and nn >= array.get(axMinN, i)
            wSum += math.sqrt(nn)
            sSum += math.sqrt(nn) * (sh - 50.0)
        int sg = array.get(axSig, i)
        sigBull += sg > 0 ? 1 : 0
        sigBear += sg < 0 ? 1 : 0
    biasScore := wSum > 0 ? 50.0 + sSum / wSum : na

    bool gateUp = requireSig ? (sigBull >= 1 and sigBear == 0) : true
    bool gateDn = requireSig ? (sigBear >= 1 and sigBull == 0) : true
    callDir := (na(biasScore) or not todayStable) ? 0 : (biasScore - 50.0 >= biasMin and gateUp) ? 1 : (50.0 - biasScore >= biasMin and gateDn) ? -1 : 0

    bool deep = array.size(samp) >= minSample
    tP10 := deep ? array.percentile_linear_interpolation(samp, 10) : na
    tP25 := deep ? array.percentile_linear_interpolation(samp, 25) : na
    tP50 := deep ? array.percentile_linear_interpolation(samp, 50) : na
    tP75 := deep ? array.percentile_linear_interpolation(samp, 75) : na
    tP90 := deep ? array.percentile_linear_interpolation(samp, 90) : na

    tExpAbs   := (skN > 0 and not na(toPct)) ? skAbs / skN * toPct : na
    tVolRatio := (skN > 0 and uN > 0 and uAbs > 0) ? (skAbs / skN) / (uAbs / uN) : na
    tSesN     := sesN
    tAs       := sesN > 0 ? sumAs / sesN : na
    tLd       := sesN > 0 ? sumLd / sesN : na
    tNy       := sesN > 0 ? sumNy / sesN : na

float elMs   = time - dayStartTime
int   sesNow = sesOf(hour(time, "UTC"))
if newDay or high > dayHi
    hiEl  := elMs
    hiSes := sesNow
if newDay or low < dayLo
    loEl  := elMs
    loSes := sesNow
dayHi := newDay ? high : math.max(dayHi, high)
dayLo := newDay ? low  : math.min(dayLo, low)

if session.ismarket
    lastRegClose := close
    regToday     := true

if intraday and not na(dayRef) and dayRef != 0
    float bStep = (close - (newDay ? dayRef : close[1])) / math.abs(dayRef) * 100.0
    int   hU    = hour(time, "UTC")
    if hU >= 8 and hU < 13
        sLd += bStep
    else if hU >= 13 and hU < 21
        sNy += bStep
    else
        sAs += bStep

float devRet = (na(dayRef) or dayRef == 0) ? na : (close - dayRef) / math.abs(dayRef) * 100.0

if intraday
    int bkt = math.min(23, int(math.floor(elMs / 3600000.0)))
    array.set(dSign, bkt, (not na(devRet) and devRet > 0) ? 1 : 0)

// ═══════════════════════════════════════════════════════════════════════════
// 4. OSCILLATOR PANE

bool  stripes = oscStyle == "Heat Stripes"
bool  wave    = oscStyle == "Waveform"
color devCol  = na(devRet) ? na : devRet >= 0 ? color.new(colUp, 30) : color.new(colDn, 30)
plot(oscStyle == "Bar Columns" ? devRet : na, "Developing Daily Return %", color = devCol, style = plot.style_columns, histbase = 0.0, display = display.pane, editable = false)

bool  wGap = intraday and newDay     // one-bar gap marks the start of each day on intraday charts
bool  wOk  = wave and not wGap and not na(dayRef) and dayRef != 0
float wUp  = wOk ? math.max((dayHi - dayRef) / math.abs(dayRef) * 100.0, 0.0) : na
float wDn  = wOk ? math.min((dayLo - dayRef) / math.abs(dayRef) * 100.0, 0.0) : na
float wNow = wOk ? devRet : na
float wSig = (na(drawSigma) or drawSigma <= 0) ? 1.0 : drawSigma
float wUpT = na(wUp) ? 0.0 : math.min(wUp / (2.0 * wSig), 1.0)     // 0 = no stretch, 1 = 2σ or more
float wDnT = na(wDn) ? 0.0 : math.min(-wDn / (2.0 * wSig), 1.0)

pW0  = plot(wave ? 0.0 : na, "Wave Zero", color = color.new(color.gray, 100), display = display.pane, editable = false)
pWUp = plot(wUp, "Wave High", color = color.new(colUp, 30), linewidth = 1, style = plot.style_linebr, display = display.pane, editable = false)
pWDn = plot(wDn, "Wave Low", color = color.new(colDn, 30), linewidth = 1, style = plot.style_linebr, display = display.pane, editable = false)
fill(pWUp, pW0, top_value = wUp, bottom_value = 0.0,
     top_color = color.new(colUp, 30 + 55 * (1.0 - wUpT)), bottom_color = color.new(colUp, 96), title = "Wave Fill Up")
fill(pW0, pWDn, top_value = 0.0, bottom_value = wDn,
     top_color = color.new(colDn, 96), bottom_color = color.new(colDn, 30 + 55 * (1.0 - wDnT)), title = "Wave Fill Down")

color wCol = na(wNow) ? na : wNow >= 0 ? colUp : colDn
plot(wNow, "Wave Close Glow", color = color.new(wCol, 70), linewidth = 7, style = plot.style_linebr, display = display.pane, editable = false)
plot(wNow, "Wave Close", color = cTxt, linewidth = 2, style = plot.style_linebr, display = display.pane, editable = false)

float heatT   = (na(devRet) or na(drawSigma) or drawSigma <= 0) ? na : math.max(-1.0, math.min(1.0, devRet / (2.0 * drawSigma)))
color heatCol = na(heatT) ? na : heatT >= 0 ? color.new(colUp, 88 - 58 * heatT) : color.new(colDn, 88 + 58 * heatT)
bgcolor(stripes ? heatCol : na, title = "Heat Stripes", editable = false)

float rollLine = (stripes and not na(devRet) and not na(baseSum)) ? baseSum + devRet : na
plot(rollLine, "Rolling Return Glow", color = color.new(cNeut, 82), linewidth = 6, display = display.pane, editable = false)
plot(rollLine, "Rolling Return %", color = cNeut, linewidth = 2, display = display.pane, editable = false)

float rngBase = oscStyle == "Off" ? na : stripes ? baseSum : 0.0
plot(showBand and not na(rngBase) ? rngBase + tP90 : na, "Range Anchor Top", color = color.new(color.gray, 100), display = display.pane, editable = false)
plot(showBand and not na(rngBase) ? rngBase + tP10 : na, "Range Anchor Bottom", color = color.new(color.gray, 100), display = display.pane, editable = false)

var box  outerBox = na
var box  innerBox = na
var line medLine  = na

if barstate.islast
    if not na(outerBox)
        box.delete(outerBox)
    if not na(innerBox)
        box.delete(innerBox)
    if not na(medLine)
        line.delete(medLine)
    int xEnd = bar_index + 3
    if showBand and not na(rngBase) and not na(tP10) and not na(tP90)
        outerBox := box.new(dayStartBar, rngBase + tP90, xEnd, rngBase + tP10, xloc = xloc.bar_index, bgcolor = color.new(cNeut, 94),
             border_color = color.new(cNeut, 45), border_style = line.style_dotted, border_width = 1,
             text = "today P90 " + fPct(tP90) + "\n\n\ntoday P10 " + fPct(tP10), text_size = lblSz, text_formatting = fmtBI, text_color = cTxt,
             text_halign = text.align_right, text_valign = text.align_center)
        innerBox := box.new(dayStartBar, rngBase + tP75, xEnd, rngBase + tP25, xloc = xloc.bar_index, bgcolor = color.new(cNeut, 86), border_width = 0)
    if showMedian and not na(rngBase) and not na(tP50)
        medLine := line.new(dayStartBar, rngBase + tP50, xEnd, rngBase + tP50, xloc = xloc.bar_index,
             color = tP50 >= 0 ? colUp : colDn, style = line.style_dashed, width = 1)

hline(0.0, "Zero", color = color.new(cNeut, 70), linestyle = hline.style_dotted, editable = false)

plotshape(newDay and callDir > 0, title = "Strong Bullish Day", style = shape.triangleup, location = location.bottom,
     color = color.new(colUp, 20), size = size.tiny, display = display.pane, editable = false)
plotshape(newDay and callDir < 0, title = "Strong Bearish Day", style = shape.triangledown, location = location.top,
     color = color.new(colDn, 20), size = size.tiny, display = display.pane, editable = false)

// ═══════════════════════════════════════════════════════════════════════════
// 5. MAIN CHART — CANDLES, LIVE LABEL, EXPECTED PRICE LEVELS

color dayCol = candleMode == "Vs Prior Close" ? (na(devRet) ? na : devRet >= 0 ? candleUp : candleDn) : na
barcolor(dayCol, editable = false)
plotcandle(not na(dayCol) ? open : na, not na(dayCol) ? high : na, not na(dayCol) ? low : na, not na(dayCol) ? close : na,
     "Candle Wick / Border", color = color.new(color.gray, 100), wickcolor = dayCol, bordercolor = dayCol,
     editable = false, force_overlay = true, display = display.pane)

var label liveLbl = na
if barstate.islast
    if not na(liveLbl)
        label.delete(liveLbl)
    if showDayLbl and dayLblWhere == "Main Chart" and not na(devRet)
        bool lPos = devRet >= 0
        liveLbl := label.new(bar_index, lPos ? dayHi : dayLo, fPct(devRet) + " today", xloc = xloc.bar_index,
             style = lPos ? label.style_label_down : label.style_label_up, size = size.small,
             color = color.new(cPanelBg, 100), textcolor = lPos ? cUpTxt : cDnTxt, text_formatting = fmtBI, force_overlay = true)

var box liveBox = na
if barstate.islast
    if not na(liveBox)
        box.delete(liveBox)
    if showDayBox and not na(dayRef)
        color lbC = na(devRet) ? cNeut : devRet >= 0 ? colUp : colDn
        liveBox := box.new(dayStartBar, dayHi, bar_index, dayLo, xloc = xloc.bar_index, border_color = color.new(lbC, 20),
             border_width = 1, border_style = line.style_dashed, bgcolor = color.new(lbC, math.min(dayBoxFill + 3, 100)), force_overlay = true)

if showPDHL and array.size(pdLines) > 0
    for i = 0 to array.size(pdLines) - 1
        if array.get(pdAlive, i)
            line  ln   = array.get(pdLines, i)
            float px   = array.get(pdPrice, i)
            bool  isHi = array.get(pdIsHi, i)
            line.set_x2(ln, bar_index)
            if barstate.isconfirmed and line.get_x1(ln) < bar_index and (isHi ? high > px : low < px)
                array.set(pdAlive, i, false)
                line.set_color(ln, color.new(isHi ? colUp : colDn, 60))
                array.push(pdMarks, label.new(bar_index, low, brkMark, xloc = xloc.bar_index, style = label.style_label_up,
                     size = size.small, color = color.new(cPanelBg, 100), textcolor = cTxt,
                     text_formatting = fmtBI, force_overlay = true,
                     tooltip = (isHi ? "Prior-day high " : "Prior-day low ") + str.tostring(px, format.mintick) + " broken"))
                if array.size(pdMarks) > pdMax * 2
                    label.delete(array.shift(pdMarks))

// ═══════════════════════════════════════════════════════════════════════════
// 6. WEEKDAY COLUMN CHART + SCORECARD

var array<int> DOW_ORDER = array.from(dayofweek.monday, dayofweek.tuesday, dayofweek.wednesday,
     dayofweek.thursday, dayofweek.friday, dayofweek.saturday, dayofweek.sunday)

int HT_COLS = 8          // up to 7 weekdays + ALL
int GUIDE_K = 9          // last segment row above the 50% boundary
int SC0     = NSTRIP + 2 // first scorecard row
int HT_ROWS = NSTRIP + 6

var table heatTbl = na

float MAP_SEG = mapH / NSTRIP

paintColumn(int col, string head, string tip, float upRate, bool highlight, float colW) =>
    int   h    = math.max(0, math.min(NSTRIP, int(math.round(upRate / 100.0 * NSTRIP))))
    color side = upRate >= 50.0 ? colUp : colDn
    table.cell(heatTbl, col, 0, fRate(upRate), text_color = highlight ? ink(side) : color.new(ink(side), 25), text_size = uiSz, text_formatting = fmtBI,
         bgcolor = cCard, width = colW, tooltip = tip)
    for k = 0 to NSTRIP - 1
        bool  filled = k >= NSTRIP - h
        float t      = h > 1 ? (k - (NSTRIP - h)) / float(h - 1) : 0.0
        color bg     = filled ? color.new(side, (highlight ? 0 : 30) + 50 * t) : k == GUIDE_K ? color.new(cMute, 78) : cCard2
        table.cell(heatTbl, col, k + 1, "", bgcolor = bg, width = colW, height = MAP_SEG, tooltip = tip)
    table.cell(heatTbl, col, NSTRIP + 1, head, text_color = highlight ? ink(colGrid) : cMute, text_size = uiSz, text_formatting = fmtBI,
         bgcolor = cCard, width = colW, tooltip = tip)

scoreRow(int r, int half, string title, string val, color vc, string tip) =>
    table.cell(heatTbl, 0, r, title, text_color = cMute, text_size = uiSz, text_formatting = fmtBI, text_halign = text.align_left,
         bgcolor = cCard, tooltip = tip)
    table.cell(heatTbl, half, r, val, text_color = vc, text_size = uiSz, text_formatting = fmtBI, text_halign = text.align_right,
         bgcolor = cCard, tooltip = tip)

fSgn(float v) =>
    na(v) ? "—" : (v > 0 ? "+" : "") + str.tostring(v, "0.00")

if barstate.islast
    if showMap
        int nCols = (showBaseRow and allN > 0) ? 1 : 0
        for d in DOW_ORDER
            nCols += array.get(wkN, d - 1) > 0 ? 1 : 0
        nCols := math.max(nCols, 1)
        float colW = mapW / nCols
        int   half = int(nCols / 2)
        if na(heatTbl)
            if mapOnChart
                heatTbl := table.new(tablePosition(mapPos), HT_COLS, HT_ROWS, bgcolor = cCard,
                     frame_color = cCard, frame_width = 8, border_color = cCard, border_width = 1,
                     force_overlay = true)
            else
                heatTbl := table.new(tablePosition(mapPos), HT_COLS, HT_ROWS, bgcolor = cCard,
                     frame_color = cCard, frame_width = 8, border_color = cCard, border_width = 1,
                     force_overlay = false)
            if showScore and nCols > 1
                for r = SC0 to SC0 + 3
                    if half > 1
                        table.merge_cells(heatTbl, 0, r, half - 1, r)
                    if nCols - 1 > half
                        table.merge_cells(heatTbl, half, r, nCols - 1, r)

        int col = 0
        for d in DOW_ORDER
            float n = array.get(wkN, d - 1)
            if n > 0
                float up   = array.get(wkUp, d - 1)
                float rate = up / n * 100.0
                [lo, hi] = wilson(up, n)
                bool thin    = n < minSample
                bool sig     = not thin and (lo > 50.0 or hi < 50.0)
                bool isToday = d == todayDow
                string lbl = (isToday ? "▶ " : "") + dowName(d) + (sig ? " ✓" : "") + "\n" + fCount(n) + " days"
                string tip = dowName(d) + " — closed green on " + fRate(rate) + " of the last " + fCount(n) + " " + dowName(d) + " days  (95% Wilson interval " + fRate(lo) + " – " + fRate(hi) + ")"
                     + "\nAvg return " + fPct(array.get(wkSum, d - 1) / n) + "  ·  avg |move| " + str.tostring(array.get(wkAbs, d - 1) / n, "0.00") + "%"
                     + (sig ? "\n✓ 95% Wilson interval is fully above or below 50%." : "\n95% Wilson interval still overlaps 50%.") + (thin ? "\nFew days — treat as a rough hint only." : "")
                paintColumn(col, lbl, tip, rate, isToday, colW)
                col += 1

        if showBaseRow and allN > 0
            [blo, bhi] = wilson(allUp, allN)
            float bRate = allUp / allN * 100.0
            string btip = "All days — closed green on " + fRate(bRate) + " of the last " + fCount(allN) + " days  (95% Wilson interval " + fRate(blo) + " – " + fRate(bhi) + ")"
                 + "\nCompare each weekday with this column: a weekday only stands out if it is clearly above or below it."
            paintColumn(col, "ALL\n" + fCount(allN) + " days", btip, bRate, false, colW)
            col += 1

        if col < HT_COLS
            table.clear(heatTbl, col, 0, HT_COLS - 1, NSTRIP + 1)

        if showScore and nCols > 1
            float hitR  = callN > 0 ? callHit / callN * 100.0 : na
            float drift = callN > 0 ? callBase / callN * 100.0 : na
            string callVal = callN > 0 ? fRate(hitR) + " vs " + fRate(drift) : todayStable ? "none yet" : "warm-up " + fCount(daysDone) + "/" + str.tostring(warmDays)
            color  callTc  = callN > 0 ? (hitR > drift ? cUpTxt : cDnTxt) : cMute
            scoreRow(SC0, half, "CALLS", callVal, callTc,
                 "Strong bullish / bearish days, scored when each day completed: hit rate vs drift" + (callN > 0 ? " (" + fCount(callN) + " calls)" : "") + ".\n'drift' = hit rate the same calls would have had by following the all-days up-rate alone. A call only adds value if it beats drift, and small N means little.")

            string rngVal = calN > 0 ? fRate(calIn80 / calN * 100.0) + " · " + fRate(calIn50 / calN * 100.0) : "—"
            scoreRow(SC0 + 1, half, "RANGE HIT", rngVal, cTxt,
                 "How often completed days closed inside the range projected at their open: P10–P90 · P25–P75 (" + fCount(calN) + " days). A well-calibrated range lands near 80% and 50%.")

            string volVal = (na(tExpAbs) ? "—" : str.tostring(tExpAbs, "0.00") + "%") + "  ×" + (na(tVolRatio) ? "—" : str.tostring(tVolRatio, "0.00"))
            color  volTc  = na(tVolRatio) ? cMute : tVolRatio >= 1.10 ? colCoin : cTxt
            scoreRow(SC0 + 2, half, "|MOVE| " + dowName(todayDow), volVal, volTc,
                 "Average absolute daily move of today's weekday in current return units, and ×ratio versus all days. Above ×1.10 is highlighted: this weekday has historically moved more than usual. Says nothing about direction.")

            string sesVal = intraday ? fSgn(tAs) + "  " + fSgn(tLd) + "  " + fSgn(tNy) : "intraday only"
            scoreRow(SC0 + 3, half, "SESSIONS", sesVal, intraday ? cTxt : cMute,
                 "Average % return contributed by Asia · London · New York on " + dowName(todayDow) + " (" + fCount(tSesN) + " days), bar by bar, as % of the prior close. Sessions by UTC hour: Asia 21–08, London 08–13, New York 13–21. Extended-hours bars are included, so the parts can differ slightly from the daily return.")
    else if not na(heatTbl)
        table.delete(heatTbl)
        heatTbl := na

// ═══════════════════════════════════════════════════════════════════════════
// 7. STATISTICS PANEL — pane, four cards, completed days only

var table statTbl = na

float  ST_GAP  = 1.0                                   // gap between cards, % of pane
float  ST_CARD = (statW - 3.0 * ST_GAP) / 4.0          // one card's width
float  ST_LW   = ST_CARD * 0.52
float  ST_VW   = ST_CARD * 0.48
float  ST_TITH = statH * 0.13
float  ST_HERH = statH * 0.27
float  ST_ROWH = statH * 0.15
string ST_SZ   = uiSz
string ST_HERO = statTxt == "Large" ? size.huge : statTxt == "Small" ? size.normal : size.large

color ST_ACC0 = (not na(devRet) and devRet > 0) ? colUp : colDn

cardAcc(int c) =>
    c == 0 ? ST_ACC0 : c == 1 ? colGrid : c == 2 ? colCoin : colAcc

relMark(float k, float n) =>
    [lo, hi] = wilson(k, n)
    n <= 0 ? "" : n < minSample ? "  few" : (lo > 50.0 or hi < 50.0) ? "  ✓" : ""

pctVal(float k, float n) =>
    n > 0 ? fRate(k / n * 100.0) + relMark(k, n) : "—"

statTitle(int c, string t, string tip) =>
    table.cell(statTbl, c * 3, 0, "●  " + t, text_color = ink(cardAcc(c)), text_size = lblSz, text_formatting = fmtBI,
         text_halign = text.align_left, text_valign = text.align_bottom, bgcolor = cCard, height = ST_TITH, tooltip = tip)

statHero(int c, string big, string cap, color bc, string tip) =>
    table.cell(statTbl, c * 3, 1, big, text_color = bc, text_size = ST_HERO, text_formatting = fmtBI, text_halign = text.align_left,
         bgcolor = cCard, width = ST_LW, height = ST_HERH, tooltip = tip)
    table.cell(statTbl, c * 3 + 1, 1, cap, text_color = cMute, text_size = lblSz, text_formatting = fmtBI, text_halign = text.align_right,
         bgcolor = cCard, width = ST_VW, height = ST_HERH, tooltip = tip)

statLine(int c, int r, string lbl, string val, color vc, string tip) =>
    table.cell(statTbl, c * 3, r, lbl, text_color = cMute, text_size = ST_SZ, text_formatting = fmtBI, text_halign = text.align_left,
         bgcolor = cCard, width = ST_LW, height = ST_ROWH, tooltip = tip)
    table.cell(statTbl, c * 3 + 1, r, val, text_color = na(vc) ? cTxt : vc, text_size = ST_SZ, text_formatting = fmtBI, text_halign = text.align_right,
         bgcolor = cCard, width = ST_VW, height = ST_ROWH, tooltip = tip)

if barstate.islast
    if showStats
        if na(statTbl)
            statTbl := table.new(tablePosition(statPos), 12, 6, bgcolor = color.new(cCard, 100), border_width = 0, frame_width = 0, force_overlay = false)
            for c = 0 to 3
                table.merge_cells(statTbl, c * 3, 0, c * 3 + 1, 0)
            for c = 0 to 2
                for r = 0 to 5
                    table.cell(statTbl, c * 3 + 2, r, "", width = ST_GAP, bgcolor = color.new(cCard, 100))

        int   nS     = array.size(hRet)
        float nowEl  = time - dayStartTime
        int   nowBkt = math.min(23, int(math.floor(nowEl / 3600000.0)))
        float pwNow  = math.pow(2, nowBkt)
        bool  hasNow = intraday and not na(devRet)
        bool  nowUp  = hasNow and devRet > 0
        int   stkCap = math.max(-3, math.min(3, todayStreak))
        float tRng   = (na(dayRef) or dayRef == 0) ? na : (dayHi - dayLo) / math.abs(dayRef) * 100.0

        float lvN   = 0.0
        float lvK   = 0.0
        float bN    = 0.0
        float bHK   = 0.0
        float bLK   = 0.0
        float bothK = 0.0
        float insK  = 0.0
        float hdHN  = 0.0
        float hdHK  = 0.0
        float hdLN  = 0.0
        float hdLK  = 0.0
        float tmN   = 0.0
        float hiNow = 0.0
        float loNow = 0.0
        array<float> hiS = array.new<float>(3, 0.0)
        array<float> loS = array.new<float>(3, 0.0)
        float stN   = 0.0
        float stK   = 0.0
        float rgN   = 0.0
        float rgK   = 0.0

        if nS > 0
            for i = 0 to nS - 1
                bool up = array.get(hRet, i) > 0
                if hasNow and math.floor(array.get(hMSeen, i) / pwNow) % 2 == 1
                    bool wasUp = math.floor(array.get(hMUp, i) / pwNow) % 2 == 1
                    if wasUp == nowUp
                        lvN += 1.0
                        lvK += up == nowUp ? 1.0 : 0.0
                int bh = array.get(hBrkH, i)
                int bl = array.get(hBrkL, i)
                if bh >= 0
                    bN    += 1.0
                    bHK   += bh
                    bLK   += bl
                    bothK += (bh == 1 and bl == 1) ? 1.0 : 0.0
                    insK  += (bh == 0 and bl == 0) ? 1.0 : 0.0
                int kh = array.get(hHeldH, i)
                if kh >= 0
                    hdHN += 1.0
                    hdHK += kh
                int kl = array.get(hHeldL, i)
                if kl >= 0
                    hdLN += 1.0
                    hdLK += kl
                int hs = array.get(hHiSes, i)
                int ls = array.get(hLoSes, i)
                if hs >= 0 and ls >= 0
                    tmN += 1.0
                    array.set(hiS, hs, array.get(hiS, hs) + 1.0)
                    array.set(loS, ls, array.get(loS, ls) + 1.0)
                    hiNow += array.get(hHiEl, i) <= nowEl ? 1.0 : 0.0
                    loNow += array.get(hLoEl, i) <= nowEl ? 1.0 : 0.0
                if todayStreak != 0 and math.max(-3, math.min(3, array.get(hStk, i))) == stkCap
                    stN += 1.0
                    stK += up ? 1.0 : 0.0
                if not na(tRng)
                    rgN += 1.0
                    rgK += array.get(hRng, i) > tRng ? 1.0 : 0.0

        float adr    = na
        int   adrLen = math.min(volLenEff, nS)
        if adrLen > 0
            float sr = 0.0
            for i = nS - adrLen to nS - 1
                sr += array.get(hRng, i)
            adr := sr / adrLen

        string sideW = nowUp ? "green" : "red"
        color  sideC = nowUp ? cUpTxt : cDnTxt
        string tip0  = "Past days that were on the same side of their prior close at this hour of the day, and how often they closed on that side. How often it happened, not a guarantee."
        statTitle(0, hasNow ? "NOW  ·  HOUR " + str.tostring(nowBkt + 1) : "NOW", tip0)
        if hasNow
            float baseK = nowUp ? allUp : allN - allUp
            float baseP = allN > 0 ? baseK / allN * 100.0 : na
            float edge  = (lvN > 0 and allN > 0) ? lvK / lvN * 100.0 - baseP : na
            statHero(0, lvN > 0 ? fRate(lvK / lvN * 100.0) : "—", "closed " + sideW + "\n" + fCount(lvN) + " similar days", sideC, tip0)
            statLine(0, 2, "Vs prior close", fPct(devRet), sideC, "Today's move so far versus the prior close.")
            statLine(0, 3, "All days " + sideW, fRate(baseP), na, "How often any day closed " + sideW + ". Today's situation only matters if the big number clearly beats this.")
            statLine(0, 4, "Difference", na(edge) ? "—" : (edge >= 0 ? "+" : "") + str.tostring(edge, "0.0") + " pts", na(edge) or edge < 0 ? cMute : sideC,
                 "Big number minus the all-days rate, in percentage points.")
            string rel0 = lvN < minSample ? "few days" : relMark(lvK, lvN) != "" ? "yes  ✓" : "not yet"
            statLine(0, 5, "95% check", rel0, lvN < minSample ? ink(colCoin) : rel0 == "yes  ✓" ? sideC : cMute,
                 "✓ = the 95% Wilson interval is fully above or below 50%. At least " + str.tostring(minSample) + " days are needed.")
        else
            statHero(0, "—", intraday ? "waiting for data" : "intraday chart only", cMute, tip0)
            for r = 2 to 5
                statLine(0, r, "", "", na, "")

        bool   tBrkH = not na(prvHi) and dayHi > prvHi
        bool   tBrkL = not na(prvLo) and dayLo < prvLo
        string tip1  = "How often a day traded through the prior day's high or low, and whether the break held into the close. A wick through the level counts."
        statTitle(1, "PRIOR DAY HIGH / LOW", tip1)
        statHero(1, bN > 0 ? fRate(bHK / bN * 100.0) : "—", "broke prior high\n" + (tBrkH ? "today: broken" : "today: not yet"), tBrkH ? cUpTxt : ink(colGrid), tip1)
        statLine(1, 2, "Broke prior low", pctVal(bLK, bN), tBrkL ? cDnTxt : na, "How often a day traded below the prior day's low." + (tBrkL ? " Already happened today." : ""))
        statLine(1, 3, "Both · neither", bN > 0 ? fRate(bothK / bN * 100.0) + " · " + fRate(insK / bN * 100.0) : "—", na,
             "Both = broke the prior high AND low the same day. Neither = stayed inside the prior day's range.")
        statLine(1, 4, "High break held", pctVal(hdHK, hdHN), cUpTxt, "When the prior high broke, how often the day still closed above it. Low = breaks often failed.")
        statLine(1, 5, "Low break held", pctVal(hdLK, hdLN), cDnTxt, "When the prior low broke, how often the day still closed below it.")

        string tip2 = "Session in which past days made their high and low, by UTC hour: Asia 21–08, London 08–13, New York 13–21."
        statTitle(2, "HIGH / LOW TIMING", tip2)
        if intraday and tmN > 0
            int   hiTop = array.indexof(hiS, array.max(hiS))
            int   loTop = array.indexof(loS, array.max(loS))
            statHero(2, sesName(hiTop), "day's high forms here\n" + str.tostring(array.max(hiS) / tmN * 100.0, "0") + "% of days", ink(colCoin),
                 tip2 + "\nHigh split  Asia " + str.tostring(array.get(hiS, 0) / tmN * 100.0, "0") + "% · London " + str.tostring(array.get(hiS, 1) / tmN * 100.0, "0") + "% · NY " + str.tostring(array.get(hiS, 2) / tmN * 100.0, "0") + "%")
            statLine(2, 2, "Low forms in", sesName(loTop) + "  " + str.tostring(array.max(loS) / tmN * 100.0, "0") + "%", na,
                 "Low split  Asia " + str.tostring(array.get(loS, 0) / tmN * 100.0, "0") + "% · London " + str.tostring(array.get(loS, 1) / tmN * 100.0, "0") + "% · NY " + str.tostring(array.get(loS, 2) / tmN * 100.0, "0") + "%")
            statLine(2, 3, "High already in", pctVal(hiNow, tmN), na, "By this time of day, how often the day's final high had already been made. High = today's high may already be in.")
            statLine(2, 4, "Low already in", pctVal(loNow, tmN), na, "By this time of day, how often the day's final low had already been made.")
            statLine(2, 5, "Today H · L", sesName(hiSes) + " · " + sesName(loSes), na, "Sessions where today's high and low were made so far. Both can still change.")
        else
            statHero(2, "—", intraday ? "no completed days yet" : "intraday chart only", cMute, tip2)
            for r = 2 to 5
                statLine(2, r, "", "", na, "")

        int    stkAbs = math.abs(todayStreak)
        string tip3   = "What happened after the same streak in the past, and how much of a normal day's range today has already used."
        statTitle(3, "STREAK & RANGE", tip3)
        statHero(3, todayStreak != 0 and stN > 0 ? fRate(stK / stN * 100.0) : "—",
             todayStreak == 0 ? "no streak yet" : "next day green\nafter " + str.tostring(stkAbs) + " " + (todayStreak > 0 ? "green" : "red") + " day" + (stkAbs > 1 ? "s" : ""),
             todayStreak > 0 ? cUpTxt : todayStreak < 0 ? cDnTxt : cMute, tip3 + "\nStreaks of 3 or more days are grouped together.")
        statLine(3, 2, "Based on", todayStreak == 0 ? "—" : fCount(stN) + " days" + relMark(stK, stN), na, "Past days that came after the same streak.")
        statLine(3, 3, "Avg range " + str.tostring(adrLen) + "d", na(adr) ? "—" : str.tostring(adr, "0.00") + "%", na, "Average high–low range of recent days, as % of the prior close.")
        float adrUse = (na(adr) or adr <= 0 or na(tRng)) ? na : tRng / adr * 100.0
        statLine(3, 4, "Today's range", na(tRng) ? "—" : str.tostring(tRng, "0.00") + "%" + (na(adrUse) ? "" : "  · " + str.tostring(adrUse, "0") + "%"),
             (not na(adrUse) and adrUse >= 100.0) ? ink(colCoin) : na, "Today's high–low range so far, and how much of the average range that is. Turns amber above 100%.")
        statLine(3, 5, "Days wider", pctVal(rgK, rgN), na, "How often a past day's full range was bigger than today's range so far. Low = today is already a wide day.")
    else if not na(statTbl)
        table.delete(statTbl)
        statTbl := na

// ═══════════════════════════════════════════════════════════════════════════
// 8. BULLISH / BEARISH RADAR — main chart, right of the last bar

var array<string> AX_NAMES = array.from("WEEKDAY", "PREV DAY", "3D REGIME", "RECENT", "MOVE SKEW")
var array<string> AX_TIPS  = array.from(
     "Up-rate of completed days sharing today's trading weekday.",
     "Up-rate of completed days whose prior day moved in the same direction as yesterday.",
     "Up-rate of completed days whose prior 3-day net move had the same sign as today's.",
     "Up-rate of the most recent completed days (Recent Window).",
     "Share of today's-weekday absolute movement that was upward. Significance: Student t on the mean return.")

float RING_LO = 30.0
float RING_HI = 70.0

var array<polyline> radarPolys  = array.new<polyline>()
var array<line>     radarLines  = array.new<line>()
var array<label>    radarLabels = array.new<label>()

clearRadar() =>
    for p in radarPolys
        polyline.delete(p)
    array.clear(radarPolys)
    for l in radarLines
        line.delete(l)
    array.clear(radarLines)
    for lb in radarLabels
        label.delete(lb)
    array.clear(radarLabels)

radNorm(float share) =>
    math.max(0.03, math.min(1.0, (share - RING_LO) / (RING_HI - RING_LO)))

axisAngle(int i) =>
    math.pi / 2.0 - i * 2.0 * math.pi / NAXES

radarPoint(int cx, float cy, float rx, float ry, int i, float r) =>
    float ang = axisAngle(i)
    chart.point.from_index(cx + int(math.round(rx * r * math.cos(ang))), cy + ry * r * math.sin(ang))

if barstate.islast
    clearRadar()
    if showRadar and not na(drawSigma) and drawSigma > 0
        int   cx = bar_index + radarOffset + radarWidth
        float cy = close
        float rx = radarWidth
        float ry = radarHeight * drawSigma / 100.0 * math.abs(close)

        for ring = 1 to 4
            array<chart.point> pts = array.new<chart.point>()
            for i = 0 to NAXES - 1
                array.push(pts, radarPoint(cx, cy, rx, ry, i, ring / 4.0))
            bool coin = ring == 2
            array.push(radarPolys, polyline.new(pts, closed = true, xloc = xloc.bar_index,
                 line_color = coin ? colCoin : color.new(colGrid, 25),
                 line_style = coin ? line.style_solid : line.style_dotted, line_width = 1, force_overlay = true))
        for i = 0 to NAXES - 1
            chart.point tipPt = radarPoint(cx, cy, rx, ry, i, 1.0)
            array.push(radarLines, line.new(cx, cy, tipPt.index, tipPt.price, xloc = xloc.bar_index,
                 color = color.new(colGrid, 45), style = line.style_dotted, width = 1, force_overlay = true))

        array<chart.point> bullPts = array.new<chart.point>()
        array<chart.point> bearPts = array.new<chart.point>()
        for i = 0 to NAXES - 1
            float sh   = array.get(axShare, i)
            bool  thin = na(sh) or array.get(axN, i) < array.get(axMinN, i)
            float s    = thin ? 50.0 : sh
            array.push(bullPts, radarPoint(cx, cy, rx, ry, i, radNorm(s)))
            array.push(bearPts, radarPoint(cx, cy, rx, ry, i, radNorm(100.0 - s)))
        array.push(radarPolys, polyline.new(bearPts, closed = true, xloc = xloc.bar_index,
             line_color = colDn, line_width = 1, fill_color = color.new(colDn, 62), force_overlay = true))
        array.push(radarPolys, polyline.new(bullPts, closed = true, xloc = xloc.bar_index,
             line_color = colUp, line_width = 1, fill_color = color.new(colUp, 62), force_overlay = true))

        for i = 0 to NAXES - 1
            float  sh   = array.get(axShare, i)
            float  nn   = array.get(axN, i)
            int    sg   = array.get(axSig, i)
            bool   thin = na(sh) or nn < array.get(axMinN, i)
            float  ang  = axisAngle(i)
            chart.point p = radarPoint(cx, cy, rx, ry, i, 1.12)
            string side = thin ? "—" : sh >= 50.0 ? "BULLISH " + fRate(sh) : "BEARISH " + fRate(100.0 - sh)
            string st   = math.cos(ang) > 0.3 ? label.style_label_left : math.cos(ang) < -0.3 ? label.style_label_right : label.style_label_down
            string tip  = array.get(AX_NAMES, i) + " — " + array.get(AX_TIPS, i) + "\nBased on " + fCount(nn) + " days."
                 + (sg != 0 ? "\n✓ 95% interval is fully above or below 50%." : "\n95% Wilson interval still overlaps 50%.")
                 + (thin ? "\nBelow Minimum Sample: drawn on the 50% ring and ignored by the score." : "")
            array.push(radarLabels, label.new(p.index, p.price, side + (sg != 0 ? " ✓" : ""), xloc = xloc.bar_index, style = st, size = lblSz,
                 color = thin ? color.new(cPanelBg, 12) : color.new(sh >= 50.0 ? colUp : colDn, 72),
                 textcolor = thin ? cMute : (isDark ? color.white : cTxt), text_formatting = fmtBI, tooltip = tip, force_overlay = true))

// ═══════════════════════════════════════════════════════════════════════════
// 9. ALERTS — events, not states

var bool firedHi = false
var bool firedLo = false
if newDay
    firedHi := false
    firedLo := false

bool evAbove = false
bool evBelow = false
if barstate.isconfirmed and not na(devRet)
    if not na(tP90) and devRet > tP90 and not firedHi
        evAbove := true
        firedHi := true
    if not na(tP10) and devRet < tP10 and not firedLo
        evBelow := true
        firedLo := true

bool evBullDay = newDay and callDir > 0
bool evBearDay = newDay and callDir < 0

alertcondition(evBullDay, "🟢 Strong Bullish Day",
     "tradewsamet • Daily Bias Intelligence\n🟢 Strong bullish historical day bias\n{{ticker}} • {{interval}}\nEducational use only.")
alertcondition(evBearDay, "🔴 Strong Bearish Day",
     "tradewsamet • Daily Bias Intelligence\n🔴 Strong bearish historical day bias\n{{ticker}} • {{interval}}\nEducational use only.")
alertcondition(evAbove, "⚡ Day Above Weekday P90",
     "tradewsamet • Daily Bias Intelligence\n⚡ Developing day closed above its historical weekday P90 level\n{{ticker}} • {{interval}}\nEducational use only.")
alertcondition(evBelow, "⚡ Day Below Weekday P10",
     "tradewsamet • Daily Bias Intelligence\n⚡ Developing day closed below its historical weekday P10 level\n{{ticker}} • {{interval}}\nEducational use only.")

bool evAny = evBullDay or evBearDay or evAbove or evBelow
alertcondition(evAny, "🔔 Any Daily Bias Intelligence Alert",
     "tradewsamet • Daily Bias Intelligence\n🔔 A Daily Bias Intelligence event triggered\n{{ticker}} • {{interval}}\nEducational use only.")
````
