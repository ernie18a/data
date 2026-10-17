# PReversion [MohaveTrader]

- url: https://www.tradingview.com/script/o4TbxKZH-PReversion-MohaveTrader/
- type: indicator
- pine_id: PUB;856327f2a8ae4eb596e3e4f24494e7ab
- version: 1.0

## Description

PReversion is a structural extension indicator that measures how far price has moved from an adaptive equilibrium basis — and whether that distance is increasing or beginning to unwind.

Unlike a fixed moving average, the equilibrium rail automatically adjusts to changing market conditions. Extension is measured from that adaptive equilibrium, not from a static reference point.

━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW PREVERSION WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━

PReversion measures extension using an adaptive equilibrium rail and presents that information as both ATR distance and a continuous score. The score adjusts as extension expands or contracts, helping distinguish an accelerating move from one that is already beginning to unwind.

The score is a continuous version of the four zones — not a separate signal.

━━━━━━━━━━━━━━━━━━━━━━━━━━
THE FOUR ZONES
━━━━━━━━━━━━━━━━━━━━━━━━━━

Normal — 0 to 1.0 ATR from rail. Price is near equilibrium.

Extended — 1.0 to 1.5 ATR from rail. Price has moved meaningfully from the rail.

Stretched — 1.5 to 2.0 ATR from rail. Extension is elevated.

Extreme — 2.0+ ATR from rail. Extension is at its greatest, where traders often monitor for signs of exhaustion or reversion.

━━━━━━━━━━━━━━━━━━━━━━━━━━
UNDERSTANDING THE DASHBOARD
━━━━━━━━━━━━━━━━━━━━━━━━━━

Trend — Direction of the adaptive rail.

Direction — Whether price is currently above or below the rail.

State — The current zone. Read this first.

Score — Remaining reversion risk on a 0–100 scale. Falls as reversion progresses even while extension remains elevated.

Extension — Distance from the rail in ATR units. The primary metric.

━━━━━━━━━━━━━━━━━━━━━━━━━━
GETTING STARTED
━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Add PReversion to any chart. It works on all instruments and timeframes.
2. In Settings → Display, choose dashboard position and size.
3. Read the State row first. Then check Score to understand how much reversion has already occurred.
4. Use Extension ATR as the objective distance measure independent of score.
5. Trend responsiveness and score sensitivity can be adjusted for different instruments in Settings.

━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE IT
━━━━━━━━━━━━━━━━━━━━━━━━━━

PReversion is not a buy or sell signal. Use it as a structural context layer alongside your existing methodology. Typical applications:

• Identifying blow-off extensions before momentum indicators have responded.
• Tracking reversion progress during a pullback — score falling while extension remains elevated indicates the move is unwinding even if price has not returned to the rail.
• Evaluating entry risk when price is deep in the Extreme zone versus re-entering from the Extended zone after a partial reversion.
• Confirming reversion completion when State returns to Normal and Score approaches zero.

Strong trends often do not fully revert to the rail. Price commonly finds support in the outer bands while the rail rises to meet it. PReversion measures the distance; it does not require price to traverse the entire fan.

━━━━━━━━━━━━━━━━━━━━━━━━━━
WORKS WELL ALONGSIDE
━━━━━━━━━━━━━━━━━━━━━━━━━━

• Trend indicators and moving averages
• Volume Profile and VWAP
• Momentum and second-derivative tools
• Market structure and support/resistance

━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT THIS TOOL IS NOT
━━━━━━━━━━━━━━━━━━━━━━━━━━

PReversion measures structural extension from an adaptive equilibrium basis. It does not predict reversals or guarantee price returns to the rail. Use it as analytical context alongside your existing trading methodology.

━━━━━━━━━━━━━━━━━━━━━━━━━━
VISUAL INSPIRATION
━━━━━━━━━━━━━━━━━━━━━━━━━━

Special thanks to NICK789. The visual design of the extension bands draws inspiration from the cloud fill approach used in the Fusion EMA Trend Trade Planner by NICK789, whose work on adaptive trend visualization influenced the aesthetic direction of PReversion.

## Source Code

````pine
//@version=6
// PReversion [MohaveTrader]
// Version: v1.5 — June 2026
//
// Structural extension engine. Measures distance from adaptive equilibrium rail.
// Four ATR bands: Normal / Extended / Stretched / Extreme.
//
// DISCLAIMER
// For educational and informational purposes only. Not financial advice.
// Trading involves substantial risk. Past performance is not indicative of future results.

indicator("PReversion [MohaveTrader]", shorttitle="PReversion", overlay=true)

// INPUTS

string G_RAIL  = "Equilibrium Rail"
string G_ZONES = "Extension Zones"
string G_VIS   = "Display"
string G_COLOR = "Colors"

i_adaptStrength = input.float(4.0, "Rail Responsiveness", minval=1.0, maxval=10.0, step=0.5, group=G_RAIL,
     tooltip="Controls how quickly the equilibrium rail responds to changing market conditions. Lower = more stable. Higher = more responsive.")

// Internal constants
var int   _basisLen         = 16
var int   _bullConfirm      = 2
var int   _bearConfirm      = 4
var bool  _bearBreakOn      = true
var float _breakPct         = 0.75
var float _minBearBodyRatio = 0.70

i_atrLen       = input.int(14,   "ATR Length",     minval=1, maxval=100, group=G_ZONES,
     tooltip="ATR period for zone width calculation.")
i_extLevel     = input.float(1.0, "Extended Zone",  minval=0.1, maxval=10.0, step=0.1, group=G_ZONES,
     tooltip="ATR distance from rail where Extended zone begins.")
i_stretchLevel = input.float(1.5, "Stretched Zone", minval=0.1, maxval=10.0, step=0.1, group=G_ZONES,
     tooltip="ATR distance from rail where Stretched zone begins.")
i_extremeLevel = input.float(2.0, "Extreme Zone",   minval=0.1, maxval=10.0, step=0.1, group=G_ZONES,
     tooltip="ATR distance from rail where Extreme zone begins.")

i_scoreSens = input.float(0.25, "Score Sensitivity", minval=0.05, maxval=1.0, step=0.05, group=G_ZONES,
     tooltip="Controls how quickly the score responds to changes in extension. Lower = more sensitive.")

// Internal constants
var float _normScale   = 2.0
var float _rocWeight   = 8.0
var float _gammaWeight = 5.0

i_showZones  = input.bool(true,  "Show Extension Zones", group=G_VIS)
i_showDash   = input.bool(true,  "Show Dashboard",       group=G_VIS)
i_labelPos   = input.string("Top Right", "Dashboard Position",
               options=["Top Right", "Top Left", "Top Center",
                        "Middle Right", "Middle Left", "Middle Center",
                        "Bottom Right", "Bottom Left", "Bottom Center"],
               group=G_VIS)
i_labelSize  = input.string("Small", "Dashboard Text Size",
               options=["Small", "Normal", "Large"], group=G_VIS)

i_bullColor      = input.color(#00FF66, "Bull Color",          group=G_COLOR)
i_bearColor      = input.color(#FF1744, "Bear Color",          group=G_COLOR)
i_bullCloudColor = input.color(#00FF66, "Bull Cloud Color",    group=G_COLOR)
i_bearCloudColor = input.color(#FF1744, "Bear Cloud Color",    group=G_COLOR)
i_cloudTransp    = input.int(62,        "Cloud Transparency",  minval=0, maxval=95, group=G_COLOR)
i_extColor       = input.color(#00E5FF, "Extended Color",      group=G_COLOR)
i_stretchColor   = input.color(#FF6200, "Stretched Color",     group=G_COLOR)
i_extremeColor   = input.color(#FFD000, "Extreme Color",       group=G_COLOR)

// RAIL ENGINE

float bodyPct = high != low ? math.abs(close - open) / (high - low) : 0.0
float bodyMid = math.avg(high, low) + bodyPct * (close - math.avg(high, low))

var float mgBasis = na
float mgPrev      = nz(mgBasis[1], bodyMid)
float deviation   = mgPrev != 0.0 ? math.abs(bodyMid - mgPrev) / mgPrev : 0.0
float adaptLen    = math.max(_basisLen * math.max(1.0 - deviation * i_adaptStrength, 0.1), 1.0)
mgBasis           := na(mgBasis[1]) ? bodyMid :
     mgBasis[1] + (bodyMid - mgBasis[1]) / adaptLen

bool basisUp   = mgBasis > mgBasis[1]
bool basisDown = mgBasis < mgBasis[1]

bool bullCondition = basisUp   and close > mgBasis
bool bearCondition = basisDown and close < mgBasis

var int bullStreak = 0
var int bearStreak = 0
bullStreak := bullCondition ? nz(bullStreak[1], 0) + 1 : 0
bearStreak := bearCondition ? nz(bearStreak[1], 0) + 1 : 0

float barRange_   = high - low
float bodySize_   = math.abs(close - open)
bool  belowEnough = close < mgBasis * (1.0 - _breakPct / 100.0)
bool  bearImpulse = close < open and
     barRange_ > syminfo.mintick and
     bodySize_ / math.max(barRange_, syminfo.mintick) >= _minBearBodyRatio
bool  bearBreak   = _bearBreakOn and belowEnough and bearImpulse

var int trendDir = 1
trendDir := (bearBreak                    ? -1 :
             bullStreak >= _bullConfirm   ?  1 :
             bearStreak >= _bearConfirm   ? -1 :
                                            nz(trendDir[1], 1))

// EXTENSION CALCULATION

float atrVal   = ta.atr(i_atrLen)
float distance = close - mgBasis
float distAbs  = math.abs(distance)
float distATR  = atrVal > 0.0 ? distAbs / atrVal : 0.0

bool isBullExt = distance >= 0.0
bool isBearExt = distance <  0.0

// SCORE

float baseScore = math.min((distATR / _normScale) * 100.0, 100.0)

float rocDelta  = distATR - nz(distATR[1], distATR)
float rocMod    = math.max(math.min(rocDelta / i_scoreSens, 1.0), -1.0) * _rocWeight

float rocPrev   = nz(distATR[1], distATR) - nz(distATR[2], nz(distATR[1], distATR))
float accel     = rocDelta - rocPrev
float gammaMod  = math.max(math.min(accel / i_scoreSens, 1.0), -1.0) * _gammaWeight

float score     = math.min(math.max(baseScore + rocMod + gammaMod, 0.0), 100.0)

// ATR BAND LEVELS

float lvl_ext_u     = mgBasis + atrVal * i_extLevel
float lvl_stretch_u = mgBasis + atrVal * i_stretchLevel
float lvl_extreme_u = mgBasis + atrVal * i_extremeLevel
float lvl_far_u     = mgBasis + atrVal * (i_extremeLevel + (i_extremeLevel - i_stretchLevel))

float lvl_ext_l     = mgBasis - atrVal * i_extLevel
float lvl_stretch_l = mgBasis - atrVal * i_stretchLevel
float lvl_extreme_l = mgBasis - atrVal * i_extremeLevel
float lvl_far_l     = mgBasis - atrVal * (i_extremeLevel + (i_extremeLevel - i_stretchLevel))

// ZONE MEMBERSHIP

bool inNormal    = distATR <  i_extLevel
bool inExtended  = distATR >= i_extLevel    and distATR < i_stretchLevel
bool inStretched = distATR >= i_stretchLevel and distATR < i_extremeLevel
bool inExtreme   = distATR >= i_extremeLevel

string bucket = (inExtreme   ? "Extreme"   :
                 inStretched ? "Stretched" :
                 inExtended  ? "Extended"  :
                               "Normal")

// ZONE VISUAL

p_rail_u    = plot(i_showZones ? mgBasis       : na, "Rail Upper",    color=color.new(chart.fg_color, 100), editable=false)
p_norm_u    = plot(i_showZones ? lvl_ext_u     : na, "Normal Upper",  color=color.new(chart.fg_color, 100))
p_ext_u     = plot(i_showZones ? lvl_stretch_u : na, "Ext Upper",     color=color.new(chart.fg_color, 100))
p_stretch_u = plot(i_showZones ? lvl_extreme_u : na, "Stretch Upper", color=color.new(chart.fg_color, 100))
p_extreme_u = plot(i_showZones ? lvl_far_u     : na, "Extreme Upper", color=color.new(chart.fg_color, 100))

p_rail_l    = plot(i_showZones ? mgBasis       : na, "Rail Lower",    color=color.new(chart.fg_color, 100), editable=false)
p_norm_l    = plot(i_showZones ? lvl_ext_l     : na, "Normal Lower",  color=color.new(chart.fg_color, 100))
p_ext_l     = plot(i_showZones ? lvl_stretch_l : na, "Ext Lower",     color=color.new(chart.fg_color, 100))
p_stretch_l = plot(i_showZones ? lvl_extreme_l : na, "Stretch Lower", color=color.new(chart.fg_color, 100))
p_extreme_l = plot(i_showZones ? lvl_far_l     : na, "Extreme Lower", color=color.new(chart.fg_color, 100))

fill(p_rail_u,    p_norm_u,    color=i_showZones ? color.new(i_bullCloudColor, math.min(95, i_cloudTransp + 20)) : na, title="Bull Normal Fill")
fill(p_norm_u,    p_ext_u,     color=i_showZones ? color.new(i_bullCloudColor, math.min(95, i_cloudTransp + 12)) : na, title="Bull Extended Fill")
fill(p_ext_u,     p_stretch_u, color=i_showZones ? color.new(i_bullCloudColor, math.max(0,  i_cloudTransp - 3))  : na, title="Bull Stretched Fill")
fill(p_stretch_u, p_extreme_u, color=i_showZones ? color.new(i_bullCloudColor, math.max(0,  i_cloudTransp - 12)) : na, title="Bull Extreme Fill")

fill(p_rail_l,    p_norm_l,    color=i_showZones ? color.new(i_bearCloudColor, math.min(95, i_cloudTransp + 20)) : na, title="Bear Normal Fill")
fill(p_norm_l,    p_ext_l,     color=i_showZones ? color.new(i_bearCloudColor, math.min(95, i_cloudTransp + 12)) : na, title="Bear Extended Fill")
fill(p_ext_l,     p_stretch_l, color=i_showZones ? color.new(i_bearCloudColor, math.max(0,  i_cloudTransp - 3))  : na, title="Bear Stretched Fill")
fill(p_stretch_l, p_extreme_l, color=i_showZones ? color.new(i_bearCloudColor, math.max(0,  i_cloudTransp - 12)) : na, title="Bear Extreme Fill")

// RAIL PLOT

railColor = trendDir == 1 ? i_bullColor : i_bearColor

plot(mgBasis, "PReversion Rail",
     color     = railColor,
     linewidth = 2)

// SCALE ANCHOR

plotcandle(open, high, low, close,
     title       = "Scale Anchor",
     color       = color.new(color.black, 99),
     wickcolor   = color.new(color.black, 99),
     bordercolor = color.new(color.black, 99))

// DASHBOARD

color  C_BG_dash    = color.rgb(4,   7,  12)
color  C_PANEL_dash = color.rgb(8,  13,  22)
color  C_MUTED_dash = color.rgb(132, 145, 160)

string dirLabel   = isBullExt ? "Bull" : "Bear"
string dirArrow   = isBullExt ? "↑" : "↓"
string scoreStr   = str.tostring(math.round(score))
string atrStr     = str.tostring(distATR, "#.##") + " ATR"
color  dirColor   = isBullExt ? i_bullColor : i_bearColor
color  stateColor = (inExtreme   ? i_extremeColor :
                     inStretched ? i_stretchColor :
                     inExtended  ? i_extColor     :
                     color.new(chart.fg_color, 40))

color frameColor = (inExtreme   ? i_extremeColor :
                    inStretched ? i_stretchColor :
                    inExtended  ? i_extColor     :
                    dirColor)

var table dash      = na
var int   lastTrend = 0
var int   lastState = -1

if barstate.islast and i_showDash
    int stateInt = inExtreme ? 3 : inStretched ? 2 : inExtended ? 1 : 0
    if na(dash) or trendDir != lastTrend or stateInt != lastState
        if not na(dash)
            table.delete(dash)

        tablePos = (i_labelPos == "Top Right"     ? position.top_right     :
                    i_labelPos == "Top Left"      ? position.top_left      :
                    i_labelPos == "Middle Right"  ? position.middle_right  :
                    i_labelPos == "Middle Left"   ? position.middle_left   :
                    i_labelPos == "Middle Center" ? position.middle_center :
                    i_labelPos == "Bottom Right"  ? position.bottom_right  :
                    i_labelPos == "Bottom Left"   ? position.bottom_left   :
                    i_labelPos == "Top Center"    ? position.top_center    :
                                                    position.bottom_center)

        txtSize = (i_labelSize == "Small"  ? size.small  :
                   i_labelSize == "Large"  ? size.large  :
                                             size.normal)

        dash := table.new(tablePos, 2, 5,
             bgcolor      = color.new(C_PANEL_dash, 4),
             frame_color  = color.new(frameColor, 30),
             frame_width  = 2,
             border_color = color.new(color.silver, 70),
             border_width = 1)

        lastTrend := trendDir
        lastState := stateInt

    txtSize = (i_labelSize == "Small"  ? size.small  :
               i_labelSize == "Large"  ? size.large  :
                                         size.normal)

    table.cell(dash, 0, 0, "TREND",     text_color=dirColor,      bgcolor=color.new(C_BG_dash, 0),    text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 0, dirArrow,    text_color=dirColor,      bgcolor=color.new(C_BG_dash, 0),    text_size=txtSize, text_halign=text.align_right)
    table.cell(dash, 0, 1, "DIRECTION", text_color=C_MUTED_dash,  bgcolor=color.new(C_PANEL_dash, 0), text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 1, dirLabel,    text_color=dirColor,      bgcolor=color.new(C_PANEL_dash, 0), text_size=txtSize, text_halign=text.align_right)
    table.cell(dash, 0, 2, "STATE",     text_color=C_MUTED_dash,  bgcolor=color.new(C_PANEL_dash, 0), text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 2, bucket,      text_color=stateColor,    bgcolor=color.new(C_PANEL_dash, 0), text_size=txtSize, text_halign=text.align_right)
    table.cell(dash, 0, 3, "SCORE",     text_color=C_MUTED_dash,  bgcolor=color.new(C_PANEL_dash, 0), text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 3, scoreStr,    text_color=color.white,   bgcolor=color.new(C_PANEL_dash, 0), text_size=txtSize, text_halign=text.align_right)
    table.cell(dash, 0, 4, "EXTENSION", text_color=C_MUTED_dash,  bgcolor=color.new(C_PANEL_dash, 0), text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 4, atrStr,      text_color=stateColor,    bgcolor=color.new(C_PANEL_dash, 0), text_size=txtSize, text_halign=text.align_right)

// ALERTS

alertcondition(inExtreme  and isBullExt, "Bull Extreme",   "PReversion - Bull Extreme extension")
alertcondition(inExtreme  and isBearExt, "Bear Extreme",   "PReversion - Bear Extreme extension")
alertcondition(inStretched and isBullExt, "Bull Stretched", "PReversion - Bull Stretched extension")
alertcondition(inStretched and isBearExt, "Bear Stretched", "PReversion - Bear Stretched extension")
alertcondition(not inExtended and not inStretched and not inExtreme and isBullExt and (inExtended[1] or inStretched[1] or inExtreme[1]), "Bull Returned Normal", "PReversion - Bull extension resolved to Normal")
alertcondition(not inExtended and not inStretched and not inExtreme and isBearExt and (inExtended[1] or inStretched[1] or inExtreme[1]), "Bear Returned Normal", "PReversion - Bear extension resolved to Normal")
````
