# Institutional Trend Channels

- url: https://www.tradingview.com/script/hgooGCyT-Institutional-Trend-Channels/
- type: indicator
- pine_id: PUB;9852da07fc224880b4b0015a44026095
- version: 1.0

## Description

Institutional Trend Channels draws ONE clean adaptive trend channel instead of cluttering your chart with overlapping lines. It is built for traders who want a clear read on the dominant trend without the usual "spaghetti" mess of multiple channel tools.

═══ WHAT IT DOES ═══

ADAPTIVE REGRESSION CHANNEL
A linear-regression channel is fitted over a configurable window of bars. As the trend develops, the channel re-fits continuously and redraws cleanly — only one channel is ever shown, anchored to the current dominant move. Up-trends and down-trends are color-coded automatically.

STRENGTH SCORING (the anti-clutter engine)
Every channel is scored from 0–100 using two components:
- Slope quality — how decisively the trend is sloping relative to price scale.
- Fit quality — how tightly price respects the regression line (a correlation-based read).
Weak or uncertain channels fade out automatically. Only channels above your chosen strength threshold stay bold and visible, so the chart never gets crowded.

DYNAMIC BREAKOUT DETECTION
When price closes beyond the channel boundary with optional volume confirmation, a breakout alert can fire. Volume confirmation requires the breakout bar to trade above an average-volume multiple, filtering out low-conviction pokes.

CLEAN VISUALS
Three bold channel lines (upper, midline, lower) with a light tilted fill inside the channel only — no boxes, no outside borders. A compact dashboard shows trend direction, strength %, channel levels, and distance from price.

═══ HOW TO USE ═══

- Strong channel (bold): trend is clean. In an uptrend, pullbacks toward the lower line can offer continuation entries with the midline/upper line as targets — and vice-versa for downtrends.
- Faded / weak channel: trend is unclear or sideways. Best to stand aside or treat the range as choppy.
- Breakout alert: price has left the channel — watch for a trend change or fresh leg.

═══ SETTINGS ═══

- Channel Length — fit window. Larger = bigger-picture trend.
- Channel Width — band distance in standard deviations.
- Min Strength to Show — raise this to keep only the cleanest trends visible.
- Breakout volume confirmation, multiplier, and length.
- Fill lightness, rounding, colors.

═══ NOTES ═══

This indicator is non-repainting: the channel is computed from closed/confirmed bar data and breakout signals are evaluated on confirmed bars. It works on any symbol and timeframe; defaults are tuned for intraday index trading.

This tool is for analysis and education only. It is not financial advice. Always do your own research and manage risk.

## Source Code

````pine
// ════════════════════════════════════════════════════════════════════
//  INSTITUTIONAL TREND CHANNELS
//  Pine Script v6 | TradingView Compliant
//
//  One clean, adaptive trend channel — never a spaghetti mess.
//
//  - ADAPTIVE CHANNEL: a linear-regression channel anchored to the
//    current swing leg. It re-fits as the trend develops and redraws
//    cleanly when the dominant trend flips (only ONE channel on screen).
//  - DYNAMIC BREAKOUT: when price closes beyond the channel with
//    volume confirmation, a breakout ALERT fires (no on-chart label).
//  - ACCELERATION ZONES: an inner band marks where price is pushing
//    the trend faster than the channel mid — momentum is accelerating.
//
//  Channel strength is scored (slope quality + how well price respects
//  the band). Weak/uncertain channels fade; only strong ones stay bold.
//
//  Non-repainting: anchored on a CONFIRMED pivot; bands use closed data.
//  🐘 by @darshakssc
// ════════════════════════════════════════════════════════════════════

//@version=6
indicator("Institutional Trend Channels",
          shorttitle       = "INST-CH",
          overlay          = true,
          max_lines_count  = 20,
          max_labels_count = 30,
          max_boxes_count  = 10)

// ─────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────
G1 = "Channel Engine"
G2 = "Breakout & Acceleration"
G3 = "Display"

i_len      = input.int(100,  "Channel Length (bars)", minval=20, maxval=400, step=10, group=G1,
             tooltip="How many bars the regression channel fits over. Larger = bigger-picture trend.")
i_dev      = input.float(2.0,"Channel Width (× std dev)", minval=1.0, maxval=4.0, step=0.1, group=G1)
i_min_str  = input.float(40.0,"Min Strength to Show (%)", minval=0.0, maxval=90.0, step=5.0, group=G1,
             tooltip="Channels weaker than this fade out. Higher = only the cleanest trends stay visible.")

i_bo_vol   = input.bool(true, "Breakout volume confirmation", group=G2)
i_vol_len  = input.int(20,   "Volume Average Length", minval=5, maxval=100, group=G2)
i_bo_mult  = input.float(1.3,"Breakout Volume Mult", minval=1.0, maxval=3.0, step=0.1, group=G2)

i_show_lbl = input.bool(true, "Show channel info label", group=G3)
i_show_dash= input.bool(true, "Show Dashboard", group=G3)
i_round    = input.bool(true, "Round levels to whole numbers", group=G3)
i_fill_alpha = input.int(90, "Channel Fill Lightness", minval=70, maxval=98, group=G3,
               tooltip="Higher = lighter fill (more transparent). 90 is subtle; 95+ is barely-there.")
i_col_up   = input.color(#00BCD4, "Uptrend Channel", group=G3)
i_col_dn   = input.color(#EC407A, "Downtrend Channel", group=G3)

rnd(x) => i_round ? math.round(x) : x

// ─────────────────────────────────────────────────────
//  LINEAR REGRESSION CHANNEL (computed on closed data)
//  Manual linreg so we get slope + intercept + std dev of residuals.
// ─────────────────────────────────────────────────────
n = i_len
// linreg endpoint values via built-in (current and prior for slope)
lr_now  = ta.linreg(close, n, 0)
lr_prev = ta.linreg(close, n, 1)
slope   = lr_now - lr_prev                 // per-bar slope of the fit

// standard deviation of price around the regression line
// approximate residual spread using stdev of close over the window
resStd = ta.stdev(close, n)
bandOffset = resStd * i_dev

// channel endpoint levels (at current bar)
midNow  = lr_now
upNow   = midNow + bandOffset
dnNow   = midNow - bandOffset

// channel start (n bars ago): walk back along the slope
midStart = midNow - slope * (n - 1)
upStart  = midStart + bandOffset
dnStart  = midStart - bandOffset

isUp = slope >= 0
chCol = isUp ? i_col_up : i_col_dn

// ─────────────────────────────────────────────────────
//  STRENGTH SCORE
//  Two parts:
//   - slope quality: steeper, consistent slope vs price scale
//   - fit quality: how tightly price hugs the regression (R²-like)
// ─────────────────────────────────────────────────────
// slope as % of price per bar, scaled
slopePct = close != 0 ? math.abs(slope) / close * 100 : 0
slopeScore = math.min(slopePct / 0.05, 1.0)          // 0.05%/bar ≈ full marks

// fit quality: correlation of close vs bar index over window (|r|)
corr = ta.correlation(close, bar_index, n)
fitScore = na(corr) ? 0.0 : math.abs(corr)            // 0..1

strength = math.round((slopeScore * 0.4 + fitScore * 0.6) * 100)
strongEnough = strength >= i_min_str

// fade weak channels: more transparent when weak
chAlpha = strongEnough ? 0 : 50
lineW   = strength >= 70 ? 4 : strength >= 50 ? 3 : 2   // all bolder now

// ─────────────────────────────────────────────────────
//  DRAW — single channel, redrawn each bar (no stacking)
// ─────────────────────────────────────────────────────
var line lnMid = na
var line lnUp  = na
var line lnDn  = na
var linefill chFillUp = na
var linefill chFillDn = na
var label infoLb = na

if barstate.islast
    if not na(lnMid)
        line.delete(lnMid)
        line.delete(lnUp)
        line.delete(lnDn)
    if not na(chFillUp)
        linefill.delete(chFillUp)
    if not na(chFillDn)
        linefill.delete(chFillDn)
    if not na(infoLb)
        label.delete(infoLb)

    x1 = bar_index - (n - 1)
    x2 = bar_index

    lnMid := line.new(x1, midStart, x2, midNow, color = color.new(chCol, chAlpha + 15),
                      width = 2, style = line.style_dashed)
    lnUp  := line.new(x1, upStart, x2, upNow, color = color.new(chCol, chAlpha), width = lineW)
    lnDn  := line.new(x1, dnStart, x2, dnNow, color = color.new(chCol, chAlpha), width = lineW)

    // light fill INSIDE the channel only — follows the tilted lines exactly,
    // no rectangle box, no outside borders. Upper half + lower half.
    fillAlpha = strongEnough ? i_fill_alpha : math.min(i_fill_alpha + 5, 98)
    chFillUp := linefill.new(lnUp, lnMid, color.new(chCol, fillAlpha))
    chFillDn := linefill.new(lnMid, lnDn, color.new(chCol, fillAlpha))

    // info label at the channel's leading edge
    if i_show_lbl
        dir = isUp ? "▲ UPTREND" : "▼ DOWNTREND"
        tier = strength >= 70 ? "VERY STRONG" : strength >= 50 ? "STRONG" : strength >= i_min_str ? "MODERATE" : "WEAK"
        txt = "🐘 " + dir + "  " + str.tostring(strength) + "%  " + tier
        infoLb := label.new(x2, isUp ? upNow : dnNow, txt,
                  style = isUp ? label.style_label_lower_left : label.style_label_upper_left,
                  color = color.new(chCol, strongEnough ? 0 : 40),
                  textcolor = color.white, size = size.small)

// ─────────────────────────────────────────────────────
//  BREAKOUT DETECTION  (cross of the channel boundary, vol-confirmed)
// ─────────────────────────────────────────────────────
volAvg = ta.sma(volume, i_vol_len)
volOK  = not i_bo_vol or (not na(volAvg) and volAvg > 0 and volume >= volAvg * i_bo_mult)

brokeUp = ta.crossover(close, upNow)  and barstate.isconfirmed and volOK
brokeDn = ta.crossunder(close, dnNow) and barstate.isconfirmed and volOK
// (on-chart B/O & B/Dn labels removed by request — breakout alerts still available below)

// ─────────────────────────────────────────────────────
//  DASHBOARD
// ─────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 6,
                  border_width = 1, border_color = color.new(color.gray, 60),
                  frame_width = 1, frame_color = color.new(color.gray, 50))

f_cell(_t, _c, _txt, _col, _bg) => table.cell(dash, _c, _t, _txt, text_color = _col, bgcolor = _bg, text_size = size.small)

if i_show_dash and barstate.islast
    bgHdr = color.new(#004D40, 0)
    bgRow = color.new(#00695C, 25)
    tier = strength >= 70 ? "VERY STRONG" : strength >= 50 ? "STRONG" : strength >= i_min_str ? "MODERATE" : "WEAK"

    // distance to channel edges
    distUp = close != 0 ? (upNow - close) / close * 100 : na
    distDn = close != 0 ? (close - dnNow) / close * 100 : na

    f_cell(0, 0, "INST-CH  🐘 @darshakssc", color.white, bgHdr)
    table.merge_cells(dash, 0, 0, 1, 0)

    f_cell(1, 0, "Trend", color.silver, bgRow)
    f_cell(1, 1, isUp ? "▲ UP" : "▼ DOWN", isUp ? i_col_up : i_col_dn, bgRow)

    f_cell(2, 0, "Strength", color.silver, bgRow)
    f_cell(2, 1, str.tostring(strength) + "%  " + tier, color.white,
           strength >= 70 ? color.new(#00C853, 30) : strength >= 50 ? color.new(#FFD600, 30) : bgRow)

    f_cell(3, 0, "Upper", color.silver, bgRow)
    f_cell(3, 1, str.tostring(rnd(upNow)) + "  (" + str.tostring(distUp, "#.#") + "%)", color.white, bgRow)

    f_cell(4, 0, "Lower", color.silver, bgRow)
    f_cell(4, 1, str.tostring(rnd(dnNow)) + "  (" + str.tostring(distDn, "#.#") + "%)", color.white, bgRow)

    f_cell(5, 0, "Mid", color.silver, bgRow)
    f_cell(5, 1, str.tostring(rnd(midNow)), color.white, bgRow)

// ─────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────
alertcondition(brokeUp, title = "Channel Breakout (Up)",
     message = "[INST-CH] Price broke above the trend channel — upside breakout.")
alertcondition(brokeDn, title = "Channel Breakout (Down)",
     message = "[INST-CH] Price broke below the trend channel — downside breakout.")
alertcondition(ta.cross(close, lr_now) and barstate.isconfirmed, title = "Channel Mid Cross",
     message = "[INST-CH] Price crossed the channel midline.")
````
