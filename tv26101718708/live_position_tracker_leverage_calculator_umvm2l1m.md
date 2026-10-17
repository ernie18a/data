# Live Position Tracker Leverage Calculator

- url: https://www.tradingview.com/script/UMvM2l1M-Live-Position-Tracker-Leverage-Calculator/
- type: indicator
- pine_id: PUB;7cc073a28a4a4ba7ade3dca741dbe005
- version: 1.0

## Description

[b]Live Position Tracker Leverage Calculator[/b]

A leverage and position calculator that lives on your chart. Set your entry candle, entry price, take profit, and stop loss with a few clicks and get an instant visual breakdown of the trade — risk, reward, liquidation distance, breakeven, and live PnL — all anchored to the actual candle you entered on.

Unlike static calculator widgets, this tool tracks your trade from entry to exit. It records the best and worst points your position reached, counts how many bars you've held, and freezes everything when the trade closes so you have a clean snapshot of how it played out.

[b]WHAT GETS PLOTTED ON THE CHART[/b]

· Entry, Take Profit, and Stop Loss lines anchored from your entry candle forward
· Liquidation price line (calculated from your leverage and maintenance margin)
· Breakeven line (entry adjusted for fees)
· Filled zones between entry/TP (green) and entry/SL (red)
· Best Point and Worst Point markers showing the maximum favorable and adverse excursion the trade reached
· Live PnL label that updates with current price

[b]WHAT'S IN THE INFO PANEL[/b]

· Position: capital, notional, quantity, maintenance margin, fee rate
· Outcomes: live PnL, projected PnL at TP, projected loss at SL, risk-to-reward ratio
· Liquidation: liquidation price, distance to liquidation, round-trip fees
· Trade history: bars in trade, best point reached, worst point reached
· Status: pending entry, active, target hit, stop hit, or liquidated

[b]KEY FEATURES[/b]

· Click-to-set workflow: TradingView prompts you to click the entry candle, entry price, TP, and SL when you add the indicator
· Auto direction detection from your TP and SL placement (or manually force Long/Short)
· Liquidation calculator with adjustable maintenance margin (works for any exchange — set the value from your exchange's tier table)
· Sanity warnings: flags when stop loss is past the liquidation price, or when TP/SL are on the wrong side of entry
· Trade tracking freezes the moment any exit (TP/SL/liquidation) is hit, giving you a clean post-trade snapshot
· Three independent color systems: on-chart tag colors, Live PnL label colors, and panel theme — each customizable without affecting the others
· Customizable line widths, label colors, font color, and panel theme (dark, light, or fully custom)
· Adjustable label offsets and stagger so the chart never gets cluttered regardless of timeframe or symbol
· Alerts for TP, SL, liquidation, and breakeven crossings

[b]MAINTENANCE MARGIN REFERENCE[/b]

Maintenance margin (MMR) is the minimum equity percentage required to keep your leveraged position open. The default 0.5% is roughly accurate for BTC/ETH on major exchanges, but real values vary:

· BTC/ETH majors: 0.4 – 0.5%
· Top 20 alts: 0.5 – 1.0%
· Mid-cap alts: 1.0 – 2.5%
· Low-cap and meme coins: 2.5%+

For accurate liquidation calculations, find your exchange's exact MMR for your symbol and position size.

[b]NOTES[/b]

The liquidation price is a simplified isolated-margin approximation and does not account for tiered margin requirements at different position sizes. Always verify against your exchange's actual liquidation calculator before sizing real positions.

This tool calculates risk-to-reward as the gross price-distance ratio (matching TradingView's built-in long/short position tool). The fee-adjusted dollar amounts are shown separately in the "If TP Hit" and "If SL Hit" rows.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © geneclash

//@version=6
indicator("Live Position Tracker Leverage Calculator", shorttitle="LPT", overlay=true, max_lines_count=100, max_labels_count=100, max_boxes_count=20)

// ═══════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════

// --- Position Setup ---
grpPos = "Position Setup"
side       = input.string("Auto", "Direction", options=["Auto", "Long", "Short"], group=grpPos, tooltip="Auto detects direction from your TP and SL: TP above SL = Long, TP below SL = Short. Use Long/Short to force a specific direction.")
entryTime  = input.time(0,    "Entry Candle",     confirm=true, group=grpPos, tooltip="Click on the candle where you entered the trade")
entryPx    = input.price(0.0, "Entry Price",      confirm=true, group=grpPos, tooltip="Click on chart to set entry price")
tpPx       = input.price(0.0, "Take Profit",      confirm=true, group=grpPos, tooltip="Click on chart to set TP")
slPx       = input.price(0.0, "Stop Loss",        confirm=true, group=grpPos, tooltip="Click on chart to set SL")
extendBars     = input.int(20, "Extend Lines Right (bars)", minval=0, maxval=500, group=grpPos, tooltip="How many bars past the current candle to extend the lines")
labelOffset    = input.int(3, "Label Offset (bars)", minval=0, maxval=20, group=grpPos, tooltip="Base gap between line endpoint and labels (TP, SL, Entry, Liq, Live PnL)")
secondaryStag  = input.int(80, "Secondary Label Stagger (bars)", minval=0, maxval=120, group=grpPos, tooltip="Horizontal offset for the Best and Worst labels — keeps them clear of the TP/SL column when prices are close")

// --- Account & Risk ---
grpAcc = "Account & Risk"
capital    = input.float(10000.0, "Account Capital ($)", minval=1, group=grpAcc)
leverage   = input.float(10.0,    "Leverage (x)",        minval=1, maxval=125, step=1, group=grpAcc)
mmr        = input.float(0.5,     "Maintenance Margin %", minval=0.1, maxval=20, step=0.1, group=grpAcc, tooltip="The minimum equity % required to keep your position open. Find your exchange's exact value for accurate liquidation.\n\nTypical reference values:\n• BTC/ETH majors: 0.4 – 0.5%\n• Top 20 alts (SOL, XRP, etc): 0.5 – 1.0%\n• Mid-cap alts: 1.0 – 2.5%\n• Low-cap / meme coins: 2.5 – 10%\n\nNote: Larger position sizes use higher tiers — check your exchange's tier table.")
feeRate    = input.float(0.05,    "Fee per side (%)",    minval=0, maxval=1, step=0.01, group=grpAcc, tooltip="Taker fee per entry/exit. Default 0.05% = Binance taker.")

// --- Visual ---
grpVis = "Visual"
showZones    = input.bool(true,  "Show TP/SL Zones",     group=grpVis)
showLiq      = input.bool(true,  "Show Liquidation Line", group=grpVis)
showBE       = input.bool(true,  "Show Breakeven Line",   group=grpVis)
bePos        = input.string("Centered", "Breakeven Label Position", options=["Centered","Right Column"], group=grpVis, tooltip="Centered floats inside the trade window away from other labels. Right Column aligns with TP/SL on the right side.")
showPanel    = input.bool(true,  "Show Info Panel",       group=grpVis)
panelPos     = input.string("Top Right", "Panel Position", options=["Top Right","Top Left","Middle Right","Bottom Right","Bottom Left"], group=grpVis)
panelSize    = input.string("Normal", "Panel Size", options=["Tiny","Small","Normal","Large"], group=grpVis)
lineWidth    = input.int(1, "Line Width", minval=1, maxval=5, group=grpVis, tooltip="Thickness of Entry, TP, SL, and Liquidation lines")

// --- Colors ---
grpClr = "Colors"
cEntry      = input.color(color.new(#3a5a7a, 0),  "Entry",       group=grpClr)
cTP         = input.color(color.new(#3d7a5c, 0),  "TP",          group=grpClr)
cSL         = input.color(color.new(#8b3a2f, 0),  "SL",          group=grpClr)
cLiq        = input.color(color.new(#5c1a14, 0),  "Liquidation", group=grpClr)
cBE         = input.color(color.new(#8a6d3b, 0),  "Breakeven",   group=grpClr)
cLabelText  = input.color(#e8e3d8,                "Label Text",  group=grpClr, tooltip="Text color inside on-chart label tags.")
zoneFill    = input.int(94, "Zone Transparency", minval=70, maxval=98, group=grpClr, tooltip="Higher value = more subtle TP/SL zone shading.")

// --- Live PnL Label ---
grpLive = "Live PnL Label"
cLiveStyle      = input.string("Solid",                "Style", options=["Solid","Pulsing"], group=grpLive, tooltip="Solid: static color. Pulsing: alpha cycles for a live feel.")
cLiveAuto       = input.bool(true,                     "Auto Color (green/red by P&L)", group=grpLive, tooltip="ON: uses on-chart TP color in profit, SL color in loss. OFF: uses the Custom Backgrounds below.")
cLiveBgProfit   = input.color(color.new(#3d7a5c, 0),   "Custom Background — Profit",    group=grpLive, tooltip="Used when Auto Color is OFF and P&L is positive.")
cLiveBgLoss     = input.color(color.new(#8b3a2f, 0),   "Custom Background — Loss",      group=grpLive, tooltip="Used when Auto Color is OFF and P&L is negative.")
cLiveText       = input.color(#e8e3d8,                 "Font Color",                    group=grpLive, tooltip="Text color for the Live PnL value inside the label.")
cLiveSize       = input.string("Small",                "Size", options=["Tiny","Small","Normal","Large","Huge"], group=grpLive, tooltip="Independent of the panel size.")

// --- Panel Theme ---
grpPnl = "Panel Theme"
panelTheme    = input.string("Dark",   "Theme Preset",     options=["Dark","Light","Custom"], group=grpPnl, tooltip="Dark, Light, or Custom (use the colors below).")
cPnlBg        = input.color(color.new(#0d1117, 0),  "Background",          group=grpPnl, tooltip="Custom theme only.")
cPnlRow       = input.color(color.new(#161b22, 0),  "Alt Row (zebra)",     group=grpPnl, tooltip="Custom theme only.")
cPnlAccent    = input.color(color.new(#1c2128, 0),  "P&L Block Accent",    group=grpPnl, tooltip="Custom theme only.")
cPnlHeader    = input.color(color.new(#21262d, 0),  "Header Background",   group=grpPnl, tooltip="Custom theme only.")
cPnlTxtMuted  = input.color(#7d8590,                "Muted Text (labels)", group=grpPnl, tooltip="Custom theme only.")
cPnlTxtBright = input.color(#f0f0ec,                "Bright Text (values)",group=grpPnl, tooltip="Custom theme only.")
cPnlBorder    = input.color(color.new(#30363d, 0),  "Border",              group=grpPnl, tooltip="Custom theme only.")
cPnlGreen     = input.color(#6cb191,                "Profit Green",        group=grpPnl, tooltip="Profit value text inside the panel. Independent from on-chart colors.")
cPnlRed       = input.color(#c4625d,                "Loss Red",            group=grpPnl, tooltip="Loss value text inside the panel. Independent from on-chart colors.")

// ═══════════════════════════════════════════════════════════════════
// CALCULATIONS
// ═══════════════════════════════════════════════════════════════════

// Resolve direction (Auto picks Long/Short from TP/SL geometry)
isLong = side == "Auto" ? (tpPx >= slPx) : (side == "Long")
sideMul = isLong ? 1.0 : -1.0

// Margin & position size
margin     = capital
notional   = margin * leverage
qty        = entryPx > 0 ? notional / entryPx : 0.0

// Fees (per side, applied to entry and exit)
feeMul     = feeRate / 100.0
entryFee   = notional * feeMul
exitFeeTP  = (qty * tpPx) * feeMul
exitFeeSL  = (qty * slPx) * feeMul

// PnL at TP / SL (gross and net of fees)
pnlTPgross = (tpPx - entryPx) * qty * sideMul
pnlSLgross = (slPx - entryPx) * qty * sideMul
pnlTPnet   = pnlTPgross - entryFee - exitFeeTP
pnlSLnet   = pnlSLgross - entryFee - exitFeeSL

// PnL as % of capital
pctTP = capital > 0 ? (pnlTPnet / capital) * 100.0 : 0.0
pctSL = capital > 0 ? (pnlSLnet / capital) * 100.0 : 0.0

// R-multiple: gross price-distance ratio (matches TradingView's long/short tool)
rewardDist = math.abs(tpPx - entryPx)
riskDist   = math.abs(entryPx - slPx)
rMult      = riskDist > 0 ? rewardDist / riskDist : 0.0

// Liquidation price (simplified isolated margin formula)
// Long:  Liq = Entry * (1 - 1/lev + mmr)
// Short: Liq = Entry * (1 + 1/lev - mmr)
mmrDec     = mmr / 100.0
liqPx      = isLong ? entryPx * (1 - 1.0/leverage + mmrDec) : entryPx * (1 + 1.0/leverage - mmrDec)

// Breakeven (entry adjusted for round-trip fees)
beOffset   = entryPx * feeMul * 2.0
bePx       = isLong ? entryPx + beOffset : entryPx - beOffset

// Live PnL based on current close
curPx      = close
pnlLiveGross = (curPx - entryPx) * qty * sideMul
pnlLiveNet   = pnlLiveGross - entryFee - (qty * curPx * feeMul)
pctLive      = capital > 0 ? (pnlLiveNet / capital) * 100.0 : 0.0

// Distance to liquidation from current price (%)
distLiqPct = curPx > 0 ? math.abs(curPx - liqPx) / curPx * 100.0 : 0.0
distSLPct  = curPx > 0 ? math.abs(curPx - slPx) / curPx * 100.0 : 0.0
distTPPct  = curPx > 0 ? math.abs(curPx - tpPx) / curPx * 100.0 : 0.0

// ═══════════════════════════════════════════════════════════════════
// VALIDATION & WARNINGS
// ═══════════════════════════════════════════════════════════════════

// SL past liquidation — stop won't trigger before liquidation
slPastLiq = isLong ? (slPx <= liqPx) : (slPx >= liqPx)

// TP/SL on wrong side of entry
tpWrongSide = isLong ? (tpPx <= entryPx) : (tpPx >= entryPx)
slWrongSide = isLong ? (slPx >= entryPx) : (slPx <= entryPx)

// ═══════════════════════════════════════════════════════════════════
// ENTRY-ANCHORED TRACKING
// ═══════════════════════════════════════════════════════════════════

// In-trade flag (entry candle reached)
inTrade = time >= entryTime and entryTime > 0

// Entry bar index (set once, on first bar at or after entry time)
var int entryBarIdx = na
if inTrade and na(entryBarIdx)
    entryBarIdx := bar_index

// Max favorable / adverse excursion since entry (in price)
var float mfePx = na
var float maePx = na

// Exit flags (only set after entry; first hit wins)
var bool tpReached  = false
var bool slReached  = false
var bool liqReached = false

// Bar index at which the trade closed; freezes barsInTrade and MFE/MAE
var int exitBarIdx = na
tradeClosed = not na(exitBarIdx)

if inTrade and not tradeClosed
    if isLong
        if not na(tpPx) and tpPx > 0 and high >= tpPx
            tpReached := true
        if not na(slPx) and slPx > 0 and low <= slPx
            slReached := true
        if low <= liqPx
            liqReached := true
    else
        if not na(tpPx) and tpPx > 0 and low <= tpPx
            tpReached := true
        if not na(slPx) and slPx > 0 and high >= slPx
            slReached := true
        if high >= liqPx
            liqReached := true

    if tpReached or slReached or liqReached
        exitBarIdx := bar_index

    if isLong
        mfePx := na(mfePx) ? high : math.max(mfePx, high)
        maePx := na(maePx) ? low  : math.min(maePx, low)
    else
        mfePx := na(mfePx) ? low  : math.min(mfePx, low)
        maePx := na(maePx) ? high : math.max(maePx, high)

// Bars elapsed since entry (frozen on close)
barsInTrade = not na(entryBarIdx) ? (na(exitBarIdx) ? bar_index - entryBarIdx : exitBarIdx - entryBarIdx) : 0

// MFE/MAE as PnL $
mfePnl = not na(mfePx) ? (mfePx - entryPx) * qty * sideMul - entryFee - (qty * mfePx * feeMul) : 0.0
maePnl = not na(maePx) ? (maePx - entryPx) * qty * sideMul - entryFee - (qty * maePx * feeMul) : 0.0
mfePct = capital > 0 ? (mfePnl / capital) * 100.0 : 0.0
maePct = capital > 0 ? (maePnl / capital) * 100.0 : 0.0

// ═══════════════════════════════════════════════════════════════════
// DRAWING (lines, zones, labels)
// ═══════════════════════════════════════════════════════════════════

// Drawings rebuilt on the last bar only
var line lEntry    = na
var line lEntryV   = na  // vertical entry marker
var line lTP       = na
var line lSL       = na
var line lLiq      = na
var line lBE       = na
var line lMFE      = na
var line lMAE      = na
var line lLiveLead = na
var box  bxTP      = na
var box  bxSL      = na
var label lblEntry = na
var label lblTP    = na
var label lblSL    = na
var label lblLiq   = na
var label lblBE    = na
var label lblLive  = na
var label lblMFE   = na
var label lblMAE   = na

if barstate.islast
    line.delete(lEntry), line.delete(lEntryV), line.delete(lTP), line.delete(lSL), line.delete(lLiq), line.delete(lBE), line.delete(lMFE), line.delete(lMAE), line.delete(lLiveLead)
    box.delete(bxTP),    box.delete(bxSL)
    label.delete(lblEntry), label.delete(lblTP), label.delete(lblSL), label.delete(lblLiq), label.delete(lblBE), label.delete(lblLive), label.delete(lblMFE), label.delete(lblMAE)

    // Anchor lines from entry candle to extendBars past current; fall back if entry not yet visible
    xLeft  = not na(entryBarIdx) ? entryBarIdx : bar_index - 50
    xRight = bar_index + extendBars
    xLabel = xRight + labelOffset

    // Vertical entry marker
    if not na(entryBarIdx)
        topY    = math.max(math.max(entryPx, tpPx), math.max(slPx, liqPx))
        botY    = math.min(math.min(entryPx, tpPx), math.min(slPx, liqPx))
        lEntryV := line.new(entryBarIdx, botY, entryBarIdx, topY, color=color.new(cEntry, 40), width=1, style=line.style_dashed)

    // Entry line
    lEntry := line.new(xLeft, entryPx, xRight, entryPx, color=cEntry, width=lineWidth, style=line.style_solid)
    lblEntry := label.new(xLabel, entryPx, "ENTRY  " + str.tostring(entryPx, format.mintick), style=label.style_label_left, textcolor=cLabelText, color=cEntry, size=size.small)

    // TP line + zone
    if not na(tpPx) and tpPx > 0
        lTP := line.new(xLeft, tpPx, xRight, tpPx, color=cTP, width=lineWidth, style=line.style_solid)
        tpHitTxt = tpReached ? "  ✓" : ""
        lblTP := label.new(xLabel, tpPx, "TP  " + str.tostring(tpPx, format.mintick) + "  +" + str.tostring(rMult, "#.##") + "R  +$" + str.tostring(pnlTPnet, "#.##") + "  +" + str.tostring(pctTP, "#.##") + "%" + tpHitTxt, style=label.style_label_left, textcolor=cLabelText, color=cTP, size=size.small)
        if showZones
            bxTP := box.new(xLeft, tpPx, xRight, entryPx, bgcolor=color.new(cTP, zoneFill), border_color=color.new(cTP, 100))

    // SL line + zone
    if not na(slPx) and slPx > 0
        lSL := line.new(xLeft, slPx, xRight, slPx, color=cSL, width=lineWidth, style=line.style_solid)
        slHitTxt = slReached ? "  ✗" : ""
        lblSL := label.new(xLabel, slPx, "SL  " + str.tostring(slPx, format.mintick) + "  -1R  -$" + str.tostring(math.abs(pnlSLnet), "#.##") + "  " + str.tostring(pctSL, "#.##") + "%" + slHitTxt, style=label.style_label_left, textcolor=cLabelText, color=cSL, size=size.small)
        if showZones
            bxSL := box.new(xLeft, slPx, xRight, entryPx, bgcolor=color.new(cSL, zoneFill), border_color=color.new(cSL, 100))

    // Liquidation line
    if showLiq
        lLiq := line.new(xLeft, liqPx, xRight, liqPx, color=cLiq, width=lineWidth, style=line.style_dashed)
        liqWarn = slPastLiq ? "  ⚠ SL PAST LIQ" : ""
        lblLiq := label.new(xLabel, liqPx, "LIQ  " + str.tostring(liqPx, format.mintick) + "  (" + str.tostring(distLiqPct, "#.##") + "% away)" + liqWarn, style=label.style_label_left, textcolor=cLabelText, color=cLiq, size=size.small)

    // Breakeven line — position depends on user setting
    if showBE
        if bePos == "Centered"
            lBE := line.new(xLeft, bePx, xRight, bePx, color=cBE, width=1, style=line.style_dotted)
            beCenterX = math.round((xLeft + bar_index) / 2)
            lblBE := label.new(beCenterX, bePx, "BE  " + str.tostring(bePx, format.mintick), style=label.style_label_center, textcolor=cLabelText, color=cBE, size=size.small)
        else
            lBE := line.new(xLeft, bePx, xRight + secondaryStag, bePx, color=cBE, width=1, style=line.style_dotted)
            lblBE := label.new(xLabel + secondaryStag, bePx, "BE  " + str.tostring(bePx, format.mintick), style=label.style_label_left, textcolor=cLabelText, color=cBE, size=size.small)

    // Best / Worst markers (secondary column)
    if not na(mfePx) and not na(maePx) and inTrade
        lMFE := line.new(xLeft, mfePx, xRight + secondaryStag, mfePx, color=color.new(cTP, 50), width=1, style=line.style_dotted)
        lblMFE := label.new(xLabel + secondaryStag, mfePx, "BEST  " + (mfePnl >= 0 ? "+$" : "-$") + str.tostring(math.abs(mfePnl), "#,##0.00"), style=label.style_label_left, textcolor=cLabelText, color=color.new(cTP, 20), size=size.small)

        lMAE := line.new(xLeft, maePx, xRight + secondaryStag, maePx, color=color.new(cSL, 50), width=1, style=line.style_dotted)
        lblMAE := label.new(xLabel + secondaryStag, maePx, "WORST  " + (maePnl >= 0 ? "+$" : "-$") + str.tostring(math.abs(maePnl), "#,##0.00"), style=label.style_label_left, textcolor=cLabelText, color=color.new(cSL, 20), size=size.small)

    // Live PnL label (middle column between primary and secondary)
    liveBaseColor = cLiveAuto ? (pnlLiveNet >= 0 ? cTP : cSL) : (pnlLiveNet >= 0 ? cLiveBgProfit : cLiveBgLoss)

    pulseAlpha    = math.round(20 + 20 * math.sin(bar_index * 0.785))
    liveBgColor   = cLiveStyle == "Pulsing" ? color.new(liveBaseColor, pulseAlpha) : liveBaseColor
    liveLeadColor = liveBaseColor

    liveLabelSize = cLiveSize == "Tiny" ? size.tiny : cLiveSize == "Small" ? size.small : cLiveSize == "Normal" ? size.normal : cLiveSize == "Large" ? size.large : size.huge

    liveTxt = (pnlLiveNet >= 0 ? "+$" : "-$") + str.tostring(math.abs(pnlLiveNet), "#,##0.00") + "  (" + str.tostring(pctLive, "+#.##;-#.##") + "%)"

    liveLabelX  = xLabel + math.round(secondaryStag / 2)
    liveLineEnd = xRight + math.round(secondaryStag / 2)

    // Suppress label if current price is within ~0.3% of any other level (panel still shows the value)
    collisionThresh = curPx * 0.003
    nearTP    = not na(tpPx)    and tpPx > 0    and math.abs(curPx - tpPx)    < collisionThresh
    nearSL    = not na(slPx)    and slPx > 0    and math.abs(curPx - slPx)    < collisionThresh
    nearEntry = not na(entryPx) and entryPx > 0 and math.abs(curPx - entryPx) < collisionThresh
    nearBE    = showBE and not na(bePx) and math.abs(curPx - bePx) < collisionThresh
    nearBest  = not na(mfePx) and math.abs(curPx - mfePx) < collisionThresh
    nearWorst = not na(maePx) and math.abs(curPx - maePx) < collisionThresh
    liveOverlapping = nearTP or nearSL or nearEntry or nearBE or nearBest or nearWorst

    lLiveLead := line.new(bar_index, curPx, liveLineEnd, curPx, color=color.new(liveLeadColor, 60), width=1, style=line.style_dotted)
    if not liveOverlapping
        lblLive := label.new(liveLabelX, curPx, liveTxt, style=label.style_label_left, textcolor=cLiveText, color=liveBgColor, size=liveLabelSize)

// ═══════════════════════════════════════════════════════════════════
// INFO PANEL
// ═══════════════════════════════════════════════════════════════════

panelPosition(p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Middle Right" => position.middle_right
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

panelTextSize(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.normal

var table panel = na

if showPanel and barstate.islast
    table.delete(panel)

    // Theme resolution
    bgDark    = panelTheme == "Dark"   ? color.new(#0a0e14, 5)  : panelTheme == "Light" ? color.new(#fafafa, 5)  : cPnlBg
    bgRow     = panelTheme == "Dark"   ? color.new(#11161e, 5)  : panelTheme == "Light" ? color.new(#f0f0f0, 5)  : cPnlRow
    bgHeader  = panelTheme == "Dark"   ? color.new(#161b25, 0)  : panelTheme == "Light" ? color.new(#e8e8e8, 0)  : cPnlHeader
    bgAccent  = panelTheme == "Dark"   ? color.new(#1a2030, 0)  : panelTheme == "Light" ? color.new(#e6ecf2, 0)  : cPnlAccent
    txtMuted  = panelTheme == "Dark"   ? #6e7681                : panelTheme == "Light" ? #57606a                : cPnlTxtMuted
    txtBright = panelTheme == "Dark"   ? #e6edf3                : panelTheme == "Light" ? #1f2328                : cPnlTxtBright
    borderClr = panelTheme == "Dark"   ? color.new(#21262d, 30) : panelTheme == "Light" ? color.new(#d0d7de, 30) : cPnlBorder

    panel := table.new(panelPosition(panelPos), 2, 17, bgcolor=bgDark, border_width=0, frame_color=borderClr, frame_width=1)
    txtSize = panelTextSize(panelSize)

    sideAccent = isLong ? cPnlGreen : cPnlRed

    // Header
    table.cell(panel, 0, 0, "  " + (isLong ? "▲ LONG" : "▼ SHORT") + "  ", text_color=sideAccent, bgcolor=bgHeader, text_size=txtSize)
    table.cell(panel, 1, 0, "  " + str.tostring(leverage, "#.#") + "x  ", text_color=txtBright, bgcolor=bgHeader, text_size=txtSize)

    // Position group
    table.cell(panel, 0, 1, " Capital ",  text_color=txtMuted, bgcolor=bgDark, text_size=txtSize)
    table.cell(panel, 1, 1, " $" + str.tostring(capital, "#,###.##") + " ", text_color=txtBright, bgcolor=bgDark, text_size=txtSize)

    table.cell(panel, 0, 2, " Notional ", text_color=txtMuted, bgcolor=bgRow, text_size=txtSize)
    table.cell(panel, 1, 2, " $" + str.tostring(notional, "#,###.##") + " ", text_color=txtBright, bgcolor=bgRow, text_size=txtSize)

    table.cell(panel, 0, 3, " Quantity ", text_color=txtMuted, bgcolor=bgDark, text_size=txtSize)
    table.cell(panel, 1, 3, " " + str.tostring(qty, "#,###.####") + " ", text_color=txtBright, bgcolor=bgDark, text_size=txtSize)

    table.cell(panel, 0, 4, " Maint. Margin ", text_color=txtMuted, bgcolor=bgRow, text_size=txtSize)
    table.cell(panel, 1, 4, " " + str.tostring(mmr, "#.##") + "%  ⚙ ", text_color=txtBright, bgcolor=bgRow, text_size=txtSize)

    table.cell(panel, 0, 5, " Fee/Side ", text_color=txtMuted, bgcolor=bgDark, text_size=txtSize)
    table.cell(panel, 1, 5, " " + str.tostring(feeRate, "#.###") + "%  ⚙ ", text_color=txtBright, bgcolor=bgDark, text_size=txtSize)

    // PnL group
    livePnlColor = pnlLiveNet >= 0 ? cPnlGreen : cPnlRed
    table.cell(panel, 0, 6, " ▎ Live P&L ", text_color=livePnlColor, bgcolor=bgAccent, text_size=txtSize)
    table.cell(panel, 1, 6, " " + (pnlLiveNet >= 0 ? "+$" : "-$") + str.tostring(math.abs(pnlLiveNet), "#,##0.00") + "  (" + str.tostring(pctLive, "+#.##;-#.##") + "%) ", text_color=livePnlColor, bgcolor=bgAccent, text_size=txtSize)

    table.cell(panel, 0, 7, " If TP Hit ", text_color=txtMuted, bgcolor=bgAccent, text_size=txtSize)
    table.cell(panel, 1, 7, " +$" + str.tostring(pnlTPnet, "#,##0.00") + "  (+" + str.tostring(pctTP, "#.##") + "%) ", text_color=cPnlGreen, bgcolor=bgAccent, text_size=txtSize)

    table.cell(panel, 0, 8, " If SL Hit ", text_color=txtMuted, bgcolor=bgAccent, text_size=txtSize)
    table.cell(panel, 1, 8, " -$" + str.tostring(math.abs(pnlSLnet), "#,##0.00") + "  (" + str.tostring(pctSL, "#.##") + "%) ", text_color=cPnlRed, bgcolor=bgAccent, text_size=txtSize)

    rColor = rMult >= 2.0 ? cPnlGreen : rMult >= 1.0 ? cBE : cPnlRed
    table.cell(panel, 0, 9, " ▎ Risk:Reward ", text_color=rColor, bgcolor=bgAccent, text_size=txtSize)
    table.cell(panel, 1, 9, " 1 : " + str.tostring(rMult, "#.##") + " ", text_color=rColor, bgcolor=bgAccent, text_size=txtSize)

    // Liquidation group
    liqColor = distLiqPct < 2.0 ? cPnlRed : distLiqPct < 5.0 ? cBE : cPnlGreen
    table.cell(panel, 0, 10, " Liq Price ",  text_color=txtMuted, bgcolor=bgDark, text_size=txtSize)
    table.cell(panel, 1, 10, " " + str.tostring(liqPx, format.mintick) + " ", text_color=cPnlRed, bgcolor=bgDark, text_size=txtSize)

    table.cell(panel, 0, 11, " ▎ Distance to Liq ", text_color=liqColor, bgcolor=bgRow, text_size=txtSize)
    table.cell(panel, 1, 11, " " + str.tostring(distLiqPct, "#.##") + "% ", text_color=liqColor, bgcolor=bgRow, text_size=txtSize)

    table.cell(panel, 0, 12, " Round Trip Fees ", text_color=txtMuted, bgcolor=bgDark, text_size=txtSize)
    table.cell(panel, 1, 12, " ~$" + str.tostring(entryFee * 2, "#,##0.00") + " ", text_color=txtBright, bgcolor=bgDark, text_size=txtSize)

    // Trade history
    table.cell(panel, 0, 13, " Bars in Trade ", text_color=txtMuted, bgcolor=bgRow, text_size=txtSize)
    table.cell(panel, 1, 13, " " + (inTrade ? str.tostring(barsInTrade) : "—") + " ", text_color=txtBright, bgcolor=bgRow, text_size=txtSize)

    bestStr = inTrade and not na(mfePnl) ? (mfePnl >= 0 ? "+$" : "-$") + str.tostring(math.abs(mfePnl), "#,##0.00") + " (" + str.tostring(mfePct, "+#.##;-#.##") + "%)" : "—"
    table.cell(panel, 0, 14, " ▎ Best Point ", text_color=cPnlGreen, bgcolor=bgDark, text_size=txtSize)
    table.cell(panel, 1, 14, " " + bestStr + " ", text_color=cPnlGreen, bgcolor=bgDark, text_size=txtSize)

    worstStr = inTrade and not na(maePnl) ? (maePnl >= 0 ? "+$" : "-$") + str.tostring(math.abs(maePnl), "#,##0.00") + " (" + str.tostring(maePct, "+#.##;-#.##") + "%)" : "—"
    table.cell(panel, 0, 15, " ▎ Worst Point ", text_color=cPnlRed, bgcolor=bgRow, text_size=txtSize)
    table.cell(panel, 1, 15, " " + worstStr + " ", text_color=cPnlRed, bgcolor=bgRow, text_size=txtSize)

    // Status row
    warnText = ""
    warnColor = bgDark
    warnTextColor = txtBright
    if slPastLiq
        warnText := " ⚠  SL PAST LIQUIDATION "
        warnColor := cPnlRed
        warnTextColor := color.white
    else if tpWrongSide or slWrongSide
        warnText := " ⚠  TP/SL WRONG SIDE "
        warnColor := cPnlRed
        warnTextColor := color.white
    else if not inTrade
        warnText := " ◌  PENDING ENTRY "
        warnColor := color.new(#30363d, 0)
        warnTextColor := txtBright
    else if liqReached
        warnText := " ✗  LIQUIDATED "
        warnColor := cPnlRed
        warnTextColor := color.white
    else if tpReached
        warnText := " ✓  TARGET HIT "
        warnColor := cPnlGreen
        warnTextColor := color.white
    else if slReached
        warnText := " ✗  STOP HIT "
        warnColor := cPnlRed
        warnTextColor := color.white
    else
        warnText := " ●  POSITION ACTIVE "
        warnColor := color.new(cPnlGreen, 70)
        warnTextColor := cPnlGreen

    table.cell(panel, 0, 16, warnText, text_color=warnTextColor, bgcolor=warnColor, text_size=txtSize)
    table.cell(panel, 1, 16, " ", text_color=warnTextColor, bgcolor=warnColor, text_size=txtSize)

// ═══════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════

alertcondition(ta.cross(close, tpPx),  "TP Hit",  "Price reached Take Profit")
alertcondition(ta.cross(close, slPx),  "SL Hit",  "Price reached Stop Loss")
alertcondition(ta.cross(close, liqPx), "Liq Hit", "Price reached Liquidation — position liquidated")
alertcondition(ta.cross(close, bePx),  "Breakeven", "Price reached Breakeven")
````
