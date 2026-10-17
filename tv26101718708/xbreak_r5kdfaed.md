# X-Break

- url: https://www.tradingview.com/script/R5KdFAed-X-Break/
- type: indicator
- pine_id: PUB;5234ed0fe47947ae879c750c6e186dae
- version: 1.0

## Description

X-Break — London Breakout Indicator
X-Break is a London Session Breakout indicator built on the Asian Range. It automatically calculates the Asian session high and low (03:00–10:00 UTC+3), draws the range box, and waits for a strong breakout candle after the London open (11:00 UTC+3).
How it works:

Builds the Asian Range box every day automatically
Looks for breakout signals only after London open
Confirms signals on candle close only — no repaint
Filters weak breakouts using candle body strength

Signal conditions:

BUY: Close above Asia High with strong bullish body
SELL: Close below Asia Low with strong bearish body

Built-in filters:

Min body % of bar: 60%
Min body vs Asia Range: 30%
Optional EMA trend filter
Optional ATR body filter

Risk Management:

TP and SL calculated automatically
Multiple SL modes: AsiaRange · Asia Edge · ATR · % of Price · Points
Supports single R:R or split TP/SL mode

Best timeframe: 15 minutes
Best markets: US100 · US30 · US500 · XAUUSD · BTCUSD
Alerts: Built-in BUY and SELL alerts — set to Once Per Bar Close

## Source Code

````pine
//@version=6
indicator("X-Break", shorttitle="X-Break", overlay=true,
          max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════
//  X-Break  —  London Breakout based on Asian Range
//  Primary Markets : US100 · US30 · US500
//  Secondary       : XAUUSD · BTCUSD
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
i_useATRBody  = input.bool (false, "Body ≥ k × ATR(14)",                            group=GF)
i_atrBodyK    = input.float(0.5,   "K for ATR Filter",               step=0.1,      group=GF)

var string GR = "💰 Risk Controls"
i_slBasis  = input.string("AsiaRange", "SL Basis",
             options=["AsiaRange","Asia Edge","ATR Mode","% of Price","Points Mode"], group=GR)
i_singleRR = input.bool (false, "Use Single R:R",       group=GR)
i_rrVal    = input.float(1.5,   "R:R  (Single Mode)",   step=0.1,   group=GR)
i_tpR      = input.float(1.45,  "TP Multiplier",        step=0.05,  group=GR)
i_slR      = input.float(1.25,  "SL Multiplier",        step=0.05,  group=GR)
i_atrKsl   = input.float(1.0,   "ATR k (ATR Mode)",     step=0.1,   group=GR)
i_pctPrice = input.float(0.003, "% of Price",           step=0.001, group=GR)
i_pts      = input.float(1.0,   "Points (Points Mode)", step=0.1,   group=GR)

var string GSI = "📡 Signal Settings"
i_multiSig = input.bool(false, "Allow Multiple Signals Per Day", group=GSI)

var string GE = "📈 EMA Filter"
i_useEMA   = input.bool(false, "Use EMA Filter (signal with trend only)", group=GE)
i_emaPer   = input.int (200,   "EMA Period", minval=1, maxval=500,         group=GE)
i_emaShow  = input.bool(true,  "Show EMA on chart",                        group=GE)
i_emaColor = input.color(color.new(#f5a623, 0), "EMA Color",               group=GE)

var string GV = "🎨 Visual"
i_buyColor   = input.color(color.new(#00e676, 0),  "BUY Color",   group=GV)
i_sellColor  = input.color(color.new(#ff1744, 0),  "SELL Color",  group=GV)
i_tpColor    = input.color(color.new(#00bcd4, 0),  "TP Color",    group=GV)
i_slColor    = input.color(color.new(#f44336, 0),  "SL Color",    group=GV)
i_entryColor = input.color(color.new(#bdbdbd, 30), "Entry Color", group=GV)
i_lineLen    = input.int  (200, "TP/SL/Entry Line Length (bars)", minval=10, maxval=2000,
               tooltip="Number of bars the TP/SL/Entry lines extend to the right", group=GV)


// ───────────────────────────────────────────────────────────────────
//  TIME HELPERS
// ───────────────────────────────────────────────────────────────────

barHour  = hour(time, "UTC")
isInAsia = barHour >= i_asiaStart and barHour < i_asiaEnd
isSignal = barHour >= i_sigStart

// New-day detection (UTC) — safe on first bar
isNewDay = na(time[1]) ? false : dayofmonth(time, "UTC") != dayofmonth(time[1], "UTC")


// ───────────────────────────────────────────────────────────────────
//  INDICATORS
// ───────────────────────────────────────────────────────────────────

atr14 = ta.atr(14)
ema   = ta.ema(close, i_emaPer)

// EMA plot (optional)
plot(i_emaShow ? ema : na, title="EMA", color=i_emaColor, linewidth=2)


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
//  DAILY RESET  (calculations only — drawings always persist)
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

// Asia session just ended → finalise range and draw box
if not isInAsia and wasInAsia
    asiaRange    := asiaHigh - asiaLow
    asiaComplete := true
    wasInAsia    := false          // prevents re-entry next bar

    if not na(asiaBarStart) and not na(asiaHigh) and not na(asiaLow)
        // Asian Range Box
        box.new(asiaBarStart, asiaHigh, bar_index - 1, asiaLow,
                border_color=i_boxBorder, bgcolor=i_boxFill, border_width=1)

        // Asia High / Low extension lines
        if i_showHL
            line.new(bar_index - 1, asiaHigh, bar_index + i_lineLen, asiaHigh,
                     color=i_hlColor, width=1, style=line.style_dashed)
            line.new(bar_index - 1, asiaLow,  bar_index + i_lineLen, asiaLow,
                     color=i_hlColor, width=1, style=line.style_dashed)


// ───────────────────────────────────────────────────────────────────
//  SIGNAL CONDITIONS
// ───────────────────────────────────────────────────────────────────

body   = math.abs(close - open)
barRng = math.max(high - low, 1e-10)          // guard against zero-range bar

bodyPct  = body / barRng
bodyAsia = (not na(asiaRange) and asiaRange > 0) ? body / asiaRange : 0.0

filterOK = not i_useFilter or (bodyPct >= i_minBody and bodyAsia >= i_minBodyAsia)
atrOK    = not i_useATRBody or (body >= atr14 * i_atrBodyK)
canSign  = i_multiSig or not signalFired

timeOK  = barstate.isconfirmed and asiaComplete and isSignal
priceOK = not na(asiaHigh) and not na(asiaLow) and not na(asiaRange)
// EMA filter: BUY needs price above EMA, SELL needs price below EMA
emaLong  = not i_useEMA or close > ema
emaShort = not i_useEMA or close < ema
baseOK   = timeOK and priceOK and filterOK and atrOK and canSign

buyTrig  = baseOK and emaLong  and close > asiaHigh + asiaRange * i_breakBuf
sellTrig = baseOK and emaShort and close < asiaLow  - asiaRange * i_breakBuf and not buyTrig


// ───────────────────────────────────────────────────────────────────
//  SL DISTANCE  (selected by SL Basis input)
// ───────────────────────────────────────────────────────────────────

// Asia Edge: SL is placed at AsiaHigh/Low — slDist computed inside BUY/SELL blocks
// All other modes: fixed slDist used below
slDist = switch i_slBasis
    "AsiaRange"   => asiaRange * i_slR
    "ATR Mode"    => atr14 * i_atrKsl
    "% of Price"  => close * i_pctPrice
    "Points Mode" => i_pts
    =>               asiaRange * i_slR          // fallback


// ───────────────────────────────────────────────────────────────────
//  BUY — DRAWINGS
// ───────────────────────────────────────────────────────────────────

if buyTrig
    entry   = close
    // Asia Edge → SL at AsiaHigh (break level), TP uses actual SL distance
    sl      = i_slBasis == "Asia Edge" ? asiaLow : entry - slDist
    slDistB = entry - sl
    tp      = i_singleRR ? entry + slDistB * i_rrVal : i_slBasis == "Asia Edge" ? entry + slDistB * (i_tpR / i_slR) : entry + asiaRange * i_tpR
    yOff    = asiaRange * 0.25

    // BUY label (below bar)
    label.new(bar_index, low - yOff,
              "▲ BUY\n" + str.tostring(entry, format.mintick),
              style     = label.style_label_up,
              color     = i_buyColor,
              textcolor = color.white,
              size      = size.normal)

    // Entry dashed line
    line.new(bar_index, entry, bar_index + i_lineLen, entry,
             color = i_entryColor, width = 1, style = line.style_dashed)

    // TP line + label
    line.new(bar_index, tp, bar_index + i_lineLen, tp,
             color = i_tpColor, width = 1)
    label.new(bar_index + 1, tp,
              "TP  " + str.tostring(tp, format.mintick),
              style     = label.style_label_right,
              color     = i_tpColor,
              textcolor = color.white,
              size      = size.small)

    // SL line + label
    line.new(bar_index, sl, bar_index + i_lineLen, sl,
             color = i_slColor, width = 1)
    label.new(bar_index + 1, sl,
              "SL  " + str.tostring(sl, format.mintick),
              style     = label.style_label_right,
              color     = i_slColor,
              textcolor = color.white,
              size      = size.small)

    signalFired := true


// ───────────────────────────────────────────────────────────────────
//  SELL — DRAWINGS
// ───────────────────────────────────────────────────────────────────

if sellTrig
    entry   = close
    // Asia Edge → SL at AsiaLow (break level), TP uses actual SL distance
    sl      = i_slBasis == "Asia Edge" ? asiaHigh : entry + slDist
    slDistS = sl - entry
    tp      = i_singleRR ? entry - slDistS * i_rrVal : i_slBasis == "Asia Edge" ? entry - slDistS * (i_tpR / i_slR) : entry - asiaRange * i_tpR
    yOff    = asiaRange * 0.25

    // SELL label (above bar)
    label.new(bar_index, high + yOff,
              "▼ SELL\n" + str.tostring(entry, format.mintick),
              style     = label.style_label_down,
              color     = i_sellColor,
              textcolor = color.white,
              size      = size.normal)

    // Entry dashed line
    line.new(bar_index, entry, bar_index + i_lineLen, entry,
             color = i_entryColor, width = 1, style = line.style_dashed)

    // TP line + label
    line.new(bar_index, tp, bar_index + i_lineLen, tp,
             color = i_tpColor, width = 1)
    label.new(bar_index + 1, tp,
              "TP  " + str.tostring(tp, format.mintick),
              style     = label.style_label_right,
              color     = i_tpColor,
              textcolor = color.white,
              size      = size.small)

    // SL line + label
    line.new(bar_index, sl, bar_index + i_lineLen, sl,
             color = i_slColor, width = 1)
    label.new(bar_index + 1, sl,
              "SL  " + str.tostring(sl, format.mintick),
              style     = label.style_label_right,
              color     = i_slColor,
              textcolor = color.white,
              size      = size.small)

    signalFired := true


// ───────────────────────────────────────────────────────────────────
//  ALERT CONDITIONS
//  In TradingView → Create Alert → Condition = X-Break
//  Set Trigger = "Once Per Bar Close"
// ───────────────────────────────────────────────────────────────────

alertcondition(buyTrig,
    title   = "BUY Signal - X-Break",
    message = "BUY Signal - X-Break | Close: {{close}} | Time: {{time}}")

alertcondition(sellTrig,
    title   = "SELL Signal - X-Break",
    message = "SELL Signal - X-Break | Close: {{close}} | Time: {{time}}")

// ═══════════════════════════════════════════════════════════════════
//  ALERT NAMING GUIDE (set manually in TradingView)
//  🟢 BUY US100 - X-Break      🔴 SELL US100 - X-Break
//  🟢 BUY US30  - X-Break      🔴 SELL US30  - X-Break
//  🟢 BUY US500 - X-Break      🔴 SELL US500 - X-Break
//  🟢 BUY GOLD  - X-Break      🔴 SELL GOLD  - X-Break
//  🟢 BUY BTC   - X-Break      🔴 SELL BTC   - X-Break
// ═══════════════════════════════════════════════════════════════════
````
