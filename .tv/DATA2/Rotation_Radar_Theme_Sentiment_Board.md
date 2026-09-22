<!-- tradingview-pine-id: PUB;7cc2df50c6c3436d9d501c1619f52279 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Rotation Radar — Theme Sentiment Board

Source: https://www.tradingview.com/script/SmE5Zj3k-Rotation-Radar-Theme-Sentiment-Board/

## Description

# Rotation Radar - Theme Sentiment Board

**What it is:** an at-a-glance dashboard of market *sentiment and capital rotation* across regime, growth, physical/policy, cycle, and speculative (“froth”) thermometers.

**What it is not:** a buy list, a ranking of “best ETFs to own,” or a trading signal. Rows tell you where money is moving. They do not tell you where yours should go.

The table is built for one job: name the regime, name the leading layer, then open a chart. If you cannot do that in 30 seconds, you are staring at colors instead of using the tool.

--------------------

## What the table shows

Each row is a liquid US-listed ETF used as a thermometer for a theme.

**Ticker** - symbol actually requested (exchange prefix stripped; hover the cell for EXCHANGE:TICKER).

**Theme** - short label for the bid this fund is meant to represent.

**1D / 1W / 1M / 3M / YTD** - absolute total return on the *daily* series.
• 1W = 5 sessions
• 1M = 21 sessions
• 3M = 63 sessions
• YTD = vs first daily close of the calendar year

**1M vs B / 3M vs B** - absolute return minus the same-window return of SPY or QQQ (setting: Relative vs).

**Align** - how many of the five absolute windows are greater than 0% (see Align section).

Heat colors scale with the size of the move: deeper green / red = larger percentage. Grey = missing data or a mixed Align score.

Returns are always computed on daily bars, regardless of the chart timeframe you drop the indicator on.

--------------------

## Layers

Rows are grouped on purpose. Do not read the board as one flat leaderboard.

**REGIME** - the legend for everything below
SPY, QQQ, IWM, UUP, TLT, HYG, GLD

**GROWTH** - digital / software / compute stack
SMH, IGV, HACK, DTCR (data-center REITs *and* tower landlords)

**PHYSICAL / POLICY** - electrons, metals, fiscal, defence
XLE, OIH, URA, NLR, XLU, GRID, PAVE, COPX, REMX, GDX, SIL, SHLD

**CYCLE** - old-economy, credit, EM, batteries
XLI, IYT, KRE, XLF, XLV, EEM, EWY, KWEB, LIT

**FROTH** - speculative positioning, not structural themes
IBIT, WGMI, XBI, UFO, QTUM, BOTZ, ICLN

Hiding a layer in settings only hides rows. Pine still requests every symbol (TradingView limit: 40 unique request.*() calls).

--------------------

## Align

Align is a 0–5 *count*, not a score and not relative to the benchmark.

Each of 1D, 1W, 1M, 3M, YTD that is strictly positive adds 1. Missing or ≤ 0% adds 0. Displayed as n/5.

• 4/5 or 5/5 - green: most horizons up
• 0/5 or 1/5 - red: most horizons down
• 2/5 or 3/5 - grey: mixed

It does **not** use the vs-benchmark columns.
It does **not** treat +0.2% differently from +40%. Magnitude lives in the heat cells.

Read Align as consistency:

• 5/5 - bid across the whole lookback, not a one-day spike
• 4/5 - same idea; usually YTD or 1D is the odd window
• 1D/1W green and 3M/YTD red → often Align 2/5 → bounce in a loser
• 1D/1W red and 3M/YTD green → often Align 3/5 → pullback in a leader

Do not sort the published default by Align. Sort by 1M or 3M. Use Align as a filter on that sort.

--------------------

## How to use it

Work in this order every time: **header → layer vs layer → one ticker**. Never start at the hottest 1D cell.

### 1. Read REGIME first

• QQQ and IWM green, TLT red, HYG green → risk-on. Growth/froth greens are real bids, not squeezes.
• TLT and GLD green, HYG and IWM red → risk-off. Ignore a green SMH 1-day print.
• UUP ripping, EEM / KWEB / COPX red → dollar squeeze. Physical and EM strength is suspect until the dollar rolls.
• HYG red, KRE red, XLF holding → credit stress starting in regionals, not a full bank crisis yet.
• GLD green, GDX flatter → bullion bid (rates / geopolitics), not a miners cycle.

If REGIME is mixed, do not invent a narrative from PHYSICAL or FROTH. Mixed header = two-way tape.

### 2. Ask which layer is winning

The sections exist so you compare *layers*, not 39 unrelated lines.

• GROWTH > PHYSICAL - digital capex / multiple expansion (semis, software, cyber)
• PHYSICAL > GROWTH - bottleneck left the chip (power, grid, metals, defence, oil services)
• CYCLE green, GROWTH flat - old-economy / credit / industrial mid-cycle, not an AI melt-up
• FROTH Align 4–5 while HYG and IWM are red - speculative bid on a weak base. Positioning, not confirmation

A useful weekly habit: write one sentence.
Example: “Grid + uranium + copper beating SMH; XLV quiet; froth dead.”
That sentence is the output. The cells are evidence.

### 3. Prefer relative columns

Sort by **1M** or **3M**, not 1D.

• Green 1M vs B / 3M vs B = beating the benchmark you chose. That is leadership.
• Absolute +8% when SPY is +9% is camouflage. Align can still print 5/5.
• Set Relative vs to **QQQ** when the question is “is this beating growth?” GRID vs QQQ is the AI-power question. GRID vs SPY is “is anything working?” Those are different questions.

1D answers “what is being chased into the close.” Useful after you already know the regime. Dangerous as a sort key.

### 4. Watch pairs that are supposed to diverge

If a pair moves together, you learned nothing. If they split, you did.

• SMH vs GRID / XLU / NLR - bottleneck still in chips, or already in power
• URA vs NLR - spot uranium / miners vs nuclear utilities and PPAs
• COPX vs XLI - copper-specific / China+grid vs broad industrials
• GDX vs GLD - miner leverage vs bullion
• SIL vs GDX - silver / industrial kicker vs gold
• KRE vs XLF - regional credit vs megabanks
• XLV vs SMH - defensive equity rotation
• PAVE vs GRID - US construction / fiscal vs electrical equipment
• DTCR vs SMH - towers / REIT rates vs compute hardware
• EWY vs SMH - Korea / memory satellite vs US-listed semis
• XBI vs XLV - speculative biotech vs healthcare cash-flow
• IBIT vs WGMI - coin bid vs miner leverage (same idea as GLD / GDX)
• HACK vs IGV - security spend vs broad software

### 5. A practical cadence

**Weekly (Monday or Sunday night)**
Sort by 1M. Note the top three and bottom three per layer. Write one sentence on regime.

**During the week**
Look at 1D only if you already have a thesis. “Is the PHYSICAL bid still there today?” - not “what’s hot.”

**After a shock** (CPI, FOMC, geopolitics)
REGIME first: TLT, UUP, HYG, GLD, IWM. Then see which theme *layer* flipped. Froth will whip; ignore it for two or three sessions.

Do not rebalance a portfolio off this table. A theme can lead for months and still be a bad holding.

--------------------

## When the board is lying

• Everything green - beta rally. Use vs-QQQ and look for the *least* extended layer, or do nothing.
• Everything red except gold / TLT - de-risking. “Cheap” physical names can still fall.
• One name 5/5, rest of its layer 1/5 - idiosyncratic (contract, squeeze, ETF flow). Not a theme.
• YTD Align still high after a three-month collapse - leftover from January. Trust 1M / 3M more than YTD in the back half of the year.

--------------------

## How people misuse it

• Treating 5/5 as a buy. That is often late.
• Adding risk because 1D is the greenest cell. That is the crowded chase.
• Reading ICLN, UFO, QTUM, BOTZ as structural themes. They sit in FROTH on purpose: they confirm risk appetite; they do not define the cycle.
• Forcing a story when REGIME and the winning layer disagree. Dollar up + COPX 5/5 is usually a trap until one of them yields.
• Watching all 39 rows equally. Semis, copper, HYG, and TLT explain more of global risk appetite than space, quantum, and clean energy combined.

--------------------

## Settings

• **Layer toggles** (default: all on) - display only. Requests still run.
• **Sort by** (default: 1M) - use 1M or 3M for rotation; 1D for tape-reading; OFF to keep listed order.
• **Strongest first** (default: on) - sorts inside each layer, not across the whole universe.
• **Relative vs** (default: SPY) - switch to QQQ to test leadership against growth.
• **Show vs benchmark** (default: on) - hide if you want a narrower table.
• **Table position / text size / colors** - cosmetic.

If a row prints "-", TradingView did not resolve that EXCHANGE:TICKER. Open the fund on a chart and copy the exact symbol from the header (AMEX:, NASDAQ:, BATS:, NYSE:). NYSE Arca ETFs usually resolve as AMEX: on TradingView. TLT is NASDAQ:TLT.

--------------------

## Design notes (why these funds)

Thermometers were chosen for *liquidity and distinct tapes*, not for “best theme ETF to own.”

• SMH, not SOXX - same semiconductor complex, one slot.
• No SKYY - too close to QQQ via AMZN / MSFT / GOOGL. IGV covers software.
• DTCR is labeled “data ctr / towers” because towers (AMT, CCI, SBAC) are a large weight. It is not a pure AI data-center developer fund.
• URA and NLR both stay: miners / spot uranium vs nuclear utilities and the fuel cycle.
• PAVE and GRID both stay: US construction / fiscal vs electrical equipment and smart grid.
• XLF and KRE both stay: megabanks vs regionals (credit-stress split).
• XBI instead of ARKG, UFO instead of ARKX - index / rules-based tapes, not an active manager’s book. ARK funds measure Cathie Wood + ARK flows. That is a positioning gauge, not a theme.
• ICLN stays in FROTH: it is a rates-and-China-solar punchbag, not a clean “energy transition” pulse.

Known gaps (left empty on purpose, given the 40-request cap): no dedicated HBM/memory ETF (infer from SMH vs EWY), no pure Europe-defence line (SHLD is global primes + defence tech), no water line.

--------------------

## Disclaimer

This script is for research and tape-reading. It is not investment advice, a recommendation, or an offer to buy or sell any security. Theme ETFs are concentrated, often expensive, and often correlate with Nasdaq even when the label says otherwise. Past returns shown in the table are not a forecast. You are responsible for symbol availability on your data feed and for any decision you make after looking at the board.

---

## Source Code

````pine
//@version=6
indicator("Rotation Radar — Theme Sentiment Board", overlay = true)

// -----------------------------------------------------------------------------
// Rotation Radar
// Sentiment / capital-rotation table. Not a buy list.
// Unique request.security() calls: 39 (TV limit is 40).
// Relative columns reuse SPY or QQQ already in the REGIME block — no extra feed.
// -----------------------------------------------------------------------------

grpVis  = "Display"
grpSort = "Ranking"
grpRel  = "Relative strength"
grpCol  = "Colors"

showRegime   = input.bool(true, "Regime",             group = grpVis)
showGrowth   = input.bool(true, "Growth stack",       group = grpVis)
showPhysical = input.bool(true, "Physical / policy",  group = grpVis)
showCycle    = input.bool(true, "Cycle",              group = grpVis)
showFroth    = input.bool(true, "Froth / satellites", group = grpVis)

sortBy   = input.string("1M", "Sort by", options = ["OFF", "1D", "1W", "1M", "3M", "YTD"], group = grpSort)
sortDesc = input.bool(true, "Strongest first", group = grpSort)

relVs   = input.string("SPY", "Relative vs", options = ["SPY", "QQQ"], group = grpRel)
showRel = input.bool(true, "Show vs benchmark (1M / 3M)", group = grpRel)

tblPos  = input.string("top_right", "Table position",
     options = ["top_right", "top_left", "middle_left", "middle_center", "bottom_right", "bottom_left"], group = grpVis)
txtSize = input.string("tiny", "Text size", options = ["tiny", "small", "normal"], group = grpVis)

bullCol = input.color(color.new(#089981, 0), "Up",         group = grpCol)
bearCol = input.color(color.new(#f23645, 0), "Down",       group = grpCol)
hdrBg   = input.color(color.new(#131722, 0), "Header bg",  group = grpCol)
hdrFg   = input.color(color.white,           "Header tx",  group = grpCol)
secBg   = input.color(color.new(#2a2e39, 0), "Section bg", group = grpCol)
rowBg   = input.color(color.new(#1e222d, 0), "Row bg",     group = grpCol)
neutBg  = input.color(color.new(#363a45, 0), "NA / zero",  group = grpCol)

f_pos() =>
    switch tblPos
        "top_left"     => position.top_left
        "bottom_right" => position.bottom_right
        "bottom_left"  => position.bottom_left
        "middle_left"  => position.middle_left
        "middle_center" => position.middle_center
        => position.top_right

f_size() =>
    switch txtSize
        "small"  => size.small
        "normal" => size.normal
        => size.tiny

f_heat(float v) =>
    if na(v)
        neutBg
    else
        a = math.min(80, math.abs(v) * 5)
        color.new(v >= 0 ? bullCol : bearCol, 85 - a)

f_txt(float v) =>
    na(v) ? "—" : str.tostring(v, v >= 0 ? "+#.##" : "#.##") + "%"

// Display ticker without exchange prefix (AMEX:SPY → SPY)
f_sym(string tkr) =>
    int p = str.pos(tkr, ":")
    p >= 0 ? str.substring(tkr, p + 1) : tkr

// One daily request per ticker. YTD from first daily close of the calendar year.
f_pack() =>
    float start = ta.valuewhen(year != year[1], close, 0)
    start := na(start) ? close : start
    [close / close[1] - 1, close / close[5] - 1, close / close[21] - 1, close / close[63] - 1, close / start - 1]

f_req(string ticker) =>
    request.security(ticker, "D", f_pack(), ignore_invalid_symbol = true)

type Theme
    string layer
    string name
    string ticker
    float  d1
    float  w1
    float  m1
    float  m3
    float  ytd
    float  rel1m
    float  rel3m

f_theme(string layer, string name, string ticker) =>
    [d1, w1, m1, m3, ytd] = f_req(ticker)
    Theme.new(layer, name, ticker, d1 * 100, w1 * 100, m1 * 100, m3 * 100, ytd * 100, na, na)

// ----- 39 unique securities (limit 40) ---------------------------------------
// REGIME 7
t00 = f_theme("REGIME",   "S&P 500",           "AMEX:SPY")
t01 = f_theme("REGIME",   "Nasdaq 100",        "NASDAQ:QQQ")
t02 = f_theme("REGIME",   "Russell 2000",      "AMEX:IWM")
t03 = f_theme("REGIME",   "US Dollar",         "AMEX:UUP")
t04 = f_theme("REGIME",   "Long Treasuries",   "NASDAQ:TLT")
t05 = f_theme("REGIME",   "High Yield",        "AMEX:HYG")
t06 = f_theme("REGIME",   "Gold",              "AMEX:GLD")

// GROWTH 4  (SKYY dropped — ~Nasdaq clone via AMZN/MSFT/GOOGL)
t10 = f_theme("GROWTH",   "Semiconductors",    "NASDAQ:SMH")
t12 = f_theme("GROWTH",   "Software",          "AMEX:IGV")
t14 = f_theme("GROWTH",   "Cybersecurity",     "AMEX:HACK")
t15 = f_theme("GROWTH",   "Data ctr / towers", "NASDAQ:DTCR")

// PHYSICAL 12
t20 = f_theme("PHYSICAL", "Oil & gas",         "AMEX:XLE")
t21 = f_theme("PHYSICAL", "Oil services",      "AMEX:OIH")
t22 = f_theme("PHYSICAL", "Uranium miners",    "AMEX:URA")
t23 = f_theme("PHYSICAL", "Nuclear complex",   "AMEX:NLR")
t24 = f_theme("PHYSICAL", "Utilities",         "AMEX:XLU")
t25 = f_theme("PHYSICAL", "Smart grid",        "NASDAQ:GRID")
t2c = f_theme("PHYSICAL", "US infrastructure", "AMEX:PAVE")
t26 = f_theme("PHYSICAL", "Copper miners",     "AMEX:COPX")
t27 = f_theme("PHYSICAL", "Rare earths",       "AMEX:REMX")
t28 = f_theme("PHYSICAL", "Gold miners",       "AMEX:GDX")
t29 = f_theme("PHYSICAL", "Silver miners",     "AMEX:SIL")
t2b = f_theme("PHYSICAL", "Defence tech",      "AMEX:SHLD")

// CYCLE 9
t30 = f_theme("CYCLE",    "Industrials",       "AMEX:XLI")
t31 = f_theme("CYCLE",    "Transports",        "AMEX:IYT")
t32 = f_theme("CYCLE",    "Banks (regional)",  "AMEX:KRE")
t33 = f_theme("CYCLE",    "Financials",        "AMEX:XLF")
t38 = f_theme("CYCLE",    "Healthcare",        "AMEX:XLV")
t34 = f_theme("CYCLE",    "Emerging mkts",     "AMEX:EEM")
t35 = f_theme("CYCLE",    "Korea",             "AMEX:EWY")
t36 = f_theme("CYCLE",    "China internet",    "AMEX:KWEB")
t37 = f_theme("CYCLE",    "Lithium",           "AMEX:LIT")

// FROTH 7
t40 = f_theme("FROTH",    "Bitcoin spot",      "NASDAQ:IBIT")
t41 = f_theme("FROTH",    "BTC miners",        "NASDAQ:WGMI")
t42 = f_theme("FROTH",    "Biotech",           "AMEX:XBI")
t43 = f_theme("FROTH",    "Space",             "NASDAQ:UFO")
t44 = f_theme("FROTH",    "Quantum",           "AMEX:QTUM")
t45 = f_theme("FROTH",    "Robotics / AI",     "NASDAQ:BOTZ")
t46 = f_theme("FROTH",    "Clean energy",      "NASDAQ:ICLN")

// Relative vs already-loaded SPY or QQQ — zero extra request.*()
float b1m = relVs == "QQQ" ? t01.m1 : t00.m1
float b3m = relVs == "QQQ" ? t01.m3 : t00.m3

f_rel(Theme t) =>
    t.rel1m := t.m1 - b1m
    t.rel3m := t.m3 - b3m
    t

t00 := f_rel(t00)
t01 := f_rel(t01)
t02 := f_rel(t02)
t03 := f_rel(t03)
t04 := f_rel(t04)
t05 := f_rel(t05)
t06 := f_rel(t06)
t10 := f_rel(t10)
t12 := f_rel(t12)
t14 := f_rel(t14)
t15 := f_rel(t15)
t20 := f_rel(t20)
t21 := f_rel(t21)
t22 := f_rel(t22)
t23 := f_rel(t23)
t24 := f_rel(t24)
t25 := f_rel(t25)
t2c := f_rel(t2c)
t26 := f_rel(t26)
t27 := f_rel(t27)
t28 := f_rel(t28)
t29 := f_rel(t29)
t2b := f_rel(t2b)
t30 := f_rel(t30)
t31 := f_rel(t31)
t32 := f_rel(t32)
t33 := f_rel(t33)
t38 := f_rel(t38)
t34 := f_rel(t34)
t35 := f_rel(t35)
t36 := f_rel(t36)
t37 := f_rel(t37)
t40 := f_rel(t40)
t41 := f_rel(t41)
t42 := f_rel(t42)
t43 := f_rel(t43)
t44 := f_rel(t44)
t45 := f_rel(t45)
t46 := f_rel(t46)

f_key(Theme t) =>
    switch sortBy
        "1D"  => t.d1
        "1W"  => t.w1
        "1M"  => t.m1
        "3M"  => t.m3
        "YTD" => t.ytd
        => na

if barstate.islast
    themes = array.new<Theme>()
    if showRegime
        array.push(themes, t00)
        array.push(themes, t01)
        array.push(themes, t02)
        array.push(themes, t03)
        array.push(themes, t04)
        array.push(themes, t05)
        array.push(themes, t06)
    if showGrowth
        array.push(themes, t10)
        array.push(themes, t12)
        array.push(themes, t14)
        array.push(themes, t15)
    if showPhysical
        array.push(themes, t20)
        array.push(themes, t21)
        array.push(themes, t22)
        array.push(themes, t23)
        array.push(themes, t24)
        array.push(themes, t25)
        array.push(themes, t2c)
        array.push(themes, t26)
        array.push(themes, t27)
        array.push(themes, t28)
        array.push(themes, t29)
        array.push(themes, t2b)
    if showCycle
        array.push(themes, t30)
        array.push(themes, t31)
        array.push(themes, t32)
        array.push(themes, t33)
        array.push(themes, t38)
        array.push(themes, t34)
        array.push(themes, t35)
        array.push(themes, t36)
        array.push(themes, t37)
    if showFroth
        array.push(themes, t40)
        array.push(themes, t41)
        array.push(themes, t42)
        array.push(themes, t43)
        array.push(themes, t44)
        array.push(themes, t45)
        array.push(themes, t46)

    if sortBy != "OFF"
        n = array.size(themes)
        if n > 1
            for i = 0 to n - 2
                for j = 0 to n - 2 - i
                    a = array.get(themes, j)
                    c = array.get(themes, j + 1)
                    ka = f_key(a)
                    kc = f_key(c)
                    doSwap = a.layer == c.layer and not na(ka) and not na(kc) and (sortDesc ? ka < kc : ka > kc)
                    if doSwap
                        array.set(themes, j, c)
                        array.set(themes, j + 1, a)

    int cols = showRel ? 10 : 8
    var table tbl = table.new(f_pos(), cols, 80, border_width = 1, border_color = color.new(color.black, 50), frame_width = 1, frame_color = color.new(color.black, 0))
    table.clear(tbl, 0, 0, cols - 1, 79)

    hdrs = array.from("Ticker", "Theme", "1D", "1W", "1M", "3M", "YTD")
    if showRel
        array.push(hdrs, "1M vs " + relVs)
        array.push(hdrs, "3M vs " + relVs)
    array.push(hdrs, "Align")

    for i = 0 to array.size(hdrs) - 1
        table.cell(tbl, i, 0, array.get(hdrs, i), bgcolor = hdrBg, text_color = hdrFg, text_size = f_size(), text_halign = text.align_center)

    int row = 1
    string lastL = ""
    for t in themes
        if t.layer != lastL
            lastL := t.layer
            table.merge_cells(tbl, 0, row, cols - 1, row)
            table.cell(tbl, 0, row, t.layer, bgcolor = secBg, text_color = color.white, text_size = f_size(), text_halign = text.align_left)
            row += 1

        int align = 0
        align += not na(t.d1)  and t.d1  > 0 ? 1 : 0
        align += not na(t.w1)  and t.w1  > 0 ? 1 : 0
        align += not na(t.m1)  and t.m1  > 0 ? 1 : 0
        align += not na(t.m3)  and t.m3  > 0 ? 1 : 0
        align += not na(t.ytd) and t.ytd > 0 ? 1 : 0

        table.cell(tbl, 0, row, f_sym(t.ticker), bgcolor = rowBg, text_color = color.new(#d1d4dc, 0), text_size = f_size(), text_halign = text.align_left, tooltip = t.ticker)
        table.cell(tbl, 1, row, t.name, bgcolor = rowBg, text_color = color.white, text_size = f_size(), text_halign = text.align_left, tooltip = t.ticker)

        float[] vals = array.from(t.d1, t.w1, t.m1, t.m3, t.ytd)
        for i = 0 to 4
            v = array.get(vals, i)
            table.cell(tbl, i + 2, row, f_txt(v), bgcolor = f_heat(v), text_color = color.white, text_size = f_size(), text_halign = text.align_right)

        int col = 7
        if showRel
            table.cell(tbl, col, row, f_txt(t.rel1m), bgcolor = f_heat(t.rel1m), text_color = color.white, text_size = f_size(), text_halign = text.align_right)
            col += 1
            table.cell(tbl, col, row, f_txt(t.rel3m), bgcolor = f_heat(t.rel3m), text_color = color.white, text_size = f_size(), text_halign = text.align_right)
            col += 1

        color ac = align >= 4 ? bullCol : align <= 1 ? bearCol : neutBg
        table.cell(tbl, col, row, str.tostring(align) + "/5", bgcolor = color.new(ac, 55), text_color = color.white, text_size = f_size(), text_halign = text.align_center)
        row += 1
````
