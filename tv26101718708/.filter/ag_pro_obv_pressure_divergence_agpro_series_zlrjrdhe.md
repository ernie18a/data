# AG Pro OBV Pressure Divergence [AGPro Series]

- url: https://www.tradingview.com/script/ZlRjrdhE-AG-Pro-OBV-Pressure-Divergence-AGPro-Series/
- type: indicator
- pine_id: PUB;c11d86ec21534a9d8a77d8cd41907147
- version: 5.0

## Description

[b]AG Pro OBV Pressure Divergence [AGPro Series][/b]

Overview

AG Pro OBV Pressure Divergence is a context-aware divergence quality map built around the relationship between price structure and On-Balance Volume pressure.

The script is designed to identify bullish and bearish divergence events, then rank those events by participation quality, structural context, and follow-through behavior. Instead of treating every divergence as equally important, it separates weaker pressure disagreements from more meaningful setups and organizes them into a cleaner decision framework.

This is not a generic divergence marker that prints every local mismatch between price and an underlying series. Its purpose is to classify divergence events through a layered process that includes pivot structure, price displacement, OBV behavior, trend context, confirmation timing, and visual emphasis.

The result is a tool that can be used to study when price and participation begin to disagree, while still preserving a practical chart view that remains readable during live market conditions.

[image]https://www.tradingview.com/x/zQMxH27o/[/image]

What this script does

- Detects bullish divergence when price forms a lower low while OBV forms a higher low
- Detects bearish divergence when price forms a higher high while OBV forms a lower high
- Filters divergence candidates using pivot separation and ATR-based price swing requirements
- Scores events by quality instead of treating all signals the same
- Highlights the strongest events with more prominent chart objects
- Tracks confirmation and invalidation behavior after the initial event
- Displays a compact summary panel for state, pressure, context, and freshness


Unique Edge

Many divergence tools stop at basic detection. They show a disagreement between price and an oscillator or cumulative volume series and leave the rest to the user.

This script takes a different approach.

Its goal is not to maximize the number of divergence labels on the chart. Its goal is to classify divergence quality.

That difference matters. A simple divergence can appear in noisy conditions, in weak structural locations, or without any meaningful follow-through. In those cases, the event may still be technically valid, but not equally useful from an analytical point of view.

AG Pro OBV Pressure Divergence attempts to address that by combining several layers:

1. Structural divergence detection
2. ATR-normalized price displacement filtering
3. OBV pressure comparison between pivots
4. Local trend context using fast and slow EMA structure
5. Setup monitoring through confirmation and invalidation logic
6. Visual hierarchy that distinguishes lower-quality from higher-quality events

Because of this design, the script is better understood as a divergence classification framework rather than a simple divergence marker.

It is also distinct from breakout, reclaim, or trend continuation tools. It does not evaluate break-retest mechanics, VWAP reclaim logic, or general trend strength as its primary objective. Its focus is the quality of price-versus-participation disagreement.


Methodology

The script begins by identifying swing pivots through a configurable pivot length. These pivots form the structural anchor points used to compare price and OBV behavior.

For bullish divergence:
- price must form a lower low
- OBV must form a higher low

For bearish divergence:
- price must form a higher high
- OBV must form a lower high

After a raw divergence is found, the script applies additional requirements before the event is accepted:

Pivot Separation
A minimum bar gap is enforced between pivots so that tightly packed micro-swings do not dominate the output.

Minimum Price Swing
The distance between the two relevant pivots is measured relative to ATR. This prevents very small structural changes from being treated like full-quality events.

Pressure Evaluation
The OBV relationship between the two pivots is examined to determine whether participation is actually improving or weakening in a meaningful way.

Trend Context
Fast and slow EMA structure is used to frame whether the event is appearing against or within the prevailing price environment.

Contextual Location
The script also evaluates where the event is occurring in its local range structure. This helps separate mid-range noise from more interesting reversal or exhaustion locations.

Scoring
All of the above components contribute to a quality score. That score is then used to separate lower-priority events from stronger ones.

Confirmation
After the initial event, the script tracks a confirmation window. During that window, the setup may confirm, remain pending, expire, or become invalidated.

This layered structure is intentional. The script does not assume that a divergence label alone is enough.


Signal Structure

The script organizes events into a sequence instead of a single binary output.

Event Detected
A new bullish or bearish divergence is found and scored.

Pending State
The event remains active while the script monitors whether follow-through appears within the confirmation window.

Confirmed
If the confirmation condition is met within the allowed window, the event is marked as confirmed.

Invalidated
If price fails the setup before confirmation, the event is marked as invalidated.

Expired
If no confirmation occurs within the defined number of bars, the setup is no longer treated as active.

This state-based behavior is useful because it prevents the chart from presenting all divergence events as finalized conclusions the moment they appear.


Quality Model

The script uses a quality threshold and a premium threshold to distinguish event strength.

Lower-quality events can still be displayed when the user wants a fuller map of all structure, but the script can also be configured to focus only on stronger setups.

This creates three practical layers of interpretation:

Building
A divergence exists, but the score is lower and the event should be treated with more caution.

High
The event passes the main quality threshold and receives stronger visual treatment.

Premium
The event exceeds the premium threshold and receives the strongest category treatment in the script.

This does not mean that premium events are guarantees, and it does not imply that lower-quality events are unusable. It simply reflects that not every divergence deserves the same level of attention.


Panel Summary

The summary panel is intended to give quick context without forcing the user to inspect every label one by one.

The panel includes:

- Bias
A simple view of the current directional background based on the fast and slow EMA relationship.

- Pressure
A quick summary of whether OBV pressure is rising, falling, or mixed.

- Last Event
Shows the most recent detected divergence direction.

- Quality
Displays the score and current classification of the most recent event.

- State
Shows whether the most recent tracked setup is in watch, confirmed, invalidated, or idle state.

- Context
Provides a compact view of the local environment, such as trend-up, trend-down, or range-related placement.

- Freshness
Indicates how many bars have passed since the latest tracked event.


Visual Design

The chart output is intentionally organized with hierarchy.

Qualified events are easier to spot than weaker ones.
Confirmation labels are visually distinct from initial event labels.
Link lines help explain which two pivots created the divergence.
Optional background pulse and active setup zone provide temporary emphasis without permanently dominating the chart.
EMA context remains available but is visually secondary to the divergence structure.

Tooltips are included for key settings so that the logic behind the inputs remains understandable directly from the settings panel.


Signals and Alerts

The script includes alert conditions for the main state transitions:

- New Bullish Pressure Divergence
- New Bearish Pressure Divergence
- Premium Bullish Pressure Divergence
- Premium Bearish Pressure Divergence
- Bullish Pressure Divergence Confirmed
- Bearish Pressure Divergence Confirmed
- Pressure Divergence Invalidated

These alerts are designed to reflect internal script states rather than making claims about future price outcomes.


Key Inputs

Pivot Length
Controls how swings are defined. Higher values reduce noise but may delay detection.

OBV Smoothing
Smooths the OBV series before divergence analysis. Higher values create a cleaner but slower pressure curve.

Minimum Pivot Separation
Prevents overly compressed pivots from producing excessive clustering.

Minimum Price Swing (ATR)
Requires meaningful structural movement before a divergence is accepted.

Quality Threshold
Defines the minimum score required for a divergence to be treated as a qualified event.

Premium Threshold
Defines the score level required for premium classification.

Confirmation Window (Bars)
Controls how long a pending event is monitored before it expires.

Use Close-Based Confirmation
Switches confirmation logic between close-based behavior and intrabar high/low behavior.

Main Label Size
Scales event, confirmation, and invalidation labels.

Panel Text Size
Controls panel readability independently from chart labels.

Drawing Emphasis
Adjusts how visually prominent lines, EMA context, and active zone objects appear on the chart.


How to use it

This script is best approached as a context tool, not as a stand-alone decision engine.

A practical workflow may look like this:

1. Identify whether the panel context is aligned with a broad directional background or whether the market is behaving more like a range.
2. Observe whether a new divergence appears in a meaningful local location rather than in the middle of random price noise.
3. Compare the quality score and classification.
4. Watch whether the event confirms or invalidates within the chosen time window.
5. Combine the information with your own structure, risk, and execution framework.

The script is often more informative when used to reduce attention on weaker disagreements and concentrate on better-formed pressure divergences.


Who it may be useful for

This script may be useful for users who want:

- a more structured way to study price and OBV disagreement
- a cleaner divergence map with stronger visual hierarchy
- a chart that distinguishes raw detection from confirmed follow-through
- a volume-pressure oriented lens that is different from standard oscillator-only divergence tools

It may be less suitable for users who want a high-frequency signal stream, a one-click entry engine, or a tool that treats every local divergence as equally relevant.


Limitations and Transparency

This script has important limitations.

First, divergence is an analytical concept, not a guaranteed turning-point mechanism. A divergence can appear and still fail, extend, or resolve slowly.

Second, the scoring model is a ranking method, not a prediction formula. A higher score does not mean certainty. It only means that the event better satisfies the script's internal conditions.

Third, pivot-based logic requires structure to form. This means the script necessarily depends on completed swing information and will not behave like a forward-only projection model.

Fourth, confirmation and invalidation logic are simplifications intended to organize event follow-through. They do not replace full trade management, execution rules, or independent risk control.

Fifth, any indicator that uses volume-derived inputs depends on the characteristics of the underlying market data. Users should be aware that data quality and market structure can differ across symbols and venues.

This script is therefore best used as a contextual classification tool rather than a complete standalone methodology.


What this script is not

- It is not a guarantee of reversals.
- It is not a promise engine.
- It is not a fully automated trading system.
- It is not a substitute for independent structure analysis or risk management.
- It is not designed to predict every local top or bottom.
- It is not intended to imply that premium signals are always superior in every market condition.

Its purpose is narrower and more practical:
to organize OBV-based divergence events into a more useful analytical framework.


Risk Disclosure

This script is for chart analysis and research purposes only.

It does not provide financial advice, investment advice, portfolio advice, or a guarantee of future market behavior. Market conditions can change quickly, and any signal or classification generated by the script can fail or become invalid.

Users should make independent decisions and apply their own risk controls before acting on any chart output.


In summary

AG Pro OBV Pressure Divergence is a public, chart-based tool for analyzing divergence quality through the interaction of price structure and OBV pressure.

Its main contribution is not that it detects divergence, but that it attempts to rank divergence events by structural relevance, pressure context, and follow-through state.

For users who want a cleaner way to study whether price and participation are beginning to disagree, this script aims to provide a more selective and better-organized framework than a raw all-events divergence marker.

## Source Code

````pine
// -------------------------------------------------
// OBV Pressure Divergence [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// A premium On-Balance Volume divergence and confirmation map for price-action traders.
// The script detects bullish and bearish OBV Pressure Divergence, ranks each setup
// with trend, impulse, range-location, and follow-through filters, then projects clean
// reaction zones to frame confirmation, invalidation, and continuation context.
// Includes a plain-language Next Action readout and a historical confirm rate
// statistic measured across resolved divergence setups.
// -------------------------------------------------

//@version=6
indicator("OBV Pressure Divergence [AGPro Series]",
     shorttitle = "AG Pro OBV",
     overlay = true,
     max_labels_count = 360,
     max_lines_count = 360,
     max_boxes_count = 160)

//------------------------------------------------------------------------------
// INPUT GROUPS
//------------------------------------------------------------------------------
G_CORE   = "Detection Engine"
G_FILTER = "Qualification"
G_ALERT  = "Confirmation Logic"
G_ZONE   = "Reaction Zones"
G_VIS    = "Visual Map"

//------------------------------------------------------------------------------
// CORE INPUTS
//------------------------------------------------------------------------------
pivotLen         = input.int(5, "Pivot Length", minval = 2, maxval = 20, group = G_CORE, tooltip = "Defines the left and right pivot strength used to anchor OBV divergence comparisons. Higher values create fewer but more mature swing points.")
obvSmoothLen     = input.int(5, "OBV Smoothing", minval = 1, maxval = 50, group = G_CORE, tooltip = "Smooths the raw On-Balance Volume stream before pivot comparison. Higher values reduce noise but make the participation curve slower.")
minPivotGap      = input.int(8, "Minimum Pivot Separation", minval = 1, maxval = 100, group = G_CORE, tooltip = "Minimum number of bars required between the two pivots that form a divergence. This prevents compressed micro-swings from dominating the chart.")
trendFastLen     = input.int(21, "Trend Fast EMA", minval = 2, maxval = 200, group = G_CORE, tooltip = "Fast EMA used to read the near-term directional background around each divergence event.")
trendSlowLen     = input.int(55, "Trend Slow EMA", minval = 3, maxval = 300, group = G_CORE, tooltip = "Slow EMA used with the fast EMA to classify broader trend context.")
contextLen       = input.int(34, "Context Lookback", minval = 10, maxval = 300, group = G_CORE, tooltip = "Lookback window used to judge whether a divergence forms near a meaningful local range edge or in the middle of the current structure.")

//------------------------------------------------------------------------------
// QUALITY INPUTS
//------------------------------------------------------------------------------
minPriceAtr        = input.float(0.35, "Minimum Price Swing (ATR)", minval = 0.0, maxval = 10.0, step = 0.05, group = G_FILTER, tooltip = "Minimum price displacement required between pivots, expressed in ATR units. Larger values focus the script on more meaningful structural movement.")
qualityThreshold   = input.int(60, "Quality Threshold", minval = 0, maxval = 100, group = G_FILTER, tooltip = "Minimum score required for a divergence to qualify as a main chart event. Lower values show more structure; higher values keep the map more selective.")
premiumThreshold   = input.int(78, "Prime Threshold", minval = 0, maxval = 100, group = G_FILTER, tooltip = "Score level required for the strongest visual treatment. Prime events receive the highest emphasis in labels, lines, and panel coloring.")
showWeakSignals    = input.bool(true, "Show Building Signals", group = G_FILTER, tooltip = "Displays sub-threshold divergence events as lower-emphasis building signals. Disable this for a stricter, cleaner chart.")
signalCooldownBars = input.int(16, "Same-Side Signal Cooldown", minval = 0, maxval = 100, group = G_FILTER, tooltip = "Minimum spacing between same-direction qualified signals. Prime events can still appear even when the cooldown is active.")

//------------------------------------------------------------------------------
// CONFIRMATION INPUTS
//------------------------------------------------------------------------------
confirmBars      = input.int(14, "Confirmation Window (Bars)", minval = 1, maxval = 100, group = G_ALERT, tooltip = "Maximum number of bars allowed for a pending divergence setup to confirm before it expires.")
confirmUseClose  = input.bool(true, "Use Close-Based Confirmation", group = G_ALERT, tooltip = "Requires the candle close to break the trigger level when enabled. When disabled, intrabar high or low movement can confirm the setup.")
showInvalidation = input.bool(true, "Show Invalidation Labels", group = G_ALERT, tooltip = "Displays a small invalidation tag when a pending divergence fails before confirmation.")

//------------------------------------------------------------------------------
// REACTION ZONE INPUTS
//------------------------------------------------------------------------------
showActiveZone        = input.bool(true, "Show Active Setup Zone", group = G_ZONE, tooltip = "Highlights the live setup area while a divergence is waiting for confirmation, invalidation, or expiry.")
setupZoneMode         = input.string("Range Box", "Setup Zone Mode", options = ["Range Box", "Tight Box"], group = G_ZONE, tooltip = "Range Box spans from the source pivot to the trigger level. Tight Box keeps the setup zone closer to the pivot.")
activeZoneAtr         = input.float(0.24, "Tight Box Height (ATR)", minval = 0.10, maxval = 3.0, step = 0.05, group = G_ZONE, tooltip = "Vertical size of the Tight Box mode, measured in ATR units.")
setupZonePadAtr       = input.float(0.14, "Setup Zone Padding (ATR)", minval = 0.0, maxval = 2.0, step = 0.02, group = G_ZONE, tooltip = "Extra ATR padding added around setup and reaction zones so the boxes remain readable across different instruments.")
showTriggerLevel      = input.bool(true, "Show Trigger Level", group = G_ZONE, tooltip = "Draws the horizontal confirmation trigger level for the active divergence setup.")
showReactionZone      = input.bool(true, "Show Confirmed Reaction Zone", group = G_ZONE, tooltip = "Projects the latest confirmed bullish and bearish reaction zones to the right. These zones help frame follow-through without creating a full support/resistance system.")
reactionExtendBars    = input.int(64, "Reaction Zone Extension", minval = 5, maxval = 300, group = G_ZONE, tooltip = "Number of bars used to extend the latest confirmed reaction zone. Longer extensions make the zone easier to track after confirmation.")
showReactionMidline   = input.bool(true, "Show Reaction Trigger Line", group = G_ZONE, tooltip = "Extends the confirmed trigger level through the latest reaction zone as a clean reference line.")
removeResolvedSetups  = input.bool(true, "Remove Resolved Setup Zones", group = G_ZONE, tooltip = "Deletes temporary setup boxes and trigger lines after confirmation, invalidation, or expiry. This keeps the chart polished while preserving confirmed reaction zones.")

//------------------------------------------------------------------------------
// VISUAL INPUTS
//------------------------------------------------------------------------------
showPanel              = input.bool(true, "Show Summary Panel", group = G_VIS, tooltip = "Displays the compact OBV Pressure dashboard in the selected chart corner.")
panelPositionInput     = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = G_VIS, tooltip = "Chooses where the summary panel appears on the chart.")
themeInput             = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_VIS, tooltip = "Switches the summary panel between a dark professional theme and a light chart-friendly theme.")
showLinkLines          = input.bool(true, "Show Pivot Link Lines", group = G_VIS, tooltip = "Draws clean guide lines between the two price pivots that form each OBV divergence.")
showLabelStems         = input.bool(true, "Show Label Stems", group = G_VIS, tooltip = "Draws short connector stems from price toward event, confirmation, and invalidation labels for better readability.")
showBgPulse            = input.bool(true, "Background Pulse on New Event", group = G_VIS, tooltip = "Adds a brief background pulse when a new divergence event appears. Prime events use the stronger accent tone.")
showContextEMAs        = input.bool(true, "Show Context EMAs", group = G_VIS, tooltip = "Displays the fast and slow EMA pair used to frame trend context. The lines are secondary by design so divergence objects stay dominant.")
showConfirmMarkers     = input.bool(false, "Show Confirmation Diamonds", group = G_VIS, tooltip = "Displays small diamond markers on confirmation bars. Disabled by default because labels and zones already communicate confirmation clearly.")
maxVisibleEventLabels  = input.int(4, "Recent Event Labels Per Side", minval = 1, maxval = 10, group = G_VIS, tooltip = "Keeps only the most recent divergence event labels per side. This preserves a premium chart without leaving the map empty.")
maxVisibleConfirmTags  = input.int(3, "Recent Confirm Tags Per Side", minval = 1, maxval = 10, group = G_VIS, tooltip = "Keeps only the most recent confirmation and invalidation tags per side.")
labelSizeInput         = input.string("Normal", "Main Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VIS, tooltip = "Controls the size of event, confirmation, and invalidation labels. Normal is designed as the default publication view.")
panelTextSizeInput     = input.string("Normal", "Panel Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VIS, tooltip = "Controls the text size used inside the summary panel. Normal keeps the panel readable without taking over the chart.")
drawingEmphasisInput   = input.string("Strong", "Drawing Emphasis", options = ["Normal", "Strong"], group = G_VIS, tooltip = "Controls how prominent the main chart drawings appear. Strong is optimized for screenshots and public script presentation.")
eventLabelRightBars    = input.int(5, "Event Label Right Offset", minval = 0, maxval = 25, group = G_VIS, tooltip = "Moves divergence labels to the right of the source pivot to reduce candle overlap.")
confirmLabelRightBars  = input.int(5, "Confirm Label Right Offset", minval = 0, maxval = 25, group = G_VIS, tooltip = "Moves confirmation and invalidation labels to the right of the event bar for cleaner spacing.")
eventLabelAtrOffset    = input.float(1.10, "Event Label ATR Offset", minval = 0.0, maxval = 5.0, step = 0.05, group = G_VIS, tooltip = "Vertical distance between divergence labels and price, measured in ATR units. Higher values keep labels away from candle bodies.")
confirmLabelAtrOffset  = input.float(1.35, "Confirm Label ATR Offset", minval = 0.0, maxval = 5.0, step = 0.05, group = G_VIS, tooltip = "Vertical distance between confirmation or invalidation labels and price, measured in ATR units.")
showConfirmStat        = input.bool(true, "Show Confirm Rate Statistic", group = G_VIS, tooltip = "Shows the historical share of resolved divergence setups on this chart that reached confirmation before being invalidated or expiring. Descriptive statistic only - past behavior does not guarantee future outcomes.")

//------------------------------------------------------------------------------
// HELPERS
//------------------------------------------------------------------------------
f_clamp(_v, _min, _max) =>
    math.max(_min, math.min(_max, _v))

f_score_from_ratio(_ratio, _scale, _cap) =>
    f_clamp(_ratio * _scale, 0.0, _cap)

f_label_size(_s) =>
    switch _s
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge"  => size.huge
        => size.normal

f_fmt_score(_v) =>
    str.tostring(math.round(_v))

f_quality_bucket(_q) =>
    string _txt = "Early"
    if _q >= premiumThreshold
        _txt := "Prime"
    else if _q >= qualityThreshold
        _txt := "High"
    else if _q >= 45
        _txt := "Building"
    _txt

f_panel_pos(_p) =>
    switch _p
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

f_bias_text(_fast, _slow) =>
    _fast > _slow ? "Bullish" : _fast < _slow ? "Bearish" : "Neutral"

f_pressure_text(_obvFast, _obvSlow) =>
    _obvFast > _obvSlow ? "Rising" : _obvFast < _obvSlow ? "Falling" : "Mixed"

f_event_text(_isBull, _q) =>
    string _txt = _isBull ? "Bull OBV" : "Bear OBV"
    if _q >= premiumThreshold
        _txt := _isBull ? "Prime Bull OBV" : "Prime Bear OBV"
    else if _q >= qualityThreshold
        _txt := _isBull ? "Bull OBV +" : "Bear OBV +"
    _txt

f_last_event_text(_event) =>
    switch _event
        "Bull OBV" => "Bullish OBV"
        "Bear OBV" => "Bearish OBV"
        => "None"

f_state_text(_state) =>
    _state

f_next_action(_bullPend, _bearPend, _state, _fresh) =>
    string _txt = "Wait - No Active Divergence"
    if _bullPend and _bearPend
        _txt := "Watch Both Trigger Levels"
    else if _bullPend
        _txt := "Watch Bull Trigger Level"
    else if _bearPend
        _txt := "Watch Bear Trigger Level"
    else if _state == "Confirmed" and not na(_fresh) and _fresh <= 30
        _txt := "Track Reaction Zone"
    else if _state == "Invalidated" and not na(_fresh) and _fresh <= 10
        _txt := "Stand Aside - Setup Failed"
    else if _state == "Expired" and not na(_fresh) and _fresh <= 10
        _txt := "Wait - Setup Expired"
    _txt

f_confirm_text(_conf, _inv, _exp) =>
    _n = _conf + _inv + _exp
    string _txt = "Collecting Data"
    if _n >= 5
        _txt := str.tostring(math.round(100.0 * _conf / _n)) + "% of " + str.tostring(_n) + " setups"
    else if _n > 0
        _txt := "Collecting (" + str.tostring(_n) + " setups)"
    _txt

f_line_width(_q, _strong) =>
    int _w = _strong ? 2 : 1
    if _q >= premiumThreshold
        _w := _strong ? 4 : 3
    else if _q >= qualityThreshold
        _w := _strong ? 3 : 2
    _w

f_event_bg_alpha(_q) =>
    int _a = 18
    if _q >= premiumThreshold
        _a := 0
    else if _q >= qualityThreshold
        _a := 4
    _a

f_zone_bg_alpha(_strong) =>
    _strong ? 90 : 93

f_zone_border_alpha(_strong) =>
    _strong ? 70 : 82

f_state_color(_state, _panelText, _neutralColor, _grayColor, _accentColor) =>
    color _c = _panelText
    if _state == "Confirmed"
        _c := _accentColor
    else if _state == "Watch"
        _c := _neutralColor
    else if _state == "Invalidated" or _state == "Expired"
        _c := _grayColor
    _c

f_trim_labels(array<label> _arr, int _maxItems) =>
    while array.size(_arr) > _maxItems
        _old = array.shift(_arr)
        if not na(_old)
            label.delete(_old)

f_trim_lines(array<line> _arr, int _maxItems) =>
    while array.size(_arr) > _maxItems
        _old = array.shift(_arr)
        if not na(_old)
            line.delete(_old)

//------------------------------------------------------------------------------
// AGPRO COLOR PALETTE
//------------------------------------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)

panelBgDarkA  = color.rgb(15, 23, 42)
panelBgDarkB  = color.rgb(20, 30, 52)
panelBgLightA = color.rgb(248, 250, 252)
panelBgLightB = color.rgb(241, 245, 249)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)

bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)
grayColor     = color.rgb(148, 163, 184)

panelBgA      = themeInput == "Dark" ? color.new(panelBgDarkA, 0) : color.new(panelBgLightA, 0)
panelBgB      = themeInput == "Dark" ? color.new(panelBgDarkB, 0) : color.new(panelBgLightB, 0)
panelText     = themeInput == "Dark" ? panelValueCol : color.rgb(30, 41, 59)
subText       = themeInput == "Dark" ? panelLabelCol : color.rgb(100, 116, 139)

mainLabelSize  = f_label_size(labelSizeInput)
panelTextSize  = f_label_size(panelTextSizeInput)
panelPos       = f_panel_pos(panelPositionInput)
strongDrawings = drawingEmphasisInput == "Strong"

//------------------------------------------------------------------------------
// CORE SERIES
//------------------------------------------------------------------------------
atr14 = ta.atr(14)

obvRaw       = ta.cum(close > close[1] ? volume : close < close[1] ? -volume : 0.0)
obv          = ta.ema(obvRaw, obvSmoothLen)
obvFast      = ta.ema(obv, 5)
obvSlow      = ta.ema(obv, 13)
obvDelta     = obv - obv[1]
obvImpulse   = ta.ema(obvDelta, 5)
obvNorm      = nz(ta.stdev(obv, 50), 1.0)
obvNormSafe  = obvNorm == 0.0 ? 1.0 : obvNorm

emaFast = ta.ema(close, trendFastLen)
emaSlow = ta.ema(close, trendSlowLen)
trendUp = emaFast > emaSlow
trendDn = emaFast < emaSlow

rangeLow  = ta.lowest(low, contextLen)
rangeHigh = ta.highest(high, contextLen)
rangeSpan = math.max(rangeHigh - rangeLow, syminfo.mintick)
rangePos  = (close - rangeLow) / rangeSpan

pivotWindow       = pivotLen * 2 + 1
localPivotLow     = ta.lowest(low, pivotWindow)
localPivotHigh    = ta.highest(high, pivotWindow)
pricePivotLow     = ta.pivotlow(low, pivotLen, pivotLen)
pricePivotHigh    = ta.pivothigh(high, pivotLen, pivotLen)

bullNewEvent     = false
bearNewEvent     = false
bullPremiumEvent = false
bearPremiumEvent = false
bullConfirmedNow = false
bearConfirmedNow = false
bullInvalidNow   = false
bearInvalidNow   = false

//------------------------------------------------------------------------------
// PERSISTENT STORAGE
//------------------------------------------------------------------------------
var float prevLowPrice = na
var float prevLowObv   = na
var int   prevLowIndex = na

var float prevHighPrice = na
var float prevHighObv   = na
var int   prevHighIndex = na

var bool  bullPending       = false
var float bullPendingLow    = na
var float bullPendingLevel  = na
var int   bullPendingIndex  = na
var float bullPendingScore  = na
var float bullPendingAtr    = na

var bool  bearPending       = false
var float bearPendingHigh   = na
var float bearPendingLevel  = na
var int   bearPendingIndex  = na
var float bearPendingScore  = na
var float bearPendingAtr    = na

var int   lastBullSignalBar = na
var int   lastBearSignalBar = na

var string lastEvent    = "None"
var string lastState    = "Idle"
var float  lastScore    = na
var int    lastEventBar = na

// Proof layer counters (historical, resolution-anchored)
var int confirmCount = 0
var int invalidCount = 0
var int expireCount  = 0

// Label anti-stack memory (shared by event, confirm, and invalidation labels)
var int   lastTopLblX = -1000
var int   lastBotLblX = -1000
var float lastTopLblY = 0.0
var float lastBotLblY = 0.0

var box  activeBullBox        = na
var box  activeBearBox        = na
var line bullTriggerLine      = na
var line bearTriggerLine      = na
var box  lastBullReactionBox  = na
var box  lastBearReactionBox  = na
var line lastBullReactionLine = na
var line lastBearReactionLine = na
var int  lastBullConfirmBar   = na
var int  lastBearConfirmBar   = na

var array<label> bullEventLabels   = array.new<label>()
var array<label> bearEventLabels   = array.new<label>()
var array<line>  bullEventLines    = array.new<line>()
var array<line>  bearEventLines    = array.new<line>()
var array<label> bullConfirmLabels = array.new<label>()
var array<label> bearConfirmLabels = array.new<label>()
var array<line>  bullConfirmLines  = array.new<line>()
var array<line>  bearConfirmLines  = array.new<line>()

//------------------------------------------------------------------------------
// BULLISH DIVERGENCE ENGINE
//------------------------------------------------------------------------------
if not na(pricePivotLow)
    currLowIndex = bar_index - pivotLen
    currLowPrice = pricePivotLow
    currLowObv   = obv[pivotLen]
    currAtr      = atr14[pivotLen]

    if not na(prevLowPrice) and not na(prevLowObv) and not na(prevLowIndex)
        gapOk      = currLowIndex - prevLowIndex >= minPivotGap
        priceSwing = prevLowPrice - currLowPrice
        priceOk    = currLowPrice < prevLowPrice and priceSwing >= currAtr * minPriceAtr
        obvOk      = currLowObv > prevLowObv
        bullDivRaw = gapOk and priceOk and obvOk

        if bullDivRaw
            nearRangeLow = currLowPrice <= rangeLow[pivotLen] + currAtr * 0.25

            priceComp    = f_score_from_ratio(priceSwing / math.max(currAtr, syminfo.mintick), 12.0, 25.0)
            obvComp      = f_score_from_ratio((currLowObv - prevLowObv) / obvNormSafe[pivotLen], 14.0, 25.0)
            gapComp      = f_score_from_ratio((currLowIndex - prevLowIndex) / minPivotGap, 8.0, 10.0)
            pressureComp = (obvFast[pivotLen] > obvSlow[pivotLen] ? 12.0 : 4.0) + (obvImpulse[pivotLen] > 0 ? 10.0 : 2.0)
            contextComp  = nearRangeLow ? 15.0 : 8.0
            trendComp    = trendDn[pivotLen] ? 12.0 : trendUp[pivotLen] ? 7.0 : 9.0

            bullScore  = f_clamp(priceComp + obvComp + gapComp + pressureComp + contextComp + trendComp, 0.0, 100.0)
            cooldownOk = na(lastBullSignalBar) or currLowIndex - lastBullSignalBar >= signalCooldownBars or bullScore >= premiumThreshold
            bullPass   = (bullScore >= qualityThreshold or showWeakSignals) and cooldownOk

            if bullPass
                bullNewEvent      := true
                bullPremiumEvent  := bullScore >= premiumThreshold
                lastBullSignalBar := currLowIndex

                labelBg = bullScore >= premiumThreshold ? accentColor : bullColor
                line bullLinkLine = na
                line bullStemLine = na

                if showLinkLines
                    bullLinkLine := line.new(prevLowIndex, prevLowPrice, currLowIndex, currLowPrice, xloc = xloc.bar_index, extend = extend.none, color = color.new(labelBg, 0), width = f_line_width(bullScore, strongDrawings), style = bullScore >= premiumThreshold ? line.style_dotted : line.style_dashed)
                    array.push(bullEventLines, bullLinkLine)

                bullStack = not na(prevLowIndex) and currLowIndex - prevLowIndex <= 14 ? 0.24 : 0.0
                bullLabelY = math.min(currLowPrice, localPivotLow) - currAtr * (eventLabelAtrOffset + bullStack)
                if math.abs(currLowIndex + eventLabelRightBars - lastBotLblX) <= 14
                    bullLabelY := math.min(bullLabelY, lastBotLblY - currAtr * 2.00)
                lastBotLblX := currLowIndex + eventLabelRightBars
                lastBotLblY := bullLabelY

                if showLabelStems
                    bullStemLine := line.new(currLowIndex, currLowPrice, currLowIndex + eventLabelRightBars, bullLabelY, xloc = xloc.bar_index, extend = extend.none, color = color.new(labelBg, 10), width = strongDrawings ? 2 : 1, style = line.style_solid)
                    array.push(bullEventLines, bullStemLine)

                labelText = f_event_text(true, bullScore) + "\n" + f_fmt_score(bullScore) + " | " + f_quality_bucket(bullScore)
                bullEventLabel = label.new(currLowIndex + eventLabelRightBars, bullLabelY, labelText, xloc = xloc.bar_index, style = label.style_label_up, textcolor = color.white, color = color.new(labelBg, f_event_bg_alpha(bullScore)), size = mainLabelSize)
                array.push(bullEventLabels, bullEventLabel)
                f_trim_labels(bullEventLabels, maxVisibleEventLabels)
                f_trim_lines(bullEventLines, maxVisibleEventLabels * 2)

                bullPending      := true
                bullPendingLow   := currLowPrice
                bullPendingLevel := high[pivotLen]
                bullPendingIndex := currLowIndex
                bullPendingScore := bullScore
                bullPendingAtr   := currAtr

                if showActiveZone
                    if not na(activeBullBox)
                        box.delete(activeBullBox)
                    bullBoxTop    = setupZoneMode == "Range Box" ? math.max(currLowPrice, bullPendingLevel) + currAtr * setupZonePadAtr : currLowPrice + currAtr * activeZoneAtr
                    bullBoxBottom = setupZoneMode == "Range Box" ? math.min(currLowPrice, bullPendingLevel) - currAtr * setupZonePadAtr : currLowPrice - currAtr * activeZoneAtr
                    activeBullBox := box.new(left = currLowIndex - 1, top = bullBoxTop, right = currLowIndex + confirmBars, bottom = bullBoxBottom, xloc = xloc.bar_index, bgcolor = color.new(labelBg, f_zone_bg_alpha(strongDrawings)), border_color = color.new(labelBg, f_zone_border_alpha(strongDrawings)), border_width = strongDrawings ? 2 : 1)

                if showTriggerLevel
                    if not na(bullTriggerLine)
                        line.delete(bullTriggerLine)
                    bullTriggerLine := line.new(currLowIndex, bullPendingLevel, currLowIndex + confirmBars, bullPendingLevel, xloc = xloc.bar_index, extend = extend.none, color = color.new(labelBg, 0), width = strongDrawings ? 2 : 1, style = line.style_solid)

                lastEvent    := "Bull OBV"
                lastState    := "Watch"
                lastScore    := bullScore
                lastEventBar := bar_index

    prevLowPrice := currLowPrice
    prevLowObv   := currLowObv
    prevLowIndex := currLowIndex

//------------------------------------------------------------------------------
// BEARISH DIVERGENCE ENGINE
//------------------------------------------------------------------------------
if not na(pricePivotHigh)
    currHighIndex = bar_index - pivotLen
    currHighPrice = pricePivotHigh
    currHighObv   = obv[pivotLen]
    currAtr       = atr14[pivotLen]

    if not na(prevHighPrice) and not na(prevHighObv) and not na(prevHighIndex)
        gapOk      = currHighIndex - prevHighIndex >= minPivotGap
        priceSwing = currHighPrice - prevHighPrice
        priceOk    = currHighPrice > prevHighPrice and priceSwing >= currAtr * minPriceAtr
        obvOk      = currHighObv < prevHighObv
        bearDivRaw = gapOk and priceOk and obvOk

        if bearDivRaw
            nearRangeHigh = currHighPrice >= rangeHigh[pivotLen] - currAtr * 0.25

            priceComp    = f_score_from_ratio(priceSwing / math.max(currAtr, syminfo.mintick), 12.0, 25.0)
            obvComp      = f_score_from_ratio((prevHighObv - currHighObv) / obvNormSafe[pivotLen], 14.0, 25.0)
            gapComp      = f_score_from_ratio((currHighIndex - prevHighIndex) / minPivotGap, 8.0, 10.0)
            pressureComp = (obvFast[pivotLen] < obvSlow[pivotLen] ? 12.0 : 4.0) + (obvImpulse[pivotLen] < 0 ? 10.0 : 2.0)
            contextComp  = nearRangeHigh ? 15.0 : 8.0
            trendComp    = trendUp[pivotLen] ? 12.0 : trendDn[pivotLen] ? 7.0 : 9.0

            bearScore  = f_clamp(priceComp + obvComp + gapComp + pressureComp + contextComp + trendComp, 0.0, 100.0)
            cooldownOk = na(lastBearSignalBar) or currHighIndex - lastBearSignalBar >= signalCooldownBars or bearScore >= premiumThreshold
            bearPass   = (bearScore >= qualityThreshold or showWeakSignals) and cooldownOk

            if bearPass
                bearNewEvent      := true
                bearPremiumEvent  := bearScore >= premiumThreshold
                lastBearSignalBar := currHighIndex

                labelBg = bearScore >= premiumThreshold ? accentColor : bearColor
                line bearLinkLine = na
                line bearStemLine = na

                if showLinkLines
                    bearLinkLine := line.new(prevHighIndex, prevHighPrice, currHighIndex, currHighPrice, xloc = xloc.bar_index, extend = extend.none, color = color.new(labelBg, 0), width = f_line_width(bearScore, strongDrawings), style = bearScore >= premiumThreshold ? line.style_dotted : line.style_dashed)
                    array.push(bearEventLines, bearLinkLine)

                bearStack = not na(prevHighIndex) and currHighIndex - prevHighIndex <= 14 ? 0.24 : 0.0
                bearLabelY = math.max(currHighPrice, localPivotHigh) + currAtr * (eventLabelAtrOffset + bearStack)
                if math.abs(currHighIndex + eventLabelRightBars - lastTopLblX) <= 14
                    bearLabelY := math.max(bearLabelY, lastTopLblY + currAtr * 2.00)
                lastTopLblX := currHighIndex + eventLabelRightBars
                lastTopLblY := bearLabelY

                if showLabelStems
                    bearStemLine := line.new(currHighIndex, currHighPrice, currHighIndex + eventLabelRightBars, bearLabelY, xloc = xloc.bar_index, extend = extend.none, color = color.new(labelBg, 10), width = strongDrawings ? 2 : 1, style = line.style_solid)
                    array.push(bearEventLines, bearStemLine)

                labelText = f_event_text(false, bearScore) + "\n" + f_fmt_score(bearScore) + " | " + f_quality_bucket(bearScore)
                bearEventLabel = label.new(currHighIndex + eventLabelRightBars, bearLabelY, labelText, xloc = xloc.bar_index, style = label.style_label_down, textcolor = color.white, color = color.new(labelBg, f_event_bg_alpha(bearScore)), size = mainLabelSize)
                array.push(bearEventLabels, bearEventLabel)
                f_trim_labels(bearEventLabels, maxVisibleEventLabels)
                f_trim_lines(bearEventLines, maxVisibleEventLabels * 2)

                bearPending      := true
                bearPendingHigh  := currHighPrice
                bearPendingLevel := low[pivotLen]
                bearPendingIndex := currHighIndex
                bearPendingScore := bearScore
                bearPendingAtr   := currAtr

                if showActiveZone
                    if not na(activeBearBox)
                        box.delete(activeBearBox)
                    bearBoxTop    = setupZoneMode == "Range Box" ? math.max(currHighPrice, bearPendingLevel) + currAtr * setupZonePadAtr : currHighPrice + currAtr * activeZoneAtr
                    bearBoxBottom = setupZoneMode == "Range Box" ? math.min(currHighPrice, bearPendingLevel) - currAtr * setupZonePadAtr : currHighPrice - currAtr * activeZoneAtr
                    activeBearBox := box.new(left = currHighIndex - 1, top = bearBoxTop, right = currHighIndex + confirmBars, bottom = bearBoxBottom, xloc = xloc.bar_index, bgcolor = color.new(labelBg, f_zone_bg_alpha(strongDrawings)), border_color = color.new(labelBg, f_zone_border_alpha(strongDrawings)), border_width = strongDrawings ? 2 : 1)

                if showTriggerLevel
                    if not na(bearTriggerLine)
                        line.delete(bearTriggerLine)
                    bearTriggerLine := line.new(currHighIndex, bearPendingLevel, currHighIndex + confirmBars, bearPendingLevel, xloc = xloc.bar_index, extend = extend.none, color = color.new(labelBg, 0), width = strongDrawings ? 2 : 1, style = line.style_solid)

                lastEvent    := "Bear OBV"
                lastState    := "Watch"
                lastScore    := bearScore
                lastEventBar := bar_index

    prevHighPrice := currHighPrice
    prevHighObv   := currHighObv
    prevHighIndex := currHighIndex

//------------------------------------------------------------------------------
// CONFIRMATION / INVALIDATION
//------------------------------------------------------------------------------
if bullPending
    if showActiveZone and not na(activeBullBox)
        box.set_right(activeBullBox, bar_index + 1)
    if showTriggerLevel and not na(bullTriggerLine)
        line.set_x2(bullTriggerLine, bar_index + 1)

    expired = bar_index - bullPendingIndex > confirmBars
    invalid = low < bullPendingLow
    confirm = (confirmUseClose ? close > bullPendingLevel : high > bullPendingLevel) and obvFast > obvSlow

    if confirm
        bullConfirmedNow := true
        bullPending      := false
        confirmCount     += 1
        bullConfirmStack = not na(lastBullConfirmBar) and bar_index - lastBullConfirmBar <= 12 ? 0.30 : 0.0
        bullConfirmY     = high + atr14 * (confirmLabelAtrOffset + bullConfirmStack)
        if math.abs(bar_index + confirmLabelRightBars - lastTopLblX) <= 14
            bullConfirmY := math.max(bullConfirmY, lastTopLblY + atr14 * 2.00)
        lastTopLblX := bar_index + confirmLabelRightBars
        lastTopLblY := bullConfirmY
        line bullConfirmStem = na

        if showLabelStems
            bullConfirmStem := line.new(bar_index, high, bar_index + confirmLabelRightBars, bullConfirmY, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 5), width = strongDrawings ? 2 : 1, style = line.style_solid)
            array.push(bullConfirmLines, bullConfirmStem)

        bullConfirmLabel = label.new(bar_index + confirmLabelRightBars, bullConfirmY, "Bull Confirmed", xloc = xloc.bar_index, style = label.style_label_down, textcolor = color.white, color = color.new(accentColor, 0), size = mainLabelSize)
        array.push(bullConfirmLabels, bullConfirmLabel)
        f_trim_labels(bullConfirmLabels, maxVisibleConfirmTags)
        f_trim_lines(bullConfirmLines, maxVisibleConfirmTags)
        lastBullConfirmBar := bar_index

        if removeResolvedSetups
            if not na(activeBullBox)
                box.delete(activeBullBox)
                activeBullBox := na
            if not na(bullTriggerLine)
                line.delete(bullTriggerLine)
                bullTriggerLine := na
        else
            if showActiveZone and not na(activeBullBox)
                box.set_right(activeBullBox, bar_index + 2)
                box.set_bgcolor(activeBullBox, color.new(accentColor, 92))
                box.set_border_color(activeBullBox, color.new(accentColor, 72))
            if showTriggerLevel and not na(bullTriggerLine)
                line.set_x2(bullTriggerLine, bar_index + 2)
                line.set_color(bullTriggerLine, color.new(accentColor, 0))

        if showReactionZone
            if not na(lastBullReactionBox)
                box.delete(lastBullReactionBox)
            bullReactTop    = setupZoneMode == "Range Box" ? math.max(bullPendingLow, bullPendingLevel) + bullPendingAtr * setupZonePadAtr : bullPendingLow + bullPendingAtr * activeZoneAtr
            bullReactBottom = setupZoneMode == "Range Box" ? math.min(bullPendingLow, bullPendingLevel) - bullPendingAtr * setupZonePadAtr : bullPendingLow - bullPendingAtr * activeZoneAtr
            lastBullReactionBox := box.new(left = bullPendingIndex - 1, top = bullReactTop, right = bar_index + reactionExtendBars, bottom = bullReactBottom, xloc = xloc.bar_index, bgcolor = color.new(bullColor, 90), border_color = color.new(accentColor, 64), border_width = strongDrawings ? 2 : 1)

        if showReactionMidline
            if not na(lastBullReactionLine)
                line.delete(lastBullReactionLine)
            lastBullReactionLine := line.new(bullPendingIndex, bullPendingLevel, bar_index + reactionExtendBars, bullPendingLevel, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 0), width = strongDrawings ? 2 : 1, style = line.style_solid)

        lastEvent    := "Bull OBV"
        lastState    := "Confirmed"
        lastScore    := bullPendingScore
        lastEventBar := bar_index

    else if invalid
        bullInvalidNow := true
        bullPending    := false
        invalidCount   += 1

        if showInvalidation
            bullInvalidY = low - atr14 * (confirmLabelAtrOffset * 0.70)
            if math.abs(bar_index + confirmLabelRightBars - lastBotLblX) <= 14
                bullInvalidY := math.min(bullInvalidY, lastBotLblY - atr14 * 2.00)
            lastBotLblX := bar_index + confirmLabelRightBars
            lastBotLblY := bullInvalidY
            line bullInvalidStem = na
            if showLabelStems
                bullInvalidStem := line.new(bar_index, low, bar_index + confirmLabelRightBars, bullInvalidY, xloc = xloc.bar_index, extend = extend.none, color = color.new(grayColor, 5), width = 1, style = line.style_solid)
                array.push(bullConfirmLines, bullInvalidStem)
            bullInvalidLabel = label.new(bar_index + confirmLabelRightBars, bullInvalidY, "Bull Invalidated", xloc = xloc.bar_index, style = label.style_label_up, textcolor = color.white, color = color.new(grayColor, 0), size = mainLabelSize)
            array.push(bullConfirmLabels, bullInvalidLabel)
            f_trim_labels(bullConfirmLabels, maxVisibleConfirmTags)
            f_trim_lines(bullConfirmLines, maxVisibleConfirmTags)

        if removeResolvedSetups
            if not na(activeBullBox)
                box.delete(activeBullBox)
                activeBullBox := na
            if not na(bullTriggerLine)
                line.delete(bullTriggerLine)
                bullTriggerLine := na
        else
            if showActiveZone and not na(activeBullBox)
                box.set_right(activeBullBox, bar_index + 1)
                box.set_bgcolor(activeBullBox, color.new(grayColor, 95))
                box.set_border_color(activeBullBox, color.new(grayColor, 86))
            if showTriggerLevel and not na(bullTriggerLine)
                line.set_x2(bullTriggerLine, bar_index + 1)
                line.set_color(bullTriggerLine, color.new(grayColor, 12))

        lastState    := "Invalidated"
        lastEventBar := bar_index

    else if expired
        bullPending := false
        expireCount += 1

        if removeResolvedSetups
            if not na(activeBullBox)
                box.delete(activeBullBox)
                activeBullBox := na
            if not na(bullTriggerLine)
                line.delete(bullTriggerLine)
                bullTriggerLine := na
        else
            if showActiveZone and not na(activeBullBox)
                box.set_right(activeBullBox, bar_index + 1)
                box.set_bgcolor(activeBullBox, color.new(grayColor, 96))
                box.set_border_color(activeBullBox, color.new(grayColor, 88))
            if showTriggerLevel and not na(bullTriggerLine)
                line.set_x2(bullTriggerLine, bar_index + 1)
                line.set_color(bullTriggerLine, color.new(grayColor, 18))

        lastState    := "Expired"
        lastEventBar := bar_index

if bearPending
    if showActiveZone and not na(activeBearBox)
        box.set_right(activeBearBox, bar_index + 1)
    if showTriggerLevel and not na(bearTriggerLine)
        line.set_x2(bearTriggerLine, bar_index + 1)

    expired = bar_index - bearPendingIndex > confirmBars
    invalid = high > bearPendingHigh
    confirm = (confirmUseClose ? close < bearPendingLevel : low < bearPendingLevel) and obvFast < obvSlow

    if confirm
        bearConfirmedNow := true
        bearPending      := false
        confirmCount     += 1
        bearConfirmStack = not na(lastBearConfirmBar) and bar_index - lastBearConfirmBar <= 12 ? 0.30 : 0.0
        bearConfirmY     = low - atr14 * (confirmLabelAtrOffset + bearConfirmStack)
        if math.abs(bar_index + confirmLabelRightBars - lastBotLblX) <= 14
            bearConfirmY := math.min(bearConfirmY, lastBotLblY - atr14 * 2.00)
        lastBotLblX := bar_index + confirmLabelRightBars
        lastBotLblY := bearConfirmY
        line bearConfirmStem = na

        if showLabelStems
            bearConfirmStem := line.new(bar_index, low, bar_index + confirmLabelRightBars, bearConfirmY, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 5), width = strongDrawings ? 2 : 1, style = line.style_solid)
            array.push(bearConfirmLines, bearConfirmStem)

        bearConfirmLabel = label.new(bar_index + confirmLabelRightBars, bearConfirmY, "Bear Confirmed", xloc = xloc.bar_index, style = label.style_label_up, textcolor = color.white, color = color.new(accentColor, 0), size = mainLabelSize)
        array.push(bearConfirmLabels, bearConfirmLabel)
        f_trim_labels(bearConfirmLabels, maxVisibleConfirmTags)
        f_trim_lines(bearConfirmLines, maxVisibleConfirmTags)
        lastBearConfirmBar := bar_index

        if removeResolvedSetups
            if not na(activeBearBox)
                box.delete(activeBearBox)
                activeBearBox := na
            if not na(bearTriggerLine)
                line.delete(bearTriggerLine)
                bearTriggerLine := na
        else
            if showActiveZone and not na(activeBearBox)
                box.set_right(activeBearBox, bar_index + 2)
                box.set_bgcolor(activeBearBox, color.new(accentColor, 92))
                box.set_border_color(activeBearBox, color.new(accentColor, 72))
            if showTriggerLevel and not na(bearTriggerLine)
                line.set_x2(bearTriggerLine, bar_index + 2)
                line.set_color(bearTriggerLine, color.new(accentColor, 0))

        if showReactionZone
            if not na(lastBearReactionBox)
                box.delete(lastBearReactionBox)
            bearReactTop    = setupZoneMode == "Range Box" ? math.max(bearPendingHigh, bearPendingLevel) + bearPendingAtr * setupZonePadAtr : bearPendingHigh + bearPendingAtr * activeZoneAtr
            bearReactBottom = setupZoneMode == "Range Box" ? math.min(bearPendingHigh, bearPendingLevel) - bearPendingAtr * setupZonePadAtr : bearPendingHigh - bearPendingAtr * activeZoneAtr
            lastBearReactionBox := box.new(left = bearPendingIndex - 1, top = bearReactTop, right = bar_index + reactionExtendBars, bottom = bearReactBottom, xloc = xloc.bar_index, bgcolor = color.new(bearColor, 90), border_color = color.new(accentColor, 64), border_width = strongDrawings ? 2 : 1)

        if showReactionMidline
            if not na(lastBearReactionLine)
                line.delete(lastBearReactionLine)
            lastBearReactionLine := line.new(bearPendingIndex, bearPendingLevel, bar_index + reactionExtendBars, bearPendingLevel, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 0), width = strongDrawings ? 2 : 1, style = line.style_solid)

        lastEvent    := "Bear OBV"
        lastState    := "Confirmed"
        lastScore    := bearPendingScore
        lastEventBar := bar_index

    else if invalid
        bearInvalidNow := true
        bearPending    := false
        invalidCount   += 1

        if showInvalidation
            bearInvalidY = high + atr14 * (confirmLabelAtrOffset * 0.70)
            if math.abs(bar_index + confirmLabelRightBars - lastTopLblX) <= 14
                bearInvalidY := math.max(bearInvalidY, lastTopLblY + atr14 * 2.00)
            lastTopLblX := bar_index + confirmLabelRightBars
            lastTopLblY := bearInvalidY
            line bearInvalidStem = na
            if showLabelStems
                bearInvalidStem := line.new(bar_index, high, bar_index + confirmLabelRightBars, bearInvalidY, xloc = xloc.bar_index, extend = extend.none, color = color.new(grayColor, 5), width = 1, style = line.style_solid)
                array.push(bearConfirmLines, bearInvalidStem)
            bearInvalidLabel = label.new(bar_index + confirmLabelRightBars, bearInvalidY, "Bear Invalidated", xloc = xloc.bar_index, style = label.style_label_down, textcolor = color.white, color = color.new(grayColor, 0), size = mainLabelSize)
            array.push(bearConfirmLabels, bearInvalidLabel)
            f_trim_labels(bearConfirmLabels, maxVisibleConfirmTags)
            f_trim_lines(bearConfirmLines, maxVisibleConfirmTags)

        if removeResolvedSetups
            if not na(activeBearBox)
                box.delete(activeBearBox)
                activeBearBox := na
            if not na(bearTriggerLine)
                line.delete(bearTriggerLine)
                bearTriggerLine := na
        else
            if showActiveZone and not na(activeBearBox)
                box.set_right(activeBearBox, bar_index + 1)
                box.set_bgcolor(activeBearBox, color.new(grayColor, 95))
                box.set_border_color(activeBearBox, color.new(grayColor, 86))
            if showTriggerLevel and not na(bearTriggerLine)
                line.set_x2(bearTriggerLine, bar_index + 1)
                line.set_color(bearTriggerLine, color.new(grayColor, 12))

        lastState    := "Invalidated"
        lastEventBar := bar_index

    else if expired
        bearPending := false
        expireCount += 1

        if removeResolvedSetups
            if not na(activeBearBox)
                box.delete(activeBearBox)
                activeBearBox := na
            if not na(bearTriggerLine)
                line.delete(bearTriggerLine)
                bearTriggerLine := na
        else
            if showActiveZone and not na(activeBearBox)
                box.set_right(activeBearBox, bar_index + 1)
                box.set_bgcolor(activeBearBox, color.new(grayColor, 96))
                box.set_border_color(activeBearBox, color.new(grayColor, 88))
            if showTriggerLevel and not na(bearTriggerLine)
                line.set_x2(bearTriggerLine, bar_index + 1)
                line.set_color(bearTriggerLine, color.new(grayColor, 18))

        lastState    := "Expired"
        lastEventBar := bar_index

plotshape(showConfirmMarkers and bullConfirmedNow, title = "Bull Confirmation Marker", style = shape.diamond, location = location.abovebar, color = accentColor, size = size.tiny)
plotshape(showConfirmMarkers and bearConfirmedNow, title = "Bear Confirmation Marker", style = shape.diamond, location = location.belowbar, color = accentColor, size = size.tiny)

//------------------------------------------------------------------------------
// VISUAL CONTEXT
//------------------------------------------------------------------------------
biasText      = f_bias_text(emaFast, emaSlow)
pressureText  = f_pressure_text(obvFast, obvSlow)

string contextText = "Mid-Range"
if rangePos >= 0.75
    contextText := "Upper-Range"
else if rangePos <= 0.25
    contextText := "Lower-Range"
else if trendUp
    contextText := "Trend-Up"
else if trendDn
    contextText := "Trend-Down"

freshBars     = not na(lastEventBar) ? bar_index - lastEventBar : na
lastEventText = f_last_event_text(lastEvent)
nextActionTxt = f_next_action(bullPending, bearPending, lastState, freshBars)
confirmTxt    = f_confirm_text(confirmCount, invalidCount, expireCount)

bgcolor(showBgPulse and bullPremiumEvent ? color.new(accentColor, 91) : showBgPulse and bullNewEvent ? color.new(bullColor, 94) : na)
bgcolor(showBgPulse and bearPremiumEvent ? color.new(accentColor, 91) : showBgPulse and bearNewEvent ? color.new(bearColor, 94) : na)

plot(showContextEMAs ? emaFast : na, "Fast EMA", color = color.new(accentColor, strongDrawings ? 22 : 38), linewidth = strongDrawings ? 2 : 1)
plot(showContextEMAs ? emaSlow : na, "Slow EMA", color = color.new(neutralColor, strongDrawings ? 18 : 34), linewidth = strongDrawings ? 2 : 1)

//------------------------------------------------------------------------------
// PANEL
//------------------------------------------------------------------------------
var table panel = table.new(panelPos, 2, 10, frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)

if barstate.isfirst
    table.merge_cells(panel, 0, 0, 1, 0)

if barstate.islast
    if showPanel
        table.cell(panel, 0, 0, "AG Pro OBV Pressure Divergence", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize)

        table.cell(panel, 0, 1, "Bias", text_color = subText, bgcolor = panelBgA, text_size = panelTextSize)
        table.cell(panel, 1, 1, biasText, text_color = trendUp ? bullColor : trendDn ? bearColor : panelText, bgcolor = panelBgA, text_size = panelTextSize)

        table.cell(panel, 0, 2, "Next Action", text_color = subText, bgcolor = panelBgB, text_size = panelTextSize)
        table.cell(panel, 1, 2, nextActionTxt, text_color = headerText, bgcolor = color.new(accentColor, 55), text_size = panelTextSize)

        table.cell(panel, 0, 3, "OBV Pressure", text_color = subText, bgcolor = panelBgA, text_size = panelTextSize)
        table.cell(panel, 1, 3, pressureText, text_color = pressureText == "Rising" ? bullColor : pressureText == "Falling" ? bearColor : panelText, bgcolor = panelBgA, text_size = panelTextSize)

        table.cell(panel, 0, 4, "Last Event", text_color = subText, bgcolor = panelBgB, text_size = panelTextSize)
        table.cell(panel, 1, 4, lastEventText, text_color = lastEvent == "Bull OBV" ? bullColor : lastEvent == "Bear OBV" ? bearColor : panelText, bgcolor = panelBgB, text_size = panelTextSize)

        qualityText = na(lastScore) ? "n/a" : f_fmt_score(lastScore) + " | " + f_quality_bucket(lastScore)
        qualityCol  = na(lastScore) ? panelText : lastScore >= premiumThreshold ? accentColor : lastEvent == "Bull OBV" ? bullColor : lastEvent == "Bear OBV" ? bearColor : panelText
        table.cell(panel, 0, 5, "Quality", text_color = subText, bgcolor = panelBgA, text_size = panelTextSize)
        table.cell(panel, 1, 5, qualityText, text_color = qualityCol, bgcolor = panelBgA, text_size = panelTextSize)

        table.cell(panel, 0, 6, "State", text_color = subText, bgcolor = panelBgB, text_size = panelTextSize)
        table.cell(panel, 1, 6, f_state_text(lastState), text_color = f_state_color(lastState, panelText, neutralColor, grayColor, accentColor), bgcolor = panelBgB, text_size = panelTextSize)

        table.cell(panel, 0, 7, "Context", text_color = subText, bgcolor = panelBgA, text_size = panelTextSize)
        table.cell(panel, 1, 7, contextText, text_color = panelText, bgcolor = panelBgA, text_size = panelTextSize)

        table.cell(panel, 0, 8, "Freshness", text_color = subText, bgcolor = panelBgB, text_size = panelTextSize)
        table.cell(panel, 1, 8, na(freshBars) ? "n/a" : str.tostring(freshBars) + " bars", text_color = panelText, bgcolor = panelBgB, text_size = panelTextSize)

        if showConfirmStat
            table.cell(panel, 0, 9, "Confirm Rate", text_color = subText, bgcolor = panelBgA, text_size = panelTextSize)
            table.cell(panel, 1, 9, confirmTxt, text_color = panelText, bgcolor = panelBgA, text_size = panelTextSize)
    else
        table.clear(panel, 0, 0, 1, 9)

//------------------------------------------------------------------------------
// ALERTS
//------------------------------------------------------------------------------
alertcondition(bullNewEvent, "New Bullish OBV Pressure Divergence", "New bullish OBV Pressure Divergence detected.")
alertcondition(bearNewEvent, "New Bearish OBV Pressure Divergence", "New bearish OBV Pressure Divergence detected.")
alertcondition(bullPremiumEvent, "Prime Bullish OBV Pressure Divergence", "Prime bullish OBV Pressure Divergence detected.")
alertcondition(bearPremiumEvent, "Prime Bearish OBV Pressure Divergence", "Prime bearish OBV Pressure Divergence detected.")
alertcondition(bullConfirmedNow, "Bullish OBV Pressure Divergence Confirmed", "Bullish OBV Pressure Divergence confirmed.")
alertcondition(bearConfirmedNow, "Bearish OBV Pressure Divergence Confirmed", "Bearish OBV Pressure Divergence confirmed.")
alertcondition(bullInvalidNow or bearInvalidNow, "OBV Pressure Divergence Invalidated", "An active OBV Pressure Divergence was invalidated.")
````
