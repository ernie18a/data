<!-- tradingview-pine-id: PUB;429ada93cf394bda90ae3c31c710ca9a -->
<!-- tradingviewscripts-format: 1 -->
# ORB Detector Dynamic

Source: https://www.tradingview.com/script/TMohG3x3-ORB-Detector-Dynamic/

## Description

ORB Detector Dynamic

OVERVIEW
ORB Detector Dynamic is an Opening Range Breakout (ORB) visualization tool for Asia, London, and New York sessions.
It builds and locks the opening-range high and low for a selected session window, keeps session labels on history, and marks breakouts only after the range is locked — not while the range is still forming.
Built by the Xcelerate Trade team.

CONCEPT
An Opening Range Breakout uses the high and low of a defined window after a session open (for example the first 5, 15, or 30 minutes).
Once that window closes, the range is treated as locked. Breaks of the locked high or low can then be used as timing context together with broader session and structure tools.

HOW IT WORKS
1) Choose one session: Asia, London, or New York
2) Set the ORB window times in Inputs (Eastern Time — America/New_York; editable)
3) During the window, the script updates ORB High and ORB Low
4) When the window closes, the range locks and the label stops showing “forming”
5) Breakout conditions are evaluated only after lock, until the next ORB window starts
6) One breakout flag per direction per session (no repeated spam)

Default ORB windows (EST / America/New_York):
• Asia — 19:00–19:15
• London — 03:00–03:15
• New York — 09:30–09:45

Change start and end times in Inputs to match your ORB length (5 / 15 / 30 minutes). If you change ORB Timeframe, also adjust the session end time.

FEATURES
• ORB High / ORB Low levels (Style colors editable; defaults blue)
• Session labels on history (example: “NY ORB 15m”, “Asia ORB 15m”)
• “forming” label text while the window is still open
• Breakout flash (background highlight on first break — on by default)
• Optional breakout arrows in Style (off by default)
• Alerts:
  – ORB Session Start
  – ORB Range Locked
  – ORB High Breakout (after range)
  – ORB Low Breakdown (after range)

HOW TO USE
1) Add the indicator and select the session you trade
2) Confirm ORB Timeframe and session start/end match your playbook
3) Wait until the label no longer says “forming” (range locked)
4) Use a clean break of ORB High as long bias context, or ORB Low as short bias context
5) Prefer confluence with session boxes and higher-timeframe structure before acting
6) Recommended chart timeframe: same as the ORB window or lower (example: 1m–15m for a 15m ORB)

Works well together with:
• Xcelerate - Best Sessions - New York, London & Asia
• Fluid Liquidity Zones - CHoCH + Mitigation + HTF | Xcelerate Trade

SKIP / AVOID
• Trading breaks while the ORB window is still forming
• Chop or news spikes that pierce both sides of the range
• Entries with no session context and no higher-timeframe bias

LIMITATIONS
• This script is a visualization and alert tool. It does not place trades and does not guarantee results.
• Session times use America/New_York so DST is handled by TradingView’s timezone engine; verify times for your market and broker.
• On very low timeframes, noise and gaps can produce false or early breaks relative to your rules.
• Always confirm with your own risk management and market context.

---

## Source Code

````pine
//@version=6
indicator("ORB Detector Dynamic", shorttitle="ORB Detector Dynamic", overlay=true, max_labels_count=500, max_bars_back=5000)

TIMEZONE = "America/New_York"

// ── Inputs ─────────────────────────────────────────────────────────
groupOrb = "ORB"
orb_tf = input.string("15", "ORB Timeframe", options=["5", "15", "30"], group=groupOrb, tooltip="Chart resolution used to detect the ORB window. Match your ORB session end time to this length.")
session_choice = input.string("Asia", "Select Session", options=["Asia", "London", "NY"], group=groupOrb)

// Editable ORB windows (same style as Best Sessions) — times in EST / America/New_York
S_ASIA = input.session("1900-1915", "Asia ORB [19:00–19:15 EST]", group=groupOrb)
S_LONDON = input.session("0300-0315", "London ORB [03:00–03:15 EST]", group=groupOrb)
S_NY = input.session("0930-0945", "New York ORB [09:30–09:45 EST]", group=groupOrb)

groupVis = "Display"
colOrbHigh = input.color(#2962FF, "ORB High color", group=groupVis)
colOrbLow = input.color(#2962FF, "ORB Low color", group=groupVis)
showOrbFill = input.bool(false, "Shade ORB range while forming", group=groupVis)

// ── Active ORB session window ──────────────────────────────────────
orb_sess = session_choice == "Asia" ? S_ASIA : session_choice == "London" ? S_LONDON : S_NY
session_spec = orb_sess + ":1234567"
t = time(orb_tf, session_spec, TIMEZONE)

in_session = not na(t)
is_first = in_session and not in_session[1]
orb_just_closed = not in_session and in_session[1]

// ── ORB high / low ─────────────────────────────────────────────────
var float orb_high = na
var float orb_low = na
var bool broke_high = false
var bool broke_low = false
var label orb_label = na
var int orb_start_bar = na

lblColor = colOrbHigh
lblText = session_choice + " ORB " + orb_tf + "m"

if is_first
    orb_high := high
    orb_low := low
    broke_high := false
    broke_low := false
    orb_start_bar := bar_index
    // Keep historical labels — do not delete previous session labels
    orb_label := label.new(
         bar_index,
         high,
         lblText,
         style=label.style_label_down,
         color=lblColor,
         textcolor=color.white,
         size=size.small)

if in_session
    orb_high := math.max(nz(orb_high, high), high)
    orb_low := math.min(nz(orb_low, low), low)
    if not na(orb_label) and not na(orb_start_bar)
        label.set_xy(orb_label, orb_start_bar, orb_high)
        label.set_text(orb_label, lblText + " (forming)")

if orb_just_closed and not na(orb_label)
    if not na(orb_start_bar)
        label.set_xy(orb_label, orb_start_bar, orb_high)
    label.set_text(orb_label, lblText)

// Valid breakout window: after ORB closes, until next ORB starts
post_orb = not in_session and not na(orb_high) and not na(orb_low)

break_high = post_orb and not broke_high and high > orb_high
break_low = post_orb and not broke_low and low < orb_low

if break_high
    broke_high := true
if break_low
    broke_low := true

// site message timing (fixed — not in Settings menu)
showSitePromo = true
promoIntervalMin = 7
promoHighlightSec = 30
// Two lines so mobile chart doesn't clip / overflow the center banner
promoMsg = "For more indicators & strategies\nvisit trading.xcelerate.trade"
promoIntervalMs = promoIntervalMin * 60 * 1000
promoVisibleMs = promoHighlightSec * 1000

// ── Colors / plots (defaults match Style: blue high/low, arrows off, flash on)
line_color_hi = colOrbHigh
line_color_lo = colOrbLow

// Same idea as original: break the plot when a new ORB starts so sessions
// are not connected. During formation, also hide the expanding segment
// (orb_high/low changing) so you get flat levels, not stairs inside the window.
hiChanged = is_first or (not na(orb_high) and not na(orb_high[1]) and orb_high != orb_high[1])
loChanged = is_first or (not na(orb_low) and not na(orb_low[1]) and orb_low != orb_low[1])
pHi = plot(orb_high, "ORB High", color=hiChanged ? na : line_color_hi, linewidth=2, style=plot.style_line)
pLo = plot(orb_low, "ORB Low", color=loChanged ? na : line_color_lo, linewidth=2, style=plot.style_line)
fill(pHi, pLo, color=showOrbFill and in_session ? color.new(line_color_hi, 88) : na, title="ORB forming fill")

// Breakout visuals: series always computed so Style checkboxes work.
// Arrows hidden by default (display.none); flash visible by default.
bgcolor(
     break_high ? color.new(color.green, 85) : break_low ? color.new(color.red, 85) : na,
     title="Breakout flash",
     display=display.all)

plotshape(
     break_high,
     title="ORB High Break",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.green,
     size=size.small,
     text="ORB↑",
     display=display.none)

plotshape(
     break_low,
     title="ORB Low Break",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small,
     text="ORB↓",
     display=display.none)

// ── Alerts (breakouts only AFTER ORB window) ───────────────────────
alertcondition(is_first, "ORB Session Start", "XCEL ORB: session started — range forming")
alertcondition(orb_just_closed, "ORB Range Locked", "XCEL ORB: opening range locked")
alertcondition(break_high, "ORB High Breakout", "XCEL ORB: high breakout (after range)")
alertcondition(break_low, "ORB Low Breakdown", "XCEL ORB: low breakdown (after range)")

// ═══════════════════════════════════════════════════════════════════
// trading.xcelerate.trade — center flash: hidden 7 min → visible 30 s → repeat
// ═══════════════════════════════════════════════════════════════════
var table sitePromoTbl = na
varip int promoHiddenAnchorMs = -1
varip int promoVisibleAnchorMs = -1

if showSitePromo and barstate.islast
    if na(sitePromoTbl)
        sitePromoTbl := table.new(position.middle_center, 1, 1, border_width=0, frame_color=color.new(color.black, 100), bgcolor=color.new(color.black, 100))
    nowMs = na(timenow) ? time_close : timenow
    if promoHiddenAnchorMs < 0 and promoVisibleAnchorMs < 0
        promoHiddenAnchorMs := nowMs
    if promoVisibleAnchorMs >= 0
        if nowMs - promoVisibleAnchorMs >= promoVisibleMs
            promoHiddenAnchorMs := nowMs
            promoVisibleAnchorMs := -1
    else if promoHiddenAnchorMs >= 0 and nowMs - promoHiddenAnchorMs >= promoIntervalMs
        promoVisibleAnchorMs := nowMs
    showPromoNow = promoVisibleAnchorMs >= 0 and nowMs - promoVisibleAnchorMs < promoVisibleMs
    if showPromoNow
        table.cell(sitePromoTbl, 0, 0, promoMsg, text_color=color.white, text_size=size.large, bgcolor=color.new(color.black, 25), text_halign=text.align_center)
    else
        table.cell(sitePromoTbl, 0, 0, "", bgcolor=color.new(color.black, 100), text_color=color.new(color.white, 100), text_size=size.large)
````
