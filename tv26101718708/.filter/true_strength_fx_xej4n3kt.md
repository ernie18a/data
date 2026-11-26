# True Strength FX

- url: https://www.tradingview.com/script/XEj4n3KT-True-Strength-FX/
- type: indicator
- pine_id: PUB;a2855a80c71a441b8195d521f0acb0f0
- version: 1.0

## Description

True Strength FX shows you which currency is really driving a forex pair.

When EUR/USD falls, the chart alone can't tell you why. Is the euro weakening, or is the US dollar strengthening? Or both? The answer matters. If you're trading a hawkish Fed, you want to see the dollar gaining across the board, not a pair falling because of euro-specific news.

True Strength FX splits any major pair into its two currencies and plots each one as its own line underneath your chart, so you can see the real source of the move at a glance.

WHY I BUILT IT

I trade macro, and for years I used my own custom currency indexes in my TradingView watchlist to confirm my bias after central bank decisions and major data releases. Standard indexes like the DXY didn't work for this, because they're unevenly weighted. The euro makes up more than half of the DXY, so it often tells you more about EUR/USD than about the dollar as a whole.

I wanted indexes where every currency in the basket counts exactly the same. This indicator turns that idea into a tool anyone can add to their chart.

HOW IT WORKS

- Each of the 8 major currencies (USD, EUR, GBP, JPY, CHF, CAD, AUD, NZD) gets its own index, measured against the other 7.
- All 7 pairs in each basket carry equal weight at all times. The index averages the percentage moves of the pairs rather than adding up their prices, so a pair like USD/JPY (priced around 150) doesn't outweigh a pair like EUR/USD (priced around 1.10).
- Every pair is flipped where needed, so a rising line always means that currency is getting stronger.
- The indicator detects the pair on your chart automatically. Open GBP/JPY and you get a GBP line and a JPY line. Switch to AUD/CAD and it updates on its own.
- Both lines start at 0% from your chosen starting point, so you see exactly how much each currency has gained or lost since then.

HOW TO READ IT

Example: EUR/USD is falling.
- EUR line flat, USD line rising → the move is US dollar strength.
- EUR line falling, USD line flat → the move is euro weakness.
- EUR falling and USD rising → both are pushing the same way, which usually means a stronger, cleaner move.
- Both lines moving in the same direction → the two currencies are cancelling each other out, and the pair tends to go sideways.

WAYS TO USE IT

- Confirm a fundamental bias. After a central bank decision or a major data release, check whether the currency is actually strengthening against the whole basket, not just against one pair.
- Measure event reactions. Set the starting point to the exact time of an FOMC, ECB or CPI release and see how each currency has moved since.
- Choose the cleanest pair. If your bias is "strong USD," pick the pair where the other currency is also weak, so both sides work in your favour.
- Avoid one-sided traps. If a pair is moving but your currency isn't the driver, the move may not mean what you think it does.

SETTINGS

- Data source: price feed for all pairs (OANDA by default). Keep the same source across your charts.
- Backup data source: FX_IDC (ICE Data Services) by default.
- Backup data source: OANDA by default.
- Measure change from:
  – Visible chart start: both lines start at 0% at the left edge of your screen and reset when you scroll or zoom.
  – Custom date: pick an exact date and time, such as a central bank announcement.
  – Rolling bars: shows the % change over the last N bars.
- Rolling bars: the number of bars used in rolling mode.
- Show: Both, Base only or Quote only. Prefer each currency in its own pane? Add the indicator twice, set one to Base only and the other to Quote only.

NOTES

- Works on any pair between the 8 major currencies, on any timeframe. I mainly use it on the 4H, daily and weekly charts.
- If a currency can't be calculated, a grey label names the missing pairs. Switching the data source usually fixes it.
- This is an analysis tool, not a buy or sell signal. Use it alongside your own analysis and risk management.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────
//  True Strength FX
//  Built by Jake Koel  ·  © jakekoel
// ─────────────────────────────────────────────────────────────
// Shows whether a pair is moving because of the base currency or the quote currency.
// Each currency index is an equal-weighted basket of its 7 pairs against the other majors
// (average of percentage moves, so every pair always counts the same).
indicator("True Strength FX", shorttitle = "TSFX", overlay = false, precision = 2)

// ───────────────────────── Inputs ─────────────────────────
string srcPrefix  = input.string("OANDA", "Data source", options = ["OANDA", "FX_IDC", "FXCM", "FOREXCOM", "SAXO", "PEPPERSTONE"], tooltip = "Price feed used for all 7 pairs of each currency. Keep the same source across your charts.")
string anchorMode = input.string("Visible chart start", "Measure change from", options = ["Visible chart start", "Custom date", "Rolling bars"], tooltip = "Visible chart start: both lines start at 0% at the left edge of your screen.\nCustom date: e.g. the minute of an FOMC decision.\nRolling bars: % change over the last N bars.")
int    anchorDate = input.time(timestamp("2026-01-01T00:00:00"), "Custom date")
int    rollLen    = input.int(20, "Rolling bars", minval = 1)
bool   useBackup    = input.bool(true, "Use backup feed for missing pairs", tooltip = "If the main data source doesn't carry one of the pairs, that pair is taken from the backup feed instead, so the index can still be built.")
string backupPrefix = input.string("FX_IDC", "Backup data source", options = ["FX_IDC", "OANDA", "FXCM", "FOREXCOM", "SAXO", "PEPPERSTONE"])
string showMode   = input.string("Both", "Show", options = ["Both", "Base only", "Quote only"], tooltip = "Want two separate panes? Add the indicator twice: one set to Base only, the other to Quote only.")

// ───────────────────────── Setup ─────────────────────────
// Standard FX quoting order: a pair is always written with the earlier currency first (EURUSD, GBPJPY, AUDNZD...)
var CCY = array.from("EUR", "GBP", "AUD", "NZD", "USD", "CAD", "CHF", "JPY")

ccyColor(string c) =>
    switch c
        "USD" => #4CAF50   // green
        "EUR" => #2962FF   // blue
        "GBP" => #9C27B0   // purple
        "JPY" => #00BCD4   // light blue
        "CAD" => #F44336   // red
        "AUD" => #FF9800   // orange
        "NZD" => #C9A400   // dark yellow (gold)
        "CHF" => #8D6E63   // brown
        => color.gray

// Market name of the pair between c and o (earlier currency first)
pairName(string c, string o) =>
    CCY.indexof(c) < CCY.indexof(o) ? c + o : o + c

// Log price of currency c against currency o from one feed (flipped if the market quotes it the other way)
pairLogFrom(string src, string c, string o) =>
    bool  cFirst = CCY.indexof(c) < CCY.indexof(o)
    float lp     = request.security(src + ":" + pairName(c, o), timeframe.period, math.log(close), ignore_invalid_symbol = true)
    cFirst ? lp : -lp

// Main feed first; if that feed doesn't have the pair, use the backup feed
pairLog(string c, string o) =>
    float p = pairLogFrom(srcPrefix, c, o)
    float f = useBackup and backupPrefix != srcPrefix ? pairLogFrom(backupPrefix, c, o) : na
    na(p) ? f : p

// Equal-weighted index: average of the 7 log prices (= geometric mean of the pairs)
// Also returns the names of any pairs that had no data, so the problem can be shown on the chart
ccyIndex(string c) =>
    float  s    = 0.0
    int    n    = 0
    string miss = ""
    for o in CCY
        if o != c
            float v = pairLog(c, o)
            if not na(v)
                s += v
                n += 1
            else
                miss += (miss == "" ? "" : ", ") + pairName(c, o)
    [n == 7 ? s / 7 : na, miss]

pct(float x, float a) => (math.exp(x - a) - 1) * 100

fmt(float x) => (x >= 0 ? "+" : "") + str.tostring(x, "0.00") + "%"

// ───────────────────────── Currencies of the chart ─────────────────────────
string baseC  = syminfo.basecurrency
string quoteC = syminfo.currency
bool   valid  = CCY.includes(baseC) and CCY.includes(quoteC) and baseC != quoteC
if not valid
    runtime.error("True Strength FX works on pairs between the 8 majors: EUR, GBP, AUD, NZD, USD, CAD, CHF, JPY.")

[baseIdx, baseMiss]   = ccyIndex(baseC)
[quoteIdx, quoteMiss] = ccyIndex(quoteC)

// ───────────────────────── Starting point ─────────────────────────
bool rolling = anchorMode == "Rolling bars"
int  anchorT = anchorMode == "Custom date" ? anchorDate : chart.left_visible_bar_time

var float bAnchor = na
var float qAnchor = na
if not rolling and time >= anchorT
    if na(bAnchor)
        bAnchor := baseIdx
    if na(qAnchor)
        qAnchor := quoteIdx

float bChg = rolling ? pct(baseIdx, baseIdx[rollLen]) : pct(baseIdx, bAnchor)
float qChg = rolling ? pct(quoteIdx, quoteIdx[rollLen]) : pct(quoteIdx, qAnchor)

// ───────────────────────── Plots ─────────────────────────
color bCol = ccyColor(baseC)
color qCol = ccyColor(quoteC)
// Dark text on the yellow (NZD) label so it stays readable, white text on the rest
color bTxt = baseC == "NZD" ? color.black : color.white
color qTxt = quoteC == "NZD" ? color.black : color.white

plot(showMode != "Quote only" ? bChg : na, "Base currency", bCol, 2)
plot(showMode != "Base only" ? qChg : na, "Quote currency", qCol, 2)
hline(0, "Zero line", color.gray, hline.style_dotted)

// Name + % labels at the right edge
var label lb = na
var label lq = na
if barstate.islast
    label.delete(lb)
    label.delete(lq)
    if showMode != "Quote only" and not na(bChg)
        lb := label.new(bar_index, bChg, baseC + " " + fmt(bChg), style = label.style_label_left, color = bCol, textcolor = bTxt, size = size.small)
    if showMode != "Base only" and not na(qChg)
        lq := label.new(bar_index, qChg, quoteC + " " + fmt(qChg), style = label.style_label_left, color = qCol, textcolor = qTxt, size = size.small)

// Only appears if a currency can't be built: names the pairs with no data
var label lw = na
if barstate.islast
    label.delete(lw)
    string allMiss = baseMiss + (baseMiss != "" and quoteMiss != "" ? ", " : "") + quoteMiss
    if na(baseIdx) or na(quoteIdx)
        lw := label.new(bar_index, 0, "No data for: " + (allMiss == "" ? "unknown pair" : allMiss) + "\nTry another data source in settings", style = label.style_label_left, color = color.new(color.gray, 20), textcolor = color.white, size = size.small)

// Signature in the bottom-right corner of the indicator pane
var table sig = table.new(position.bottom_right, 1, 1, bgcolor = na, frame_width = 0, border_width = 0)
if barstate.islast
    table.cell(sig, 0, 0, "@jakekoel", text_color = color.new(color.gray, 30), text_size = size.small, bgcolor = na)
````
