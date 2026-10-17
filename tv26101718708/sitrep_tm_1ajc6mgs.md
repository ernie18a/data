# SITREP TM

- url: https://www.tradingview.com/script/1ajC6Mgs-SITREP-TM/
- type: indicator
- pine_id: PUB;b3ccb37ee2a04fc994935d92bc68eb6d
- version: 1.0

## Description

SITREP Trade Manager
A clean 13/48/200 EMA fan that surfaces trend regime and direction at a glance.
The cloud between the 13 and 48 carries the read: green when bullish (13 > 48), red when bearish, and richest/most solid when fully stacked (13 > 48 > 200, "mega" trend). When the fan compresses, the cloud drains toward gray and fades — your chop tell. When it expands, the color solidifies — trend participation. The 200 line turns green or red when both the 13 and 48 are above or below it, confirming alignment with the anchor.
Flip arrows (▲/▼) mark each 13×48 cross — the structural direction change — with an optional alert.
Designed to pair with SITREP Key Levels: the levels tell you where, the fan tells you what regime you're in.

## Source Code

````pine
//@version=6
indicator("SITREP Trade Manager", shorttitle="SITREP·TM", overlay=true,
     max_lines_count=10, max_labels_count=100, max_boxes_count=5)

// ============================================================================
// SITREP TRADE MANAGER v4
// Rebuilt from v3:
//   — EMAs reduced to 13 / 48 / 200 (9 and 21 removed)
//   — Flip arrows now trigger on 13×48 cross (was 9×13)
//   — Exit logic removed entirely (no exit candle, no EXIT label, no exit alert,
//     no 13/48 proximity active-line, no fuschia pre-exit)
//   — Cloud kept, now fills 13–48
//   — 5-state model: mega-bull (13>48>200) / bull (13>48) / mixed /
//     bear (13<48) / mega-bear (13<48<200)
//   — Cloud color = direction; saturation = mega vs plain; expansion vs
//     compression modulates opacity + desaturation (chop tell)
//   — Line brightness driven by fan spread (expanding = brighter)
//   — 200 colored by whether 13 & 48 are both above / below it
//   — Alert on 13×48 flip
// ============================================================================

// ============================================================================
// INPUTS — EMA FAN
// ============================================================================
grp_ema = "EMA Fan"
i_showFan      = input.bool(true, "Show EMA Fan (13/48/200)", group=grp_ema)
i_spreadThresh = input.float(0.15, "Full Spread Threshold (% of price)",
     minval=0.05, maxval=1.0, step=0.05, group=grp_ema,
     tooltip="When EMA13–EMA48 spread exceeds this % of price the fan is at full brightness.")

// ============================================================================
// INPUTS — CLOUD
// ============================================================================
grp_cloud    = "Fan Cloud (13–48)"
i_showCloud  = input.bool(true, "Show Cloud", group=grp_cloud)
i_cloudOpMin = input.int(90, "Min Opacity (plain / compressing)",
     minval=50, maxval=99, group=grp_cloud,
     tooltip="Cloud opacity when direction only (not mega) and/or compressing. Higher = more transparent.")
i_cloudOpMax = input.int(55, "Max Opacity (mega + expanding)",
     minval=0,  maxval=75, group=grp_cloud,
     tooltip="Cloud opacity when fully stacked (13>48>200) and expanding. Lower = more solid.")

// ============================================================================
// INPUTS — COLORS
// ============================================================================
grp_col      = "Colors"
i_colBull    = input.color(#00E676, "Bull",            group=grp_col)
i_colBear    = input.color(#FF1744, "Bear",            group=grp_col)
i_colMixed   = input.color(#90A4AE, "Mixed / unknown", group=grp_col)

// ============================================================================
// INPUTS — ALERTS
// ============================================================================
grp_alerts = "Alerts"
alrt_flip  = input.bool(true, "Alert: 13×48 flip", group=grp_alerts)

// ============================================================================
// EMA VALUES
// ============================================================================
ema13  = ta.ema(close, 13)
ema48  = ta.ema(close, 48)
ema200 = ta.ema(close, 200)

// ============================================================================
// FAN DIRECTION — persistent, latches on 13×48 crossover
// ============================================================================
ema13x48Bull = ta.crossover(ema13,  ema48)
ema13x48Bear = ta.crossunder(ema13, ema48)

var int fanDir = 0   // 1=bull  -1=bear  0=unknown
if ema13x48Bull
    fanDir := 1
if ema13x48Bear
    fanDir := -1

// ============================================================================
// STATE MODEL — mega vs plain (200 alignment is the intensity boost)
//   mega-bull : 13 > 48 > 200
//   bull      : 13 > 48 (but not full stack)
//   mixed     : direction unknown
//   bear      : 13 < 48
//   mega-bear : 13 < 48 < 200
// ============================================================================
isMegaBull = ema13 > ema48 and ema48 > ema200
isMegaBear = ema13 < ema48 and ema48 < ema200
isMega     = (fanDir == 1 and isMegaBull) or (fanDir == -1 and isMegaBear)

// stackLevel: 0 = mixed, 1 = plain direction, 2 = mega
stackLevel = fanDir == 0 ? 0 : (isMega ? 2 : 1)

// ============================================================================
// FAN SPREAD — expansion vs compression (drives line brightness + cloud)
// ============================================================================
fanSpread      = math.abs(ema13 - ema48) / close * 100
fanSpreadPrev  = math.abs(ema13[1] - ema48[1]) / close[1] * 100
fanExpanding   = fanSpread > fanSpreadPrev
fanCompressing = fanSpread < fanSpreadPrev
spreadNorm     = math.min(1.0, fanSpread / i_spreadThresh)

// Line opacity: brighter (lower opacity) when spread is wide; expanding gets a
// brightness edge over compressing.
baseOpacity = fanExpanding ? math.round((1.0 - spreadNorm) * 25) : math.round((1.0 - spreadNorm) * 55)
baseOpacity := math.max(0, math.min(55, baseOpacity))

// ============================================================================
// COLORS
// ============================================================================
fanBase = fanDir == 1 ? i_colBull : fanDir == -1 ? i_colBear : i_colMixed

// --- Cloud color: direction hue, with mega = richer and compression = drained
cloudHue = stackLevel == 0 ? i_colMixed : fanBase

// Opacity from two factors:
//   mega (stackLevel 2) pushes toward solid (i_cloudOpMax)
//   plain (stackLevel 1) sits mid
//   compressing adds transparency (drains the cloud → chop tell)
stackOp = stackLevel == 2 ? i_cloudOpMax : stackLevel == 1 ? math.round((i_cloudOpMin + i_cloudOpMax) / 2) : i_cloudOpMin
compPenalty = fanCompressing ? 12 : 0
cloudOpacity = math.min(99, stackOp + compPenalty)

// Slight desaturation toward gray when compressing (color "drains" in chop):
// blend the direction hue 35% toward the mixed/gray color.
cloudColFull = color.new(cloudHue, cloudOpacity)
cloudColComp = color.new(color.from_gradient(35.0, 0.0, 100.0, cloudHue, i_colMixed), cloudOpacity)
cloudCol = fanCompressing ? cloudColComp : cloudColFull

// --- Line colors (13 and 48 share direction hue + spread brightness)
col13 = not i_showFan ? na : color.new(fanBase, math.max(0, baseOpacity))
col48 = not i_showFan ? na : color.new(fanBase, math.max(10, baseOpacity + 20))

// --- 200 colored by whether BOTH 13 and 48 are above / below it
above200 = ema13 > ema200 and ema48 > ema200
below200 = ema13 < ema200 and ema48 < ema200
col200 = not i_showFan ? na : above200 ? color.new(#00E676, 45) : below200 ? color.new(#FF1744, 45) : color.new(#90A4AE, 60)

// ============================================================================
// EMA PLOTS
// ============================================================================
p13 = plot(ema13,  "EMA 13",  color=col13,  linewidth=2)
p48 = plot(ema48,  "EMA 48",  color=col48,  linewidth=2)
plot(ema200, "EMA 200", color=col200, linewidth=3)

// ============================================================================
// CLOUD — fill between EMA 13 and EMA 48
// ============================================================================
fill(p13, p48,
     color = i_showCloud and i_showFan ? cloudCol : na,
     title = "Fan Cloud (13–48)")

// ============================================================================
// FLIP ARROWS — on 13×48 crossover (direction change marker)
// ============================================================================
atr14 = ta.atr(14)

if ema13x48Bull
    label.new(bar_index, low - atr14 * 0.5, "▲",
         xloc=xloc.bar_index, yloc=yloc.price,
         style=label.style_label_up,
         color=color.new(i_colBull, 0),
         textcolor=color.white,
         size=size.small)

if ema13x48Bear
    label.new(bar_index, high + atr14 * 0.5, "▼",
         xloc=xloc.bar_index, yloc=yloc.price,
         style=label.style_label_down,
         color=color.new(i_colBear, 0),
         textcolor=color.white,
         size=size.small)

// ============================================================================
// ALERT — 13×48 flip
// ============================================================================
if alrt_flip and ema13x48Bull
    alert("SITREP TM: BULL FLIP — 13 crossed above 48", alert.freq_once_per_bar_close)
if alrt_flip and ema13x48Bear
    alert("SITREP TM: BEAR FLIP — 13 crossed below 48", alert.freq_once_per_bar_close)

// ============================================================================
// END — SITREP TRADE MANAGER v4
// ============================================================================// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
````
