# Psychology Meter

- url: https://www.tradingview.com/script/fMSqR9MQ-Psychology-Meter/
- type: indicator
- pine_id: PUB;fc047654ae2d4d18a74aff9786d4b5c1
- version: 1.0

## Description

Psychology Meter

[b]WHAT IT DOES[/b]
This indicator reads crowd behaviour from data the chart can actually measure. For every candle it shows how much volume was bought versus sold, how many of the bars inside the candle were buyer-led or seller-led, and what the largest-volume bars inside the candle did. It then classifies the crowd into a psychological phase (panic, fear, hope, optimism, FOMO breakout, euphoria and others) and explains in plain words what that phase means and how traders usually handle it.

[b]HOW IT WORKS[/b]

1. Buy vs sell volume inside each candle
The script loads the lower-timeframe bars that make up each candle with request.security_lower_tf(). Each intrabar is classified with the tick rule: a bar that closes above its open is buyer-led, below its open is seller-led, and an unchanged bar keeps the direction of the previous bar. The volume of buyer-led bars is summed as buy volume, seller-led bars as sell volume.
- Auto intrabar timeframe: 5 minutes on a daily chart, 60 minutes on a weekly chart, 240 minutes on a monthly chart, 1 minute on intraday charts. You can override it.
- The dashboard shows how many intrabars were used and what share of the candle's volume they cover.
- If no intrabar data exists (old history, illiquid symbols), the meter falls back to an estimate based on where the candle closed in its range and labels it ESTIMATE.
This is a classification of price direction, not exchange trade-by-trade aggressor data.

[b]2. Big-money bars (proxy)[/b]
Intrabars whose volume is at least 3x the candle's average intrabar volume are flagged as big-money bars. The dashboard shows what share of that large volume was buying. Large orders tend to come from institutions, so this is a proxy for large players, not proof of who traded.

[b]3. Behaviour signals (closed bars only, no repainting)[/b]
- FOMO breakout: up close above the prior 252-bar high on at least 2x the 20-bar average volume.
- Euphoria: up close on at least 2.5x volume with RSI(14) above 75 and price more than 2.5 ATR above the 20-bar average.
- Panic: down close on at least 2.5x volume with RSI(14) below 35.
- Capitulation confirmed: a panic bar that closed in the upper 70% of its range, followed by a higher close on the next bar.
- Sellers in control: less than 35% of the last 20 bars' volume traded on up bars, with price below the 50-bar average.

[b]4. Crowd phase and mood gauge[/b]
Phases are assigned in priority order from the signals above and from price relative to the 50- and 200-bar averages and the 52-week high: Euphoria, Herd breakout (FOMO), Capitulation confirmed, Panic, Fear - sellers in control, Optimism at the high (anchoring), Optimism - uptrend, Anxiety - pullback, Hope - recovery, Depression - downtrend.
The mood gauge (0-100) averages RSI(14), position in the 52-week range, distance from the 20-bar average in ATR, and the 20-bar buyer share. It describes the current mood; it is not a forecast.
The recent buyers' average cost is the 60-bar volume-weighted average price, shown with how far holders are in profit or under water.

[b]5. Dashboard[/b]
The dashboard can be shown on the price chart, where it floats over the candles, or in the indicator's own pane. It can be placed in any of 9 positions, in three layouts:
- Compact (default): crowd phase, this candle's buy/sell split, big-money bars, last 20 bars, recent buyers' average cost, mood gauge and suggestion.
- Full: adds the number of buyer-led and seller-led intrabars, data source and coverage, distance from the 52-week high, what the phase means, the tested result for the current signal, bars since each signal, and notes.
- Phase only: a single line with the current crowd phase.
Text size can be set from Tiny to Large. The buy/sell volume columns in the pane can be hidden if you only want the dashboard.

[b]TESTED STATISTICS[/b]
The signal statistics shown in the dashboard come from a test on 75 liquid Egyptian Exchange (EGX) stocks, daily bars, June 2015 to September 2026, with entry at the next open and results measured 5 and 20 sessions later. For comparison, a typical day was up after 20 sessions 52% of the time with a median return of +0.5%.
- FOMO breakout: up after 5 sessions 57%, after 20 sessions 56%, median 20-session return +2.5%.
- Euphoria: up after 5 sessions 56%, after 20 sessions 55%, median +2.2%.
- Panic bought on the day: up after 5 sessions 46%, worse than a typical day.
- Capitulation confirmed: up after 20 sessions 57%, median +1.0% (small sample).
- Sellers in control: up after 20 sessions 49%, median 0.0%.
These are past frequencies on one market. They are not predictions and every signal had losing years. On any other market the dashboard states that the statistics were not tested there.

[b]HOW TO USE[/b]
- Use the daily chart for the tested signals; use lower timeframes to watch buy/sell volume during the session.
- Open the settings (gear icon) and choose the dashboard place, position and layout under Display. Pick a corner where your chart has empty space so the table does not cover the candles.
- Read the phase first, then check whether the current candle and the last 20 bars are buyer-led (above 55%) or seller-led (below 45%).
- A FOMO breakout with buyer-led volume and big-money bars buying is the strongest combination.
- Do not buy a panic bar on its own; wait for the next bar to close higher.
- Alerts are available for FOMO breakout, euphoria, panic, capitulation confirmed, sellers taking control, and big-money bars buying or selling. All alerts fire on bar close.

[b]OTHER MARKETS
[/b]The calculations work on any symbol that has real volume and intraday history: stocks, ETFs, futures and crypto. On forex and CFDs the volume is tick volume (a count of price changes), and the dashboard warns about this. Volume is detected from the data itself, not from the symbol's volume-type label; only symbols that have never had any volume show NO VOLUME DATA.

[b]LIMITATIONS[/b]
- Buy/sell volume is classified from intrabar price direction, not from exchange trade records. Data depth for intrabars depends on your TradingView plan and the symbol.
- Investor identity (for example foreign versus local, retail versus institutional) is not available inside TradingView and is not shown.
- The live candle's buy/sell split is labelled DEVELOPING until it closes.

This indicator is for education and analysis. It does not give financial advice.

## Source Code

````pine
//@version=6
indicator("Crowd Psychology Meter", shorttitle = "Psych Meter", overlay = false, max_labels_count = 50)

// ════════════════════════════════════════════════════════════════════════
// CROWD PSYCHOLOGY METER v1.2 (works on any symbol with volume; statistics tested on EGX)
// Reads crowd behaviour from what the chart can actually measure:
//   1) BUY vs SELL volume inside each candle, measured from lower-timeframe
//      (intrabar) bars: a minute bar that closes up counts as buyer-led, down
//      as seller-led, flat bars inherit the last direction (tick rule).
//      This is TradingView's standard up/down-volume method. It is NOT the
//      exchange's trade-by-trade buyer/seller data, which EGX does not publish
//      on TradingView. If no intrabar data exists, the meter falls back to an
//      ESTIMATE from where the candle closed in its range, and says so.
//   2) "Big-money minutes": intrabar bars whose volume is >= N x the average
//      intrabar volume of that candle. A PROXY for large players, not identity.
//   3) Behaviour signals tested on EGX daily data before being included.
//
// WHO IS BUYING (Egyptians / Arabs / foreigners, individuals / institutions):
//   The exchange publishes this ONLY for the whole market, once per session,
//   not per stock and not per candle. Pine cannot load outside data, so it
//   cannot appear here. It is reported in the daily post-session scan instead.
//
// OTHER MARKETS: the buy/sell measurement and all signals work on any symbol
// with real volume and intraday history. The tested statistics are EGX-only;
// on other markets the dashboard says so. Forex/CFD volume is tick count,
// not traded volume, and the meter warns about it.
//
// TESTED STATISTICS shown in the dashboard come from 75 liquid EGX stocks,
// daily bars, Jun 2015 - Sep 2026 (gamaat stocks excluded), entry at the next
// open, results at the close 5 and 20 sessions later. They are valid for the
// DAILY chart with default settings. Past frequencies, not guarantees.
// Typical day for comparison: up after 5 sessions 48%, after 20 sessions 52%,
// median 20-session return +0.5%.
//
// No repainting: signals and alerts are taken only on closed bars. The live
// candle's buy/sell split is shown as DEVELOPING until it closes.
// Not compile-verified by the author. Report any error with a screenshot.
// ════════════════════════════════════════════════════════════════════════

// ───────── Inputs ─────────
grpA = "Buy / sell measurement"
ltfIn   = input.timeframe("", "Intrabar timeframe (empty = auto)", group = grpA, tooltip = "Auto: daily chart uses 5-minute bars, weekly uses 60-minute, intraday uses 1-minute.")
bigMult = input.float(3.0, "Big-money minute = volume x average", minval = 1.5, step = 0.5, group = grpA)

grpS = "Behaviour signals (tested values - change only if you accept untested results)"
herdVol  = input.float(2.0, "FOMO breakout: volume x 20-bar average", minval = 1.0, step = 0.1, group = grpS)
climVol  = input.float(2.5, "Euphoria / panic: volume x 20-bar average", minval = 1.0, step = 0.1, group = grpS)
recentN  = input.int(3, "Signal stays 'recent' for (bars)", minval = 1, group = grpS)

grpD = "Display"
showMarks = input.bool(true, "Show signal marks on the price chart", group = grpD)
showTable = input.bool(true, "Show dashboard", group = grpD)
tableWhere = input.string("Price chart", "Dashboard shown on", options = ["Price chart", "Indicator pane"], group = grpD, tooltip = "Price chart: the dashboard floats over the candles, so it is never squeezed by a small pane.")
tablePos  = input.string("Bottom right", "Dashboard position", options = ["Top left", "Top center", "Top right", "Middle left", "Middle center", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = grpD)
tableMode = input.string("Compact", "Dashboard layout", options = ["Compact", "Full", "Phase only"], group = grpD, tooltip = "Compact: 7 key rows. Full: all 16 rows. Phase only: one line.")
txtSizeIn = input.string("Small", "Dashboard text size", options = ["Tiny", "Small", "Normal", "Large"], group = grpD)
showHist  = input.bool(true, "Show buy/sell volume bars in the pane", group = grpD)

// ───────── Colours ─────────
color C_BUY  = #1b8a4b
color C_SELL = #c0392b
color C_WARN = #b7791f
color C_INFO = #2a6f97

// ═════════════════ 1 · BUY vs SELL VOLUME (intrabar) ═════════════════
f_autoLtf() =>
    int s = timeframe.in_seconds()
    s >= 2419200 ? "240" : s >= 604800 ? "60" : s >= 86400 ? "5" : "1"

string ltf = ltfIn == "" ? f_autoLtf() : ltfIn
bool ltfOK = timeframe.in_seconds(ltf) < timeframe.in_seconds()

// Direction of each intrabar: up close = buyer-led, down close = seller-led,
// unchanged = same as the previous intrabar (tick rule)
f_intra() =>
    var int d = 0
    float pc = nz(close[1], open)
    d := close > open ? 1 : close < open ? -1 : close > pc ? 1 : close < pc ? -1 : d
    [nz(volume), d]

[ivol, idir] = request.security_lower_tf(syminfo.tickerid, ltf, f_intra(), ignore_invalid_timeframe = true)

int   nIn  = ltfOK ? array.size(ivol) : 0
float bV   = 0.0
float sV   = 0.0
float zV   = 0.0
int   nB   = 0
int   nS   = 0
float bigB = 0.0
float bigS = 0.0
int   nBig = 0
if nIn > 0
    float thr = array.avg(ivol) * bigMult
    for i = 0 to nIn - 1
        float vv = array.get(ivol, i)
        int   dd = array.get(idir, i)
        if dd == 1
            bV += vv
            nB += 1
        else if dd == -1
            sV += vv
            nS += 1
        else
            zV += vv
        if vv > 0 and vv >= thr
            nBig += 1
            if dd == 1
                bigB += vv
            else if dd == -1
                bigS += vv

bool  hasIntra = nIn > 0 and bV + sV > 0
float rng      = high - low
float cpos     = rng > 0 ? (close - low) / rng : 0.5
float estB     = nz(volume) * cpos
float buyVol   = hasIntra ? bV : estB
float sellVol  = hasIntra ? sV : nz(volume) - estB
float totBS    = buyVol + sellVol
float buyPct   = totBS > 0 ? buyVol / totBS * 100 : na
float netVol   = buyVol - sellVol
float covPct   = hasIntra and nz(volume) > 0 ? (bV + sV + zV) / volume * 100 : na
float bigTot   = bigB + bigS
float bigBuyPct = bigTot > 0 ? bigB / bigTot * 100 : na
float buy20    = math.sum(buyVol, 20)
float tot20    = math.sum(totBS, 20)
float buyPct20 = tot20 > 0 ? buy20 / tot20 * 100 : na

// ═════════════════ 2 · TESTED BEHAVIOUR SIGNALS ═════════════════
float atr    = ta.atr(14)
float ma20   = ta.sma(close, 20)
float ma50   = ta.sma(close, 50)
float ma200  = ta.sma(close, 200)
float vAvg   = ta.sma(volume, 20)[1]
float vr     = vAvg > 0 ? volume / vAvg : na
float rsi    = ta.rsi(close, 14)
float prevHi = ta.highest(high, 252)[1]
float lo252  = ta.lowest(low, 252)
float hi252  = ta.highest(high, 252)
bool  upBar  = close > close[1]
bool  dnBar  = close < close[1]
float upShare = math.sum(upBar ? volume : 0.0, 20) / math.sum(volume, 20)
float vwap60 = math.sum(close * volume, 60) / math.sum(volume, 60)

bool cHerd   = upBar and close > prevHi and vr >= herdVol
bool cEuph   = upBar and vr >= climVol and rsi > 75 and (close - ma20) / atr > 2.5
bool cPanic  = dnBar and vr >= climVol and rsi < 35
bool cPanOk  = cPanic[1] and cpos[1] >= 0.3 and close > close[1]
bool cNearHi = close >= prevHi * 0.97 and close <= prevHi
bool cSell   = upShare < 0.35 and close < ma50

// Closed bars only (no repaint)
bool sHerd  = barstate.isconfirmed and cHerd
bool sEuph  = barstate.isconfirmed and cEuph
bool sPanic = barstate.isconfirmed and cPanic
bool sPanOk = barstate.isconfirmed and cPanOk
bool sSell  = barstate.isconfirmed and cSell and not cSell[1]

int agoHerd  = ta.barssince(cHerd)
int agoEuph  = ta.barssince(cEuph)
int agoPanic = ta.barssince(cPanic)
int agoPanOk = ta.barssince(cPanOk)
bool rHerd  = not na(agoHerd) and agoHerd < recentN
bool rEuph  = not na(agoEuph) and agoEuph < recentN
bool rPanic = not na(agoPanic) and agoPanic < recentN
bool rPanOk = not na(agoPanOk) and agoPanOk < recentN

// ═════════════════ 3 · MOOD GAUGE (descriptive, not a forecast) ═════════════════
float pos52 = hi252 - lo252 > 0 ? (close - lo252) / (hi252 - lo252) * 100 : 50
float extSc = math.max(0, math.min(100, 50 + (close - ma20) / atr * 15))
float flowSc = na(buyPct20) ? upShare * 100 : buyPct20
float mood  = (nz(rsi, 50) + pos52 + extSc + flowSc) / 4
string moodTxt = mood < 20 ? "EXTREME FEAR" : mood < 40 ? "FEAR" : mood < 60 ? "NEUTRAL" : mood < 80 ? "GREED" : "EXTREME GREED"
color  moodCol = mood < 40 ? C_SELL : mood < 60 ? C_WARN : C_BUY

// ═════════════════ 4 · CROWD PHASE, MEANING, SUGGESTION ═════════════════
string phase = "NEUTRAL"
string means = "No clear crowd behaviour."
string sugg  = "No action from psychology alone."
string stat  = "Typical day: up after 20 sessions 52%, median +0.5%."
color  phCol = C_WARN
if bar_index < 252
    phase := "INSUFFICIENT DATA"
    means := "Needs 252 bars for the 52-week high and averages."
    sugg  := "Use a daily chart with at least one year of history."
    stat  := "-"
else if rEuph
    phase := "EUPHORIA (greed climax)"
    means := "The crowd is paying any price on huge volume, far above its average. Fear of missing out is at its peak."
    sugg  := "On EGX this usually continued short-term, but with violent swings. Do not open a new position here; if you hold, trail the stop under the climax bar's low."
    stat  := "Tested n=1,557: up after 5 sessions 56%, after 20 sessions 55%, median +2.2%. Typical dip first -4.4%."
    phCol := C_WARN
else if rHerd
    phase := "HERD BREAKOUT (FOMO)"
    means := "Price closed above its 52-week high on at least 2x normal volume. Everyone who bought in the past year is in profit, so there are no trapped sellers above."
    sugg  := "Best-tested setup on EGX. Enter at the next open or on a 1-3 day dip that holds above the old high; stop below the breakout bar's low."
    stat  := "Tested n=1,615: up after 5 sessions 57% (60% when the close is in the top quarter of the bar), after 20 sessions 56%, median +2.5%. Typical dip first -4.2%."
    phCol := C_BUY
else if rPanOk
    phase := "CAPITULATION CONFIRMED"
    means := "Panic sellers dumped on heavy volume, then the next session closed higher: buyers absorbed the panic."
    sugg  := "Small edge only. A speculative rebound: small size, stop under the panic low."
    stat  := "Tested n=181: up after 20 sessions 57%, median +1.0%. Small sample."
    phCol := C_INFO
else if rPanic
    phase := "PANIC (fear selling)"
    means := "Holders are dumping at any price: heavy volume, down close, RSI under 35."
    sugg  := "Do not catch it. Wait for the next session to close above the panic day's close."
    stat  := "Tested n=1,113: buying the panic day was up after 5 sessions only 46% - worse than a typical day."
    phCol := C_SELL
else if cSell
    phase := "FEAR - SELLERS IN CONTROL"
    means := "Less than 35% of the last 20 sessions' volume traded on up days, and price is below its 50-day average."
    sugg  := "Avoid new buys until buyer-led volume returns above 50%."
    stat  := "Tested n=22,718: up after 20 sessions 49%, median 0.0% - below a typical day."
    phCol := C_SELL
else if close > ma50 and ma50 > ma200 and cNearHi
    phase := "OPTIMISM AT THE HIGH (anchoring)"
    means := "The crowd is anchored on the 52-week high, within 3% of it. A close above it on heavy volume would release fear of missing out."
    sugg  := "Watch for the trigger: a close above " + str.tostring(prevHi, format.mintick) + " on 2x volume."
    stat  := "Tested n=5,956: up after 20 sessions 55%, median +1.5%. Weak and not stable by year."
    phCol := C_BUY
else if close > ma50 and ma50 > ma200
    phase := "OPTIMISM - UPTREND"
    means := "Recent buyers are mostly in profit and confident."
    sugg  := "Hold. Add only on pullbacks where candles turn buyer-led (buy volume over 55%)."
    phCol := C_BUY
else if close > ma200 and close < ma50
    phase := "ANXIETY - PULLBACK"
    means := "The long-term trend is intact, but recent buyers are nervous and selling."
    sugg  := "Wait for buyer-led candles at support before buying."
    phCol := C_WARN
else if close < ma200 and close > ma50
    phase := "HOPE - RECOVERY"
    means := "A short-term recovery inside a long-term downtrend. Holders who are under water sell when they get back to break-even."
    sugg  := "Expect selling near the recent buyers' average cost, " + str.tostring(vwap60, format.mintick) + "."
    phCol := C_WARN
else if close < ma200 and close < ma50
    phase := "DEPRESSION - DOWNTREND"
    means := "Below both the 50- and 200-day averages. Most recent buyers are losing."
    sugg  := "Stay out until price closes back above the 50-day average."
    phCol := C_SELL

// Market awareness: statistics were tested on EGX only
bool isEGX = syminfo.prefix == "EGX"
bool tickVol = syminfo.volumetype == "tick"
// Decide from the data itself: some exchanges (EGX included) report the
// volume type as "n/a" even though real volume is published.
float cumVol = ta.cum(nz(volume))
bool noVol = cumVol == 0
if not isEGX and stat != "-"
    stat := "Not tested on " + syminfo.prefix + ". EGX reference: " + stat
if noVol
    phase := "NO VOLUME DATA"
    means := "This symbol has no volume, so buying and selling cannot be measured."
    sugg  := "Use the meter on stocks, ETFs, futures or crypto with real volume."
    phCol := C_WARN

// ═════════════════ 5 · PLOTS ═════════════════
color buyCol  = barstate.isconfirmed ? color.new(C_BUY, 25) : color.new(C_BUY, 60)
color sellCol = barstate.isconfirmed ? color.new(C_SELL, 25) : color.new(C_SELL, 60)
plot(showHist ? buyVol : na, "Buy volume", color = buyCol, style = plot.style_columns, display = display.pane)
plot(showHist ? -sellVol : na, "Sell volume", color = sellCol, style = plot.style_columns, display = display.pane)
plot(showHist ? netVol : na, "Net (buy - sell)", color = chart.fg_color, linewidth = 1, display = display.pane)
hline(0, "Zero", color = color.new(color.gray, 50))

plotshape(showMarks and sHerd, "FOMO breakout", shape.triangleup, location.belowbar, C_BUY, text = "FOMO", textcolor = C_BUY, size = size.small, force_overlay = true)
plotshape(showMarks and sEuph, "Euphoria", shape.diamond, location.abovebar, C_WARN, text = "EUPH", textcolor = C_WARN, size = size.small, force_overlay = true)
plotshape(showMarks and sPanic, "Panic", shape.xcross, location.belowbar, C_SELL, text = "PANIC", textcolor = C_SELL, size = size.small, force_overlay = true)
plotshape(showMarks and sPanOk, "Capitulation confirmed", shape.circle, location.belowbar, C_INFO, text = "CAP OK", textcolor = C_INFO, size = size.small, force_overlay = true)

// ═════════════════ 6 · DASHBOARD ═════════════════
f_pos(string s) =>
    switch s
        "Top left"      => position.top_left
        "Top center"    => position.top_center
        "Top right"     => position.top_right
        "Middle left"   => position.middle_left
        "Middle center" => position.middle_center
        "Middle right"  => position.middle_right
        "Bottom left"   => position.bottom_left
        "Bottom center" => position.bottom_center
        => position.bottom_right

f_sz(string s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : s == "Large" ? size.large : size.small

f_v(float x) =>
    na(x) ? "-" : str.tostring(x, format.volume)

f_p(float x) =>
    na(x) ? "-" : str.tostring(x, "#.#") + "%"

// One dashboard row: label on the left, value on the right
f_row(table t, int r, string lbl, string val, color valCol, color bg, string sz, color fg) =>
    table.cell(t, 0, r, lbl, text_color = fg, text_size = sz, bgcolor = bg, text_halign = text.align_left)
    table.cell(t, 1, r, val, text_color = valCol, text_size = sz, bgcolor = bg, text_halign = text.align_left)

// force_overlay must be a fixed value, so one table is kept for each place
// and only the chosen one is created and filled.
bool onChart = tableWhere == "Price chart"
var table tbChart = na
var table tbPane  = na
if showTable and barstate.islast
    if onChart and na(tbChart)
        tbChart := table.new(f_pos(tablePos), 2, 16, bgcolor = color.new(chart.bg_color, 5), border_color = color.new(chart.fg_color, 85), border_width = 1, frame_color = color.new(chart.fg_color, 70), frame_width = 1, force_overlay = true)
    if not onChart and na(tbPane)
        tbPane := table.new(f_pos(tablePos), 2, 16, bgcolor = color.new(chart.bg_color, 5), border_color = color.new(chart.fg_color, 85), border_width = 1, frame_color = color.new(chart.fg_color, 70), frame_width = 1, force_overlay = false)
    table tb = onChart ? tbChart : tbPane
    sz = f_sz(txtSizeIn)
    color fg  = chart.fg_color
    color mut = color.new(chart.fg_color, 45)
    color hd  = color.new(chart.fg_color, 88)
    bool full    = tableMode == "Full"
    bool compact = tableMode == "Compact"
    string volNote = tickVol ? " - WARNING: tick volume (count of price changes), not traded volume" : ""
    string srcTxt = (hasIntra ? "Measured: " + str.tostring(nIn) + " bars of " + ltf + " min" + (na(covPct) ? "" : " - covers " + f_p(covPct) + " of volume") : "ESTIMATE from close position (no intrabar data)") + volNote
    string liveTxt = barstate.isconfirmed ? "closed" : "DEVELOPING"
    float plH = (close / vwap60 - 1) * 100
    string lastTxt = "FOMO " + (na(agoHerd) ? "-" : str.tostring(agoHerd) + " bars ago") + " | EUPH " + (na(agoEuph) ? "-" : str.tostring(agoEuph)) + " | PANIC " + (na(agoPanic) ? "-" : str.tostring(agoPanic)) + " | CAP OK " + (na(agoPanOk) ? "-" : str.tostring(agoPanOk))
    int r = 0

    // Header: always shown (this is the whole dashboard in "Phase only")
    table.cell(tb, 0, r, "Psych Meter - " + syminfo.ticker + " - " + timeframe.period, text_color = fg, text_size = sz, bgcolor = hd, text_halign = text.align_left)
    table.cell(tb, 1, r, phase, text_color = color.white, text_size = sz, bgcolor = phCol)
    r += 1

    if full or compact
        f_row(tb, r, "This candle (" + liveTxt + ")", "Buy " + f_v(buyVol) + "  vs  Sell " + f_v(sellVol) + "  = " + f_p(buyPct) + " buyer-led", nz(buyPct, 50) >= 55 ? C_BUY : nz(buyPct, 50) <= 45 ? C_SELL : fg, na, sz, fg)
        r += 1
    if full
        f_row(tb, r, "How many bars inside", hasIntra ? str.tostring(nB) + " buyer-led, " + str.tostring(nS) + " seller-led of " + str.tostring(nIn) + " (" + ltf + "-min bars, not trades)" : "Not available (no intrabar data)", fg, na, sz, fg)
        r += 1
    if full or compact
        f_row(tb, r, "Big-money minutes (proxy)", hasIntra and nBig > 0 ? str.tostring(nBig) + " large bars: " + f_p(bigBuyPct) + " buying (" + f_v(bigB) + " vs " + f_v(bigS) + ")" : "None this candle", na(bigBuyPct) ? mut : bigBuyPct >= 60 ? C_BUY : bigBuyPct <= 40 ? C_SELL : fg, na, sz, fg)
        r += 1
        f_row(tb, r, "Last 20 bars", f_p(buyPct20) + " of volume buyer-led", nz(buyPct20, 50) >= 55 ? C_BUY : nz(buyPct20, 50) <= 45 ? C_SELL : fg, na, sz, fg)
        r += 1
    if full
        f_row(tb, r, "Source", srcTxt, hasIntra ? mut : C_WARN, na, sz, fg)
        r += 1
    if full or compact
        f_row(tb, r, "Recent buyers' average cost", na(vwap60) ? "-" : str.tostring(vwap60, format.mintick) + " (60-bar VWAP): holders " + (plH >= 0 ? "+" : "") + str.tostring(plH, "#.#") + "% " + (plH >= 0 ? "in profit" : "under water"), plH >= 0 ? C_BUY : C_SELL, hd, sz, fg)
        r += 1
        f_row(tb, r, "Mood gauge", str.tostring(math.round(mood)) + " / 100 - " + moodTxt, moodCol, na, sz, fg)
        r += 1
    if full
        f_row(tb, r, "52-week high", na(prevHi) ? "-" : str.tostring(prevHi, format.mintick) + " (" + str.tostring((close / prevHi - 1) * 100, "#.#") + "% from close)", fg, na, sz, fg)
        r += 1
        f_row(tb, r, "Crowd phase", phase, phCol, hd, sz, fg)
        r += 1
        f_row(tb, r, "What it means", means, fg, na, sz, fg)
        r += 1
    if full or compact
        f_row(tb, r, "Suggestion", sugg, fg, na, sz, fg)
        r += 1
    if full
        f_row(tb, r, "EGX test result", stat, mut, na, sz, fg)
        r += 1
        f_row(tb, r, "Last signals", lastTxt, mut, na, sz, fg)
        r += 1
        f_row(tb, r, "Who is buying", isEGX ? "Egyptians / Arabs / foreigners: published by the exchange for the whole market only, not per stock." : "Investor-type data (who bought) is not available inside TradingView.", mut, na, sz, fg)
        r += 1
        f_row(tb, r, "Note", "Test results: EGX daily chart, default settings. Past frequencies, not a forecast.", mut, na, sz, fg)
        r += 1

// ═════════════════ 7 · ALERTS (closed bars only) ═════════════════
bool sBigBuy  = barstate.isconfirmed and hasIntra and nBig >= 3 and bigB >= 2 * bigS and bigB > 0
bool sBigSell = barstate.isconfirmed and hasIntra and nBig >= 3 and bigS >= 2 * bigB and bigS > 0
alertcondition(sHerd, "FOMO breakout", "Psych Meter: FOMO breakout above the 52-week high on {{ticker}} ({{interval}})")
alertcondition(sEuph, "Euphoria climax", "Psych Meter: euphoria climax on {{ticker}} ({{interval}})")
alertcondition(sPanic, "Panic selling", "Psych Meter: panic selling on {{ticker}} ({{interval}})")
alertcondition(sPanOk, "Capitulation confirmed", "Psych Meter: capitulation confirmed on {{ticker}} ({{interval}})")
alertcondition(sSell, "Sellers take control", "Psych Meter: sellers took control on {{ticker}} ({{interval}})")
alertcondition(sBigBuy, "Big-money minutes buying", "Psych Meter: large-volume minutes mostly buying on {{ticker}} ({{interval}})")
alertcondition(sBigSell, "Big-money minutes selling", "Psych Meter: large-volume minutes mostly selling on {{ticker}} ({{interval}})")
````
