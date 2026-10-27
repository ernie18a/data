# GuardRail MA Signal

- url: https://www.tradingview.com/script/t5SmwbMq-GuardRail-MA-Signal/
- type: indicator
- pine_id: PUB;66ff325d01e043cd9e401ad3cdc41d78
- version: 1.0

## Description

GuardRail MA Signal is a streamlined trend-following overlay that displays a timeframe-locked moving average with dynamic color coding to indicate the current market regime at a glance.
How it works
The indicator plots your chosen moving average — SMA or EMA, any length — locked to a specific timeframe regardless of what chart interval you're viewing. A 200-day SMA stays a 200-day SMA whether your chart is set to daily, weekly, or monthly bars. No repainting, no surprises.
The MA line changes color automatically based on where price closes relative to it:

🟢 Green — Risk ON: price is at or above the MA
🔴 Red — Risk OFF: price is below the MA

Features

Timeframe-locked MA (daily, weekly, monthly, or intraday) — consistent signal across all chart views
SMA or EMA with fully adjustable length, source, width, and color
Up to 3 additional moving averages, each independently configurable with its own type, length, source, timeframe, and color
HUD overlay displaying the current regime signal, ticker, MA specification, and percentage distance from the MA — available in compact or expanded layout with adjustable size, corner placement, and dynamic color matching

Designed for
Trend-following strategies that use a long-term moving average as a risk-on/risk-off signal — particularly useful for systematic investors who switch between different chart timeframes and need the signal to remain stable and consistent.

## Source Code

````pine
//@version=5
indicator("GuardRail MA Signal", overlay=true)

// ═══════════════════════════════════════════
//  STRATEGY MA (MAIN SIGNAL LINE)
// ═══════════════════════════════════════════

maLen       = input.int(200, "MA Length", minval=1, group="Strategy MA")
maType      = input.string("SMA", "MA Type", options=["SMA", "EMA"], group="Strategy MA")
maTF        = input.string("D", "MA Timeframe", options=["60", "240", "D", "W", "M"], group="Strategy MA",
               tooltip="Timeframe is locked here — switching your chart to weekly/monthly will NOT change the MA period. A 200D SMA stays a 200D SMA.")
maSource    = input.source(close, "MA Source", group="Strategy MA")
maWidth     = input.int(2, "MA Line Width", minval=1, maxval=5, group="Strategy MA")

colorBull   = input.color(color.new(#00e676, 0), "Risk ON Color (above MA)", group="Strategy MA")
colorBear   = input.color(color.new(#ff1744, 0), "Risk OFF Color (below MA)", group="Strategy MA")

// ═══════════════════════════════════════════
//  HUD
// ═══════════════════════════════════════════

showHUD         = input.bool(true, "Show HUD", group="HUD")
hudCorner       = input.string("Bottom Right", "HUD Corner", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="HUD")
hudTextSize     = input.string("normal", "HUD Text Size", options=["tiny", "small", "normal", "large"], group="HUD")
hudCompact      = input.bool(true, "Compact Mode", group="HUD")
hudOpacity      = input.int(20, "Background Opacity (0–100)", minval=0, maxval=100, group="HUD")
hudDynamicColor = input.bool(true, "Dynamic Color (match regime)", group="HUD")
hudStaticColor  = input.color(color.new(color.white, 0), "Static Color (if dynamic off)", group="HUD")

// ═══════════════════════════════════════════
//  EXTRA MOVING AVERAGES
// ═══════════════════════════════════════════

showExtraMA = input.bool(false, "Show Additional MAs", group="Extra MAs")

// MA 1
ma1_on    = input.bool(false, "Show MA 1", group="Extra MAs")
ma1_type  = input.string("SMA", "MA 1 Type", options=["SMA", "EMA"], group="Extra MAs")
ma1_len   = input.int(50, "MA 1 Length", group="Extra MAs")
ma1_src   = input.source(close, "MA 1 Source", group="Extra MAs")
ma1_tf    = input.string("D", "MA 1 Timeframe", options=["60", "240", "D", "W", "M"], group="Extra MAs")
ma1_color = input.color(color.new(#2196f3, 0), "MA 1 Color", group="Extra MAs")
ma1_width = input.int(1, "MA 1 Width", minval=1, maxval=5, group="Extra MAs")

// MA 2
ma2_on    = input.bool(false, "Show MA 2", group="Extra MAs")
ma2_type  = input.string("SMA", "MA 2 Type", options=["SMA", "EMA"], group="Extra MAs")
ma2_len   = input.int(100, "MA 2 Length", group="Extra MAs")
ma2_src   = input.source(close, "MA 2 Source", group="Extra MAs")
ma2_tf    = input.string("D", "MA 2 Timeframe", options=["60", "240", "D", "W", "M"], group="Extra MAs")
ma2_color = input.color(color.new(#ff9800, 0), "MA 2 Color", group="Extra MAs")
ma2_width = input.int(1, "MA 2 Width", minval=1, maxval=5, group="Extra MAs")

// MA 3
ma3_on    = input.bool(false, "Show MA 3", group="Extra MAs")
ma3_type  = input.string("EMA", "MA 3 Type", options=["SMA", "EMA"], group="Extra MAs")
ma3_len   = input.int(20, "MA 3 Length", group="Extra MAs")
ma3_src   = input.source(close, "MA 3 Source", group="Extra MAs")
ma3_tf    = input.string("D", "MA 3 Timeframe", options=["60", "240", "D", "W", "M"], group="Extra MAs")
ma3_color = input.color(color.new(#9c27b0, 0), "MA 3 Color", group="Extra MAs")
ma3_width = input.int(1, "MA 3 Width", minval=1, maxval=5, group="Extra MAs")

// ═══════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════

f_ma(_s, _len, _type) =>
    _type == "SMA" ? ta.sma(_s, _len) : ta.ema(_s, _len)

f_pos(sel) =>
    sel == "Top Left"     ? position.top_left  :
     sel == "Top Right"   ? position.top_right :
     sel == "Bottom Left" ? position.bottom_left : position.bottom_right

f_size(sel) =>
    sel == "tiny"   ? size.tiny  :
     sel == "small" ? size.small :
     sel == "large" ? size.large : size.normal

// ═══════════════════════════════════════════
//  STRATEGY MA — locked to chosen timeframe
// ═══════════════════════════════════════════

// Pull both close and MA value from the locked timeframe
tfClose = request.security(syminfo.tickerid, maTF, close)
tfMA    = request.security(syminfo.tickerid, maTF, f_ma(maSource, maLen, maType))

isBull = tfClose >= tfMA
isBear = not isBull

maLineColor = isBull ? colorBull : colorBear

plot(tfMA, "Strategy MA", color=maLineColor, linewidth=maWidth)

// ═══════════════════════════════════════════
//  EXTRA MAs — each locked to their own TF
// ═══════════════════════════════════════════

f_extra(_on, _tf, _src, _len, _type) =>
    showExtraMA and _on ? request.security(syminfo.tickerid, _tf, f_ma(_src, _len, _type)) : na

ma1val = f_extra(ma1_on, ma1_tf, ma1_src, ma1_len, ma1_type)
ma2val = f_extra(ma2_on, ma2_tf, ma2_src, ma2_len, ma2_type)
ma3val = f_extra(ma3_on, ma3_tf, ma3_src, ma3_len, ma3_type)

plot(ma1val, "MA 1", color=ma1_color, linewidth=ma1_width)
plot(ma2val, "MA 2", color=ma2_color, linewidth=ma2_width)
plot(ma3val, "MA 3", color=ma3_color, linewidth=ma3_width)

// ═══════════════════════════════════════════
//  HUD
// ═══════════════════════════════════════════

var table hud = na

if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)

    pos   = f_pos(hudCorner)
    tsize = f_size(hudTextSize)

    regimeTxt = isBull ? "▲  Risk ON" : "▼  Risk OFF"
    distPct   = (tfClose - tfMA) / tfMA * 100
    distStr   = (distPct >= 0 ? "+" : "") + str.tostring(distPct, "#.##") + "%"

    bgColor = hudDynamicColor
         ? (isBull ? color.new(colorBull, hudOpacity) : color.new(colorBear, hudOpacity))
         : color.new(hudStaticColor, hudOpacity)
    txtColor = color.white

    if hudCompact
        hud := table.new(pos, 1, 1, border_color=color.new(color.white, 60), border_width=1)
        label1 = regimeTxt + "   " + syminfo.ticker + "  " + maType + str.tostring(maLen) + "(" + maTF + ")  " + distStr
        table.cell(hud, 0, 0, label1, text_color=txtColor, bgcolor=bgColor, text_size=tsize)
    else
        hud := table.new(pos, 1, 3, border_color=color.new(color.white, 60), border_width=1)
        table.cell(hud, 0, 0, regimeTxt, text_color=txtColor, bgcolor=bgColor, text_size=tsize)
        table.cell(hud, 0, 1, syminfo.ticker + "  •  " + maType + str.tostring(maLen) + " (" + maTF + ")", text_color=txtColor, bgcolor=bgColor, text_size=tsize)
        table.cell(hud, 0, 2, "Distance from MA: " + distStr, text_color=txtColor, bgcolor=bgColor, text_size=tsize)
````
