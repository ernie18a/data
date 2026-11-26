#  UnR [IMPROVE VERSION] - Daily 8 & 21 EMA + Weekly 9 EMA

- url: https://www.tradingview.com/script/hNXzoGiD-UnR-IMPROVE-VERSION-Daily-8-21-EMA-Weekly-9-EMA/
- type: indicator
- pine_id: PUB;3d48664bb15a4baf8e01d65a60addc81
- version: 1.0

## Description

Improve version of UnR of Joel Liquori

Daily 8 & 21 EMA + Weekly 9 EMA — Indicator Description

Overview
This indicator plots three institutional-grade exponential moving averages — the Daily 8 EMA, Daily 21 EMA, and Weekly 9 EMA — directly on any intraday or daily chart. It is built for traders who use multi-timeframe EMA structure as the backbone of their trading decisions, and includes a proprietary Undercut & Rally signal engine that detects one of the most reliable mean-reversion setups in price action trading.
Whether you trade off 5-minute, 15-minute, or daily charts, the EMAs repaint smoothly in real time using the true daily and weekly values — so you always know exactly where price stands relative to the levels that institutional traders are watching.

Key Features

Daily 8 & 21 EMA plotted on any timeframe
Weekly 9 EMA plotted on any timeframe
Dynamic color fill between the 8 and 21 EMA (green = bullish stack, red = bearish stack)
Undercut & Rally signal with once-per-day filtering
Fully customizable labels: toggle, color, transparency, and size independently for every label type
Built-in alert conditions for crosses, EMA crossovers, and Undercut & Rally signals


The EMAs Explained
Daily 8 EMA
The fastest of the three. This is the short-term momentum line. Strong trending stocks and ETFs tend to ride above the 8 EMA during powerful uptrends. A close below it is often the first warning that momentum is fading.
Daily 21 EMA
The primary mean-reversion level used by swing traders and institutional desks. Healthy pullbacks in uptrending names will often find support at the 21 EMA before continuing higher. A sustained break below the 21 EMA signals a potential change in trend.
Weekly 9 EMA
The macro trend filter. This is the level that separates short-term noise from true trend direction. Price above the Weekly 9 EMA = bullish bias. Price below = proceed with extreme caution on the long side. Many professional growth stock traders use this as their ultimate line in the sand.

EMA Fill
The shaded region between the 8 and 21 EMA acts as a quick visual trend gauge:

Green fill — The 8 EMA is above the 21 EMA, indicating a bullish EMA stack. Favor long setups.
Red fill — The 8 EMA is below the 21 EMA, indicating a bearish EMA stack. Favor caution or short setups.

You can adjust the fill transparency (50–99) to keep the chart clean, or disable it entirely if you prefer a minimal look.

Undercut & Rally Signal
This is the core signal engine of the indicator. The Undercut & Rally (U&R) is a setup popularized by trader Richard Moglen (RDR) and rooted in the work of William O'Neil. It identifies moments where price briefly dips below a key EMA — shaking out weak holders — before snapping back above it with conviction.
How the signal works, step by step:

Within the lookback window (default: 3 bars), the low of at least one candle dips below the EMA
Price closes back above that EMA on the trigger bar
The next candle (confirmation bar) closes green (close > open) and remains above the EMA
Price is still below the daily opening price — meaning this is a reclaim from weakness, not a chase into strength
The signal fires only once per day per EMA, prioritizing the 8 EMA first, then 21, then Weekly 9

When all conditions align, a labeled arrow appears at the low of the confirmation candle pointing upward.
What it means in practice:
The market tested a key level, found buyers, and confirmed the reclaim with a green candle. This is not a random bounce — it is a structured, rules-based signal that a support level held and the bulls are back in control. The ideal entry is on the open of the candle after the confirmation, or on a pullback into the EMA with a tight stop below the undercut low.
Session Filter (optional):
Enable "Restrict to session 0930–1600" to limit signals to regular market hours only, filtering out pre-market and after-hours noise.

Settings Reference
EMA Display
SettingDescriptionShow Daily 8 / 21 EMAToggle each EMA line on or offShow Weekly 9 EMAToggle the weekly EMA on or off8 / 21 / 9W EMA ColorSet the color of each EMA lineLine WidthControls thickness of all EMA lines (1–4)Fill Between EMAsToggle the shaded region between 8 and 21 EMAFill TransparencyHow opaque the fill is (50 = solid, 99 = nearly invisible)
Price Labels (right-side EMA labels)
SettingDescriptionShow 8 / 21 / 9W EMA LabelToggle each price label independentlyLabel ColorBackground color of the label bubbleLabel Transparency0 = fully opaque, 99 = nearly invisibleLabel SizeTiny / Small / Normal / Large / Huge
Undercut Labels (signal arrow labels)
SettingDescriptionShow Undercut 8 / 21 / 9W LabelToggle each undercut label independentlyLabel ColorColor of the signal arrow labelLabel Transparency0 = fully opaque, 99 = nearly invisibleLabel SizeTiny / Small / Normal / Large / Huge
Undercut & Rally
SettingDescriptionShow Undercut & RallyMaster toggle for all U&R signalsEnable AlertconditionsEnables the alert conditions in TradingView's alert managerRestrict to session 0930–1600Filters signals to regular market hours onlyLookback bars for undercutHow many bars back to check for the EMA dip (default: 3)Confirm with next candleRequires the confirmation bar to close green above the EMA

Alerts
Five alert conditions are built in. Set them in TradingView's alert manager (the bell icon):

Price crossed Daily 8 EMA — fires on any cross up or down
Price crossed Daily 21 EMA — fires on any cross up or down
Price crossed Weekly 9 EMA — fires on any cross up or down
Daily 8/21 EMA Cross — fires when the 8 and 21 EMA cross each other (golden/death cross on daily)
Undercut & Rally (Any EMA) — fires when a confirmed U&R signal triggers on any of the three EMAs


Recommended Usage
Intraday traders (5m / 15m chart):
Use all three EMAs to see the true daily and weekly structure on your intraday chart. The Undercut & Rally signal is especially powerful on the 15-minute chart around the Daily 21 EMA during the first 90 minutes of the trading session.
Swing traders (daily chart):
Use the Weekly 9 EMA as your trend filter. Only take long setups when price is above it. Use the 21 EMA as your primary entry and stop zone. The Undercut & Rally on the daily chart near the 21 EMA is a classic institutional accumulation signal.
General rules of thumb:

Price above all three EMAs with green fill = strong bull trend, buy pullbacks
Price between the 8 and 21 EMA = chop zone, wait for resolution
Price below the 21 EMA but above the Weekly 9 = caution, possible base building
Price below all three EMAs = avoid longs, look for short setups or stay in cash


Notes

This indicator uses lookahead_on intentionally so that the forming daily/weekly bar's EMA value updates in real time across all intraday bars. This is by design — it reflects the live EMA level, not the prior day's close.
The once-per-day filter on the Undercut & Rally signal prevents signal spam on choppy days where price oscillates around an EMA repeatedly. Only the first qualifying signal of the session fires.
The indicator does not repaint historically — signals are confirmed on the close of the confirmation candle before being drawn.


This indicator is for educational and informational purposes only. It does not constitute financial advice. Always apply your own risk management and judgment before entering any trade.

## Source Code

````pine
//@version=6
indicator("Daily 8 & 21 EMA + Weekly 9 EMA", overlay=true, max_lines_count=10, max_labels_count=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
show8EMA        = input.bool(true,  "Show Daily 8 EMA")
show21EMA       = input.bool(true,  "Show Daily 21 EMA")
show9WEMA       = input.bool(true,  "Show Weekly 9 EMA")
color8          = input.color(color.new(#00E5FF, 0),  "8 EMA Color")
color21         = input.color(color.new(#FF6D00, 0),  "21 EMA Color")
color9W         = input.color(color.new(#FF1744, 0),  "9W EMA Color")
lineWidth       = input.int(2, "Line Width", minval=1, maxval=4)
showFill        = input.bool(true, "Fill Between EMAs")
fillTransp      = input.int(88, "Fill Transparency", minval=50, maxval=99)

// ─── PRICE LABEL CONTROLS ─────────────────────────────────────────────────────
showLabel8      = input.bool(true,  "Show 8 EMA Label",  group="Price Labels")
showLabel21     = input.bool(true,  "Show 21 EMA Label", group="Price Labels")
showLabel9W     = input.bool(true,  "Show 9W EMA Label", group="Price Labels")
labelColor8     = input.color(#00E5FF, "8 EMA Label Color",  group="Price Labels")
labelColor21    = input.color(#FF6D00, "21 EMA Label Color", group="Price Labels")
labelColor9W    = input.color(#FF1744, "9W EMA Label Color", group="Price Labels")
labelTransp8    = input.int(0,  "8 EMA Label Transparency",  minval=0, maxval=99, group="Price Labels")
labelTransp21   = input.int(0,  "21 EMA Label Transparency", minval=0, maxval=99, group="Price Labels")
labelTransp9W   = input.int(0,  "9W EMA Label Transparency", minval=0, maxval=99, group="Price Labels")
labelSizeOpt8   = input.string("Small", "8 EMA Label Size",  options=["Tiny","Small","Normal","Large","Huge"], group="Price Labels")
labelSizeOpt21  = input.string("Small", "21 EMA Label Size", options=["Tiny","Small","Normal","Large","Huge"], group="Price Labels")
labelSizeOpt9W  = input.string("Small", "9W EMA Label Size", options=["Tiny","Small","Normal","Large","Huge"], group="Price Labels")

// ─── UNDERCUT LABEL CONTROLS ──────────────────────────────────────────────────
showUCLabel8    = input.bool(true,  "Show Undercut 8 Label",  group="Undercut Labels")
showUCLabel21   = input.bool(true,  "Show Undercut 21 Label", group="Undercut Labels")
showUCLabel9W   = input.bool(true,  "Show Undercut 9W Label", group="Undercut Labels")
ucLabelColor8   = input.color(#00E5FF, "Undercut 8 Label Color",  group="Undercut Labels")
ucLabelColor21  = input.color(#FF6D00, "Undercut 21 Label Color", group="Undercut Labels")
ucLabelColor9W  = input.color(#FF1744, "Undercut 9W Label Color", group="Undercut Labels")
ucLabelTransp8  = input.int(0,  "Undercut 8 Label Transparency",  minval=0, maxval=99, group="Undercut Labels")
ucLabelTransp21 = input.int(0,  "Undercut 21 Label Transparency", minval=0, maxval=99, group="Undercut Labels")
ucLabelTransp9W = input.int(0,  "Undercut 9W Label Transparency", minval=0, maxval=99, group="Undercut Labels")
ucLabelSize8    = input.string("Small", "Undercut 8 Label Size",  options=["Tiny","Small","Normal","Large","Huge"], group="Undercut Labels")
ucLabelSize21   = input.string("Small", "Undercut 21 Label Size", options=["Tiny","Small","Normal","Large","Huge"], group="Undercut Labels")
ucLabelSize9W   = input.string("Small", "Undercut 9W Label Size", options=["Tiny","Small","Normal","Large","Huge"], group="Undercut Labels")

// ─── UNDERCUT & RALLY INPUTS ──────────────────────────────────────────────────
showUndercutRally   = input.bool(true,  "Show Undercut & Rally",                          group="Undercut & Rally")
alertUndercutRally  = input.bool(true,  "Enable Undercut & Rally Alertconditions",        group="Undercut & Rally")
sessionFilter       = input.bool(false, "Restrict to session 0930–1600",                  group="Undercut & Rally")
undercutBars        = input.int(3,      "Lookback bars for undercut", minval=1, maxval=10, group="Undercut & Rally")
confirmGreen        = input.bool(true,  "Confirm with next candle: green (close > open)",  group="Undercut & Rally")

// ─── HELPER FUNCTIONS ─────────────────────────────────────────────────────────
f_labelSize(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

f_had_undercut(ema_series, lookback) =>
    had = false
    for i = 0 to lookback - 1
        if low[i] < ema_series[i]
            had := true
    had

// ─── FETCH EMAs ───────────────────────────────────────────────────────────────
ema8_daily  = request.security(syminfo.tickerid, "1D", ta.ema(close, 8),  lookahead=barmerge.lookahead_on)
ema21_daily = request.security(syminfo.tickerid, "1D", ta.ema(close, 21), lookahead=barmerge.lookahead_on)
ema9_weekly = request.security(syminfo.tickerid, "1W", ta.ema(close, 9),  lookahead=barmerge.lookahead_on)
dailyOpen   = request.security(syminfo.tickerid, "1D", open,              lookahead=barmerge.lookahead_on)

// ─── SESSION GATE ─────────────────────────────────────────────────────────────
t         = time(timeframe.period, "0930-1600")
isOpen    = not na(t)
sessionOk = not sessionFilter or isOpen

// ─── PLOT LINES ───────────────────────────────────────────────────────────────
p8  = plot(show8EMA  ? ema8_daily  : na, "Daily 8 EMA",  color=color8,  linewidth=lineWidth,     style=plot.style_line)
p21 = plot(show21EMA ? ema21_daily : na, "Daily 21 EMA", color=color21, linewidth=lineWidth,     style=plot.style_line)
p9W = plot(show9WEMA ? ema9_weekly : na, "Weekly 9 EMA", color=color9W, linewidth=lineWidth + 1, style=plot.style_line)

// ─── FILL BETWEEN EMAs ────────────────────────────────────────────────────────
bullishFill = ema8_daily >= ema21_daily
fillColor   = showFill
             ? (bullishFill ? color.new(color.green, fillTransp) : color.new(color.red, fillTransp))
             : na
fill(p8, p21, color=fillColor, title="EMA Fill")

// ─── UNDERCUT & RALLY DETECTION ───────────────────────────────────────────────
had_undercut_8  = f_had_undercut(ema8_daily,  undercutBars)
had_undercut_21 = f_had_undercut(ema21_daily, undercutBars)
had_undercut_9W = f_had_undercut(ema9_weekly, undercutBars)

undercut_then_rally_8  = sessionOk and had_undercut_8  and close > ema8_daily
undercut_then_rally_21 = sessionOk and had_undercut_21 and close > ema21_daily
undercut_then_rally_9W = sessionOk and had_undercut_9W and close > ema9_weekly

nextCandleGreen         = close > open
prevWasUndercutRally_8  = undercut_then_rally_8[1]  and (not undercut_then_rally_8[2])
prevWasUndercutRally_21 = undercut_then_rally_21[1] and (not undercut_then_rally_21[2])
prevWasUndercutRally_9W = undercut_then_rally_9W[1] and (not undercut_then_rally_9W[2])

belowDailyOpen = close < dailyOpen

undercutRallySignal_8  = showUndercutRally and prevWasUndercutRally_8  and (not confirmGreen or nextCandleGreen) and (close > ema8_daily)  and belowDailyOpen
undercutRallySignal_21 = showUndercutRally and prevWasUndercutRally_21 and (not confirmGreen or nextCandleGreen) and (close > ema21_daily) and belowDailyOpen
undercutRallySignal_9W = showUndercutRally and prevWasUndercutRally_9W and (not confirmGreen or nextCandleGreen) and (close > ema9_weekly) and belowDailyOpen

// ─── ONCE-PER-DAY GATE ────────────────────────────────────────────────────────
dayId = time("1D")
var float lastFiredDay = na
canFireToday  = na(lastFiredDay) or (dayId != lastFiredDay)
oncePerDay_8  = undercutRallySignal_8  and canFireToday
oncePerDay_21 = undercutRallySignal_21 and canFireToday and (not oncePerDay_8)
oncePerDay_9W = undercutRallySignal_9W and canFireToday and (not oncePerDay_8) and (not oncePerDay_21)

if oncePerDay_8 or oncePerDay_21 or oncePerDay_9W
    lastFiredDay := dayId

// ─── UNDERCUT SIGNAL LABELS ───────────────────────────────────────────────────
if oncePerDay_8 and showUCLabel8
    label.new(bar_index, low, "Undercut 8",
         style     = label.style_label_up,
         color     = color.new(ucLabelColor8,  ucLabelTransp8),
         textcolor = color.white,
         size      = f_labelSize(ucLabelSize8))

if oncePerDay_21 and showUCLabel21
    label.new(bar_index, low, "Undercut 21",
         style     = label.style_label_up,
         color     = color.new(ucLabelColor21, ucLabelTransp21),
         textcolor = color.white,
         size      = f_labelSize(ucLabelSize21))

if oncePerDay_9W and showUCLabel9W
    label.new(bar_index, low, "Undercut 9W",
         style     = label.style_label_up,
         color     = color.new(ucLabelColor9W, ucLabelTransp9W),
         textcolor = color.white,
         size      = f_labelSize(ucLabelSize9W))

// ─── PRICE LABELS (right-side) ────────────────────────────────────────────────
if barstate.islast
    if show8EMA and showLabel8
        label.new(
             bar_index + 2, ema8_daily,
             text      = "8D EMA\n" + str.tostring(ema8_daily, format.mintick),
             color     = color.new(labelColor8,  labelTransp8),
             textcolor = color.white,
             style     = label.style_label_left,
             size      = f_labelSize(labelSizeOpt8))

    if show21EMA and showLabel21
        label.new(
             bar_index + 2, ema21_daily,
             text      = "21D EMA\n" + str.tostring(ema21_daily, format.mintick),
             color     = color.new(labelColor21, labelTransp21),
             textcolor = color.white,
             style     = label.style_label_left,
             size      = f_labelSize(labelSizeOpt21))

    if show9WEMA and showLabel9W
        label.new(
             bar_index + 2, ema9_weekly,
             text      = "9W EMA\n" + str.tostring(ema9_weekly, format.mintick),
             color     = color.new(labelColor9W, labelTransp9W),
             textcolor = color.white,
             style     = label.style_label_left,
             size      = f_labelSize(labelSizeOpt9W))

// ─── ALERTS ───────────────────────────────────────────────────────────────────
alertcondition(ta.cross(close, ema8_daily),       "Price crossed Daily 8 EMA",  "Price crossed the Daily 8 EMA")
alertcondition(ta.cross(close, ema21_daily),      "Price crossed Daily 21 EMA", "Price crossed the Daily 21 EMA")
alertcondition(ta.cross(close, ema9_weekly),      "Price crossed Weekly 9 EMA", "Price crossed the Weekly 9 EMA")
alertcondition(ta.cross(ema8_daily, ema21_daily), "Daily 8/21 EMA Cross",       "Daily 8 EMA crossed the Daily 21 EMA")

anyUndercut = oncePerDay_8 or oncePerDay_21 or oncePerDay_9W
alertcondition(alertUndercutRally and anyUndercut, title="Undercut & Rally (Any EMA)", message="Undercut & Rally {{ticker}} ({{interval}})")
````
