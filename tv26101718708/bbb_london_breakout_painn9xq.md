# BBB London Breakout

- url: https://www.tradingview.com/script/pAiNN9XQ-BBB-London-Breakout/
- type: indicator
- pine_id: PUB;ac88df0193d3412f9e21bcfea01e50bb
- version: 1.0

## Description

BBB London Breakout

BBB London Breakout is a session-based breakout indicator built around the Asian session range and the London session breakout concept. The purpose of the script is to help traders identify confirmed price breakouts after the Asian range has been formed, while filtering out weak breakout candles using body-strength conditions.

How the indicator works

The script first calculates the Asian session high and low during the selected session hours. These two levels form the Asian range. Once the Asian session is completed, the range is drawn on the chart using a visual box, with optional high and low extension lines.

After the selected signal start time begins, the indicator waits for a confirmed candle close outside the Asian range.

A buy signal is generated when price closes above the Asian session high.

A sell signal is generated when price closes below the Asian session low.

Signals are confirmed only after candle close to avoid repainting during the active candle.

Breakout filtering logic

The script includes a strong-break filter designed to reduce weak or low-quality breakouts. Instead of marking every small move outside the range, the indicator evaluates the breakout candle using two body-strength conditions:

The candle body size compared to the full candle range.

The candle body size compared to the Asian session range.

This helps the script focus on candles that show stronger breakout intent, instead of candles that only slightly cross the Asian high or low.

There is also an optional ATR body filter. When enabled, the breakout candle body must be greater than or equal to a selected ATR-based threshold. This can help filter signals during low-volatility conditions.

Risk management levels

After a confirmed buy or sell signal, the script automatically plots the entry level, stop-loss level, and take-profit level.

The stop-loss can be calculated using different methods, including Asian range, Asian edge, ATR mode, percentage of price, or fixed points.

The take-profit level is calculated from the actual stop-loss distance using the selected multiplier. This allows the plotted risk and reward levels to stay connected to the real distance between the entry and stop-loss.

Alerts

The script includes alert conditions for buy signals, sell signals, and any signal. Dynamic alert messages can include the symbol, entry price, stop-loss, take-profit, Asian range size, and signal time.

Recommended use

This indicator is designed mainly for US30, US100, and US500 / S&P 500.

The recommended timeframe is 15 minutes.

Wait for candle close confirmation before considering any signal.

Always review spread, volatility, session conditions, major news events, and overall market structure before using any signal.

Main features

Asian session high and low range calculation

Visual Asian range box

London breakout logic after the selected signal start time

Strong breakout candle body filter

Optional ATR body filter

Automatic Entry, Stop-loss, and Take-profit plotting

Buy, Sell, and Any signal alerts

Chart notes box with recommended symbols and timeframe

Important note

This script is intended for educational and analytical purposes only. It does not guarantee profitable trades and should not be considered financial advice. Traders should use their own risk management and additional analysis before making any trading decision.

## Source Code

````pine
//@version=6
indicator("BBB London Breakout", shorttitle="BBB Breakout", overlay=true,
          max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════
//  BBB London Breakout  —  London Breakout based on Asian Range
//  Primary Markets : US100 · US30 · US500
//  Timeframe       : 15m
//  All session times are stored in UTC internally.
//  UTC+3 reference: Asia 03:00-10:00 | Signal start 11:00
// ═══════════════════════════════════════════════════════════════════


// ───────────────────────────────────────────────────────────────────
//  INPUTS
// ───────────────────────────────────────────────────────────────────

var string GS = "⏰ Session  (UTC — UTC+3 shown in tooltip)"
i_asiaStart = input.int(0, "Asia Start Hour UTC",   minval=0, maxval=23,
              tooltip="00:00 UTC  =  03:00 UTC+3", group=GS)
i_asiaEnd   = input.int(7, "Asia End Hour UTC",     minval=0, maxval=23,
              tooltip="07:00 UTC  =  10:00 UTC+3", group=GS)
i_sigStart  = input.int(8, "Signal Start Hour UTC", minval=0, maxval=23,
              tooltip="08:00 UTC  =  11:00 UTC+3  (London open)", group=GS)

var string GB = "📦 Asian Box"
i_boxFill   = input.color(color.new(color.orange, 88), "Box Fill",   group=GB)
i_boxBorder = input.color(color.new(color.orange, 20), "Box Border", group=GB)
i_showHL    = input.bool (true,                        "Show Asia H/L Extension Lines", group=GB)
i_hlColor   = input.color(color.new(color.orange, 30), "H/L Line Color",                group=GB)

var string GF = "🔍 Break Filter"
i_useFilter   = input.bool (true,  "Use Strong-Break Filter",                        group=GF)
i_breakBuf    = input.float(0.0,   "Break Buffer (% of Asia Range)", step=0.01,
               tooltip="0 = no buffer. BUY: Close > AsiaHigh + AsiaRange×Buffer",  group=GF)
i_minBody     = input.float(0.6,   "Min Body % of Bar",              step=0.05,     group=GF)
i_minBodyAsia = input.float(0.3,   "Min Body vs Asia Range",         step=0.05,     group=GF)
i_useATRBody  = input.bool (false, "Body >= k x ATR(14)",                            group=GF)
i_atrBodyK    = input.float(0.5,   "K for ATR Filter",               step=0.1,      group=GF)

var string GR = "💰 Risk Controls"
i_slBasis  = input.string("AsiaRange", "SL Basis",
             options=["AsiaRange","Asia Edge","ATR Mode","% of Price","Points Mode"], group=GR)
i_singleRR = input.bool (false, "Use Single R:R",       group=GR)
i_rrVal    = input.float(1.5,   "R:R  (Single Mode)",   step=0.1,   group=GR)
i_tpR      = input.float(1.45,  "TP Multiplier",        step=0.05,
             tooltip="TP = actual SL distance x this multiplier. e.g. SL=100pts, TP=145pts at 1.45", group=GR)
i_slR      = input.float(1.25,  "SL Multiplier (non-Edge modes)", step=0.05, group=GR)
i_atrKsl   = input.float(1.0,   "ATR k (ATR Mode)",     step=0.1,   group=GR)
i_pctPrice = input.float(0.003, "% of Price",           step=0.001, group=GR)
i_pts      = input.float(1.0,   "Points (Points Mode)", step=0.1,   group=GR)

var string GSI = "📡 Signal Settings"
i_multiSig = input.bool(false, "Allow Multiple Signals Per Day", group=GSI)


var string GV = "🎨 Visual"
i_buyColor   = input.color(color.new(#00e676, 0),  "BUY Color",   group=GV)
i_sellColor  = input.color(color.new(#ff1744, 0),  "SELL Color",  group=GV)
i_tpColor    = input.color(color.new(#00bcd4, 0),  "TP Color",    group=GV)
i_slColor    = input.color(color.new(#f44336, 0),  "SL Color",    group=GV)
i_entryColor = input.color(color.new(#bdbdbd, 30), "Entry Color", group=GV)
i_lineLen    = input.int  (20, "TP/SL/Entry Line Length (bars)", minval=10, maxval=2000,
               tooltip="Number of bars the TP/SL/Entry lines extend to the right", group=GV)

var string GN = "📝 Notes"
i_showNotes = input.bool(true, "Show Notes Box", group=GN)


// ───────────────────────────────────────────────────────────────────
//  TIME HELPERS
// ───────────────────────────────────────────────────────────────────

barHour  = hour(time, "UTC")
isInAsia = barHour >= i_asiaStart and barHour < i_asiaEnd
isSignal = barHour >= i_sigStart

isNewDay = na(time[1]) ? false : dayofmonth(time, "UTC") != dayofmonth(time[1], "UTC")


// ───────────────────────────────────────────────────────────────────
//  INDICATORS
// ───────────────────────────────────────────────────────────────────

atr14 = ta.atr(14)


// ───────────────────────────────────────────────────────────────────
//  STATE VARIABLES
// ───────────────────────────────────────────────────────────────────

var float asiaHigh     = na
var float asiaLow      = na
var float asiaRange    = na
var int   asiaBarStart = na
var bool  asiaComplete = false
var bool  wasInAsia    = false
var bool  signalFired  = false


// ───────────────────────────────────────────────────────────────────
//  DAILY RESET
// ───────────────────────────────────────────────────────────────────

if isNewDay
    asiaHigh     := na
    asiaLow      := na
    asiaRange    := na
    asiaBarStart := na
    asiaComplete := false
    wasInAsia    := false
    signalFired  := false


// ───────────────────────────────────────────────────────────────────
//  ASIAN RANGE BUILDER
// ───────────────────────────────────────────────────────────────────

if isInAsia
    if not wasInAsia
        asiaBarStart := bar_index
        wasInAsia    := true
    asiaHigh := na(asiaHigh) ? high : math.max(asiaHigh, high)
    asiaLow  := na(asiaLow)  ? low  : math.min(asiaLow,  low)

if not isInAsia and wasInAsia
    asiaRange    := asiaHigh - asiaLow
    asiaComplete := true
    wasInAsia    := false

    if not na(asiaBarStart) and not na(asiaHigh) and not na(asiaLow)
        box.new(asiaBarStart, asiaHigh, bar_index - 1, asiaLow,
                border_color=i_boxBorder, bgcolor=i_boxFill, border_width=1)
        if i_showHL
            line.new(bar_index - 1, asiaHigh, bar_index + i_lineLen, asiaHigh,
                     color=i_hlColor, width=1, style=line.style_dashed)
            line.new(bar_index - 1, asiaLow,  bar_index + i_lineLen, asiaLow,
                     color=i_hlColor, width=1, style=line.style_dashed)


// ───────────────────────────────────────────────────────────────────
//  SIGNAL CONDITIONS
// ───────────────────────────────────────────────────────────────────

body   = math.abs(close - open)
barRng = math.max(high - low, 1e-10)

bodyPct  = body / barRng
bodyAsia = (not na(asiaRange) and asiaRange > 0) ? body / asiaRange : 0.0

filterOK = not i_useFilter or (bodyPct >= i_minBody and bodyAsia >= i_minBodyAsia)
atrOK    = not i_useATRBody or (body >= atr14 * i_atrBodyK)
canSign  = i_multiSig or not signalFired

timeOK  = barstate.isconfirmed and asiaComplete and isSignal
priceOK = not na(asiaHigh) and not na(asiaLow) and not na(asiaRange)
baseOK  = timeOK and priceOK and filterOK and atrOK and canSign

buyTrig  = baseOK and close > asiaHigh + asiaRange * i_breakBuf
sellTrig = baseOK and close < asiaLow  - asiaRange * i_breakBuf and not buyTrig
anyTrig  = buyTrig or sellTrig


// ───────────────────────────────────────────────────────────────────
//  SL DISTANCE
// ───────────────────────────────────────────────────────────────────

slDist = switch i_slBasis
    "AsiaRange"   => asiaRange * i_slR
    "ATR Mode"    => atr14 * i_atrKsl
    "% of Price"  => close * i_pctPrice
    "Points Mode" => i_pts
    =>               asiaRange * i_slR


// ───────────────────────────────────────────────────────────────────
//  BUY — DRAWINGS
// ───────────────────────────────────────────────────────────────────

if buyTrig
    entry   = close
    sl      = i_slBasis == "Asia Edge" ? asiaLow : entry - slDist
    slDistB = entry - sl
    tp      = i_singleRR ? entry + slDistB * i_rrVal : entry + slDistB * i_tpR
    yOff    = asiaRange * 0.25

    label.new(bar_index, low - yOff,
              "BUY\n" + str.tostring(entry, format.mintick),
              style=label.style_label_up, color=i_buyColor,
              textcolor=color.white, size=size.tiny)

    line.new(bar_index, entry, bar_index + i_lineLen, entry,
             color=i_entryColor, width=1, style=line.style_dashed)

    line.new(bar_index, tp, bar_index + i_lineLen, tp,
             color=i_tpColor, width=1)
    label.new(bar_index + 1, tp,
              "TP  " + str.tostring(tp, format.mintick),
              style=label.style_label_right, color=i_tpColor,
              textcolor=color.white, size=size.tiny)

    line.new(bar_index, sl, bar_index + i_lineLen, sl,
             color=i_slColor, width=1)
    label.new(bar_index + 1, sl,
              "SL  " + str.tostring(sl, format.mintick),
              style=label.style_label_right, color=i_slColor,
              textcolor=color.white, size=size.tiny)

    signalFired := true

    alert(
      "BUY " + syminfo.ticker + "\n" +
      "Entry : " + str.tostring(entry,     format.mintick) + "\n" +
      "SL    : " + str.tostring(sl,        format.mintick) + "\n" +
      "TP    : " + str.tostring(tp,        format.mintick) + "\n" +
      "Range : " + str.tostring(asiaRange, format.mintick) + " pts\n" +
      "BBB London Breakout | " + str.format_time(time, "HH:mm", "UTC") + " UTC",
      alert.freq_once_per_bar_close)


// ───────────────────────────────────────────────────────────────────
//  SELL — DRAWINGS
// ───────────────────────────────────────────────────────────────────

if sellTrig
    entry   = close
    sl      = i_slBasis == "Asia Edge" ? asiaHigh : entry + slDist
    slDistS = sl - entry
    tp      = i_singleRR ? entry - slDistS * i_rrVal : entry - slDistS * i_tpR
    yOff    = asiaRange * 0.25

    label.new(bar_index, high + yOff,
              "SELL\n" + str.tostring(entry, format.mintick),
              style=label.style_label_down, color=i_sellColor,
              textcolor=color.white, size=size.tiny)

    line.new(bar_index, entry, bar_index + i_lineLen, entry,
             color=i_entryColor, width=1, style=line.style_dashed)

    line.new(bar_index, tp, bar_index + i_lineLen, tp,
             color=i_tpColor, width=1)
    label.new(bar_index + 1, tp,
              "TP  " + str.tostring(tp, format.mintick),
              style=label.style_label_right, color=i_tpColor,
              textcolor=color.white, size=size.tiny)

    line.new(bar_index, sl, bar_index + i_lineLen, sl,
             color=i_slColor, width=1)
    label.new(bar_index + 1, sl,
              "SL  " + str.tostring(sl, format.mintick),
              style=label.style_label_right, color=i_slColor,
              textcolor=color.white, size=size.tiny)

    signalFired := true

    alert(
      "SELL " + syminfo.ticker + "\n" +
      "Entry : " + str.tostring(entry,     format.mintick) + "\n" +
      "SL    : " + str.tostring(sl,        format.mintick) + "\n" +
      "TP    : " + str.tostring(tp,        format.mintick) + "\n" +
      "Range : " + str.tostring(asiaRange, format.mintick) + " pts\n" +
      "BBB London Breakout | " + str.format_time(time, "HH:mm", "UTC") + " UTC",
      alert.freq_once_per_bar_close)


// ───────────────────────────────────────────────────────────────────
//  ALERT CONDITIONS
// ───────────────────────────────────────────────────────────────────

alertcondition(buyTrig,
    title   = "BUY Signal - BBB London Breakout",
    message = "BUY Signal - BBB London Breakout | Close: {{close}} | Time: {{time}}")

alertcondition(sellTrig,
    title   = "SELL Signal - BBB London Breakout",
    message = "SELL Signal - BBB London Breakout | Close: {{close}} | Time: {{time}}")

alertcondition(anyTrig,
    title   = "ANY Signal - BBB London Breakout",
    message = "ANY Signal - BBB London Breakout | Check chart for BUY/SELL | Close: {{close}} | Time: {{time}}")


// ───────────────────────────────────────────────────────────────────
//  NOTES BOX  —  top_center table
// ───────────────────────────────────────────────────────────────────

var table notesBox = table.new(position.top_center, 1, 4,
     border_color = color.new(color.gray, 60),
     border_width = 1,
     frame_color  = color.new(color.gray, 60),
     frame_width  = 1)

if barstate.islast
    if i_showNotes
        table.cell(notesBox, 0, 0,
                   "📋  NOTES  —  BBB London Breakout",
                   text_color  = color.new(color.white, 0),
                   bgcolor     = color.new(#1a1a2e, 10),
                   text_size   = size.small,
                   text_halign = text.align_center)
        table.cell(notesBox, 0, 1,
                   "1.  Recommended symbols: US30, US100, and US500 / S&P 500.",
                   text_color  = color.new(#e0e0e0, 0),
                   bgcolor     = color.new(#1a1a2e, 20),
                   text_size   = size.small,
                   text_halign = text.align_left)
        table.cell(notesBox, 0, 2,
                   "2.  Recommended timeframe: 15 minutes.",
                   text_color  = color.new(#e0e0e0, 0),
                   bgcolor     = color.new(#1a1a2e, 20),
                   text_size   = size.small,
                   text_halign = text.align_left)
        table.cell(notesBox, 0, 3,
                   "3.  Signals are confirmed only after candle close.",
                   text_color  = color.new(#e0e0e0, 0),
                   bgcolor     = color.new(#1a1a2e, 20),
                   text_size   = size.small,
                   text_halign = text.align_left)
    else
        table.clear(notesBox, 0, 0, 0, 3)
````
