# Rolling Midpoint Engine [AGPro Series]

- url: https://www.tradingview.com/script/HJsTL5bf-Rolling-Midpoint-Engine-AGPro-Series/
- type: indicator
- pine_id: PUB;1d5de49d4f9848efb72657f1f5d239b3
- version: 4.0

## Description

Rolling Midpoint Engine [AGPro Series]

### Overview

Rolling Midpoint Engine is an on-chart study that converts the geometric midpoint of the last N bars' high-low range into a living control line. The midline is tracked through three behavioral states — Accepted Above, Accepted Below, and Fight — and a fourth modifier (Strong) highlights high-conviction acceptance beyond an ATR threshold. The goal is to surface how price behaves around a single dominant reference level, not to predict direction or issue trade signals.

### Unique Edge

Most midpoint tools plot a static line and let the user eyeball whether price accepts or rejects it. Rolling Midpoint Engine formalises that observation into a finite state machine that requires consecutive body-closes on one side of the midline before declaring acceptance. This filters single-bar noise and distinguishes casual tags from genuine commitment. The ATR-based Strong modifier adds a second axis of information — how firmly the current side is being held — without multiplying states or cluttering the chart with additional lines.

### Methodology

The midline is computed as the average of the highest high and the lowest low over a user-defined rolling window. Optional light EMA smoothing reduces visual jitter without materially shifting the level; a Strict Reset mode disables smoothing for pure rolling output.

Acceptance is evaluated through two streak counters tracking consecutive closes (or full bars, if the user prefers a stricter rule) on each side of the midline. When a streak reaches the Acceptance Bars threshold, the state transitions to Accepted Above or Accepted Below. If the running streak is positive but below threshold, the state is Fight. A Strong flag activates whenever the current distance from the midline exceeds a configurable ATR multiple.

All logic uses confirmed bar closes. The script does not repaint historical states once a bar has closed.

### States & Alerts

States:
- Fight — price is oscillating around the midline without sustained commitment
- Accepted Above — body-closes above the midline for the required number of bars
- Accepted Below — body-closes below the midline for the required number of bars
- Strong (modifier) — current Accepted state is held beyond the ATR threshold

Alerts:
- Midline Crossed Up / Down — raw price cross of the midline
- Accepted Above / Below — state transitions into acceptance
- Midline Rejection — state flip between Accepted Above and Accepted Below, or collapse from an Accepted state back to Fight

### Key Inputs

- Rolling Length — number of bars defining the range window
- Strict Reset Mode — toggle between pure rolling midline and lightly smoothed output
- Acceptance Bars — consecutive body-closes required for acceptance
- Use Body Close vs. Full Bar — strictness of the side-determination rule
- Strong Threshold — ATR multiple that qualifies an accepted side as Strong
- Label Style / Size — Edge Only, Edge + Transitions, or Off
- Panel Location / Theme / Font Size — four corners plus Middle Right, Dark / Light / Auto themes
- Color Midline by State — toggle state-coloring on the dominant line

### How to Use

Apply the indicator to any symbol and timeframe. The midline acts as a rolling control level; the state label on the right edge summarises the current behavior. Treat Accepted Above / Below as evidence that the midline is holding as support or resistance on the corresponding side. A transition into Strong indicates the holding is well beyond routine noise. A rejection event — the state flipping or collapsing back to Fight — suggests the prior control has been compromised.

This is a contextual reading tool. It does not produce entries, exits, targets, or stops, and should not be read as a recommendation to transact.

### Limitations & Transparency

The midline reflects past price data only and will adapt as new highs or lows enter the rolling window. On illiquid or very low-timeframe charts, the streak-based acceptance logic can feel slow; increasing Acceptance Bars on noisier instruments or lowering it on cleaner ones is expected tuning. The Strong Threshold is volatility-relative via ATR but still an arbitrary cut — defaults are calibrated for typical liquid markets and may need adjustment for thinly traded symbols.

The script uses confirmed closes and does not alter historical state once a bar has closed. Intrabar, the displayed state can update in line with current price, as with any live indicator.

### Risk Disclosure

This indicator is an analytical study. It is not a strategy, not a signal service, and not financial advice. It does not forecast future prices and does not guarantee any outcome. Past behavior of price around the midline does not imply future behavior. Every trading decision is the sole responsibility of the user. Use appropriate risk management and test the tool in a non-committed environment before incorporating it into any workflow.

## Source Code

````pine
// -----------------------------------------------------
// Rolling Midpoint Engine [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// A rolling midpoint control engine that maps the midpoint of the recent
// high-low range, tracks accepted-above, accepted-below, and fight states,
// and grades how decisively one side controls equilibrium with a 0-100
// Control Score built from acceptance, ATR distance, midline slope and
// persistence. Built for midpoint analysis, equilibrium control, acceptance
// behavior, range context, and clean TradingView chart interpretation
// without predictive claims.
// Version 1.4 adds an owned midpoint-to-state connector, persistent edge-badge
// lifecycle, and a quieter configurable regime background.
// -----------------------------------------------------
//@version=6
indicator("Rolling Midpoint Engine [AGPro Series]",
     shorttitle = "AG Pro RME",
     overlay    = true,
     max_lines_count  = 50,
     max_labels_count = 120,
     max_boxes_count  = 10)

// -----------------------------------------------------
// INPUTS
// -----------------------------------------------------
grpCore   = "Core Engine"
grpBehav  = "Behavior"
grpVisual = "Visuals"
grpLabels = "Labels"
grpPanel  = "Panel"
grpAlerts = "Alerts"

rollingLen = input.int(50, "Rolling Length",
     minval = 5, maxval = 500, group = grpCore,
     tooltip = "Number of bars used to compute the rolling high-low range. The midpoint is the average of the highest high and lowest low over this window. Shorter values make the midpoint more reactive; longer values make it more structural.")

strictReset = input.bool(false, "Strict Reset Mode",
     group = grpCore,
     tooltip = "When enabled, the midpoint is recalculated from the raw rolling range on every bar. When disabled, a light EMA smoothing is applied to reduce visual jitter while keeping the control line close to the raw midpoint.")

smoothLen = input.int(3, "Smoothing Length",
     minval = 1, maxval = 20, group = grpCore,
     tooltip = "EMA length applied to the midpoint when Strict Reset Mode is disabled. Smaller values stay closer to the raw midpoint; larger values create a calmer control line.")

acceptBars = input.int(3, "Acceptance Bars",
     minval = 1, maxval = 10, group = grpBehav,
     tooltip = "Consecutive body-closes required on one side of the midpoint before the state becomes accepted. Higher values filter noise; lower values react faster.")

useBodyClose = input.bool(true, "Use Body Close",
     group = grpBehav,
     tooltip = "When enabled, acceptance is based on the close relative to the midpoint. When disabled, the full bar must sit beyond the midpoint, creating a stricter and less frequent acceptance condition.")

strongThreshold = input.float(1.5, "Strong Threshold (ATR)",
     minval = 0.3, maxval = 5.0, step = 0.1, group = grpBehav,
     tooltip = "Distance from the midpoint, measured in ATR multiples, required to mark an accepted state as strong. Strong states highlight larger commitment away from the midpoint, and define where the Control Score reaches its distance ceiling.")

atrLen = input.int(14, "ATR Length",
     minval = 1, maxval = 100, group = grpBehav,
     tooltip = "ATR period used for strong-acceptance distance, label spacing, and context measurements.")

colorByState = input.bool(true, "Color Midline by State",
     group = grpVisual,
     tooltip = "When enabled, the midpoint color follows the current state: bullish for accepted above, bearish for accepted below, and neutral during fight.")

lineWidth = input.int(3, "Midline Width",
     minval = 1, maxval = 5, group = grpVisual,
     tooltip = "Thickness of the dominant midpoint line. Width 3 is the balanced AGPro default for a main structural line.")

showShell = input.bool(true, "Show Range Shell",
     group = grpVisual,
     tooltip = "Displays a subtle high-low shell around the rolling range. The shell gives the midpoint context without turning the chart into a heavy zone tool.")

shellAlpha = input.int(93, "Range Shell Transparency",
     minval = 70, maxval = 99, group = grpVisual,
     tooltip = "Transparency of the rolling range shell. Higher values create a lighter shell.")

showStateBg = input.bool(true, "Show State Background",
     group = grpVisual,
     tooltip = "Adds a very light background pulse when price is accepted above or below the midpoint. It helps the current regime read faster without hiding candles.")

stateBgAlpha = input.int(97, "State Background Transparency",
     minval = 92, maxval = 99, group = grpVisual,
     tooltip = "Controls the accepted-state background tint. Higher values keep the midpoint, candles, and state badges visually dominant.")

labelMode = input.string("Balanced", "Label Mode",
     options = ["Balanced", "Edge Only", "Edge + Transitions", "Off"],
     group = grpLabels,
     tooltip = "Balanced shows the right-edge state tag plus controlled transition and strong-acceptance labels. Edge Only keeps a single current-state tag. Edge + Transitions marks all state changes subject to the same cleanup limits.")

labelSize = input.string("normal", "Label Font Size",
     options = ["tiny", "small", "normal", "large", "huge"],
     group = grpLabels,
     tooltip = "Font size for on-chart labels. Normal is the AGPro default for publication readability.")

maxVisibleLabels = input.int(6, "Max Visible Labels",
     minval = 1, maxval = 30, group = grpLabels,
     tooltip = "Maximum number of historical transition labels kept on the chart. This controls density while preserving a lively chart presentation.")

labelCooldown = input.int(30, "Label Cooldown Bars",
     minval = 0, maxval = 100, group = grpLabels,
     tooltip = "Minimum bars between historical labels. Higher values reduce label clustering during choppy midpoint fights.")

labelOffsetAtr = input.float(0.85, "Label Offset (ATR)",
     minval = 0.10, maxval = 3.0, step = 0.05, group = grpLabels,
     tooltip = "Vertical distance used to place labels above or below candles so they do not sit inside the candle body. Larger values push labels further from price, reducing the chance that later candles in a choppy regime reach a past label.")

rightTagOffset = input.int(8, "Right Tag Offset",
     minval = 1, maxval = 40, group = grpLabels,
     tooltip = "Number of bars used to project the right-edge state tag into the future area of the chart.")

showPanel = input.bool(true, "Show Panel",
     group = grpPanel,
     tooltip = "Shows or hides the AGPro information panel. The panel summarizes state, Control Score, midpoint slope, acceptance progress, and distance from the midpoint.")

panelLoc = input.string("Top Right", "Panel Location",
     options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"],
     group = grpPanel,
     tooltip = "Controls where the panel appears on the chart.")

panelTheme = input.string("Elite Dark", "Panel Theme",
     options = ["Elite Dark", "Slate", "Clean Light"],
     group = grpPanel,
     tooltip = "Visual theme for the panel. Elite Dark is the AGPro default, Slate is a softer dark option, and Clean Light is designed for bright chart backgrounds.")

panelFont = input.string("normal", "Panel Font Size",
     options = ["tiny", "small", "normal", "large", "huge"],
     group = grpPanel,
     tooltip = "Font size used inside the panel. Normal is the default publication size.")

alertOnCross = input.bool(true, "Alert on Midline Cross",
     group = grpAlerts,
     tooltip = "Enables alerts when price crosses the midpoint. This is a faster attention marker and may trigger more often in choppy conditions.")

alertOnAccept = input.bool(true, "Alert on Acceptance",
     group = grpAlerts,
     tooltip = "Enables alerts when the state transitions into Accepted Above or Accepted Below after the required acceptance bars.")

alertOnReject = input.bool(true, "Alert on Rejection",
     group = grpAlerts,
     tooltip = "Enables alerts when acceptance flips to the opposite side or collapses back into a fight state.")

// -----------------------------------------------------
// AGPRO COLOR PALETTE
// -----------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBg       = panelTheme == "Clean Light" ? color.rgb(248, 250, 252) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : color.rgb(15, 23, 42)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : color.rgb(148, 163, 184)
panelValueCol = panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : color.rgb(226, 232, 240)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)

// -----------------------------------------------------
// HELPERS
// -----------------------------------------------------
f_size(s) =>
    s == "tiny"  ? size.tiny  :
     s == "small" ? size.small :
     s == "large" ? size.large :
     s == "huge"  ? size.huge  : size.normal

f_panel_pos(loc) =>
    loc == "Top Left"      ? position.top_left      :
     loc == "Top Center"   ? position.top_center    :
     loc == "Middle Right" ? position.middle_right  :
     loc == "Middle Left"  ? position.middle_left   :
     loc == "Middle Center" ? position.middle_center :
     loc == "Bottom Right"  ? position.bottom_right  :
     loc == "Bottom Left"   ? position.bottom_left   :
     loc == "Bottom Center" ? position.bottom_center : position.top_right

// Luminance-aware contrast text (target luminance 145)
f_lum(c)      => 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
f_text_on(bg) => f_lum(bg) > 145 ? color.rgb(15, 23, 42) : color.rgb(245, 247, 250)

f_state_name(st, strong) =>
    st == 1 ? (strong ? "STRONG ABOVE" : "ACCEPTED ABOVE") :
     st == 2 ? (strong ? "STRONG BELOW" : "ACCEPTED BELOW") : "FIGHT"

f_state_short(st, strong) =>
    st == 1 ? (strong ? "STRONG" : "ABOVE") :
     st == 2 ? (strong ? "STRONG" : "BELOW") : "FIGHT"

f_state_color(st) =>
    st == 1 ? bullColor : st == 2 ? bearColor : neutralColor

// -----------------------------------------------------
// CORE CALCULATIONS
// -----------------------------------------------------
hiRoll  = ta.highest(high, rollingLen)
loRoll  = ta.lowest(low, rollingLen)
rawMid  = (hiRoll + loRoll) / 2.0
midline = strictReset ? rawMid : ta.ema(rawMid, smoothLen)
atrVal  = ta.atr(atrLen)
atrSafe = na(atrVal) or atrVal <= 0 ? syminfo.mintick * 10 : atrVal

aboveRaw = useBodyClose ? close > midline : low > midline
belowRaw = useBodyClose ? close < midline : high < midline

var int aboveStreak = 0
var int belowStreak = 0
aboveStreak := aboveRaw ? aboveStreak + 1 : 0
belowStreak := belowRaw ? belowStreak + 1 : 0

distFromMid = math.abs(close - midline)
isStrong    = distFromMid > atrSafe * strongThreshold

// -----------------------------------------------------
// STATE MACHINE
// 0 = Fight, 1 = Accepted Above, 2 = Accepted Below
// -----------------------------------------------------
var int state       = 0
var int prevState   = 0
var int barsInState = 0

prevState := state

int newState = state
if aboveStreak >= acceptBars and close > midline
    newState := 1
else if belowStreak >= acceptBars and close < midline
    newState := 2
else if (aboveStreak > 0 and aboveStreak < acceptBars) or (belowStreak > 0 and belowStreak < acceptBars)
    newState := 0

state       := newState
barsInState := state == prevState ? barsInState + 1 : 1

// -----------------------------------------------------
// CONTROL SCORE (0-100): how decisively one side controls the midpoint
//   Fight        → leading side's progress toward acceptance (0-35)
//   Accepted     → 40 base + ATR distance (≤30) + slope alignment (≤20) + persistence (≤10)
// -----------------------------------------------------
slope10 = bar_index > 10 ? (midline - midline[10]) / atrSafe : 0.0

f_controlScore() =>
    distA = distFromMid / atrSafe
    sc = 0.0
    if state == 0
        lead = math.max(aboveStreak, belowStreak)
        sc := math.min(35.0, lead / acceptBars * 35.0)
    else
        aligned = state == 1 ? math.max(0.0, slope10) : math.max(0.0, -slope10)
        sc += 40.0
        sc += math.min(30.0, distA / strongThreshold * 30.0)
        sc += math.min(20.0, aligned / 0.5 * 20.0)
        sc += math.min(10.0, barsInState / 10.0 * 10.0)
    math.min(100.0, math.max(0.0, sc))

controlScore = f_controlScore()

crossedUp       = ta.crossover(close, midline)
crossedDn       = ta.crossunder(close, midline)
stateChanged    = state != prevState
stateFlip       = (prevState == 1 and state == 2) or (prevState == 2 and state == 1)
collapseToFight = stateChanged and state == 0 and (prevState == 1 or prevState == 2)
rejectionEvent  = stateFlip or collapseToFight
strongTurnOn    = isStrong and not isStrong[1] and state != 0

stateColor      = f_state_color(state)
midColor        = colorByState ? stateColor : panelValueCol
stateLabel      = f_state_name(state, isStrong)
stateLabelShort = f_state_short(state, isStrong)
lblSz           = f_size(labelSize)

// -----------------------------------------------------
// PLOTS
// -----------------------------------------------------
plot(midline, title = "Midline", color = midColor, linewidth = lineWidth)

hiShell = plot(showShell ? hiRoll : na, title = "Range High", color = color.new(panelLabelCol, shellAlpha), display = display.pane)
loShell = plot(showShell ? loRoll : na, title = "Range Low", color = color.new(panelLabelCol, shellAlpha), display = display.pane)
fill(hiShell, loShell, color = showShell ? color.new(panelLabelCol, math.min(99, shellAlpha + 4)) : na, title = "Range Shell Fill")

bgcolor(showStateBg and state == 1 ? color.new(bullColor, stateBgAlpha) : showStateBg and state == 2 ? color.new(bearColor, stateBgAlpha) : na, title = "State Background")

// -----------------------------------------------------
// LABELS
// -----------------------------------------------------
var label edgeLabel = na
var line edgeRail = na
var line edgeLead = na
var array<label> eventLabels = array.new<label>()
var int lastEventLabelBar = na

if labelMode != "Off" and barstate.islast
    edgeY = state == 2 ? midline - atrSafe * 0.25 : midline + atrSafe * 0.25
    edgeX = bar_index + rightTagOffset
    bendX = math.max(bar_index + 1, edgeX - 2)
    edgeText = stateLabelShort + " " + str.tostring(math.round(controlScore)) + " | MID " + str.tostring(rollingLen)
    if na(edgeLabel)
        edgeLabel := label.new(
             x = edgeX,
             y = edgeY,
             text = edgeText,
             color = stateColor,
             textcolor = f_text_on(stateColor),
             style = label.style_label_left,
             size = lblSz)
    else
        label.set_xy(edgeLabel, edgeX, edgeY)
        label.set_text(edgeLabel, edgeText)
        label.set_color(edgeLabel, stateColor)
        label.set_textcolor(edgeLabel, f_text_on(stateColor))
        label.set_size(edgeLabel, lblSz)
    if na(edgeRail)
        edgeRail := line.new(bar_index, midline, bendX, midline, color = color.new(stateColor, 35), width = 2)
    else
        line.set_xy1(edgeRail, bar_index, midline)
        line.set_xy2(edgeRail, bendX, midline)
        line.set_color(edgeRail, color.new(stateColor, 35))
    if na(edgeLead)
        edgeLead := line.new(bendX, midline, edgeX - 1, edgeY, color = color.new(stateColor, 12), width = 2)
    else
        line.set_xy1(edgeLead, bendX, midline)
        line.set_xy2(edgeLead, edgeX - 1, edgeY)
        line.set_color(edgeLead, color.new(stateColor, 12))

if labelMode == "Off" and not na(edgeLabel)
    label.delete(edgeLabel)
    edgeLabel := na
    if not na(edgeRail)
        line.delete(edgeRail)
        edgeRail := na
    if not na(edgeLead)
        line.delete(edgeLead)
        edgeLead := na

labelAllowed = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldown
showBalancedEvent = labelMode == "Balanced" and (stateChanged or strongTurnOn)
showTransitionEvent = labelMode == "Edge + Transitions" and stateChanged

if (showBalancedEvent or showTransitionEvent) and labelAllowed and barstate.isconfirmed
    // All event labels sit clear of the candles (above the high or below the low) — never on the midline
    labelStyle = state == 2 ? label.style_label_down : label.style_label_up
    labelY     = state == 2 ? high + atrSafe * labelOffsetAtr : low - atrSafe * labelOffsetAtr
    labelText  = stateChanged ? (state == 0 ? "MIDPOINT\nFIGHT" : state == 1 ? "ACCEPTED\nABOVE" : "ACCEPTED\nBELOW") : state == 1 ? "STRONG\nABOVE" : "STRONG\nBELOW"
    label newEventLabel = label.new(
         x = bar_index,
         y = labelY,
         text = labelText,
         color = stateColor,
         textcolor = f_text_on(stateColor),
         style = labelStyle,
         size = lblSz)
    array.push(eventLabels, newEventLabel)
    lastEventLabelBar := bar_index

while array.size(eventLabels) > maxVisibleLabels
    label.delete(array.shift(eventLabels))

if labelMode == "Edge Only" or labelMode == "Off"
    while array.size(eventLabels) > 0
        label.delete(array.shift(eventLabels))
    lastEventLabelBar := na

// -----------------------------------------------------
// INFO PANEL
// -----------------------------------------------------
var table panel = na

if showPanel and barstate.islast
    if na(panel)
        panel := table.new(f_panel_pos(panelLoc), 2, 8,
             bgcolor = panelBg,
             border_color = panelBorder,
             border_width = 1,
             frame_color = panelBorder,
             frame_width = 1)
    table.set_position(panel, f_panel_pos(panelLoc))
    pFont = f_size(panelFont)
    table.clear(panel, 0, 0, 1, 7)
    table.merge_cells(panel, 0, 0, 1, 0)

    table.cell(panel, 0, 0, "AG Pro Rolling Midpoint Engine",
         bgcolor = headerBg, text_color = headerText, text_size = pFont, text_halign = text.align_center)

    table.cell(panel, 0, 1, "State",
         bgcolor = panelBg, text_color = panelLabelCol, text_size = pFont, text_halign = text.align_left)
    table.cell(panel, 1, 1, stateLabel,
         bgcolor = panelBg, text_color = stateColor, text_size = pFont, text_halign = text.align_right)

    scoreCol = controlScore >= 55 and state != 0 ? stateColor : panelValueCol
    table.cell(panel, 0, 2, "Control Score",
         bgcolor = panelBg, text_color = panelLabelCol, text_size = pFont, text_halign = text.align_left)
    table.cell(panel, 1, 2, str.tostring(math.round(controlScore)) + " / 100",
         bgcolor = panelBg, text_color = scoreCol, text_size = pFont, text_halign = text.align_right)

    slopeValid = not na(slope10)
    slopeStr = slopeValid ? (slope10 > 0 ? "+" : "") + str.tostring(slope10, "#.##") + " ATR" : "-"
    slopeCol = not slopeValid ? panelValueCol : slope10 > 0.2 ? bullColor : slope10 < -0.2 ? bearColor : panelValueCol
    table.cell(panel, 0, 3, "Mid Slope (10)",
         bgcolor = panelBg, text_color = panelLabelCol, text_size = pFont, text_halign = text.align_left)
    table.cell(panel, 1, 3, slopeStr,
         bgcolor = panelBg, text_color = slopeCol, text_size = pFont, text_halign = text.align_right)

    table.cell(panel, 0, 4, "Bars in State",
         bgcolor = panelBg, text_color = panelLabelCol, text_size = pFont, text_halign = text.align_left)
    table.cell(panel, 1, 4, str.tostring(barsInState),
         bgcolor = panelBg, text_color = panelValueCol, text_size = pFont, text_halign = text.align_right)

    progStr = close > midline ? str.tostring(aboveStreak) + " / " + str.tostring(acceptBars) + " above" : close < midline ? str.tostring(belowStreak) + " / " + str.tostring(acceptBars) + " below" : "at midpoint"
    table.cell(panel, 0, 5, "Acceptance",
         bgcolor = panelBg, text_color = panelLabelCol, text_size = pFont, text_halign = text.align_left)
    table.cell(panel, 1, 5, progStr,
         bgcolor = panelBg, text_color = panelValueCol, text_size = pFont, text_halign = text.align_right)

    distAtr = str.tostring(distFromMid / atrSafe, "#.##") + " ATR" + (isStrong ? "  *" : "")
    table.cell(panel, 0, 6, "Dist. from Mid",
         bgcolor = panelBg, text_color = panelLabelCol, text_size = pFont, text_halign = text.align_left)
    table.cell(panel, 1, 6, distAtr,
         bgcolor = panelBg, text_color = isStrong ? stateColor : panelValueCol, text_size = pFont, text_halign = text.align_right)

    table.cell(panel, 0, 7, "Control: 0 = fight · 100 = strong one-sided hold",
         bgcolor = panelBg, text_color = panelLabelCol, text_size = size.small, text_halign = text.align_left)
    table.merge_cells(panel, 0, 7, 1, 7)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na

// -----------------------------------------------------
// ALERTS
// -----------------------------------------------------
if alertOnCross and crossedUp
    alert("AG Pro RME: Midline crossed UP on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertOnCross and crossedDn
    alert("AG Pro RME: Midline crossed DOWN on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertOnAccept and stateChanged and state == 1
    alert("AG Pro RME: Accepted ABOVE midline on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertOnAccept and stateChanged and state == 2
    alert("AG Pro RME: Accepted BELOW midline on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertOnReject and rejectionEvent
    alert("AG Pro RME: Midline rejection on " + syminfo.ticker, alert.freq_once_per_bar_close)

alertcondition(crossedUp, title = "Midline Crossed Up", message = "AG Pro RME: Midline crossed UP on {{ticker}}")
alertcondition(crossedDn, title = "Midline Crossed Down", message = "AG Pro RME: Midline crossed DOWN on {{ticker}}")
alertcondition(stateChanged and state == 1, title = "Accepted Above", message = "AG Pro RME: Accepted ABOVE midline on {{ticker}}")
alertcondition(stateChanged and state == 2, title = "Accepted Below", message = "AG Pro RME: Accepted BELOW midline on {{ticker}}")
alertcondition(rejectionEvent, title = "Midline Rejection", message = "AG Pro RME: Midline rejection on {{ticker}}")
````
