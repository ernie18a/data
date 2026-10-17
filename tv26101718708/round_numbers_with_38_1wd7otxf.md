# Round Numbers with 3&8

- url: https://www.tradingview.com/script/1Wd7OTXF-Round-Numbers-with-3-8/
- type: indicator
- pine_id: PUB;0ec571e6fba54335990726c42c5a4d88
- version: 1.0

## Description

Round Numbers with 3&8 highlights the price levels that traders watch most: round numbers and the levels halfway between them. Optionally, it also adds 3 & 8 levels, which I use from my own trading experience.

It's a clean, informational tool: it draws the levels around current price and nothing else. No signals.

WHAT IT SHOWS

- Round numbers (always on): the main psychological levels.
- Mid levels (on by default): halfway between two round numbers.
- 3 & 8 levels (off by default, switch on in settings): the levels at 30% and 80% of the way between two round numbers.

Examples:
- EUR/USD: round numbers 1.1200 and 1.1300, mid level 1.1250, 3 & 8 levels 1.1230 and 1.1280.
- USD/JPY: round numbers 158.00 and 159.00, mid level 158.50, 3 & 8 levels 158.30 and 158.80.
- Gold: round numbers 4,000 and 5,000, mid level 4,500, 3 & 8 levels 4,300 and 4,800.

I use this indicator mainly on forex pairs, but it works on any market: gold, silver, oil, indices, crypto and more. The distance between round numbers is set automatically for each market:
- Forex: every 100 pips (0.01 on EUR/USD, 1.00 on yen pairs).
- Gold and S&P 500: every 1,000.
- Other markets: based on the price, e.g. US30 and Bitcoin every 1,000, silver every 1.
You can also set your own spacing in the settings.

WHY ROUND NUMBERS MATTER

Round numbers are psychological levels. Traders, banks and investors naturally think and place orders in round figures, so these levels attract a lot of interest, and price often reacts when it reaches them. This isn't only market folklore; research supports it:

- Traders favour round numbers. A Federal Reserve Bank of New York study of support and resistance levels published by trading firms found that around 70% ended in 0 and 96% ended in 0 or 5, far more than chance. Levels ending in 00 and 50 were especially common. Exchange rates also bounced off these published levels more often than off random levels, and part of that effect came from the round numbers themselves.
- Orders cluster around them. A second New York Fed study of real currency order data found that take-profit orders cluster exactly at round numbers, which helps explain why price often stalls or reverses there. Stop-loss orders cluster just beyond round numbers, so when a round number breaks, the triggered stops tend to speed the move up.
- It's not only forex. A study of the Dow Jones Industrial Average found that multiples of 100 acted as support and resistance, and that once the index broke through one, it tended to move further than it otherwise would have.

In practice, traders use round numbers as reference levels for entries, stop-losses and targets, and watch how price behaves when it reaches one: a rejection, or a clean break that may extend the move.

3 & 8 LEVELS (MY PERSONAL EXPERIENCE)

The 3 & 8 levels come from my own experience of watching, analysing and trading the forex market for many years, not from academic research. I've found that price often reacts well around the 3 and 8 levels on forex pairs (for example 1.1230 and 1.1280 on EUR/USD), and I use them for entries, targets and exit zones.

I also often treat the space between a 3 or 8 level and the nearest round number as a zone rather than a single line. For example, between 1.1280 and 1.1300, or between 1.1200 and 1.1230. This creates a 20 to 30 pip zone where, in my experience, the market has often reacted well historically.

The 3 & 8 levels are switched off by default. If you share this view or want to test it, switch them on in the settings.

SETTINGS

- Lines to show: how many levels are drawn around price, half below and half above (up to 20).
- Show mid levels: halfway levels on or off.
- Show 3 & 8 levels: on or off (off by default).
- Level spacing (0 = automatic): the distance between round numbers in price. Leave it at 0 for automatic spacing, or enter your own value, e.g. 0.005 for 50-pip spacing on EUR/USD or 10 for $10 spacing on oil.
- Round numbers / Mid levels / 3 & 8 levels: colour, width and style (solid, dashed or dotted) for each type, so you can match light or dark charts.
- Labels:
  – Show price labels: on or off.
  – Position: on the price scale, or a chosen number of bars to the right of the last candle (up to 500).
  – Label text colour.

NOTES

- Levels update automatically as price moves.
- If price-scale labels make the chart's vertical zoom too wide on low timeframes, switch labels to "Right of last candle" or tick "Scale price chart only" in TradingView's chart settings.
- This is an analysis tool, not a buy or sell signal. Use it alongside your own analysis and risk management.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────
//  Round Numbers with 3&8
//  Built by Jake Koel  ·  © jakekoel
// ─────────────────────────────────────────────────────────────
// Draws psychological price levels around the current price, on any market:
//   Round numbers  every "step"        e.g. EUR/USD 1.1200 · USD/JPY 159.00 · Gold 4000 · US30 51000
//   Mid levels     halfway             e.g. 1.1250 · 159.50 · 4500 · 51500
//   3 & 8 levels   (optional)          e.g. 1.1230 / 1.1280 · 4300 / 4800 · 51300 / 51800
indicator("Round Numbers with 3&8", shorttitle = "Round Numbers with 3&8", overlay = true, max_lines_count = 100, max_labels_count = 100)

// ───────────────────────── Inputs ─────────────────────────
int    nLines  = input.int(7, "Lines to show", minval = 2, maxval = 20, tooltip = "Total number of levels drawn around price: half below, half above.")
bool   showMid = input.bool(true, "Show mid levels")
bool   show38  = input.bool(false, "Show 3 & 8 levels")
float  stepIn  = input.float(0, "Level spacing (0 = automatic)", minval = 0, tooltip = "Distance between round numbers, in price. 0 = automatic:\n• Forex: 100 pips (EUR/USD 0.01, USD/JPY 1)\n• Gold and S&P 500: 1000\n• Other markets: based on the price, e.g. US30 and Bitcoin 1000, silver 1.\nEnter your own value to override, e.g. 0.005 for 50 pips on EUR/USD.")

string G_R  = "Round numbers"
color  colR = input.color(#787B86, "Colour", inline = "r", group = G_R)
int    wR   = input.int(1, "Width", minval = 1, maxval = 4, inline = "r", group = G_R)
string sR   = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "r", group = G_R)

string G_M  = "Mid levels"
color  colM = input.color(#787B86, "Colour", inline = "m", group = G_M)
int    wM   = input.int(1, "Width", minval = 1, maxval = 4, inline = "m", group = G_M)
string sM   = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "m", group = G_M)

string G_E  = "3 & 8 levels"
color  colE = input.color(#787B86, "Colour", inline = "e", group = G_E)
int    wE   = input.int(1, "Width", minval = 1, maxval = 4, inline = "e", group = G_E)
string sE   = input.string("Dashed", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "e", group = G_E)

string G_L     = "Labels"
bool   showLbl = input.bool(true, "Show price labels", group = G_L)
string lblPos  = input.string("Price scale", "Position", options = ["Price scale", "Right of last candle"], group = G_L, tooltip = "Price scale: labels sit on the price scale on the right edge of the chart. TradingView may stretch the chart's vertical zoom so all labelled levels fit; to stop that, choose 'Right of last candle' or tick 'Scale price chart only' in TradingView's chart settings.\nRight of last candle: labels sit a chosen number of bars to the right of the last candle.")
int    lblDist = input.int(20, "Distance from last candle (bars)", minval = 0, maxval = 500, group = G_L, tooltip = "Only used when Position is 'Right of last candle'.")
color  lblTxt  = input.color(color.white, "Label text colour", group = G_L)

// ───────────────────────── Setup ─────────────────────────
const int MAX_SLOTS = 20
float  tick   = syminfo.mintick
string TK     = str.upper(syminfo.ticker)
bool   equity = syminfo.type == "stock" or syminfo.type == "fund" or syminfo.type == "dr"

isGold() =>
    not equity and (syminfo.root == "GC" or syminfo.root == "MGC" or str.contains(TK, "XAU") or str.contains(TK, "GOLD"))

isSP500() =>
    syminfo.root == "ES" or syminfo.root == "MES" or TK == "SPX" or TK == "SPX500" or TK == "US500" or TK == "SP500" or TK == "SPX500USD" or TK == "US500USD"

// Automatic distance between round numbers
autoStep(float px) =>
    if syminfo.type == "forex"
        tick * 1000                      // 100 pips on standard 5-digit / 3-digit (yen) quotes
    else if isGold() or isSP500()
        1000.0
    else
        math.pow(10, math.floor(math.log10(px)) - 1)   // e.g. 51600 -> 1000, 84000 -> 1000, 60.4 -> 1

styleOf(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

var array<line>  lns   = array.new<line>()
var array<label> lbs   = array.new<label>()
var array<float> slotP = array.new_float(MAX_SLOTS, na)
var array<color> slotC = array.new_color(MAX_SLOTS, na)

// ───────────────────────── Levels (rebuilt on every update of the last candle) ─────────────────────────
// Each level is built as a whole number of price steps (ticks), so its type is known exactly
// and never depends on decimal rounding: block * 1000 ticks = 100 pips on standard quotes.
if barstate.islast
    for l in lns
        line.delete(l)
    lns.clear()
    for lb in lbs
        label.delete(lb)
    lbs.clear()
    for i = 0 to MAX_SLOTS - 1
        slotP.set(i, na)

    float step = stepIn > 0 ? stepIn : autoStep(close)
    if close > 0 and step > 0
        // The step as a whole number of price ticks; sub-levels need at least 10 ticks per step
        int  stepT = math.max(1, int(math.round(step / tick)))
        bool subOk = stepT >= 10
        bool useM  = showMid and subOk
        bool use38 = show38 and subOk
        int  o3    = int(math.round(stepT * 0.3))
        int  o5    = int(math.round(stepT * 0.5))
        int  o8    = int(math.round(stepT * 0.8))

        int perBlock = 1 + (useM ? 1 : 0) + (use38 ? 2 : 0)
        int reach    = int(math.ceil(nLines / perBlock)) + 2
        int base     = int(math.floor(close / (stepT * tick)))

        // All levels in ascending order, with their type: 0 = round, 1 = mid, 2 = 3 & 8
        array<float> prices = array.new_float()
        array<int>   types  = array.new_int()
        for b = base - reach to base + reach
            int t = b * stepT
            prices.push(t * tick)
            types.push(0)
            if use38
                prices.push((t + o3) * tick)
                types.push(2)
            if useM
                prices.push((t + o5) * tick)
                types.push(1)
            if use38
                prices.push((t + o8) * tick)
                types.push(2)

        // Half the lines below price, the rest at or above it
        int firstAbove = prices.size()
        for i = 0 to prices.size() - 1
            if prices.get(i) >= close
                firstAbove := i
                break
        int nBelow = int(math.floor(nLines / 2))
        int startI = math.max(0, firstAbove - nBelow)
        int endI   = math.min(prices.size() - 1, startI + nLines - 1)

        int slot = 0
        for i = startI to endI
            float  p  = math.round_to_mintick(prices.get(i))
            int    ty = types.get(i)
            color  c  = ty == 0 ? colR : ty == 1 ? colM : colE
            int    w  = ty == 0 ? wR : ty == 1 ? wM : wE
            string st = ty == 0 ? sR : ty == 1 ? sM : sE
            lns.push(line.new(bar_index - 1, p, bar_index, p, extend = extend.both, color = c, width = w, style = styleOf(st)))
            if showLbl and lblPos == "Right of last candle"
                lbs.push(label.new(bar_index + lblDist, p, str.tostring(p, "#,##0.#####"), style = label.style_label_left, color = c, textcolor = lblTxt, size = size.small))
            if slot < MAX_SLOTS
                slotP.set(slot, p)
                slotC.set(slot, c)
                slot += 1

// ───────────────────────── Labels on the price scale ─────────────────────────
// Each drawn level gets a label on the price scale (only the last candle has a value).
bool onScale = showLbl and lblPos == "Price scale" and barstate.islast
scaleVal(int i) => onScale ? slotP.get(i) : na
scaleCol(int i) => slotC.get(i)

plot(scaleVal(0),  "Level 1",  scaleCol(0),  display = display.price_scale, editable = false)
plot(scaleVal(1),  "Level 2",  scaleCol(1),  display = display.price_scale, editable = false)
plot(scaleVal(2),  "Level 3",  scaleCol(2),  display = display.price_scale, editable = false)
plot(scaleVal(3),  "Level 4",  scaleCol(3),  display = display.price_scale, editable = false)
plot(scaleVal(4),  "Level 5",  scaleCol(4),  display = display.price_scale, editable = false)
plot(scaleVal(5),  "Level 6",  scaleCol(5),  display = display.price_scale, editable = false)
plot(scaleVal(6),  "Level 7",  scaleCol(6),  display = display.price_scale, editable = false)
plot(scaleVal(7),  "Level 8",  scaleCol(7),  display = display.price_scale, editable = false)
plot(scaleVal(8),  "Level 9",  scaleCol(8),  display = display.price_scale, editable = false)
plot(scaleVal(9),  "Level 10", scaleCol(9),  display = display.price_scale, editable = false)
plot(scaleVal(10), "Level 11", scaleCol(10), display = display.price_scale, editable = false)
plot(scaleVal(11), "Level 12", scaleCol(11), display = display.price_scale, editable = false)
plot(scaleVal(12), "Level 13", scaleCol(12), display = display.price_scale, editable = false)
plot(scaleVal(13), "Level 14", scaleCol(13), display = display.price_scale, editable = false)
plot(scaleVal(14), "Level 15", scaleCol(14), display = display.price_scale, editable = false)
plot(scaleVal(15), "Level 16", scaleCol(15), display = display.price_scale, editable = false)
plot(scaleVal(16), "Level 17", scaleCol(16), display = display.price_scale, editable = false)
plot(scaleVal(17), "Level 18", scaleCol(17), display = display.price_scale, editable = false)
plot(scaleVal(18), "Level 19", scaleCol(18), display = display.price_scale, editable = false)
plot(scaleVal(19), "Level 20", scaleCol(19), display = display.price_scale, editable = false)

// ───────────────────────── Signature ─────────────────────────
var table info = table.new(position.bottom_right, 1, 1)
if barstate.islast
    table.cell(info, 0, 0, "@jakekoel", text_color = color.new(color.gray, 30), text_size = size.small)
````
