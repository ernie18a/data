# SuperTrend - Swing High Entry

- url: https://www.tradingview.com/script/NjtwUdbn-SuperTrend-Swing-High-Entry/
- type: indicator
- pine_id: PUB;834d12a30725431eac11c6e0e8d7e2cd
- version: 1.0

## Description

SuperTrend · Swing High Entry — Long Only
TradingView Indicator Documentation

Overview
This indicator identifies high-probability long entry opportunities by combining two concepts:

SuperTrend — confirms the macro trend direction
Prior Bearish Phase High — the resistance level that price must break to confirm the new bullish trend

The strategy is based on the teaching of Shubham Agrawal (Video from Upsurge Club): wait for SuperTrend to turn bullish, identify the highest high of the prior bearish phase, and enter on the first candle that closes above it.

How It Works — Step by Step
Step 1 — SuperTrend turns bullish
When the closing price crosses above the SuperTrend line, the trend flips from bearish (red) to bullish (teal). This is the starting gun.
Step 2 — Resistance level is captured
At the exact moment of the flip, the indicator scans back through every bar of the prior bearish phase and identifies the highest high of that entire downtrend. This becomes the resistance level displayed as a dashed grey line on the chart.
Step 3 — Entry trigger
The entry fires on the first candle that closes above the resistance level while SuperTrend remains bullish. This is a confirmed-close signal — it does not trigger intra-candle.
Step 4 — One entry per phase
Once the entry fires, the indicator locks out any further signals until SuperTrend turns bearish and then bullish again. This prevents chasing extended moves within the same trend phase.
Step 5 — Stop Loss and Target

Stop Loss — placed at the SuperTrend line value at the time of entry
Target — calculated from entry price using your chosen Risk:Reward ratio


Entry Label
Every entry signal displays an amber label box below the trigger candle showing:
▲ [Entry Price]
SL  [Stop Loss Price]
TP  [Target Price]
Persistent dotted lines extend rightward from the entry bar showing the SL (red) and TP (teal) levels, with price labels pinned to the right edge of the chart.

Settings
● SuperTrend
ParameterDefaultDescriptionATR Length10Lookback period for Average True Range calculationATR Multiplier3.0Controls the width of the SuperTrend band. Lower = more sensitive, more flips. Higher = smoother, fewer flips
Recommended adjustments:

Volatile stocks / crypto: increase multiplier to 3.5–4.0 to reduce noise
Slow-moving large caps: 2.5–3.0 works well
Weekly timeframe: reduce to 2.0–2.5


● Swing Detection
ParameterDefaultDescriptionBear Phase Lookback20Maximum number of bars to scan back through the bearish phase when capturing the resistance level
The indicator walks back bar by bar through consecutive bearish ST bars and stops automatically at the prior bullish phase boundary. The lookback is a safety cap — if your bearish phase is longer than this, increase it.
Recommended adjustments:

Short corrections (5–15 bars): default 20 is fine
Extended downtrends (months): increase to 50–100
If "Watching" in the info panel shows — after a flip: increase this value


● Trade Levels
ParameterDefaultDescriptionRisk : Reward2.0Multiplier applied to the entry-to-SL distance to calculate the target. 2.0 = 1:2 R:RShow Stop LossOnToggles the dotted red SL line and right-edge labelShow TargetOnToggles the dotted teal TP line and right-edge label

● Display
ParameterDefaultDescriptionShow Active Swing High LevelOnDisplays the dashed grey resistance line from the ST flip bar to the current barShow Info PanelOnDisplays the information table in the bottom-right corner

● Pre-Close Alert
ParameterDefaultDescriptionMarketNSE (India)Selects the market for pre-close timingEnable Pre-Close AlertOnActivates the pre-close alert condition
MarketPre-Close TimeLocal TimeUTCNSE (India)15 min before close15:15 IST09:45 UTCNYSE / NASDAQ (US)15 min before close15:45 EST20:45 UTC
The pre-close alert fires when all of the following are true simultaneously:

It is the pre-close candle for the selected market
SuperTrend is bullish
Price is already trading above the resistance level
No entry has been taken yet this phase

This gives you 15 minutes to review the setup and place your order before the candle closes and officially confirms the signal.

Info Panel
The panel in the bottom-right corner shows live values:
RowDescriptionTrendCurrent ST direction — ▲ Bullish (teal) or ▼ Bearish (dimmed red)SuperTrendCurrent value of the ST line (your dynamic stop reference)WatchingThe resistance level being monitored for a breakout. Dims after entry firesR : RYour configured Risk:Reward ratioPre-CloseActive market and pre-close time setting

Visual Elements
ElementDescriptionTeal ST lineSuperTrend is bullish — trend is upRed ST line (dimmed)SuperTrend is bearish — no entries consideredTeal fillSubtle shading between price and ST line in bullish phaseGrey dashed lineActive resistance level (highest high of prior bearish phase)Amber triangle ▲Entry signal below the trigger candleAmber label boxEntry price, SL, and TP printed at the signal barRed dotted lineStop Loss level extending from entry barTeal dotted lineTarget level extending from entry barViolet diamond ◆Pre-close warning — setup is valid 15 min before market close

Alerts
Three alert conditions are available. Set them up via TradingView → Alerts → Create Alert → Condition.
Alert NameWhen It FiresLong Entry — Swing High BreakoutCandle closes above resistance with bullish ST. This is the primary entry alert⏰ Pre-Close Setup AlertPrice is above resistance at the pre-close candle. Monitor for close confirmationSuperTrend → BullishST has just flipped bullish. Begin watching the resistance level
Recommended alert setup for daily charts:

Long Entry alert → Frequency: Once Per Bar Close
Pre-Close alert → Frequency: Once Per Bar
SuperTrend Bullish alert → Frequency: Once Per Bar Close


Timeframe Guidance
The indicator works on all timeframes. Recommended usage:
TimeframeUse CaseDaily (1D)Primary — swing trading, positional trades. Highest signal qualityWeekly (1W)Macro trend confirmation, position sizing context4H / 1HIntraday swing setups, finding entries within a daily trend15m / 5mScalping — increase ATR multiplier to reduce noise
Note: The pre-close alert is designed for the daily timeframe. On intraday charts it will mark the specific pre-close candle visually but the timing logic is based on a fixed UTC hour:minute match — ensure your chart timezone is set correctly in TradingView.

Important Notes
Confirmed-close signals only
The entry condition uses close — the finalised closing price of the bar. On a daily chart this means the signal is only confirmed when the day's candle closes. You enter at the next candle's open or use a limit order near the close.
One entry per SuperTrend bullish phase
The indicator deliberately fires only once per trend phase. If price breaks out, pulls back, and breaks out again — only the first breakout is signalled. This is by design, matching the original strategy intent.
Stop Loss is dynamic at entry
The SL is set to the SuperTrend line value at the moment of entry. It does not trail after entry — manage your trade manually or use a trailing stop strategy from there.
Bear Phase Lookback
If the "Watching" level in the info panel shows — after SuperTrend turns bullish, it means the bearish phase was longer than your lookback setting. Increase the Bear Phase Lookback input until a level appears.

Inputs Quick Reference
SuperTrend
  ATR Length          : 10
  ATR Multiplier      : 3.0

Swing Detection
  Bear Phase Lookback : 20

Trade Levels
  Risk : Reward       : 2.0
  Show Stop Loss      : On
  Show Target         : On

Display
  Show Swing Level    : On
  Show Info Panel     : On

Pre-Close Alert
  Market              : NSE (India) — 15:15 IST
  Enable Pre-Close    : On

Indicator built on Pine Script v5. Works on all symbols and timeframes available on TradingView.

## Source Code

````pine
// ============================================================
// SuperTrend · Swing High Entry  ·  Long Only
// Strategy: Shubham Agrawal (Upsurge Club)
// ============================================================

//@version=5
indicator("SuperTrend · Swing High Entry",
     shorttitle       = "SuperTrend · SwingHigh Long",
     overlay          = true,
     max_bars_back    = 500,
     max_labels_count = 200,
     max_lines_count  = 200)

// ════════════════════════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════════════════════════

var string G1 = "● SuperTrend"
atr_len  = input.int  (10,  "ATR Length",     minval=1,             group=G1)
atr_mult = input.float(3.0, "ATR Multiplier", minval=0.1, step=0.1, group=G1)

var string G2 = "● Swing Detection"
swing_lookback = input.int(20, "Bear Phase Lookback (bars)", minval=5, maxval=100, group=G2,
     tooltip="Maximum bars to scan back through the bearish ST phase to find the highest high. Increase for longer downtrends.")

var string G3 = "● Trade Levels"
rr_ratio = input.float(2.0, "Risk : Reward", minval=0.5, step=0.5, group=G3)
show_sl  = input.bool(true, "Show Stop Loss", group=G3)
show_tp  = input.bool(true, "Show Target",    group=G3)

var string G4 = "● Display"
show_swing_level = input.bool(true, "Show Active Swing High Level", group=G4)
show_table       = input.bool(true, "Show Info Panel",              group=G4)

var string G5 = "● Pre-Close Alert"
market_select   = input.string("NSE (India) — 15:15 IST", "Market",
     options = ["NSE (India) — 15:15 IST", "NYSE/NASDAQ (US) — 15:45 EST"],
     group   = G5)
enable_preclose = input.bool(true, "Enable Pre-Close Alert", group=G5)

// ════════════════════════════════════════════════════════════
// PALETTE
// ════════════════════════════════════════════════════════════
c_bull  = #26a69a
c_bear  = #ef5350
c_entry = #f0b429
c_sl    = #ef5350
c_tp    = #26a69a
c_swing = #90a4ae
c_white = #eceff1
c_black = #0d1117

// ════════════════════════════════════════════════════════════
// SUPERTREND
// ════════════════════════════════════════════════════════════
atr_val = ta.atr(atr_len)

ub_raw = hl2 + atr_mult * atr_val
lb_raw = hl2 - atr_mult * atr_val

var float ub = na
var float lb = na
var int   tr = 1

ub := (ub_raw < nz(ub[1]) or close[1] > nz(ub[1])) ? ub_raw : nz(ub[1])
lb := (lb_raw > nz(lb[1]) or close[1] < nz(lb[1])) ? lb_raw : nz(lb[1])

tr := nz(tr[1], 1)
if tr == -1 and close > ub[1]
    tr := 1
else if tr == 1 and close < lb[1]
    tr := -1

st_line   = tr == 1 ? lb : ub
is_bull   = tr == 1
bull_flip = is_bull and tr[1] == -1

// SuperTrend line
plot(st_line,
     title     = "SuperTrend",
     color     = is_bull ? color.new(c_bull, 0) : color.new(c_bear, 30),
     linewidth = 2,
     style     = plot.style_linebr)

p_close = plot(close,   display=display.none, editable=false)
p_st    = plot(st_line, display=display.none, editable=false)
fill(p_close, p_st,
     color = is_bull ? color.new(c_bull, 93) : na,
     title = "Bullish Fill")

// ════════════════════════════════════════════════════════════
// SWING HIGH LEVEL
// ════════════════════════════════════════════════════════════
var float sh_level    = na
var bool  entry_taken = false
var int   flip_bar    = na

if bull_flip
    entry_taken := false
    flip_bar    := bar_index

    var float phase_high = na
    phase_high := high[1]
    for i = 1 to swing_lookback
        if tr[i] == 1
            break
        if high[i] > phase_high
            phase_high := high[i]
    sh_level := phase_high

// ════════════════════════════════════════════════════════════
// ENTRY LOGIC
// ════════════════════════════════════════════════════════════
long_entry = is_bull
     and not entry_taken
     and not na(sh_level)
     and close   > sh_level
     and close[1] <= sh_level

if long_entry
    entry_taken := true

sl_price = st_line
risk     = close - sl_price
tp_price = close + risk * rr_ratio

// ════════════════════════════════════════════════════════════
// SWING HIGH LINE
// ════════════════════════════════════════════════════════════
var line sh_line = na

if bull_flip
    if not na(sh_line)
        line.delete(sh_line)

if show_swing_level and is_bull and not na(sh_level) and not na(flip_bar)
    if not na(sh_line)
        line.delete(sh_line)
    sh_line := line.new(
         x1    = flip_bar,
         y1    = sh_level,
         x2    = bar_index,
         y2    = sh_level,
         color = entry_taken
              ? color.new(c_swing, 75)
              : color.new(c_swing, 40),
         style = line.style_dashed,
         width = 1)

// ════════════════════════════════════════════════════════════
// PRE-CLOSE ALERT
// ════════════════════════════════════════════════════════════
is_nse     = market_select == "NSE (India) — 15:15 IST"
bar_hour   = hour(time,   "UTC")
bar_minute = minute(time, "UTC")

preclose_bar = is_nse
     ? (bar_hour == 9  and bar_minute == 45)
     : (bar_hour == 20 and bar_minute == 45)

preclose_alert = enable_preclose
     and preclose_bar
     and is_bull
     and not entry_taken
     and not na(sh_level)
     and close > sh_level

// ════════════════════════════════════════════════════════════
// VISUALS
// ════════════════════════════════════════════════════════════

// Tiny triangle — positional anchor, label is the hero
plotshape(long_entry,
     title    = "Long Entry",
     style    = shape.triangleup,
     location = location.belowbar,
     color    = c_entry,
     size     = size.tiny)

// Pre-close diamond
plotshape(preclose_alert,
     title    = "Pre-Close Warning",
     style    = shape.diamond,
     location = location.abovebar,
     color    = color.new(#ce93d8, 0),
     size     = size.tiny)

// ── Entry label box — amber background, dark text, 3 lines ───
if long_entry
    label.new(
         x         = bar_index,
         y         = low,
         text      = "▲ " + str.tostring(close,    format.mintick) + "\n" +
                     "SL  " + str.tostring(sl_price, format.mintick) + "\n" +
                     "TP  " + str.tostring(tp_price, format.mintick),
         yloc      = yloc.belowbar,
         color     = color.new(c_entry, 10),
         textcolor = c_black,
         style     = label.style_label_up,
         size      = size.small)

// Pre-close label box
if preclose_alert
    label.new(
         x         = bar_index,
         y         = high,
         text      = (is_nse ? "⏰ 15:15" : "⏰ 15:45") + "\n" +
                     str.tostring(close, format.mintick),
         yloc      = yloc.abovebar,
         color     = color.new(#ce93d8, 10),
         textcolor = color.new(c_black, 0),
         style     = label.style_label_down,
         size      = size.tiny)

// ── Persistent SL / TP dotted lines ──────────────────────────
var line line_sl = na
var line line_tp = na

if long_entry
    if not na(line_sl)
        line.delete(line_sl)
    if not na(line_tp)
        line.delete(line_tp)

    if show_sl
        line_sl := line.new(
             x1     = bar_index,
             y1     = sl_price,
             x2     = bar_index + 1,
             y2     = sl_price,
             color  = color.new(c_sl, 40),
             style  = line.style_dotted,
             width  = 1,
             extend = extend.right)

    if show_tp
        line_tp := line.new(
             x1     = bar_index,
             y1     = tp_price,
             x2     = bar_index + 1,
             y2     = tp_price,
             color  = color.new(c_tp, 40),
             style  = line.style_dotted,
             width  = 1,
             extend = extend.right)

// ── Right-edge SL / TP labels — last bar only ─────────────────
if barstate.islast
    if show_sl and not na(line_sl)
        label.new(
             x         = bar_index,
             y         = line.get_y2(line_sl),
             text      = "SL  " + str.tostring(line.get_y2(line_sl), format.mintick),
             color     = color.new(color.black, 100),
             textcolor = color.new(c_sl, 0),
             style     = label.style_label_left,
             size      = size.small)
    if show_tp and not na(line_tp)
        label.new(
             x         = bar_index,
             y         = line.get_y2(line_tp),
             text      = "TP  " + str.tostring(line.get_y2(line_tp), format.mintick),
             color     = color.new(color.black, 100),
             textcolor = color.new(c_tp, 0),
             style     = label.style_label_left,
             size      = size.small)

// ════════════════════════════════════════════════════════════
// INFO PANEL
// ════════════════════════════════════════════════════════════
var table tbl = table.new(
     position     = position.bottom_right,
     columns      = 2,
     rows         = 6,
     bgcolor      = color.new(#0d1117, 15),
     border_color = color.new(#30363d, 60),
     border_width = 1,
     frame_color  = color.new(#30363d, 40),
     frame_width  = 1)

if show_table and barstate.islast

    table.cell(tbl, 0, 0, "ST · Swing High  Long Only",
         text_color  = color.new(c_white, 30),
         text_size   = size.small,
         text_halign = text.align_left,
         bgcolor     = color.new(#161b22, 20))
    table.cell(tbl, 1, 0, "",
         bgcolor     = color.new(#161b22, 20))

    table.cell(tbl, 0, 1, "Trend",
         text_color  = color.new(c_white, 50),
         text_size   = size.small,
         text_halign = text.align_left)
    table.cell(tbl, 1, 1, is_bull ? "▲  Bullish" : "▼  Bearish",
         text_color  = is_bull ? c_bull : color.new(c_bear, 40),
         text_size   = size.small,
         text_halign = text.align_right)

    table.cell(tbl, 0, 2, "SuperTrend",
         text_color  = color.new(c_white, 50),
         text_size   = size.small,
         text_halign = text.align_left)
    table.cell(tbl, 1, 2, str.tostring(st_line, format.mintick),
         text_color  = is_bull ? c_bull : color.new(c_bear, 40),
         text_size   = size.small,
         text_halign = text.align_right)

    table.cell(tbl, 0, 3, "Watching",
         text_color  = color.new(c_white, 50),
         text_size   = size.small,
         text_halign = text.align_left)
    table.cell(tbl, 1, 3, na(sh_level) ? "—" : str.tostring(sh_level, format.mintick),
         text_color  = entry_taken ? color.new(c_swing, 60) : c_swing,
         text_size   = size.small,
         text_halign = text.align_right)

    table.cell(tbl, 0, 4, "R : R",
         text_color  = color.new(c_white, 50),
         text_size   = size.small,
         text_halign = text.align_left)
    table.cell(tbl, 1, 4, "1 : " + str.tostring(rr_ratio, "#.#"),
         text_color  = color.new(c_white, 20),
         text_size   = size.small,
         text_halign = text.align_right)

    table.cell(tbl, 0, 5, "Pre-Close",
         text_color  = color.new(c_white, 50),
         text_size   = size.small,
         text_halign = text.align_left)
    table.cell(tbl, 1, 5, is_nse ? "NSE 15:15 IST" : "NYSE 15:45 EST",
         text_color  = color.new(#ce93d8, 20),
         text_size   = size.small,
         text_halign = text.align_right)

// ════════════════════════════════════════════════════════════
// ALERTS
// ════════════════════════════════════════════════════════════
alertcondition(long_entry,
     title   = "Long Entry — Swing High Breakout",
     message = "LONG  {{ticker}}  {{interval}}\nClose above prior bearish phase high with bullish SuperTrend.\nEntry: {{close}}")

alertcondition(preclose_alert,
     title   = "⏰ Pre-Close Setup Alert",
     message = "PRE-CLOSE ALERT  {{ticker}}  {{interval}}\nPrice above resistance with bullish SuperTrend.\n15 min to market close — monitor for candle close.\nCurrent price: {{close}}")

alertcondition(bull_flip,
     title   = "SuperTrend → Bullish",
     message = "SuperTrend flipped BULLISH on {{ticker}}  {{interval}}. Watching for breakout above prior swing high.")
````
