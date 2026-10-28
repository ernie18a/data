# Option Positions

- url: https://www.tradingview.com/script/VimhoIPi-Option-Positions/
- type: indicator
- pine_id: PUB;7ffbf39677b94cada92c0829fa197490
- version: 3.0

## Description

Shows your own option positions on the chart and how they are doing.

What it does
• A pane under the chart with the real gain or loss of your options on this symbol over time, from each contract's own price history.
• On the price chart: the strike as a solid line, a buy mark for every purchase, and an expiry tag with days left.
• A dashed "money-back" line: the price at which selling the option would return what you paid. From the purchase day to today it is real history, computed from each day's actual contract price. From today to expiry it is a model (Black-Scholes at the volatility implied by today's price, held fixed), so it bends toward the exact expiry level as time value melts.
• A table with paid, worth, gain and days left for each position.
• On SPX, XAUUSD and XAGUSD charts it shows your SPY, GLD, SLV and SIL options with levels converted into the index or metal price.

How to use it
Open Settings and paste your positions into the "Option positions" box, one per line:
TICKER, purchase date YYYYMMDD, contracts, price paid per share, strike, C or P, expiry YYYYMMDD, dollars paid in total
Example: GLD,20260902,10,3.20,300,P,20261218,3200
Every chart shows only the positions on its own symbol.

If you use the indicator on many charts, you can instead put the positions into the code: make a copy of the script, paste the same positions as one line into OPTION_POSITIONS at the top of the source (positions separated by semicolons), and save. That one line then feeds every chart the copy is on, and you only edit the code when a position changes. The settings box wins when it has text, so leave it empty on those charts.

Limits
Needs a TradingView plan that serves US option contract prices (OPRA). The modeled part of the money-back curve assumes volatility stays where it is today and ignores dividends; worth and gain never use the model, only real prices. Expired contracts are hidden by default.

## Source Code

````pine
//@version=6
// ▼▼▼ OPTION POSITIONS DATA (optional). Either paste your positions into the indicator's
// settings ("Option positions" box, one per line) or put the line here to feed every chart.
string OPTION_POSITIONS = ""
// ▲▲▲ END OPTION POSITIONS DATA ▲▲▲

// Charts handled specially: SPX / US500 / ES1! show SPY options; XAUUSD / GOLD show GLD
// and IAU; XAGUSD / SILVER show SLV, SIL and PSLV, with levels converted (LEVER_MAP below).
//
// My option positions — a pane under the chart showing the real gain or loss of my
// option positions on this ticker over time, taken from each contract's own price
// history (e.g. OPRA:NN261218C21.0). On the price chart it also draws each contract's
// strike, breakeven and expiry marker, plus a buy mark for every lot. Lots of the same
// contract (same strike, call/put and expiry) share one set of lines; their buy marks
// alternate below / above the strike line so they never cover each other.
//
// Index and metal charts: on SPX, XAUUSD (gold) and XAGUSD (silver) the indicator shows
// the options on the FUNDS that stand in for them: SPY on the SPX chart, GLD on the gold
// chart, SLV and SIL on the silver chart (LEVER_MAP below), with strike and breakeven
// converted into the chart's own price. Funds that hold what the chart shows (SPY, GLD,
// SLV, …) convert by their price ratio to it, which is fixed to a fraction of a percent.
// Mining-company funds (SIL, GDX, …) have no fixed ratio: the indicator measures over the
// last year how many percent the fund moves per 1% move of the metal and converts through
// that slope, an approximate level redrawn from today's prices every day. On such a chart
// each fund gets its own color; on a fund's own chart calls are blue and puts orange.
//
// Format, one position per line (or separated by ";"), fields comma-separated:
//   TICKER,purchYYYYMMDD,contracts,premiumPerShare,strike,C|P,expiryYYYYMMDD,usdPaid
// e.g. GLD,20260902,10,3.20,300,P,20261218,3200
// The settings box wins when it has text; otherwise line 4 above is used.
//
// When a contract's price can't be found, the "worth" column prints the symbol it
// asked for instead of a number — compare that against TradingView's symbol search
// to see whether the date or strike is off.
indicator("My option positions", shorttitle="My options", overlay=false, dynamic_requests=true,
  max_lines_count=200, max_labels_count=100, max_polylines_count=100)

// ── which funds show on which chart ───────────────────────────────────────────────────
// chart ticker : funds whose options it shows (up to three per chart). Charts not listed
// show the options on their own ticker. Extend as needed, e.g. "GC1!:GLD,IAU".
string LEVER_MAP   = "SPX:SPY;US500:SPY;ES1!:SPY;XAUUSD:GLD,IAU;GOLD:GLD,IAU;XAGUSD:SLV,SIL,PSLV;SILVER:SLV,SIL,PSLV"
// funds that HOLD what the chart shows (an index basket, the metal) and so trade at a
// fixed ratio to it; every other mapped fund is a mining-company fund and is converted
// by its measured slope.
string RATIO_FUNDS = "SPY,GLD,IAU,PHYS,SLV,PSLV,SIVR"

string posInput  = input.text_area("", "Option positions", group="Your positions",
  tooltip="One position per line (or separated by semicolons), eight fields separated by commas:\n"
  + "TICKER, purchase date YYYYMMDD (0 if unknown), contracts, price paid per share, strike, C or P, expiry YYYYMMDD, dollars paid in total (0 lets the script compute it).\n"
  + "Example: GLD,20260902,10,3.20,300,P,20261218,3200\n"
  + "Put every position you own here; each chart shows only the ones on its own ticker (or its mapped funds).")
bool  showChart  = input.bool(true, "Draw strike / breakeven / expiry on the price chart")
bool  showTable  = input.bool(true, "Show summary table")
bool  hideExpired = input.bool(true, "Hide expired options", tooltip="Contracts whose expiry date has passed are left out everywhere: the pane, the drawings and the table.")
color callColor  = input.color(color.new(#2962ff, 0), "Call color", group="On the fund's own chart")
color putColor   = input.color(color.new(#ff9800, 0), "Put color", group="On the fund's own chart")
color spyColor   = input.color(color.new(#66bb6a, 0), "SPY color", group="On the index and metal charts")
color gldColor   = input.color(color.new(#ffd54f, 0), "GLD / IAU color", group="On the index and metal charts")
color slvColor   = input.color(color.new(#b0bec5, 0), "SLV / PSLV color", group="On the index and metal charts")
color silColor   = input.color(color.new(#4dd0e1, 0), "SIL color", group="On the index and metal charts")
color othColor   = input.color(color.new(#ce93d8, 0), "Other fund color", group="On the index and metal charts")
color upColor    = input.color(color.new(#089981, 0), "Gain color")
color downColor  = input.color(color.new(#f23645, 0), "Loss color")
bool  showCurve  = input.bool(true, "Curve: where you get your money back before expiry", group="Money-back curve",
  tooltip="Before expiry the option still has time value you could sell, so you need less of a move to get your money back than at expiry. The dashed curve shows that price for every day until expiry, computed with the standard option formula from the volatility priced into today's contract price, held fixed. Worth and gain never use this model, only the curve does.")
bool  showShade  = input.bool(true, "Shade: green where the option makes money, red where it loses", group="Money-back curve",
  tooltip="A fading band on each side of the money-back line. For a call the side above the line is green and the side below red; for a put the other way round. The band fades out with distance from the line.")
float shadeH     = input.float(2, "Shade height, % of price", minval=0.5, maxval=50, step=0.5, group="Money-back curve")
float rateIn     = input.float(4.0, "Interest rate, % per year", minval=0, maxval=20, step=0.25, group="Money-back curve")
float defVolIn   = input.float(30, "Volatility to assume when a contract has no price yet, % per year", minval=1, maxval=300, step=1, group="Money-back curve")
int   badgeDx    = input.int(8, "Badge shift sideways, in bars", minval=-200, maxval=200, group="Badges",
  tooltip="Moves the expiry tags this many bars to the right of expiry and the buy marks the same distance to the LEFT of the purchase day, so the badges sit outside the lines. Negative swaps the sides. A thin line joins each badge to its point.")
float badgeDy    = input.float(2.0, "Badge shift up or down, % of price", minval=0, maxval=50, step=0.5, group="Badges",
  tooltip="Moves every badge away from its line: buy marks alternate below and above, expiry tags go above. 0 puts the badges back on their lines.")

// ── the funds this chart shows, decided once ──────────────────────────────────────────
var array<string> funds   = array.new<string>()
var bool          isLever = false
if barstate.isfirst
    array<string> ents = str.split(LEVER_MAP, ";")
    for ent in ents
        array<string> kv = str.split(ent, ":")
        if array.size(kv) == 2 and str.upper(str.trim(array.get(kv, 0))) == syminfo.ticker
            array<string> fs = str.split(array.get(kv, 1), ",")
            for f in fs
                if array.size(funds) < 3
                    array.push(funds, str.upper(str.trim(f)))
            isLever := true
    if not isLever
        array.push(funds, syminfo.ticker)

fundsList() =>
    string s = ""
    for f in funds
        s += (s == "" ? "" : ", ") + f
    s

ratioFund(string f) =>
    str.contains("," + RATIO_FUNDS + ",", "," + f + ",")

// the plain word for the chart's price in tooltips
metalWord() =>
    syminfo.ticker == "SPX" or syminfo.ticker == "US500" or syminfo.ticker == "ES1!" ? "the S&P 500"
      : syminfo.ticker == "XAUUSD" or syminfo.ticker == "GOLD" ? "gold" : syminfo.ticker == "XAGUSD" or syminfo.ticker == "SILVER" ? "silver" : syminfo.ticker

fundColor(string f) =>
    f == "SPY" ? spyColor : f == "GLD" or f == "IAU" or f == "PHYS" ? gldColor : f == "SLV" or f == "PSLV" or f == "SIVR" ? slvColor : f == "SIL" ? silColor : othColor

// ── position data, parsed once, this chart's funds only ───────────────────────────────
var array<int>    oDate = array.new<int>()      // purchase date, 0 = unknown
var array<float>  oCnt  = array.new<float>()    // contracts
var array<float>  oPrem = array.new<float>()    // premium paid per share
var array<float>  oStk  = array.new<float>()    // strike
var array<string> oCP   = array.new<string>()   // "C" / "P"
var array<int>    oExp  = array.new<int>()      // expiry, YYYYMMDD
var array<float>  oPaid = array.new<float>()    // total dollars paid
var array<string> oSym  = array.new<string>()   // the contract's own symbol
var array<float>  oPx   = array.new<float>()    // its latest known price
var array<int>    oSlot = array.new<int>()      // which of the chart's funds (0..2) it is on

// Whole-number strikes need a trailing ".0": the symbol is NN261218C21.0, not …C21.
strikeTxt(float k) =>
    k == math.round(k) ? str.tostring(k, "#") + ".0" : str.tostring(k)

two(int x) =>
    (x < 10 ? "0" : "") + str.tostring(x)

// Built digit by digit on purpose — number formatting can slip a thousands separator
// into the date and quietly produce a symbol that matches nothing.
opraSym(string tkr, int e, string cp, float k) =>
    "OPRA:" + tkr + two(int(e / 10000) % 100) + two(int(e / 100) % 100) + two(e % 100) + cp + strikeTxt(k)

int todayDate = year(timenow) * 10000 + month(timenow) * 100 + dayofmonth(timenow)

string posData = str.length(str.trim(posInput)) > 0 ? posInput : OPTION_POSITIONS

if barstate.isfirst
    array<string> recs = str.split(str.replace_all(str.replace_all(posData, "\r", ""), "\n", ";"), ";")
    for rec in recs
        array<string> fld = str.split(str.trim(rec), ",")
        if array.size(fld) >= 8
            string tkr = str.upper(str.trim(array.get(fld, 0)))
            int    slot = array.indexof(funds, tkr)
            if slot >= 0
                float d   = str.tonumber(array.get(fld, 1))
                float c   = str.tonumber(array.get(fld, 2))
                float pr  = str.tonumber(array.get(fld, 3))
                float k   = str.tonumber(array.get(fld, 4))
                string cp = str.upper(str.trim(array.get(fld, 5)))
                float e   = str.tonumber(array.get(fld, 6))
                float pd  = str.tonumber(array.get(fld, 7))
                bool expired = not na(e) and int(e) < todayDate
                if not na(c) and c != 0 and not na(k) and not na(e) and (cp == "C" or cp == "P") and not (hideExpired and expired)
                    array.push(oDate, na(d) ? 0 : int(d))
                    array.push(oCnt,  c)
                    array.push(oPrem, na(pr) ? 0.0 : pr)
                    array.push(oStk,  k)
                    array.push(oCP,   cp)
                    array.push(oExp,  int(e))
                    array.push(oPaid, na(pd) or pd == 0 ? c * (na(pr) ? 0 : pr) * 100 : pd)
                    array.push(oPx,   float(na))
                    array.push(oSym,  opraSym(tkr, int(e), cp, k))
                    array.push(oSlot, slot)

int nPos = array.size(oSym)

// grpOf[i] = index of the first position holding the same contract as position i; decided
// once, so the money-back history can be walked bar by bar per contract
var array<int> grpOf = array.new<int>()
if barstate.isfirst and nPos > 0
    for i = 0 to nPos - 1
        int g = i
        if i > 0
            for j = 0 to i - 1
                if g == i and array.get(oSlot, j) == array.get(oSlot, i) and array.get(oStk, j) == array.get(oStk, i) and array.get(oCP, j) == array.get(oCP, i) and array.get(oExp, j) == array.get(oExp, i)
                    g := j
        array.push(grpOf, g)

fundOf(int i) =>
    array.get(funds, array.get(oSlot, i))

// ── fund prices and how they convert into the chart's price ───────────────────────────
// Three fixed slots so the running statistics stay consistent bar to bar. On a fund's own
// chart the slots point at the chart itself and the conversion is the identity.
slotSym(int s) =>
    isLever and array.size(funds) > s ? array.get(funds, s) : syminfo.tickerid

string fund0 = slotSym(0)
string fund1 = slotSym(1)
string fund2 = slotSym(2)
float  px0   = request.security(fund0, "D", close, ignore_invalid_symbol=true)
float  px1   = request.security(fund1, "D", close, ignore_invalid_symbol=true)
float  px2   = request.security(fund2, "D", close, ignore_invalid_symbol=true)

float lrChart = math.log(close / close[1])

// ratio = chart price per 1.00 of the fund, smoothed over 20 days (for funds holding the metal)
// slope = percent the fund moves per 1% move of the chart price, last 250 days (for miners)
convStats(float px) =>
    float ratio = ta.sma(close / px, 20)
    float lf    = math.log(px / px[1])
    float slope = ta.correlation(lf, lrChart, 250) * ta.stdev(lf, 250) / ta.stdev(lrChart, 250)
    [ratio, slope]

[ratio0, slope0] = convStats(px0)
[ratio1, slope1] = convStats(px1)
[ratio2, slope2] = convStats(px2)

slotPx(int s) =>
    s == 0 ? px0 : s == 1 ? px1 : px2

slotSlope(int s) =>
    float sl = s == 0 ? slope0 : s == 1 ? slope1 : slope2
    math.max(0.3, nz(sl, 1.0))

// a level on the fund (strike, breakeven) → the same level in the chart's price
convert(int s, float k) =>
    float px    = slotPx(s)
    float ratio = s == 0 ? ratio0 : s == 1 ? ratio1 : ratio2
    not isLever ? k : ratioFund(array.get(funds, s)) ? k * nz(ratio, close / px) : close * math.pow(k / px, 1 / slotSlope(s))

// ── each contract's own price, and the running gain/loss ──────────────────────────────
int barDate = year(time) * 10000 + month(time) * 100 + dayofmonth(time)
float value = na
float paid  = na
if nPos > 0
    for i = 0 to nPos - 1
        float px = request.security(array.get(oSym, i), "D", close, ignore_invalid_symbol=true)
        if not na(px)
            array.set(oPx, i, px)
        // counted from its purchase day on, once a real price exists
        if (array.get(oDate, i) == 0 or array.get(oDate, i) <= barDate) and not na(array.get(oPx, i))
            value := nz(value) + array.get(oCnt, i) * 100 * array.get(oPx, i)
            paid  := nz(paid)  + array.get(oPaid, i)
float pl = value - paid

color plc = na(pl) ? na : pl >= 0 ? upColor : downColor
pPl   = plot(pl, "Gain/loss ($)", color=plc, linewidth=2)
pZero = plot(0, "", color=color.new(chart.fg_color, 80), editable=false)
fill(pPl, pZero, color=color.new(plc, 82))

// ── wording ───────────────────────────────────────────────────────────────────────────
var array<string> MONTHS = str.split("Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec", ",")

// int() truncates; plain division here is float division and would print "2026.1119".
dateTxt(int d) =>
    int mm = int(d / 100) % 100
    d == 0 ? "?" : array.get(MONTHS, math.max(1, math.min(12, mm)) - 1) + " " + str.tostring(d % 100) + " " + str.tostring(int(d / 10000))

moneyTxt(float v) =>
    (v < 0 ? "−$" : "$") + str.tostring(math.abs(v), math.abs(v) >= 10000 ? "#,###" : "#,###.00")

lvlTxt(float v) =>
    str.tostring(v, "#,###.00")

// compact, for table cells; the fund name leads on a metal chart
posShort(int i) =>
    (isLever ? fundOf(i) + " " : "") + dateTxt(array.get(oExp, i)) + " " + str.tostring(array.get(oStk, i), "#.##") + array.get(oCP, i)
      + " ×" + str.tostring(array.get(oCnt, i), "#,###")

// plain words, for tooltips
posName(int i) =>
    (isLever ? fundOf(i) + " " : "") + dateTxt(array.get(oExp, i)) + " " + str.tostring(array.get(oStk, i), "#.##")
      + (array.get(oCP, i) == "C" ? " calls" : " puts") + " × " + str.tostring(array.get(oCnt, i), "#,###")

// "300.00 on GLD ≈ 3,240.00 gold" — only on a metal chart
convTxt(int i, float k) =>
    isLever ? lvlTxt(k) + " on " + fundOf(i) + " ≈ " + lvlTxt(convert(array.get(oSlot, i), k)) + " " + metalWord() : lvlTxt(k)

// how a level was converted, for tooltips on a metal chart
convNote(int i) =>
    string f = fundOf(i)
    not isLever ? "" : ratioFund(f) ? " Levels converted by " + f + "'s price ratio to " + metalWord() + ", which is fixed to a fraction of a percent."
      : " " + f + " is a basket of mining companies, so its levels here are approximate: over the last year " + f + " moved about "
      + str.tostring(slotSlope(array.get(oSlot, i)), "#.00") + "% per 1% move of " + metalWord() + ", and the lines are redrawn from today's prices every day."

tsOf(int d, bool eod) =>
    timestamp(int(d / 10000), int(d / 100) % 100, d % 100, eod ? 16 : 9, 30)

// where a badge sits, shifted from the point it describes, and the line joining the two
int shiftMs = badgeDx * timeframe.in_seconds() * 1000

badgeY(float lvl, bool above) =>
    lvl * (1 + (above ? 1 : -1) * badgeDy / 100)

joinLine(int tsA, float yA, int tsB, float yB, color c) =>
    if tsB != tsA or yB != yA
        line.new(tsA, yA, tsB, yB, xloc=xloc.bar_time, color=color.new(c, 35), width=1, force_overlay=true)

// A fading band on one side of a curve: four closed strips stacked away from the curve,
// each a little more transparent than the one before. `up` = the side above the curve.
int SHADE_BANDS = 4
shadeSide(array<chart.point> pts, bool up, color col) =>
    int n = array.size(pts)
    if n >= 2 and shadeH > 0
        float step = shadeH / 100 / SHADE_BANDS
        for b = 0 to SHADE_BANDS - 1
            float lo = (up ? 1 : -1) * step * b
            float hi = (up ? 1 : -1) * step * (b + 1)
            array<chart.point> poly = array.new<chart.point>()
            for i = 0 to n - 1
                chart.point q = array.get(pts, i)
                array.push(poly, chart.point.from_time(q.time, q.price * (1 + lo)))
            for i = n - 1 to 0
                chart.point q = array.get(pts, i)
                array.push(poly, chart.point.from_time(q.time, q.price * (1 + hi)))
            int transp = 72 + int(22 * b / (SHADE_BANDS - 1))
            polyline.new(poly, curved=false, closed=true, xloc=xloc.bar_time, line_color=color.new(col, 100), fill_color=color.new(col, transp), force_overlay=true)

// both sides: the side where the option makes money is green, the other red
shadeCurve(array<chart.point> pts, bool isCall) =>
    if showShade
        shadeSide(pts, isCall, upColor)
        shadeSide(pts, not isCall, downColor)

daysLeft(int d) =>
    math.max(0, math.round((tsOf(d, true) - timenow) / 86400000.0))

posColor(int i) =>
    isLever ? fundColor(fundOf(i)) : array.get(oCP, i) == "C" ? callColor : putColor

// dark text on a light badge, white text on a dark one: white on silver or orange is unreadable
textOn(color bg) =>
    0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg) > 140 ? color.new(#111111, 0) : color.white

sameContract(int a, int b) =>
    array.get(oSlot, a) == array.get(oSlot, b) and array.get(oStk, a) == array.get(oStk, b) and array.get(oCP, a) == array.get(oCP, b) and array.get(oExp, a) == array.get(oExp, b)

// The buy-mark tooltip: all lots of position g's contract bought on day d, as one purchase
// at their average price, plus their standing at the latest contract price. Refreshed on
// every tick of the last bar.
dayTip(int g, int d) =>
    float  cnt  = 0.0
    float  prm  = 0.0        // contracts × premium, summed
    float  pd   = 0.0
    int    nl   = 0
    string lots = ""
    for i = 0 to nPos - 1
        if sameContract(i, g) and array.get(oDate, i) == d
            nl  += 1
            cnt += array.get(oCnt, i)
            prm += array.get(oCnt, i) * array.get(oPrem, i)
            pd  += array.get(oPaid, i)
            lots += (lots == "" ? "" : ", ") + str.tostring(array.get(oCnt, i), "#,###") + " at " + str.tostring(array.get(oPrem, i), "#.00")
    float  avg  = cnt != 0 ? prm / cnt : 0.0
    float  px   = array.get(oPx, g)
    string head = "Option on " + fundOf(g) + (isLever ? ", shown on the " + syminfo.ticker + " chart" : "") + ".\n"
    string what = (isLever ? fundOf(g) + " " : "") + dateTxt(array.get(oExp, g)) + " " + str.tostring(array.get(oStk, g), "#.##")
      + (array.get(oCP, g) == "C" ? " calls" : " puts") + " × " + str.tostring(cnt, "#,###")
    string bought = "Bought " + what + " on " + dateTxt(d) + " at " + str.tostring(avg, "#.00") + " per share"
      + (nl > 1 ? " on average (" + str.tostring(nl) + " lots: " + lots + ")" : "") + ", " + moneyTxt(pd) + " paid in total."
    string now = "\nNo price has come back for this contract yet."
    if not na(px)
        float val = cnt * 100 * px
        float gn  = val - pd
        now := "\nNow " + str.tostring(px, "#.00") + " per share, worth " + moneyTxt(val) + ": " + moneyTxt(gn)
          + " (" + (gn >= 0 ? "+" : "") + str.tostring(pd != 0 ? gn / pd * 100 : 0, "#.0") + "%)."
    head + bought + now

// the buy marks, each with its contract (a position index) and purchase day, so their
// tooltips can follow the live price
var array<label> buyLbl = array.new<label>()
var array<int>   buyPos = array.new<int>()
var array<int>   buyDay = array.new<int>()

// ── the option formula, used ONLY for the money-back curve ────────────────────────────
// Standard option pricing (Black-Scholes). Worth, gain and the pane use real prices; this
// model only shapes the dashed curve between today and expiry.
normCdf(float x) =>
    float t = 1 / (1 + 0.2316419 * math.abs(x))
    float d = 0.3989423 * math.exp(-x * x / 2)
    float p = d * t * (0.3193815 + t * (-0.3565638 + t * (1.781478 + t * (-1.821256 + t * 1.330274))))
    x >= 0 ? 1 - p : p

// contract value per share for stock price S, strike K, T years left, rate r, volatility v
bsPrice(float S, float K, float T, float r, float v, bool isCall) =>
    if T <= 0 or v <= 0
        isCall ? math.max(S - K, 0.0) : math.max(K - S, 0.0)
    else
        float d1 = (math.log(S / K) + (r + v * v / 2) * T) / (v * math.sqrt(T))
        float d2 = d1 - v * math.sqrt(T)
        isCall ? S * normCdf(d1) - K * math.exp(-r * T) * normCdf(d2) : K * math.exp(-r * T) * normCdf(-d2) - S * normCdf(-d1)

// the volatility that makes the formula match today's contract price; na when it cannot
impliedVol(float price, float S, float K, float T, float r, bool isCall) =>
    float floor_ = isCall ? math.max(S - K * math.exp(-r * T), 0.0) : math.max(K * math.exp(-r * T) - S, 0.0)
    float lo = 0.01
    float hi = 5.0
    if na(price) or na(S) or T <= 0 or price <= floor_
        float(na)
    else
        for n = 0 to 50
            float mid = (lo + hi) / 2
            if bsPrice(S, K, T, r, mid, isCall) > price
                hi := mid
            else
                lo := mid
        (lo + hi) / 2

// the stock price at which the contract is worth exactly `prem` per share, T years before expiry
moneyBackPrice(float prem, float K, float T, float r, float v, bool isCall, float sRef) =>
    float lo = sRef / 10
    float hi = sRef * 10
    for n = 0 to 60
        float mid = math.sqrt(lo * hi)
        float pr  = bsPrice(mid, K, T, r, v, isCall)
        bool tooHigh = isCall ? pr > prem : pr < prem
        if tooHigh
            hi := mid
        else
            lo := mid
    math.sqrt(lo * hi)

float MS_YEAR = 365.25 * 86400000.0

// ── the money-back history: one point per past day per contract, from REAL prices ──────
// On every bar since a contract's first purchase: that day's real contract close and the
// fund's (or stock's) real close give the volatility priced in that day, and from it the
// price at which the lots held that day would have returned their money. Stored as chart
// points; the drawing joins them to the modeled curve that runs from today to expiry.
var array<chart.point> pastPts = array.new<chart.point>()
var array<int>         pastGrp = array.new<int>()
if showCurve and nPos > 0 and not barstate.islast
    for g = 0 to nPos - 1
        if array.get(grpOf, g) == g and barDate < array.get(oExp, g)
            // the lots of this contract held as of this bar
            float cnt = 0.0
            float prm = 0.0
            for i = g to nPos - 1
                if array.get(grpOf, i) == g and array.get(oDate, i) > 0 and array.get(oDate, i) <= barDate
                    cnt += array.get(oCnt, i)
                    prm += array.get(oCnt, i) * array.get(oPrem, i)
            float px = array.get(oPx, g)
            if cnt > 0 and not na(px)
                int    slot   = array.get(oSlot, g)
                bool   isCall = array.get(oCP, g) == "C"
                float  k      = array.get(oStk, g)
                float  prem   = prm / cnt
                float  sNow   = isLever ? slotPx(slot) : close
                float  r      = rateIn / 100
                float  T      = math.max(0.0, (tsOf(array.get(oExp, g), true) - time) / MS_YEAR)
                float  iv     = impliedVol(px, sNow, k, T, r, isCall)
                float  v      = na(iv) ? defVolIn / 100 : iv
                float  be     = isCall ? k + prem : k - prem
                if be > 0
                    float y = convert(slot, moneyBackPrice(prem, k, T, r, v, isCall, sNow))
                    if not na(y)
                        array.push(pastPts, chart.point.from_time(time, y))
                        array.push(pastGrp, g)

// ── strike, breakeven, expiry marker and buy marks on the price chart ─────────────────
// Lots of the same contract are drawn as ONE bet: one strike line from the earliest
// purchase to expiry, one dashed line at the blended breakeven (strike ± the average
// premium over all lots, weighted by contracts), one expiry tag whose tooltip lists the
// lots. Each lot keeps its own buy mark; marks alternate below / above the strike line.
// On a metal chart every level passes through convert() first.
var bool drawn = false
if barstate.islast and nPos > 0 and not drawn and showChart
    drawn := true
    for g = 0 to nPos - 1
        if array.get(grpOf, g) == g
            // this contract's lots, oldest purchase first
            array<int> mem  = array.new<int>()
            array<int> memD = array.new<int>()
            for i = g to nPos - 1
                if array.get(grpOf, i) == g
                    array.push(mem,  i)
                    array.push(memD, array.get(oDate, i))
            array<int> ord = array.sort_indices(memD)
            int    nMem   = array.size(mem)
            int    slot   = array.get(oSlot, g)
            string fund   = fundOf(g)
            bool   isCall = array.get(oCP, g) == "C"
            color  c      = posColor(g)
            float  k      = array.get(oStk, g)
            int    ex     = array.get(oExp, g)
            float  totCnt = 0.0
            float  totPrm = 0.0     // contracts × premium, summed over the lots
            int    first  = 0       // earliest known purchase date, 0 = none known
            string lots   = ""
            for r = 0 to nMem - 1
                int i = array.get(mem, array.get(ord, r))
                totCnt += array.get(oCnt, i)
                totPrm += array.get(oCnt, i) * array.get(oPrem, i)
                if array.get(oDate, i) > 0 and (first == 0 or array.get(oDate, i) < first)
                    first := array.get(oDate, i)
                lots += "\n" + str.tostring(array.get(oCnt, i), "#,###") + " bought " + dateTxt(array.get(oDate, i))
                  + " at " + str.tostring(array.get(oPrem, i), "#.00") + " per share"
            float  prem = totCnt != 0 ? totPrm / totCnt : 0.0
            float  be   = isCall ? k + prem : k - prem
            float  kC   = convert(slot, k)      // strike and breakeven in the chart's price
            float  beC  = convert(slot, be)
            if na(kC) or na(beC)                // no fund price yet, nothing sensible to draw
                continue
            int    tsP  = first > 0 ? tsOf(first, false) : tsOf(barDate, false) - 86400000 * 30
            int    tsE  = tsOf(ex, true)
            int    dl   = daysLeft(ex)
            string name = (isLever ? fund + " " : "") + dateTxt(ex) + " " + str.tostring(k, "#.##") + (isCall ? " calls" : " puts") + " × " + str.tostring(totCnt, "#,###")
            // strike (solid) from the earliest purchase day to expiry
            line.new(tsP, kC,  tsE, kC,  xloc=xloc.bar_time, color=c, width=2, force_overlay=true)
            // money-back line: the real history from the purchase day to today, then the modeled curve to expiry
            string curveTxt = ""
            int    tsNow    = time
            bool   curved   = showCurve and tsE > tsNow and be > 0
            if curved
                float sNow  = isLever ? slotPx(slot) : close                 // the fund's (or stock's) price now
                float r     = rateIn / 100
                float tNow  = (tsE - timenow) / MS_YEAR
                float iv    = impliedVol(array.get(oPx, g), sNow, k, tNow, r, isCall)
                bool  guess = na(iv)
                float v     = guess ? defVolIn / 100 : iv
                int   nPts  = 24
                array<chart.point> pts = array.new<chart.point>()
                // the real history first, from the purchase day to yesterday
                if array.size(pastPts) > 0
                    for n = 0 to array.size(pastPts) - 1
                        if array.get(pastGrp, n) == g
                            array.push(pts, array.get(pastPts, n))
                float beToday = na
                for j = 0 to nPts
                    int   tj = tsNow + int((tsE - tsNow) * j / nPts)
                    float Tj = math.max(0.0, (tsE - tj) / MS_YEAR)
                    float sj = j == nPts ? be : moneyBackPrice(prem, k, Tj, r, v, isCall, sNow)
                    float yj = convert(slot, sj)
                    if j == 0
                        beToday := yj
                    if not na(yj)
                        array.push(pts, chart.point.from_time(tj, yj))
                if array.size(pts) >= 2
                    shadeCurve(pts, isCall)
                    polyline.new(pts, curved=false, closed=false, xloc=xloc.bar_time, line_color=c, line_style=line.style_dashed, line_width=1, force_overlay=true)
                curveTxt := "\nTo get your money back: " + lvlTxt(beToday) + " today, " + lvlTxt(beC) + " at expiry, assuming "
                  + (guess ? "a volatility of " + str.tostring(defVolIn, "#") + "% (no price for this contract yet)" : "the volatility priced into today's contract price, " + str.tostring(v * 100, "#") + "%")
                  + ", held fixed."
            else if tsE > tsNow
                array<chart.point> flat = array.new<chart.point>()
                array.push(flat, chart.point.from_time(tsNow, beC))
                array.push(flat, chart.point.from_time(tsE, beC))
                shadeCurve(flat, isCall)
                line.new(tsNow, beC, tsE, beC, xloc=xloc.bar_time, color=c, width=1, style=line.style_dashed, force_overlay=true)
            string tip  = "Option on " + fund + (isLever ? ", shown on the " + syminfo.ticker + " chart" : "") + ".\n"
              + name + ": needs " + (isLever ? metalWord() : "the stock") + (isCall ? " above " : " below ") + lvlTxt(beC)
              + (isLever ? " (" + lvlTxt(be) + " on " + fund + ")" : "")
              + " by " + dateTxt(ex) + " to make money if held to the end. Solid line = strike"
              + (isLever ? " (" + lvlTxt(k) + " on " + fund + " ≈ " + lvlTxt(kC) + ")" : "") + ", dashed = where you get your money back"
              + (nMem > 1 ? " (blended over " + str.tostring(nMem) + " lots)." : ".") + convNote(g) + curveTxt
              + (nMem > 1 ? "\nLots:" + lots : "")
            // expiry: a short tick joining the two, NOT a full-height line
            line.new(tsE, kC, tsE, beC, xloc=xloc.bar_time, color=c, width=1, style=line.style_dotted, force_overlay=true)
            int   tsEB = tsE + shiftMs
            float yEB  = badgeY(beC, true)
            joinLine(tsE, beC, tsEB, yEB, c)
            label.new(tsEB, yEB, text=(isLever ? fund + " · " : "") + (dl > 0 ? str.tostring(dl) + "d left" : "expired"), xloc=xloc.bar_time, yloc=yloc.price,
              color=color.new(c, 20), style=label.style_label_down, textcolor=textOn(c), size=size.normal,
              force_overlay=true, tooltip=tip)
            // one buy mark per purchase DAY: lots of this contract bought the same day merge into
            // one badge at their average price. The first hangs below the strike line, the next
            // sits above, and so on.
            int marks   = 0
            int lastDay = -1
            for r = 0 to nMem - 1
                int i = array.get(mem, array.get(ord, r))
                int d = array.get(oDate, i)
                if d > 0 and d != lastDay
                    lastDay := d
                    float dCnt = 0.0
                    float dPrm = 0.0
                    for r2 = 0 to nMem - 1
                        int i2 = array.get(mem, r2)
                        if array.get(oDate, i2) == d
                            dCnt += array.get(oCnt, i2)
                            dPrm += array.get(oCnt, i2) * array.get(oPrem, i2)
                    float dAvg  = dCnt != 0 ? dPrm / dCnt : 0.0
                    bool  below = marks % 2 == 0
                    marks += 1
                    int   tsB = tsOf(d, false)
                    int   tsL = tsB - shiftMs           // buy marks go the opposite way from the expiry tags
                    float yL  = badgeY(kC, not below)
                    joinLine(tsB, kC, tsL, yL, c)
                    label lb = label.new(tsL, yL,
                      text=(isLever ? fund + " " : "") + str.tostring(dCnt, "#,###") + "× @" + str.tostring(dAvg, "#.00"),
                      xloc=xloc.bar_time, yloc=yloc.price, color=c, style=below ? label.style_label_up : label.style_label_down,
                      textcolor=textOn(c), size=size.normal, force_overlay=true, tooltip=dayTip(g, d))
                    array.push(buyLbl, lb)
                    array.push(buyPos, g)
                    array.push(buyDay, d)

// the tooltips follow the live contract price, like the table and the pane
if barstate.islast and array.size(buyLbl) > 0
    for n = 0 to array.size(buyLbl) - 1
        label.set_tooltip(array.get(buyLbl, n), dayTip(array.get(buyPos, n), array.get(buyDay, n)))

// ── table ─────────────────────────────────────────────────────────────────────────────
var table t = na
if barstate.islast and nPos > 0 and showTable
    if na(t)
        t := table.new(position.top_right, 5, nPos + 2, border_width=1)
    table.cell(t, 0, 0, isLever ? syminfo.ticker + ": options on " + fundsList() : syminfo.ticker + " options", text_color=chart.fg_color, text_size=size.large)
    table.cell(t, 1, 0, "paid",  text_color=chart.fg_color, text_size=size.normal, text_halign=text.align_right)
    table.cell(t, 2, 0, "worth", text_color=chart.fg_color, text_size=size.normal, text_halign=text.align_right)
    table.cell(t, 3, 0, "gain",  text_color=chart.fg_color, text_size=size.normal, text_halign=text.align_right)
    table.cell(t, 4, 0, "left",  text_color=chart.fg_color, text_size=size.normal, text_halign=text.align_right)
    float tPaid = 0.0
    float tVal  = 0.0
    bool  allPx = true
    for i = 0 to nPos - 1
        float px  = array.get(oPx, i)
        float val = na(px) ? na : array.get(oCnt, i) * 100 * px
        float gn  = na(val) ? na : val - array.get(oPaid, i)
        color gc  = na(gn) ? chart.fg_color : gn >= 0 ? upColor : downColor
        int   dl  = daysLeft(array.get(oExp, i))
        tPaid += array.get(oPaid, i)
        if na(val)
            allPx := false
        else
            tVal += val
        table.cell(t, 0, i + 1, posShort(i), text_color=isLever ? posColor(i) : chart.fg_color, text_size=size.normal, text_halign=text.align_left,
          tooltip=posName(i) + ", bought " + dateTxt(array.get(oDate, i)) + " at " + str.tostring(array.get(oPrem, i), "#.00")
            + " per share." + (isLever ? " Strike " + convTxt(i, array.get(oStk, i)) + "." : "") + " Contract symbol: " + array.get(oSym, i))
        table.cell(t, 1, i + 1, moneyTxt(array.get(oPaid, i)), text_color=chart.fg_color, text_size=size.normal, text_halign=text.align_right)
        table.cell(t, 2, i + 1, na(val) ? array.get(oSym, i) : moneyTxt(val),
          text_color=na(val) ? color.new(chart.fg_color, 45) : chart.fg_color, text_size=na(val) ? size.small : size.normal,
          text_halign=text.align_right, tooltip=na(val) ? "No price came back for this contract. Check that symbol in TradingView's symbol search." : "")
        table.cell(t, 3, i + 1, na(gn) ? "no price" : moneyTxt(gn) + " (" + (gn >= 0 ? "+" : "") + str.tostring(gn / array.get(oPaid, i) * 100, "#.0") + "%)",
          text_color=gc, text_size=size.normal, text_halign=text.align_right)
        table.cell(t, 4, i + 1, dl > 0 ? str.tostring(dl) + "d" : "exp", text_color=chart.fg_color, text_size=size.normal, text_halign=text.align_right)
    float tGn = tVal - tPaid
    color tc  = tGn >= 0 ? upColor : downColor
    table.cell(t, 0, nPos + 1, "total" + (allPx ? "" : " (partial)"), text_color=chart.fg_color, text_size=size.normal, text_halign=text.align_left)
    table.cell(t, 1, nPos + 1, moneyTxt(tPaid), text_color=chart.fg_color, text_size=size.normal, text_halign=text.align_right)
    table.cell(t, 2, nPos + 1, moneyTxt(tVal),  text_color=chart.fg_color, text_size=size.normal, text_halign=text.align_right)
    table.cell(t, 3, nPos + 1, moneyTxt(tGn) + " (" + (tGn >= 0 ? "+" : "") + str.tostring(tPaid != 0 ? tGn / tPaid * 100 : 0, "#.0") + "%)",
      text_color=tc, text_size=size.normal, text_halign=text.align_right)
    table.cell(t, 4, nPos + 1, "", text_color=chart.fg_color)

if barstate.islast and nPos == 0
    var table info = table.new(position.bottom_right, 1, 1)
    table.cell(info, 0, 0, str.length(str.trim(posData)) == 0 ? "no data. Paste your positions into the indicator's settings"
      : isLever ? "no option position on " + fundsList() + " (" + syminfo.ticker + ")" : "no option position in " + syminfo.ticker,
      text_color=color.new(color.gray, 30), text_size=size.normal)
````
