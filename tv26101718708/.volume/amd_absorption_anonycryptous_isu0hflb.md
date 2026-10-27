# AMD Absorption | Anonycryptous

- url: https://www.tradingview.com/script/isU0Hflb-AMD-Absorption-Anonycryptous/
- type: indicator
- pine_id: PUB;326803f7243c4e42860795fe93307a51
- version: 1.0

## Description

Amd Absorption | Anonycryptous
Description & user manual

Why this indicator is different
Most AMD indicators do the same thing. They draw a box for Asia, a box for London, a box for New York, and call it a cycle. They show you where the sessions are. They do not show you what is happening inside them.

Amd Absorption works differently.
It detects the full accumulation-manipulation-distribution cycle mechanically, bar by bar, within whatever session windows you define. It does not assume the cycle follows a fixed schedule. It finds it where it actually forms. And it only confirms a signal when the manipulation sweep shows evidence of institutional absorption — high volume on a bar that barely moves. That is the difference between a sweep that fails and a sweep that leads somewhere.
Most traders can look at a chart in hindsight and identify an AMD cycle. The challenge is identifying it in the moment, on any asset, at any time. That is what this indicator is built to do.
It works on every instrument. Crypto, futures, forex, stocks, commodities. The session windows, detection parameters, and absorption thresholds adapt to the asset class through a preset system. The same logic that detects a liquidity sweep on a bitcoin five-minute chart detects it on a gold two-minute chart, a nasdaq futures one-minute chart, or a forex fifteen-minute chart.

Important notice
Amd Absorption generates trading signals based on pattern detection and volume analysis.
These signals are not financial advice.
They do not predict the future.
They do not guarantee profitability.
All trading decisions are made entirely by the user.
Always manage your own risk. Always apply your own judgment.

1. Overview
Amd Absorption is a cycle detection and entry timing indicator built around three phases of price behavior: accumulation, manipulation, and distribution.

What it includes:
- Mechanical AMD cycle detection within configurable session windows
- Absorption filter on the manipulation bar using volume and body/range analysis
- Five asset class presets with individually tuned detection parameters
- Three-phase candle coloring showing accumulation, manipulation, and distribution in real time
- Absorption dot markers on qualifying manipulation bars
- Distribution target box with configurable stop loss mode and risk/reward ratio
- Volume-weighted price levels as structural reference and target zones
- Vertical session boundary lines at open and close
- Configurable session background colors
- Live dashboard showing session status, preset, last signal, and absorption statistics
- Alerts for bull and bear setups

2. The AMD cycle
2.1 Accumulation
A defined period of price compression. The market moves within a narrow range while smart money builds a position. Amd Absorption detects this as a rolling high-low range falling below a configurable percentage threshold over a set lookback period. During this phase, candles are colored gray.

2.2 Manipulation
After accumulation, price sweeps beyond the range boundary — above the high for a bearish setup, below the low for a bullish setup. This is the liquidity grab. Market orders resting beyond the range are collected. Stops are hit. Retail traders enter in the wrong direction. During this phase, candles are colored in the direction of the sweep — red for a bear sweep, green for a bull sweep.

2.3 Distribution
The real move begins. Price reverses from the sweep extreme and creates a fair value gap — a three-candle imbalance confirming displacement. The signal fires. A distribution target box is drawn from the entry close to the calculated take profit level. Candle coloring continues in the signal direction for the duration of the distribution box, then stops automatically.
The cycle can repeat multiple times within a single session. There is no hard limit on setups per session.
- A note on signal quality versus cycle validity
An AMD cycle that does not produce a signal triangle can still play out fully. The triangle means the manipulation bar showed mechanical absorption — volume confirmed, body was small. That is additional evidence of institutional presence at the sweep level. It raises conviction. It does not make setups without it invalid. Many clean AMD cycles complete without a qualifying absorption bar. The candle coloring will show the full cycle regardless. The triangle is a quality filter, not the only valid setup.

3. The absorption filter
The absorption filter is what separates Amd Absorption from a standard cycle detector.
A manipulation sweep can occur for many reasons. Not every sweep leads to a reversal. The ones that do tend to share a specific characteristic on the sweep bar itself: high volume combined with a small candle body relative to the bar's range.
This pattern means price moved far on heavy participation — a big wick — but the bar closed near where it opened. Something was absorbing the selling or buying pressure. The move did not follow through. That is absorption. It is the mechanical fingerprint of institutional defense of a level.
When the absorption filter is enabled, the signal only fires if the manipulation bar meets both conditions: volume above a configurable multiple of the rolling average, and a body-to-range ratio below a configurable threshold. Bars that qualify are colored in the absorption color and marked with a dot above or below the candle.
The filter can be disabled. With the filter off, every valid AMD + FVG pattern fires a signal. With it on, only the setups with volume confirmation fire. The trade-off is signal frequency versus quality.

4. Presets
Presets automatically configure the four core detection parameters — accumulation lookback, maximum range width, absorption volume multiplier, and absorption body ratio — for each asset class.

Crypto
Lookback: 15 bars. Range: 1.20%. Volume multiplier: 1.2×. Body ratio: 0.55.
Wider range tolerance for volatile 24/7 markets. Looser volume threshold because crypto volume behavior differs from traditional markets.

Futures
Lookback: 20 bars. Range: 0.40%. Volume multiplier: 1.4×. Body ratio: 0.45.
Tight range detection for institutionally driven instruments. Higher volume requirement to match the tick-level precision of futures order flow.

Forex
Lookback: 25 bars. Range: 0.25%. Volume multiplier: 1.3×. Body ratio: 0.50.
Longest lookback and tightest range for the slow, deliberate consolidations common in major pairs. Moderate volume threshold.

Stocks
Lookback: 22 bars. Range: 0.50%. Volume multiplier: 1.4×. Body ratio: 0.50.
Balanced settings between futures and forex. Works across individual equities and equity indices.

Commodities
Lookback: 22 bars. Range: 0.35%. Volume multiplier: 1.4×. Body ratio: 0.50.
Designed for gold, silver, oil, and similar instruments. Tighter than forex but more tolerant than futures. Handles institutional spikes well.

Custom
All four parameters are set manually in the Amd Logic and Absorption Filter groups. Use this when the presets do not match the behavior of a specific instrument or timeframe combination.

Note: the manipulation search window, FVG size filter, and ATR length are always set manually regardless of preset. These three parameters are active for all presets and can be adjusted freely.

5. Sessions
Amd Absorption detects AMD cycles only within active session windows. Outside of sessions, no accumulation is tracked, no sweeps are detected, and candle coloring is inactive. This prevents false setups forming during off-hours thin markets.
Three sessions are configurable: Asia, London, and New York. Each session has an independent toggle, a clock-picker for start and end time, and a background color. All session times are entered in your selected timezone, which can be set to any UTC offset from UTC-12 to UTC+12.
A thin vertical line marks both the opening and closing of each active session. This gives you a clear visual boundary for each session's cycle. The opening line and closing line use the same configurable color.

6. Distribution box
When a signal fires, a distribution target box is drawn from the entry bar forward. The box represents the expected move from entry to take profit.
Two stop loss modes are available:

Atr mode
Stop loss distance is calculated as ATR × the configured multiplier. This gives a consistent distance across all setups regardless of the exact FVG size. Useful for instruments where ATR matches your natural stop placement.

Fvg structure mode
Stop loss is placed at the outer edge of the FVG candle — above the FVG high for a bear setup, below the FVG low for a bull setup. This uses the actual market structure as the invalidation point, which is how many practitioners manage stops on this type of setup.

The take profit is calculated as: entry ± stop distance × RR ratio. The default ratio is 2.0, giving a 1:2 reward-to-risk setup. The ratio is adjustable.

The box width is fixed in bars. It does not track price. When the configured number of bars elapses, candle coloring for the distribution phase stops automatically. For position sizing and stop management, Risk Management Engine by Anonycryptous can be used alongside this indicator.

7. Price levels
Volume-weighted pivot highs and lows are drawn as horizontal reference lines. Pivot highs above current price act as resistance. Pivot lows below current price act as support. Each level shows its exact price value.
Line appearance reflects volume strength. A stronger volume reading at the pivot produces a more visible glow layer. Weaker pivots are more subdued.
Levels disappear automatically when price touches them. The maximum number of visible levels is configurable. These levels serve as structural context and potential distribution targets for confirmed signals.

8. Candle coloring
Amd Absorption colors candles to show the current phase of the cycle. The coloring is active only within session windows.
Gray — accumulation phase. Price is consolidating within the detected range.
Red (bear) or green (bull), dim — manipulation phase. A sweep has been detected and the indicator is searching for a confirming FVG. Colors the sweep candles and any subsequent candles until the FVG fires or the search window expires.
Absorption color (default purple) — absorption bar. A candle within the manipulation phase that meets both volume and body conditions. Also marked with a dot above or below the bar.
Red (bear) or green (bull), dim — distribution phase. Fires from the signal bar and continues until the distribution box width elapses.
Priority: absorption color overrides distribution, which overrides manipulation, which overrides accumulation.

9. Dashboard
The dashboard shows:
- Session — current active session or off
- Preset — active asset preset
- Last signal — direction of the most recent confirmed signal
- Last session — which session the last signal occurred in
- Abs / setups — absorption-confirmed signals vs total AMD setups detected
- Abs filter — whether the absorption filter is on or off
- Accumulation — current accumulation state: active, searching, or none
Position is configurable: top left, top right, bottom left, or bottom right. Size is configurable: tiny, small, or normal.

10. Settings reference
10.1 Sessions
- Timezone — utc offset for session time entry
- Asia / London / New York — toggle, time picker, background color per session
- Show session open lines — vertical lines at session open and close
- Session line color

10.2 Preset
- Asset preset — crypto / futures / forex / stocks / commodities / custom

10.3 Amd logic
- Accumulation lookback — bars used to measure consolidation range (custom only)
- Max accumulation range (%) — maximum range width to qualify (custom only)
- Manipulation search window — bars to search for a sweep after accumulation
- Min fvg size (atr multiplier) — minimum gap size for distribution confirmation
- Atr length — period for atr calculation
- Sl mode — atr or fvg structure
- Sl atr multiplier — stop distance multiplier in atr mode
- Rr ratio — reward-to-risk ratio for the distribution box
- Distribution box width (bars) — fixed bar width of the distribution target box

10.4 Absorption filter
- Enable absorption filter — toggle on/off
- Min volume multiplier — minimum volume relative to average (custom only)
- Max body/range ratio — maximum body-to-range ratio (custom only)
- Volume average length — lookback for rolling volume average

10.5 Price levels
- Show price levels — toggle on/off
- Pivot lookback — bars left and right to confirm a pivot
- Min volume multiplier — minimum volume at the pivot bar
- Volume average length — lookback for volume average
- Support level color — color for pivot lows
- Resistance level color — color for pivot highs
- Max levels shown — maximum number of visible levels

10.6 Visuals
- Show accumulation box
- Show manipulation box
- Show fvg box
- Show entry signal
- Bull color — color for bullish setups and signals
- Bear color — color for bearish setups and signals
- Absorption color — color for absorption bar highlight and dot
- Distribution color — candle color during the distribution phase

10.7 Dashboard
- Show dashboard
- Position
- Size

11. How to use
11.1 Initial setup
1. Select the preset that matches your instrument.
2. Set your timezone to match your location or preferred session reference.
3. Enable the sessions you trade. Set the times to match the actual session opens for your timezone.
4. Choose a stop loss mode. Fvg structure is the more precise option. Atr is more consistent if FVGs on your timeframe vary significantly in size.
5. Set your RR ratio. Default 2.0 is a starting point — adjust to your own risk management rules.
6. If using the custom preset, start with the preset values as a reference and tune from there.

11.2 Reading the chart
Look at the session background. Once a session opens, accumulation detection begins.
When candles turn gray, accumulation is active. The indicator has found a range that qualifies as consolidation. This is the waiting phase.
When candles turn red or green, a sweep has been detected. The indicator is now looking for a confirming FVG. This is the alert phase — something is happening.
When a purple (or absorption-colored) candle appears with a dot, the sweep bar showed absorption. This is the highest-quality moment within the manipulation phase. A signal is likely imminent if a FVG forms on the next bars.
When a signal triangle fires, the full AMD cycle has confirmed with FVG and absorption. The distribution box appears showing the entry level and target.

11.3 Illustrative bull scenario
Educational example only. Not a trading recommendation.
Session opens. Candles turn gray — accumulation detected between two levels. After several bars, price dips below the accumulation low on a high-volume candle that closes near its open. The candle colors purple. A dot appears below it. Two bars later, a gap forms above — price has displaced back through the range. A green triangle fires below the entry bar. The distribution box extends to the right showing the 1:2 target. A support level line sits just below the sweep low confirming the structural context.

11.4 Illustrative bear scenario
Educational example only. Not a trading recommendation.
Session opens in London. Candles turn gray — a tight consolidation forms. Price spikes above the range high on elevated volume. The spike candle has a large wick and closes back below the high — body is less than 40% of the bar range. The candle turns purple. A dot appears above it. A FVG opens below. A red triangle fires above the entry bar. The distribution box drops from entry toward the calculated take profit. A resistance level hovers just above the sweep high.

11.5 Using the absorption filter
With the filter on, the signal only fires when the manipulation sweep bar shows mechanical absorption. This reduces total signals but increases the average quality of what does fire. The dashboard shows abs / setups — how many confirmed absorptions versus total AMD patterns detected. A ratio of 1/5 is normal. The filter is stricter by design.
With the filter off, every valid AMD + FVG pattern produces a signal regardless of volume. Use this to explore how many setups form on your instrument before deciding whether the absorption requirement is helping or filtering too aggressively.
Regardless of filter setting, the candle coloring always shows the full AMD cycle. A setup without a triangle is still visible through the gray accumulation, the colored manipulation phase, and the FVG box. Traders who want to act on every AMD cycle can use the visual coloring as their cue and treat the triangle as an additional confirmation rather than a requirement.

11.6 Timeframe guide
- 1m–3m: scalp setups. Absorption filter on. Tight preset (futures or commodities).
- 5m–15m: intraday setups. All presets apply. Standard settings.
- 30m–1h: swing context. Manipulation window and accumulation lookback can be increased.
- 4h and above: macro context only. Signals will be infrequent. Use to identify major cycle pivots.

12. Tips
The manipulation search window is your primary tuning lever. If the indicator misses setups you can see visually, increase the manipulation window. If it produces setups that do not look like genuine sweeps, tighten the range width or increase the volume multiplier.
The absorption filter is directional. A bear sweep that qualifies will have a large upper wick and a small body. A bull sweep that qualifies will have a large lower wick and a small body. If you see a purple dot on a bar with a small wick, the volume threshold is too low — raise the min volume multiplier.
Price levels are structural context, not signals. Use them to assess whether a distribution target has a logical resting point — a prior support or resistance level aligned with the take profit zone strengthens the setup.
Multiple AMD cycles can form within a single session. The state resets after each completed cycle. If an accumulation forms but no sweep follows within the search window, the state clears automatically and the indicator waits for the next consolidation.
Candle coloring stops at the session close. If candles outside the session boundaries show unexpected colors, check that your session times are correctly set for your timezone.

13. Disclaimer
This indicator is provided for educational and informational purposes only. Nothing in this document constitutes financial advice or any form of recommendation. Trading financial instruments involves substantial risk of loss. Past performance is not indicative of future results. You may lose all of your invested capital.
Anonycryptous accepts no responsibility or liability for any losses incurred as a result of using this indicator.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// (c) Anonycryptous

//@version=6
indicator("AMD Absorption | Anonycryptous", overlay=true, max_boxes_count=500, max_lines_count=300, max_labels_count=300)

// =======================================
// GROUPS
// =======================================
G_SES  = "Sessions"
G_PRE  = "Preset"
G_AMD  = "AMD Logic"
G_ABS  = "Absorption Filter"
G_LIQ  = "Price Levels"
G_VIS  = "Visuals"
G_DSH  = "Dashboard"

// =======================================
// INPUTS — SESSIONS
// =======================================
i_tzOffset = input.string("UTC+2", "Timezone",
     options=["UTC-12","UTC-11","UTC-10","UTC-9","UTC-8","UTC-7","UTC-6","UTC-5","UTC-4","UTC-3","UTC-2","UTC-1","UTC",
              "UTC+1","UTC+2","UTC+3","UTC+4","UTC+5","UTC+6","UTC+7","UTC+8","UTC+9","UTC+10","UTC+12"],
     tooltip="Your local timezone. All session times are entered in this timezone. UTC+2 = Amsterdam summer time.",
     group=G_SES)

i_showAsia    = input.bool(true, "Asia",
     tooltip="Enable AMD detection during the Asian session.",
     group=G_SES, inline="asia")
i_asiaSes     = input.session("0000-0800", "",
     tooltip="Asian session start and end time. Use the clock picker. Times in your selected timezone.",
     group=G_SES, inline="asia")
i_asiaBgColor = input.color(color.rgb(153, 11, 11, 90), "",
     tooltip="Background highlight color for the Asian session. Set full transparency to disable.",
     group=G_SES, inline="asia")

i_showLon    = input.bool(true, "London",
     tooltip="Enable AMD detection during the London session.",
     group=G_SES, inline="lon")
i_lonSes     = input.session("0900-1700", "",
     tooltip="London session start and end time. Use the clock picker. Times in your selected timezone.",
     group=G_SES, inline="lon")
i_lonBgColor = input.color(color.rgb(22, 78, 123, 90), "",
     tooltip="Background highlight color for the London session. Set full transparency to disable.",
     group=G_SES, inline="lon")

i_showNY    = input.bool(true, "New York",
     tooltip="Enable AMD detection during the New York session.",
     group=G_SES, inline="ny")
i_nySes     = input.session("1530-2200", "",
     tooltip="New York session start and end time. Default 15:30-22:00 = NY cash open at UTC+2.",
     group=G_SES, inline="ny")
i_nyBgColor = input.color(color.rgb(20, 105, 33, 90), "",
     tooltip="Background highlight color for the New York session. Set full transparency to disable.",
     group=G_SES, inline="ny")

i_showSesLine = input.bool(true, "Show session open lines",
     tooltip="Draw a thin vertical line at the open of each enabled session.",
     group=G_SES)
i_sesLineCol  = input.color(color.rgb(139, 148, 158, 50), "",
     tooltip="Color of the thin vertical session open lines.",
     group=G_SES, inline="sesline")

// =======================================
// INPUTS — PRESET
// =======================================
i_preset = input.string("Futures", "Asset Preset",
     options=["Crypto", "Futures", "Forex", "Stocks", "Commodities", "Custom"],
     tooltip="Select your asset class to auto-configure AMD and absorption parameters. Choose Custom to set all values manually.\n\nCrypto: wider ranges, 24/7 markets, looser volume threshold.\nFutures: tight ranges, high volume required, institutionally driven.\nForex: slow consolidation, very tight ranges, moderate volume.\nStocks: balanced — between futures and forex in sensitivity.\nCommodities: XAU, Oil, Silver — tighter than Forex, institutional spikes.\nCustom: use the values set in AMD Logic and Absorption Filter groups.",
     group=G_PRE)

// =======================================
// INPUTS — AMD LOGIC
// =======================================
i_accLen   = input.int(20, "Accumulation Lookback",
     minval=5, maxval=100,
     tooltip="[Custom only] Number of bars used to measure the accumulation range. Ignored when a preset is active.",
     group=G_AMD)
i_accWidth = input.float(0.3, "Max Accumulation Range (%)",
     minval=0.05, maxval=2.0, step=0.05,
     tooltip="[Custom only] Maximum price range (as % of price) for a zone to qualify as accumulation. Lower = tighter ranges only.",
     group=G_AMD)
i_manLook  = input.int(15, "Manipulation Search Window (bars)",
     minval=3, maxval=50,
     tooltip="How many bars after accumulation ends the indicator searches for a manipulation sweep (liquidity grab above/below the range). Active for all presets.",
     group=G_AMD)
i_fvgMult  = input.float(0.05, "Min FVG Size (ATR multiplier)",
     minval=0.0, maxval=1.0, step=0.01,
     tooltip="Minimum size of the Fair Value Gap relative to ATR. Higher values require a larger imbalance to confirm distribution. Active for all presets.",
     group=G_AMD)
i_atrLen   = input.int(14, "ATR Length",
     minval=1,
     tooltip="Period for ATR calculation. Used for FVG filtering and signal placement.",
     group=G_AMD)
i_slMode   = input.string("ATR", "SL Mode",
     options=["ATR", "FVG Structure"],
     tooltip="How the stop loss is calculated for the distribution box.\n\nATR: SL = entry ± ATR × multiplier. Consistent across all setups.\nFVG Structure: SL is placed above the FVG high (bear) or below the FVG low (bull) — uses the actual imbalance candle as invalidation.",
     group=G_AMD)
i_slMult   = input.float(1.5, "SL ATR Multiplier",
     minval=0.1, maxval=10.0, step=0.1,
     tooltip="[ATR mode only] Stop loss distance from entry expressed as ATR × multiplier. Ignored when SL Mode = FVG Structure.",
     group=G_AMD)
i_rrRatio  = input.float(2.0, "RR Ratio (TP)",
     minval=0.5, maxval=10.0, step=0.1,
     tooltip="Reward-to-risk ratio for the distribution target box. TP = entry ± (SL distance × RR ratio). Default 2.0 = 1:2 RR.",
     group=G_AMD)
i_distBars = input.int(20, "Distribution Box Width (bars)",
     minval=3, maxval=100,
     tooltip="How many bars wide the distribution target box is drawn. Fixed width — does not track price.",
     group=G_AMD)

// =======================================
// INPUTS — ABSORPTION FILTER
// =======================================
i_useAbsorption = input.bool(true, "Enable Absorption Filter",
     tooltip="When enabled, the AMD signal only fires if the manipulation bar shows absorption: high volume but a small candle body relative to its range. Filters out weak sweeps.",
     group=G_ABS)
i_absVolMult = input.float(1.5, "Min Volume Multiplier",
     minval=1.0, maxval=5.0, step=0.1,
     tooltip="[Custom only] Minimum volume on the manipulation bar relative to the rolling average. Higher = only confirm on truly high-volume bars.",
     group=G_ABS)
i_absBodyRatio = input.float(0.45, "Max Body/Range Ratio",
     minval=0.1, maxval=0.9, step=0.05,
     tooltip="[Custom only] Maximum body-to-range ratio on the manipulation bar. Low ratio = big wick, small close = absorption. 0.45 = body must be less than 45% of bar range.",
     group=G_ABS)
i_absVolLen = input.int(20, "Volume Average Length",
     minval=5,
     tooltip="Lookback period for the rolling volume average used in the absorption filter.",
     group=G_ABS)

// =======================================
// INPUTS — LIQUIDITY NODES
// =======================================
i_showLiq    = input.bool(true, "Show Price Levels",
     tooltip="Display volume-weighted pivot highs and lows as horizontal price levels. Resistance levels above price, support levels below. Each level shows its exact price and disappears when touched.",
     group=G_LIQ)
i_liqLookback = input.int(5, "Pivot Lookback",
     minval=2, maxval=20,
     tooltip="Number of bars left and right used to confirm a pivot high or low. Higher = only significant structural turning points.",
     group=G_LIQ)
i_liqVolMult = input.float(1.2, "Min Volume Multiplier",
     minval=0.5, maxval=5.0, step=0.1,
     tooltip="Minimum volume at the pivot bar relative to average. Higher = only high-volume levels shown.",
     group=G_LIQ)
i_liqVolLen  = input.int(20, "Volume Average Length",
     minval=5,
     tooltip="Lookback for the rolling volume average used in price level detection.",
     group=G_LIQ)
i_liqBullCol = input.color(color.rgb(0, 255, 0, 70), "Support Level Color",
     tooltip="Color of support levels (pivot lows below price).",
     group=G_LIQ)
i_liqBearCol = input.color(color.rgb(255, 0, 0, 70), "Resistance Level Color",
     tooltip="Color of resistance levels (pivot highs above price).",
     group=G_LIQ)
i_liqMaxNodes = input.int(10, "Max Levels Shown",
     minval=1, maxval=30,
     tooltip="Maximum number of price levels visible at once. Oldest levels are removed first.",
     group=G_LIQ)

// =======================================
// INPUTS — VISUALS
// =======================================
i_showAcc    = input.bool(true, "Show Accumulation Box",
     tooltip="Display a box over the detected accumulation (consolidation) zone.",
     group=G_VIS)
i_showMan    = input.bool(true, "Show Manipulation Box",
     tooltip="Display a box over the manipulation (sweep/liquidity grab) zone.",
     group=G_VIS)
i_showFVG    = input.bool(true, "Show FVG Box",
     tooltip="Display a box highlighting the Fair Value Gap that confirms distribution.",
     group=G_VIS)
i_showSignal = input.bool(true, "Show Entry Signal",
     tooltip="Display a triangle signal at the confirmed AMD + absorption entry bar.",
     group=G_VIS)
i_bullColor  = input.color(color.rgb(0, 255, 0),     "Bull Color",
     tooltip="Color for bullish AMD setups and signals.",
     group=G_VIS)
i_bearColor  = input.color(color.rgb(255, 0, 0),     "Bear Color",
     tooltip="Color for bearish AMD setups and signals.",
     group=G_VIS)
i_absColor   = input.color(color.rgb(187, 134, 252), "Absorption Color",
     tooltip="Color used for both the absorption bar highlight and the absorption dot. One color for both — adjust to taste.",
     group=G_VIS)
i_distColor  = input.color(color.rgb(245, 197, 24),  "Distribution Color",
     tooltip="Candle color applied during the distribution phase — after a confirmed AMD signal until price breaks structure or a new accumulation begins. Default: gold.",
     group=G_VIS)

// =======================================
// INPUTS — DASHBOARD
// =======================================
i_showDash = input.bool(true, "Show Dashboard",
     tooltip="Display a compact panel showing session status, preset, last signal, and absorption stats.",
     group=G_DSH)
i_dashPos  = input.string("Bottom Right", "Position",
     options=["Top Left","Top Right","Bottom Left","Bottom Right"],
     tooltip="Screen position of the dashboard.",
     group=G_DSH)
i_dashSize = input.string("Tiny", "Size",
     options=["Tiny","Small","Normal"],
     tooltip="Text size of the dashboard.",
     group=G_DSH)

// =======================================
// PRESET RESOLVER
// =======================================
accLen = switch i_preset
    "Crypto"      => 15
    "Futures"     => 20
    "Forex"       => 25
    "Stocks"      => 22
    "Commodities" => 22
    =>               i_accLen

accWidth = switch i_preset
    "Crypto"      => 1.20
    "Futures"     => 0.40
    "Forex"       => 0.25
    "Stocks"      => 0.50
    "Commodities" => 0.35
    =>               i_accWidth

absVolMult = switch i_preset
    "Crypto"      => 1.2
    "Futures"     => 1.4
    "Forex"       => 1.3
    "Stocks"      => 1.4
    "Commodities" => 1.4
    =>               i_absVolMult

absBodyRatio = switch i_preset
    "Crypto"      => 0.55
    "Futures"     => 0.45
    "Forex"       => 0.50
    "Stocks"      => 0.50
    "Commodities" => 0.50
    =>               i_absBodyRatio

// =======================================
// TIMEZONE HELPER
// =======================================
f_tzHours(tz) =>
    switch tz
        "UTC-12" => -12
        "UTC-11" => -11
        "UTC-10" => -10
        "UTC-9"  => -9
        "UTC-8"  => -8
        "UTC-7"  => -7
        "UTC-6"  => -6
        "UTC-5"  => -5
        "UTC-4"  => -4
        "UTC-3"  => -3
        "UTC-2"  => -2
        "UTC-1"  => -1
        "UTC"    => 0
        "UTC+1"  => 1
        "UTC+2"  => 2
        "UTC+3"  => 3
        "UTC+4"  => 4
        "UTC+5"  => 5
        "UTC+6"  => 6
        "UTC+7"  => 7
        "UTC+8"  => 8
        "UTC+9"  => 9
        "UTC+10" => 10
        "UTC+12" => 12
        => 0

tzOff  = f_tzHours(i_tzOffset)
utcMin = hour(time, "UTC") * 60 + minute(time, "UTC")

f_sesStrToMins(sesStr, tzHours) =>
    startH   = math.floor(str.tonumber(str.substring(sesStr, 0, 2)))
    startM   = math.floor(str.tonumber(str.substring(sesStr, 2, 4)))
    endH     = math.floor(str.tonumber(str.substring(sesStr, 5, 7)))
    endM     = math.floor(str.tonumber(str.substring(sesStr, 7, 9)))
    startUtc = (startH * 60 + startM - tzHours * 60 + 1440) % 1440
    endUtc   = (endH   * 60 + endM   - tzHours * 60 + 1440) % 1440
    [startUtc, endUtc]

f_inSesMin(startM, endM) =>
    startM < endM ? utcMin >= startM and utcMin < endM
                  : utcMin >= startM or  utcMin < endM

[asiaS, asiaE] = f_sesStrToMins(i_asiaSes, tzOff)
[lonS,  lonE]  = f_sesStrToMins(i_lonSes,  tzOff)
[nyS,   nyE]   = f_sesStrToMins(i_nySes,   tzOff)

inAsia = i_showAsia and f_inSesMin(asiaS, asiaE)
inLon  = i_showLon  and f_inSesMin(lonS,  lonE)
inNY   = i_showNY   and f_inSesMin(nyS,   nyE)

inAnySession = inAsia or inLon or inNY

// Session ID: 0=Asia, 1=London, 2=NY, -1=none
currentSes = inNY ? 2 : inLon ? 1 : inAsia ? 0 : -1

// =======================================
// SESSION BACKGROUND COLOR
// Only paint when session is active — no bleed outside
// =======================================
sesBg = inAsia ? i_asiaBgColor : inLon ? i_lonBgColor : inNY ? i_nyBgColor : na
bgcolor(sesBg, title="Session Background")

// =======================================
// SESSION OPEN LINE
// =======================================
var int prevSesId = -1
sesJustOpened = currentSes != -1 and currentSes != prevSesId
sesJustClosed = prevSesId != -1 and currentSes != prevSesId

if sesJustOpened and i_showSesLine
    line.new(bar_index, low * 0.9999, bar_index, high * 1.0001,
         extend=extend.both,
         color=i_sesLineCol,
         width=1,
         style=line.style_solid)

if sesJustClosed and i_showSesLine
    line.new(bar_index, low * 0.9999, bar_index, high * 1.0001,
         extend=extend.both,
         color=i_sesLineCol,
         width=1,
         style=line.style_solid)

if barstate.isconfirmed
    prevSesId := currentSes

// =======================================
// CORE CALCULATIONS
// =======================================
atr    = ta.atr(i_atrLen)
avgVol = ta.sma(volume, i_absVolLen)
liqAvgVol = ta.sma(volume, i_liqVolLen)

// =======================================
// AMD STATE
// =======================================
var float accHigh        = na
var float accLow         = na
var int   accStartBar    = na
var int   accEndBar      = na
var bool  manipOccurredH = false
var bool  manipOccurredL = false
var float manipExtreme   = na
var int   manipStartBar  = na
var int   lastSetupSes   = -1

// Dashboard state
var string lastDirection  = "—"
var int    absorbCount    = 0
var int    setupCount     = 0
var string lastSesName    = "—"

// Signal fire flags — reset each bar, set when AMD fires
var bool fireBearSignal = false
var bool fireBullSignal = false
fireBearSignal := false
fireBullSignal := false

// Distribution candle color state
var int  distEndBar  = na
var bool distIsBear  = false

// Reset AMD state on session change — prevents candle color bleed
// Must be after var declarations
if sesJustClosed or sesJustOpened
    accHigh        := na
    accLow         := na
    accStartBar    := na
    accEndBar      := na
    manipOccurredH := false
    manipOccurredL := false
    manipExtreme   := na
    manipStartBar  := na
    distEndBar     := na

// =======================================
// ACCUMULATION DETECTION
// =======================================
rollingHigh = ta.highest(high, accLen)
rollingLow  = ta.lowest(low,  accLen)
rangePct    = rollingLow > 0 ? (rollingHigh - rollingLow) / rollingLow * 100 : 999.0
isAccum     = rangePct <= accWidth and inAnySession

if isAccum
    accHigh        := rollingHigh
    accLow         := rollingLow
    accStartBar    := bar_index - accLen + 1
    accEndBar      := bar_index
    manipOccurredH := false
    manipOccurredL := false
    manipExtreme   := na
    manipStartBar  := na
    lastSetupSes   := currentSes

// =======================================
// ABSORPTION CHECK
// =======================================
f_isAbsorption(barIdx) =>
    barRange  = high[barIdx] - low[barIdx]
    barBody   = math.abs(close[barIdx] - open[barIdx])
    bodyRatio = barRange > 0 ? barBody / barRange : 1.0
    highVol   = volume[barIdx] > avgVol[barIdx] * absVolMult
    smallBody = bodyRatio <= absBodyRatio
    highVol and smallBody

// =======================================
// MANIPULATION + FVG DETECTION
// =======================================

// Timeout: if manipulation started but no FVG found within manLook bars — reset
if manipOccurredH and not na(manipStartBar) and bar_index > manipStartBar + i_manLook
    manipOccurredH := false
    manipExtreme   := na
    manipStartBar  := na

if manipOccurredL and not na(manipStartBar) and bar_index > manipStartBar + i_manLook
    manipOccurredL := false
    manipExtreme   := na
    manipStartBar  := na

if not isAccum and not na(accHigh) and not na(accEndBar) and bar_index <= accEndBar + i_manLook and inAnySession

    // ---- BEARISH: manipulation high ----
    if not manipOccurredH and not manipOccurredL and high > accHigh
        manipOccurredH := true
        manipExtreme   := high
        manipStartBar  := bar_index

    if manipOccurredH
        manipExtreme := math.max(manipExtreme, high)
        fvgGap  = low[2] - high
        bearFVG = fvgGap > atr * i_fvgMult and close < accHigh
        absorbed = i_useAbsorption ? f_isAbsorption(1) : true

        if bearFVG
            if i_showAcc and not na(accStartBar)
                box.new(accStartBar, accHigh, accEndBar, accLow,
                     bgcolor=color.new(color.gray, 85),
                     border_color=color.new(color.gray, 60), border_width=1)
            if i_showMan and not na(manipStartBar)
                box.new(manipStartBar, manipExtreme, bar_index - 2, accHigh,
                     bgcolor=color.new(i_bearColor, 80),
                     border_color=color.new(i_bearColor, 50), border_width=1)
            if i_showFVG
                box.new(bar_index - 2, low[2], bar_index, high,
                     bgcolor=color.new(color.white, 75),
                     border_color=color.new(color.white, 50),
                     border_style=line.style_solid)
            if absorbed
                absorbCount    += 1
                fireBearSignal := i_showSignal
            setupCount    += 1
            lastDirection := "▼ BEAR"
            lastSesName   := currentSes == 0 ? "ASIA" : currentSes == 1 ? "LONDON" : "NEW YORK"
            distEndBar    := bar_index + i_distBars
            distIsBear    := true
            // Distribution box — SL mode: ATR or FVG Structure
            distEntry = close
            distSL    = i_slMode == "FVG Structure" ? low[2] : distEntry + atr * i_slMult
            distDist  = math.abs(distSL - distEntry)
            distTP    = distEntry - distDist * i_rrRatio
            box.new(bar_index, distEntry, bar_index + i_distBars, distTP,
                 bgcolor=color.new(i_distColor, 80),
                 border_color=color.new(i_distColor, 40),
                 border_width=1)
            accHigh        := na
            manipOccurredH := false
            manipExtreme   := na

    // ---- BULLISH: manipulation low ----
    if not manipOccurredL and not manipOccurredH and low < accLow
        manipOccurredL := true
        manipExtreme   := low
        manipStartBar  := bar_index

    if manipOccurredL
        manipExtreme := math.min(manipExtreme, low)
        fvgGap  = low - high[2]
        bullFVG = fvgGap > atr * i_fvgMult and close > accLow
        absorbed = i_useAbsorption ? f_isAbsorption(1) : true

        if bullFVG
            if i_showAcc and not na(accStartBar)
                box.new(accStartBar, accHigh, accEndBar, accLow,
                     bgcolor=color.new(color.gray, 85),
                     border_color=color.new(color.gray, 60), border_width=1)
            if i_showMan and not na(manipStartBar)
                box.new(manipStartBar, accLow, bar_index - 2, manipExtreme,
                     bgcolor=color.new(i_bullColor, 80),
                     border_color=color.new(i_bullColor, 50), border_width=1)
            if i_showFVG
                box.new(bar_index - 2, high[2], bar_index, low,
                     bgcolor=color.new(color.white, 75),
                     border_color=color.new(color.white, 50),
                     border_style=line.style_dotted)
            if absorbed
                absorbCount    += 1
                fireBullSignal := i_showSignal
            setupCount    += 1
            lastDirection := "▲ BULL"
            lastSesName   := currentSes == 0 ? "ASIA" : currentSes == 1 ? "LONDON" : "NEW YORK"
            distEndBar    := bar_index + i_distBars
            distIsBear    := false
            // Distribution box — SL mode: ATR or FVG Structure
            distEntry = close
            distSL    = i_slMode == "FVG Structure" ? high[2] : distEntry - atr * i_slMult
            distDist  = math.abs(distEntry - distSL)
            distTP    = distEntry + distDist * i_rrRatio
            box.new(bar_index, distTP, bar_index + i_distBars, distEntry,
                 bgcolor=color.new(i_distColor, 80),
                 border_color=color.new(i_distColor, 40),
                 border_width=1)
            accLow         := na
            manipOccurredL := false
            manipExtreme   := na

// =======================================
// CANDLE COLORING — AMD PHASE
// Priority: absorption > distribution > manipulation > accumulation > na
// Absorption   = absColor when manipulation bar qualifies
// Distribution = bear/bull color while within distEndBar window
// Manipulation = dim bear/bull color while searching for FVG
// Accumulation = dim gray during consolidation
// =======================================
inManip      = manipOccurredH or manipOccurredL
manipDirCol  = manipOccurredH ? i_bearColor : i_bullColor
absHighlight = i_useAbsorption and inManip and f_isAbsorption(0) and inAnySession
inDist       = not na(distEndBar) and bar_index <= distEndBar and inAnySession
distDirCol   = distIsBear ? i_bearColor : i_bullColor

candleCol = absHighlight ? i_absColor : inDist ? color.new(distDirCol, 50) : inManip and inAnySession ? color.new(manipDirCol, 50) : isAccum ? color.new(color.gray, 55) : na
barcolor(candleCol, title="AMD Phase Candle Color")

// =======================================
// SIGNALS — plotshape for true tiny size
// =======================================
plotshape(fireBearSignal, "Bear Signal", shape.triangledown, location.abovebar, i_bearColor, size=size.tiny)
plotshape(fireBullSignal, "Bull Signal", shape.triangleup,   location.belowbar, i_bullColor, size=size.tiny)

// Absorption dots — small plot circles above/below bar
absDotBear = absHighlight and manipOccurredH
absDotBull = absHighlight and manipOccurredL
plot(absDotBear ? high + atr * 0.3 : na, "Absorption Dot Bear", color.new(i_absColor, 0), linewidth=1, style=plot.style_circles)
plot(absDotBull ? low  - atr * 0.3 : na, "Absorption Dot Bull", color.new(i_absColor, 0), linewidth=1, style=plot.style_circles)

// =======================================
// PRICE LEVELS
// Volume-weighted pivot highs and lows
// Glow scales with volume strength
// =======================================
type LiqNode
    float  price
    bool   isBear
    float  vWeight
    line   ln
    line   glowLn
    label  lbl

var array<LiqNode> liqNodes = array.new<LiqNode>()

pH = ta.pivothigh(high, i_liqLookback, i_liqLookback)
pL = ta.pivotlow(low,   i_liqLookback, i_liqLookback)

pivotBar  = bar_index - i_liqLookback
lineEndX  = bar_index + 5

if i_showLiq
    // Pivot high — resistance level
    if not na(pH) and volume[i_liqLookback] > liqAvgVol[i_liqLookback] * i_liqVolMult
        vW      = math.min(volume[i_liqLookback] / liqAvgVol[i_liqLookback], 5.0)
        glowT   = math.round(85.0 + (vW - 1.0) / (5.0 - 1.0) * (50.0 - 85.0))
        glowLn  = line.new(pivotBar, pH, lineEndX, pH,
                     color=color.new(i_liqBearCol, glowT), width=3,
                     style=line.style_solid)
        ln      = line.new(pivotBar, pH, lineEndX, pH,
                     color=i_liqBearCol, width=1,
                     style=line.style_solid)
        priceStr = str.tostring(pH, format.mintick)
        lbl     = label.new(lineEndX, pH, priceStr,
                     color=color.new(color.black, 100),
                     textcolor=i_liqBearCol,
                     style=label.style_label_left,
                     size=size.tiny)
        node    = LiqNode.new(pH, true, vW, ln, glowLn, lbl)
        array.push(liqNodes, node)

    // Pivot low — support level
    if not na(pL) and volume[i_liqLookback] > liqAvgVol[i_liqLookback] * i_liqVolMult
        vW      = math.min(volume[i_liqLookback] / liqAvgVol[i_liqLookback], 5.0)
        glowT   = math.round(85.0 + (vW - 1.0) / (5.0 - 1.0) * (50.0 - 85.0))
        glowLn  = line.new(pivotBar, pL, lineEndX, pL,
                     color=color.new(i_liqBullCol, glowT), width=3,
                     style=line.style_solid)
        ln      = line.new(pivotBar, pL, lineEndX, pL,
                     color=i_liqBullCol, width=1,
                     style=line.style_solid)
        priceStr = str.tostring(pL, format.mintick)
        lbl     = label.new(lineEndX, pL, priceStr,
                     color=color.new(color.black, 100),
                     textcolor=i_liqBullCol,
                     style=label.style_label_left,
                     size=size.tiny)
        node    = LiqNode.new(pL, false, vW, ln, glowLn, lbl)
        array.push(liqNodes, node)

// Update nodes: extend +5 bars from current bar, remove if price touches
if i_showLiq and array.size(liqNodes) > 0
    for i = array.size(liqNodes) - 1 to 0
        node    = array.get(liqNodes, i)
        touched = node.isBear ? high >= node.price : low <= node.price
        newEnd  = bar_index + 5
        if touched
            line.delete(node.ln)
            line.delete(node.glowLn)
            label.delete(node.lbl)
            array.remove(liqNodes, i)
        else
            line.set_x2(node.ln,     newEnd)
            line.set_x2(node.glowLn, newEnd)
            label.set_x(node.lbl,    newEnd)

// Trim oldest if over max
while array.size(liqNodes) > i_liqMaxNodes
    old = array.shift(liqNodes)
    line.delete(old.ln)
    line.delete(old.glowLn)
    label.delete(old.lbl)

// =======================================
// DASHBOARD
// =======================================
var table dash = table.new(position.bottom_right, 2, 9,
     bgcolor      = color.new(#0d1117, 10),
     border_color = color.new(#30363d, 20), border_width=1,
     frame_color  = color.new(#30363d, 40), frame_width=1)

if i_showDash and barstate.islast
    dSize      = i_dashSize == "Tiny" ? size.tiny : i_dashSize == "Small" ? size.small : size.normal
    colorMuted = color.new(#8b949e, 0)
    colorWhite = color.new(#ffffff, 0)
    colorPanel = color.new(#161b22, 0)
    colorBG    = color.new(#0d1117, 0)
    colorBrand = color.new(#bb86fc, 0)

    dashPos = switch i_dashPos
        "Top Left"    => position.top_left
        "Top Right"   => position.top_right
        "Bottom Left" => position.bottom_left
        =>              position.bottom_right
    table.set_position(dash, dashPos)

    dirColor = lastDirection == "▲ BULL" ? color.new(i_bullColor, 0) : lastDirection == "▼ BEAR" ? color.new(i_bearColor, 0) : colorMuted

    sesStatus = switch currentSes
        0 => "▶ ASIA"
        1 => "▶ LONDON"
        2 => "▶ NEW YORK"
        => "— OFF"
    sesColor = currentSes != -1 ? colorWhite : colorMuted

    absStr   = setupCount > 0 ? str.tostring(absorbCount) + " / " + str.tostring(setupCount) : "—"
    absColor = absorbCount > 0 ? color.new(i_absColor, 0) : colorMuted

    filterStr = i_useAbsorption ? "ON" : "OFF"
    filterCol = i_useAbsorption ? color.new(i_bullColor, 0) : colorMuted

    accumStr = isAccum ? "● ACTIVE" : not na(accHigh) ? "○ SEARCHING" : "— NONE"
    accumCol = isAccum ? color.new(i_absColor, 0) : not na(accHigh) ? colorWhite : colorMuted

    // Row 0 — Header full width
    table.cell(dash, 0, 0, "AMD Absorption  v1.0", text_color=colorWhite, text_size=dSize, bgcolor=colorPanel, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 1, 0)
    // Row 1 — Session
    table.cell(dash, 0, 1, "SESSION",        text_color=colorMuted,  text_size=dSize, bgcolor=colorBG,    text_halign=text.align_left)
    table.cell(dash, 1, 1, sesStatus,        text_color=sesColor,    text_size=dSize, bgcolor=colorBG,    text_halign=text.align_right)
    // Row 2 — Preset
    table.cell(dash, 0, 2, "PRESET",         text_color=colorMuted,  text_size=dSize, bgcolor=colorBG,    text_halign=text.align_left)
    table.cell(dash, 1, 2, i_preset,         text_color=colorWhite,  text_size=dSize, bgcolor=colorBG,    text_halign=text.align_right)
    // Row 3 — Last signal
    table.cell(dash, 0, 3, "LAST SIGNAL",    text_color=colorMuted,  text_size=dSize, bgcolor=colorBG,    text_halign=text.align_left)
    table.cell(dash, 1, 3, lastDirection,    text_color=dirColor,    text_size=dSize, bgcolor=colorBG,    text_halign=text.align_right)
    // Row 4 — Last session
    table.cell(dash, 0, 4, "LAST SESSION",   text_color=colorMuted,  text_size=dSize, bgcolor=colorBG,    text_halign=text.align_left)
    table.cell(dash, 1, 4, lastSesName,      text_color=colorMuted,  text_size=dSize, bgcolor=colorBG,    text_halign=text.align_right)
    // Row 5 — Absorption hits
    table.cell(dash, 0, 5, "ABS / SETUPS",  text_color=colorMuted,  text_size=dSize, bgcolor=colorBG,    text_halign=text.align_left)
    table.cell(dash, 1, 5, absStr,           text_color=absColor,    text_size=dSize, bgcolor=colorBG,    text_halign=text.align_right)
    // Row 6 — Filter
    table.cell(dash, 0, 6, "ABS FILTER",    text_color=colorMuted,  text_size=dSize, bgcolor=colorBG,    text_halign=text.align_left)
    table.cell(dash, 1, 6, filterStr,        text_color=filterCol,   text_size=dSize, bgcolor=colorBG,    text_halign=text.align_right)
    // Row 7 — Accumulation
    table.cell(dash, 0, 7, "ACCUMULATION",  text_color=colorMuted,  text_size=dSize, bgcolor=colorBG,    text_halign=text.align_left)
    table.cell(dash, 1, 7, accumStr,         text_color=accumCol,    text_size=dSize, bgcolor=colorBG,    text_halign=text.align_right)
    // Row 8 — Brand full width
    table.cell(dash, 0, 8, "Anonycryptous", text_color=colorBrand,  text_size=dSize, bgcolor=colorPanel, text_halign=text.align_center)
    table.merge_cells(dash, 0, 8, 1, 8)

// =======================================
// ALERTS
// =======================================
var int  prevSetupCount = 0
newSetup = setupCount > prevSetupCount
var bool alertBull = false
var bool alertBear = false
alertBull      := newSetup and lastDirection == "▲ BULL"
alertBear      := newSetup and lastDirection == "▼ BEAR"
prevSetupCount := setupCount

alertcondition(alertBull,            "AMD Bull Setup", "AMD Absorption: Bullish setup confirmed")
alertcondition(alertBear,            "AMD Bear Setup", "AMD Absorption: Bearish setup confirmed")
alertcondition(alertBull or alertBear, "AMD Any Setup", "AMD Absorption: New setup confirmed")
````
