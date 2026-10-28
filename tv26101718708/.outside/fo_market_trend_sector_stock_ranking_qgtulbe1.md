# F&O Market Trend + Sector & Stock Ranking

- url: https://www.tradingview.com/script/QgtuLBE1-F-O-Market-Trend-Sector-Stock-Ranking/
- type: indicator
- pine_id: PUB;ef49f29a36c2428c8d81c41fa8870170
- version: 1.0

## Description

F&O Market Trend + Sector & Stock Ranking (NSE)

OVERVIEW
This indicator gives a live, one-screen view of the Indian F&O market. It answers three questions:
1) What is the overall market trend - Bullish, Bearish or Sideways?
2) Which sectors are leading and which are lagging today?
3) Inside a sector, which F&O stocks are strongest, and what is their OI buildup?

It covers all 210 NSE F&O stocks (Sep 2026 list), grouped into 18 sectors, plus 18 NSE sector indices and Nifty 50.

──────────────────────────────
1) MARKET TREND PANEL
──────────────────────────────
Shows the overall verdict for the market (Strong Bullish / Bullish / Sideways / Bearish / Strong Bearish) with a score and a one-line view.

The verdict blends three things:
- Nifty 50 trend score (from the Trend Engine below + Nifty futures OI buildup)
- Sector breadth - how many sector indices are bullish vs bearish
- Stock buildup breadth - Long Buildup / Short Covering vs Short Buildup / Long Unwinding in the selected sector

The panel also lists each Nifty check: Price vs 20 EMA, 20 vs 50 EMA, RSI, Supertrend, +DI vs -DI, ADX strength and Nifty futures OI buildup.

──────────────────────────────
2) SECTOR RANKING TABLE
──────────────────────────────
Ranks 18 NSE sector indices from strongest to weakest by % change (Nifty Bank, PSU Bank, Private Bank, Financial Services, IT, Auto, Pharma, Healthcare, FMCG, Metal, Energy, Oil & Gas, Realty, Media, Infra, Consumer Durables, Defence, Capital Markets), each with its trend label.

──────────────────────────────
3) STOCK TABLE
──────────────────────────────
Pick a sector (or "All F&O") and the stocks are ranked high to low. Columns:
- Price % - change vs the previous bar (today vs yesterday on a Daily chart)
- OI % - change in futures open interest
- Buildup - Long Buildup / Short Buildup / Short Covering / Long Unwinding / Neutral
- Vol x - volume vs its 20-bar average (orange when 1.5x or more)
- Trend - trend label including buildup
Sort by Price %, Trend score, OI % or Volume. The footer shows how many stocks are up and down.

──────────────────────────────
TREND ENGINE (how the trend is decided)
──────────────────────────────
Each symbol gets 5 votes (+1 bullish / -1 bearish):
1. Close above / below the 20 EMA
2. 20 EMA above / below the 50 EMA
3. RSI(14) above 55 / below 45 (between = 0)
4. Supertrend (10, 3) up / down
5. +DI above / below -DI
Futures OI buildup adds an extra vote:
- Long Buildup (Price ↑ OI ↑) = +1
- Short Covering (Price ↑ OI ↓) = +0.5
- Short Buildup (Price ↓ OI ↑) = -1
- Long Unwinding (Price ↓ OI ↓) = -0.5

Score +4 or more = Strong Bullish, +2 to +3 = Bullish, -2 to -3 = Bearish, -4 or less = Strong Bearish, otherwise Sideways.
If ADX is below 20 the trend is weak, so the label is Sideways.
All lengths, thresholds and the buildup weight can be changed in settings.

──────────────────────────────
SETTINGS
──────────────────────────────
- Trend Engine: EMA, RSI, ADX, Supertrend settings, buildup weight
- Colours: positive/negative values, high volume, each trend and buildup label
- Each table: position (9 places), text size, text/header colour, background, border, cell width and height
- Stock table: sector, rows per page (5-19), page, auto-flip pages, sort order, OI & buildup on/off, minimum OI and price change for buildup

──────────────────────────────
HOW TO USE
──────────────────────────────
- Use the Daily timeframe. Values then show today's change vs yesterday and update live during market hours.
- Check the Market Trend panel first, then find the leading sector in the Sector table, then pick that sector to see its strongest stocks and their buildup.
- To page through a sector, lower "Rows per page" (e.g. 10) and change "Page" in settings.
- Auto-flip only works while live ticks arrive (market hours). On weekends, add the indicator to a 24/7 chart such as BTCUSDT to use it.

──────────────────────────────
LIMITATIONS
──────────────────────────────
- TradingView allows about 40 data requests per script, so all 210 stocks cannot be ranked in one table. Each sector (max 19 stocks) is scanned at once, and "All F&O" is scanned page by page.
- With OI & Buildup and the Sector table both on, the stock table shows max 10 rows and ranks within each page. Turn the Sector table off to rank a whole sector together.
- OI comes from TradingView's "_OI" futures data. If it is missing for a symbol, the table shows "n/a".
- Live values need real-time NSE data on your TradingView plan. Otherwise they are delayed.
- The F&O stock list and sector groups are fixed in the code and need updating when NSE changes the F&O list.

──────────────────────────────
DISCLAIMER
──────────────────────────────
This indicator is for education and analysis only. It is not investment advice or a buy/sell recommendation. Trend and buildup signals can be wrong. Always use your own judgement and risk management.

## Source Code

````pine
//@version=6
indicator("F&O Market Trend + Sector & Stock Ranking", overlay = true)

// ═══════════════════════ SETTINGS ═══════════════════════
lookback = input.int(1, "Compare with N bars ago", minval = 1, tooltip = "On a Daily chart, 1 = today's change vs yesterday's close. Updates live during market hours.")

grpT = "Trend Engine"
emaFast  = input.int(20, "Fast EMA", minval = 2, group = grpT)
emaSlow  = input.int(50, "Slow EMA", minval = 3, group = grpT)
rsiLen   = input.int(14, "RSI length", minval = 2, group = grpT)
adxLen   = input.int(14, "ADX length", minval = 2, group = grpT)
adxMin   = input.int(20, "ADX below this = Sideways", minval = 5, group = grpT)
stFactor = input.float(3.0, "Supertrend factor", minval = 0.5, group = grpT)
stLen    = input.int(10, "Supertrend ATR length", minval = 2, group = grpT)
buW      = input.float(1.0, "Buildup weight in trend score", minval = 0, maxval = 3, step = 0.5, group = grpT, tooltip = "Long Buildup = +1 x weight, Short Covering = +0.5 x weight, Short Buildup = -1 x weight, Long Unwinding = -0.5 x weight. 0 = buildup is shown but does not change the trend.")
colorBg  = input.bool(false, "Colour chart background by trend of current symbol", group = grpT)

grpC = "Colours (values & trend labels)"
upCol     = input.color(color.lime, "Positive value", group = grpC, inline = "pn")
dnCol     = input.color(color.red, "Negative value", group = grpC, inline = "pn")
volHiCol  = input.color(color.orange, "High volume (≥1.5x)", group = grpC)
sBullCol  = input.color(color.new(color.lime, 20), "Strong Bullish", group = grpC, inline = "t1")
bullCol   = input.color(color.new(color.green, 40), "Bullish", group = grpC, inline = "t1")
sideCol   = input.color(color.new(color.gray, 40), "Sideways", group = grpC, inline = "t2")
bearCol   = input.color(color.new(color.red, 40), "Bearish", group = grpC, inline = "t2")
sBearCol  = input.color(color.new(color.maroon, 10), "Strong Bearish", group = grpC, inline = "t3")
trTxtCol  = input.color(color.white, "Trend label text", group = grpC, inline = "t3")
lbCol     = input.color(color.new(color.green, 30), "Long Buildup", group = grpC, inline = "b1")
scCol     = input.color(color.new(color.teal, 30), "Short Covering", group = grpC, inline = "b1")
sbCol     = input.color(color.new(color.red, 30), "Short Buildup", group = grpC, inline = "b2")
luCol     = input.color(color.new(color.orange, 30), "Long Unwinding", group = grpC, inline = "b2")

POS_TIP = "Table position on the chart"
SIZE_TIP = "0 = automatic size. Otherwise % of chart width / height per cell."

grpM = "Market Trend Panel"
showMkt   = input.bool(true, "Show market trend panel", group = grpM)
mktPos    = input.string("Bottom Center", "Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpM, tooltip = POS_TIP)
mktTS     = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], group = grpM)
mktTxt    = input.color(color.white, "Text", group = grpM, inline = "mc")
mktHdr    = input.color(color.yellow, "Header", group = grpM, inline = "mc")
mktBg     = input.color(color.new(color.black, 10), "Background", group = grpM, inline = "mc2")
mktBrd    = input.color(color.new(color.gray, 50), "Border", group = grpM, inline = "mc2")
mktW      = input.float(0, "Cell width %", minval = 0, maxval = 20, step = 0.5, group = grpM, inline = "ms", tooltip = SIZE_TIP)
mktH      = input.float(0, "Cell height %", minval = 0, maxval = 10, step = 0.5, group = grpM, inline = "ms")

grpA = "Sector Table"
showSectors = input.bool(true, "Show sector ranking", group = grpA)
secPos    = input.string("Top Left", "Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpA, tooltip = POS_TIP)
secTS     = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], group = grpA)
secTxt    = input.color(color.white, "Text", group = grpA, inline = "sc")
secHdr    = input.color(color.yellow, "Header", group = grpA, inline = "sc")
secBg     = input.color(color.new(color.black, 15), "Background", group = grpA, inline = "sc2")
secBrd    = input.color(color.new(color.gray, 50), "Border", group = grpA, inline = "sc2")
secW      = input.float(0, "Cell width %", minval = 0, maxval = 20, step = 0.5, group = grpA, inline = "ss", tooltip = SIZE_TIP)
secH      = input.float(0, "Cell height %", minval = 0, maxval = 10, step = 0.5, group = grpA, inline = "ss")

grpB = "Stock Table"
sector = input.string("Banks", "Sector", options = ["Banks", "NBFC & Housing Finance", "Insurance & Fintech", "Capital Markets", "IT", "Auto & Auto Ancillary", "Pharma & Healthcare", "FMCG", "Metals & Mining", "Oil & Gas", "Power & Renewables", "Capital Goods & Infra", "Defence", "Consumer Durables", "Cement, Paints & Chemicals", "Realty", "Retail & Consumer Tech", "Telecom, Transport & Others", "All F&O"], group = grpB)
rowsPP = input.int(10, "Rows per page", minval = 5, maxval = 19, group = grpB, tooltip = "How many stocks per page. A sector has at most 19 stocks, so with 19 rows every sector fits on ONE page and changing the page does nothing. Use 10 (2 pages) or 5-7 (3-4 pages).")
page   = input.int(1, "Page", options = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42], group = grpB, tooltip = "Pick the page to show. The table header shows 'Page x / y'.")
autoFlip = input.bool(false, "Auto-flip pages", group = grpB, inline = "af", tooltip = "Sectors only (not All F&O). Pages change by themselves every N seconds while live ticks are coming in (market hours).")
flipSec  = input.int(10, "every (sec)", minval = 3, maxval = 300, group = grpB, inline = "af")
sortBy = input.string("Price %", "Sort stocks by (high to low)", options = ["Price %", "Trend score", "OI %", "Volume x"], group = grpB)
showBU   = input.bool(true, "Show OI & Buildup", group = grpB, tooltip = "Adds OI % and buildup (Long Buildup / Short Buildup / Short Covering / Long Unwinding) for every stock and Nifty futures, and uses it in the trend. TradingView allows ~40 data requests per script, so while the sector table is ALSO on, the stock table shows max 10 rows and ranks stocks within each page (auto-flip off). Turn the sector table off to rank all stocks of a sector together.")
minOiChg = input.float(0.5, "Min OI change % for buildup", minval = 0, step = 0.1, group = grpB, inline = "bt")
minPxChg = input.float(0.1, "Min price change %", minval = 0, step = 0.05, group = grpB, inline = "bt")
stkPos = input.string("Top Right", "Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpB, tooltip = POS_TIP)
stkTS  = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], group = grpB)
stkTxt = input.color(color.white, "Text", group = grpB, inline = "kc")
stkHdr = input.color(color.yellow, "Header", group = grpB, inline = "kc")
stkBg  = input.color(color.new(color.black, 15), "Background", group = grpB, inline = "kc2")
stkBrd = input.color(color.new(color.gray, 50), "Border", group = grpB, inline = "kc2")
stkW   = input.float(0, "Cell width %", minval = 0, maxval = 20, step = 0.5, group = grpB, inline = "ks", tooltip = SIZE_TIP)
stkH   = input.float(0, "Cell height %", minval = 0, maxval = 10, step = 0.5, group = grpB, inline = "ks")

// ═══════════════════════ SECTOR LISTS (NSE F&O, Sep 2026) ═══════════════════════
// Futures symbols are NAME1!  ( & and - become _ , e.g. M&M -> M_M )
sectorList = switch sector
    "Banks"                       => "AUBANK,AXISBANK,BANDHANBNK,BANKBARODA,BANKINDIA,CANBK,FEDERALBNK,HDFCBANK,ICICIBANK,IDFCFIRSTB,INDIANB,INDUSINDBK,KOTAKBANK,MAHABANK,PNB,RBLBANK,SBIN,UNIONBANK,YESBANK"
    "NBFC & Housing Finance"      => "ABCAPITAL,BAJAJFINSV,BAJAJHLDNG,BAJFINANCE,CHOLAFIN,IREDA,IRFC,JIOFIN,LICHSGFIN,LTF,MANAPPURAM,MUTHOOTFIN,PFC,PNBHOUSING,RECLTD,SBICARD,SHRIRAMFIN"
    "Insurance & Fintech"         => "HDFCLIFE,ICICIGI,ICICIPRULI,LICI,MFSL,SBILIFE,POLICYBZR,PAYTM"
    "Capital Markets"             => "360ONE,ANGELONE,BSE,CAMS,CDSL,HDFCAMC,IEX,KFINTECH,MCX,MOTILALOFS,NAM_INDIA"
    "IT"                          => "COFORGE,HCLTECH,INFY,KPITTECH,LTM,MPHASIS,OFSS,PERSISTENT,SAGILITY,TATAELXSI,TCS,TECHM,WIPRO"
    "Auto & Auto Ancillary"       => "ASHOKLEY,ATHERENERG,BAJAJ_AUTO,BHARATFORG,BOSCHLTD,EICHERMOT,FORCEMOT,HEROMOTOCO,HYUNDAI,M_M,MARUTI,MOTHERSON,SONACOMS,TIINDIA,TMPV,TVSMOTOR,UNOMINDA"
    "Pharma & Healthcare"         => "ALKEM,APOLLOHOSP,AUROPHARMA,BIOCON,CIPLA,DIVISLAB,DRREDDY,FORTIS,GLENMARK,LAURUSLABS,LUPIN,MANKIND,MAXHEALTH,SUNPHARMA,TORNTPHARM,ZYDUSLIFE"
    "FMCG"                        => "BRITANNIA,COLPAL,DABUR,GODFRYPHLP,GODREJCP,HINDUNILVR,ITC,MARICO,NESTLEIND,PATANJALI,RADICO,TATACONSUM,UNITDSPR,VBL"
    "Metals & Mining"             => "COALINDIA,HINDALCO,HINDZINC,JINDALSTEL,JSWSTEEL,NATIONALUM,NMDC,SAIL,TATASTEEL,VEDL"
    "Oil & Gas"                   => "BPCL,GAIL,HINDPETRO,IOC,OIL,ONGC,PETRONET,RELIANCE"
    "Power & Renewables"          => "ADANIENSOL,ADANIGREEN,ADANIPOWER,INOXWIND,JSWENERGY,NHPC,NTPC,POWERGRID,PREMIERENE,SUZLON,TATAPOWER,WAAREEENER"
    "Capital Goods & Infra"       => "ABB,APLAPOLLO,ASTRAL,BHEL,CGPOWER,CUMMINSIND,GVT_D,KEI,LT,NBCC,POLYCAB,POWERINDIA,RVNL,SIEMENS,SUPREMEIND"
    "Defence"                     => "BDL,BEL,COCHINSHIP,HAL,MAZDOCK,SOLARINDS"
    "Consumer Durables"           => "AMBER,BLUESTARCO,CROMPTON,DIXON,HAVELLS,KALYANKJIL,KAYNES,PGEL,TITAN,VOLTAS"
    "Cement, Paints & Chemicals"  => "AMBUJACEM,ASIANPAINT,GRASIM,PIDILITIND,PIIND,SHREECEM,SRF,ULTRACEMCO,UPL"
    "Realty"                      => "DLF,GODREJPROP,LODHA,OBEROIRLTY,PHOENIXLTD,PRESTIGE"
    "Retail & Consumer Tech"      => "DELHIVERY,DMART,ETERNAL,INDHOTEL,JUBLFOOD,NAUKRI,NYKAA,PAGEIND,SWIGGY,TRENT,VMM"
    "Telecom, Transport & Others" => "ADANIENT,ADANIPORTS,BHARTIARTL,CONCOR,GMRAIRPORT,IDEA,INDIGO,INDUSTOWER"
    => "360ONE,ABB,ABCAPITAL,ADANIENSOL,ADANIENT,ADANIGREEN,ADANIPORTS,ADANIPOWER,ALKEM,AMBER,"  +
     "AMBUJACEM,ANGELONE,APLAPOLLO,APOLLOHOSP,ASHOKLEY,ASIANPAINT,ASTRAL,ATHERENERG,AUBANK,AUROPHARMA,"  +
     "AXISBANK,BAJAJFINSV,BAJAJHLDNG,BAJAJ_AUTO,BAJFINANCE,BANDHANBNK,BANKBARODA,BANKINDIA,BDL,BEL,"  +
     "BHARATFORG,BHARTIARTL,BHEL,BIOCON,BLUESTARCO,BOSCHLTD,BPCL,BRITANNIA,BSE,CAMS,"  +
     "CANBK,CDSL,CGPOWER,CHOLAFIN,CIPLA,COALINDIA,COCHINSHIP,COFORGE,COLPAL,CONCOR,"  +
     "CROMPTON,CUMMINSIND,DABUR,DELHIVERY,DIVISLAB,DIXON,DLF,DMART,DRREDDY,EICHERMOT,"  +
     "ETERNAL,FEDERALBNK,FORCEMOT,FORTIS,GAIL,GLENMARK,GMRAIRPORT,GODFRYPHLP,GODREJCP,GODREJPROP,"  +
     "GRASIM,GVT_D,HAL,HAVELLS,HCLTECH,HDFCAMC,HDFCBANK,HDFCLIFE,HEROMOTOCO,HINDALCO,"  +
     "HINDPETRO,HINDUNILVR,HINDZINC,HYUNDAI,ICICIBANK,ICICIGI,ICICIPRULI,IDEA,IDFCFIRSTB,IEX,"  +
     "INDHOTEL,INDIANB,INDIGO,INDUSINDBK,INDUSTOWER,INFY,INOXWIND,IOC,IREDA,IRFC,"  +
     "ITC,JINDALSTEL,JIOFIN,JSWENERGY,JSWSTEEL,JUBLFOOD,KALYANKJIL,KAYNES,KEI,KFINTECH,"  +
     "KOTAKBANK,KPITTECH,LAURUSLABS,LICHSGFIN,LICI,LODHA,LT,LTF,LTM,LUPIN,"  +
     "MAHABANK,MANAPPURAM,MANKIND,MARICO,MARUTI,MAXHEALTH,MAZDOCK,MCX,MFSL,MOTHERSON,"  +
     "MOTILALOFS,MPHASIS,MUTHOOTFIN,M_M,NAM_INDIA,NATIONALUM,NAUKRI,NBCC,NESTLEIND,NHPC,"  +
     "NMDC,NTPC,NYKAA,OBEROIRLTY,OFSS,OIL,ONGC,PAGEIND,PATANJALI,PAYTM,"  +
     "PERSISTENT,PETRONET,PFC,PGEL,PHOENIXLTD,PIDILITIND,PIIND,PNB,PNBHOUSING,POLICYBZR,"  +
     "POLYCAB,POWERGRID,POWERINDIA,PREMIERENE,PRESTIGE,RADICO,RBLBANK,RECLTD,RELIANCE,RVNL,"  +
     "SAGILITY,SAIL,SBICARD,SBILIFE,SBIN,SHREECEM,SHRIRAMFIN,SIEMENS,SOLARINDS,SONACOMS,"  +
     "SRF,SUNPHARMA,SUPREMEIND,SUZLON,SWIGGY,TATACONSUM,TATAELXSI,TATAPOWER,TATASTEEL,TCS,"  +
     "TECHM,TIINDIA,TITAN,TMPV,TORNTPHARM,TRENT,TVSMOTOR,ULTRACEMCO,UNIONBANK,UNITDSPR,"  +
     "UNOMINDA,UPL,VBL,VEDL,VMM,VOLTAS,WAAREEENER,WIPRO,YESBANK,ZYDUSLIFE"

// ═══════════════════════ TREND ENGINE ═══════════════════════
// 5 votes, each +1 (bullish) or -1 (bearish); RSI can also vote 0 (neutral):
//   1) Close vs fast EMA   2) Fast EMA vs slow EMA   3) RSI > 55 / < 45
//   4) Supertrend direction   5) +DI vs -DI
// ADX below the threshold = no trend strength -> Sideways.
pctChg(float src) => (src - src[lookback]) / src[lookback] * 100

trendParts() =>
    e1 = ta.ema(close, emaFast)
    e2 = ta.ema(close, emaSlow)
    r  = ta.rsi(close, rsiLen)
    [stLine, stDir] = ta.supertrend(stFactor, stLen)
    [dip, dim, adx] = ta.dmi(adxLen, adxLen)
    v1 = close > e1 ? 1 : -1
    v2 = e1 > e2 ? 1 : -1
    v3 = r > 55 ? 1 : r < 45 ? -1 : 0
    v4 = stDir < 0 ? 1 : -1
    v5 = dip > dim ? 1 : -1
    [v1, v2, v3, v4, v5, r, adx]

// Stock: price %, volume ratio, trend score, ADX
stockMetrics() =>
    [v1, v2, v3, v4, v5, r, adx] = trendParts()
    [pctChg(close), volume / ta.sma(volume, 20), float(v1 + v2 + v3 + v4 + v5), adx]

// Sector index: price %, trend score, ADX
indexMetrics() =>
    [v1, v2, v3, v4, v5, r, adx] = trendParts()
    [pctChg(close), float(v1 + v2 + v3 + v4 + v5), adx]

// Nifty: every vote, for the detailed panel
niftyMetrics() =>
    [v1, v2, v3, v4, v5, r, adx] = trendParts()
    [pctChg(close), float(v1), float(v2), float(v3), float(v4), float(v5), r, adx]

trendOf(float s, float adx) =>
    na(s) ? "n/a" : adx < adxMin ? "Sideways" : s >= 4 ? "Strong Bullish" : s >= 2 ? "Bullish" : s <= -4 ? "Strong Bearish" : s <= -2 ? "Bearish" : "Sideways"

trendCol(string t) =>
    switch t
        "Strong Bullish" => sBullCol
        "Bullish"        => bullCol
        "Bearish"        => bearCol
        "Strong Bearish" => sBearCol
        "Sideways"       => sideCol
        => color.new(color.black, 100)

// ═══════════════════════ OI BUILDUP ═══════════════════════
//   Price ↑ + OI ↑ = Long Buildup (bullish)      Price ↓ + OI ↑ = Short Buildup (bearish)
//   Price ↑ + OI ↓ = Short Covering (mild bull)  Price ↓ + OI ↓ = Long Unwinding (mild bear)
buildupOf(float pc, float oic) =>
    na(pc) or na(oic) ? "n/a" : math.abs(oic) < minOiChg or math.abs(pc) < minPxChg ? "Neutral" : pc > 0 and oic > 0 ? "Long Buildup" : pc < 0 and oic > 0 ? "Short Buildup" : pc > 0 ? "Short Covering" : "Long Unwinding"

buildupVote(string b) =>
    b == "Long Buildup" ? 1.0 : b == "Short Covering" ? 0.5 : b == "Short Buildup" ? -1.0 : b == "Long Unwinding" ? -0.5 : 0.0

buildupCol(string b) =>
    switch b
        "Long Buildup"   => lbCol
        "Short Covering" => scCol
        "Short Buildup"  => sbCol
        "Long Unwinding" => luCol
        "Neutral"        => sideCol
        => color.new(color.black, 100)

// ═══════════════════════ HELPERS ═══════════════════════
sortDesc(array<float> a) =>
    keys = array.new<float>()
    for v in a
        keys.push(na(v) ? -1e10 : v)
    keys.sort_indices(order.descending)

fmt(float v) => na(v) ? "n/a" : (v > 0 ? "+" : "") + str.tostring(v, "0.00") + "%"
clr(float v) => na(v) ? color.gray : v >= 0 ? upCol : dnCol
yesNo(float v, string up, string dn) => v > 0 ? up : v < 0 ? dn : "Neutral"
voteCol(float v) => v > 0 ? upCol : v < 0 ? dnCol : color.gray

posOf(string p) =>
    switch p
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.top_right

sizeOf(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        "Auto"   => size.auto
        => size.small

// Write one table cell. w/h = 0 means automatic size.
put(table t, int c, int r, string txt, color fg, color bg, string ts, float w, float h, bool left) =>
    table.cell(t, c, r, txt, width = w, height = h, text_color = fg, bgcolor = bg, text_size = ts, text_halign = left ? text.align_left : text.align_center)

// ═══════════════════════ CURRENT CHART SYMBOL ═══════════════════════
[c1, c2, c3, c4, c5, cR, cAdx] = trendParts()
cScore = float(c1 + c2 + c3 + c4 + c5)
cTrend = trendOf(cScore, cAdx)
bgcolor(colorBg ? color.new(trendCol(cTrend), 88) : na)
plot(cScore, "Trend score (-5..+5)", display = display.data_window)
plot(pctChg(close), "Price chg %", display = display.data_window)

// ═══════════════════════ 1) NIFTY 50 (market) ═══════════════════════
[nPc, n1, n2, n3, n4, n5, nR, nAdx] = request.security("NSE:NIFTY", timeframe.period, niftyMetrics(), ignore_invalid_symbol = true)
float nOi = na
if showBU
    nOi := request.security("NSE:NIFTY1!_OI", timeframe.period, pctChg(close), ignore_invalid_symbol = true)
nBU    = showBU ? buildupOf(nPc, nOi) : "off"
nScore = n1 + n2 + n3 + n4 + n5 + (showBU ? buildupVote(nBU) * buW : 0.0)
nTrend = trendOf(nScore, nAdx)

// ═══════════════════════ 2) SECTOR RANKING ═══════════════════════
secNames   = array.from("Nifty Bank", "PSU Bank", "Private Bank", "Financial Services", "IT", "Auto", "Pharma", "Healthcare", "FMCG", "Metal", "Energy", "Oil & Gas", "Realty", "Media", "Infra", "Consumer Durables", "Defence", "Capital Markets")
secTickers = array.from("NSE:BANKNIFTY", "NSE:CNXPSUBANK", "NSE:NIFTYPVTBANK", "NSE:CNXFINANCE", "NSE:CNXIT", "NSE:CNXAUTO", "NSE:CNXPHARMA", "NSE:NIFTY_HEALTHCARE", "NSE:CNXFMCG", "NSE:CNXMETAL", "NSE:CNXENERGY", "NSE:NIFTY_OIL_AND_GAS", "NSE:CNXREALTY", "NSE:CNXMEDIA", "NSE:CNXINFRA", "NSE:NIFTY_CONSR_DURBL", "NSE:NIFTY_IND_DEFENCE", "NSE:NIFTY_CAPITAL_MKT")

useSectors = showSectors
secChg   = array.new<float>()
secScore = array.new<float>()
secAdx   = array.new<float>()
if useSectors
    for i = 0 to secTickers.size() - 1
        [sPc, sSc, sAdx] = request.security(secTickers.get(i), timeframe.period, indexMetrics(), ignore_invalid_symbol = true)
        secChg.push(sPc)
        secScore.push(sSc)
        secAdx.push(sAdx)

// ═══════════════════════ 3) STOCKS + PAGES ═══════════════════════
// Request budget (~40): Nifty 1 + Nifty OI 1 + sectors 18 + stocks (1 each, +1 each for OI).
// - Normal: a sector (max 19 stocks) is fetched in full, sorted, then shown page by page.
// - "All F&O", or Buildup + sector table together ("lite"): only the current page is fetched
//   (max 10 rows in lite mode) and stocks are ranked within that page.
MAX_FETCH = 19
names    = str.split(sectorList, ",")
nNames   = names.size()
isAll    = sector == "All F&O"
lite     = showBU and useSectors
effRows  = lite ? math.min(rowsPP, 10) : rowsPP
pageFetch = isAll or lite
total    = isAll ? nNames : math.min(nNames, MAX_FETCH)
pages    = math.max(1, int(math.ceil(total / float(effRows))))
pg       = math.min(page, pages)
pageTooBig = page > pages
fFirst   = pageFetch ? (pg - 1) * effRows : 0
fLast    = pageFetch ? math.min(fFirst + effRows, total) - 1 : total - 1
flipOK   = autoFlip and not pageFetch

syms = array.new<string>()
pcs  = array.new<float>()
ois  = array.new<float>()
vrs  = array.new<float>()
scs  = array.new<float>()
adxs = array.new<float>()
bus  = array.new<string>()
if fFirst <= fLast
    for i = fFirst to fLast
        tkr = "NSE:" + names.get(i) + "1!"
        [pc, vr, sc, ax] = request.security(tkr, timeframe.period, stockMetrics(), ignore_invalid_symbol = true)
        float oic = na
        if showBU
            oic := request.security(tkr + "_OI", timeframe.period, pctChg(close), ignore_invalid_symbol = true)
        b = showBU ? buildupOf(pc, oic) : "-"
        syms.push(names.get(i))
        pcs.push(pc)
        ois.push(oic)
        vrs.push(vr)
        bus.push(b)
        scs.push(sc + (showBU ? buildupVote(b) * buW : 0.0))
        adxs.push(ax)

// ═══════════════════════ TABLES ═══════════════════════
var table secTbl = table.new(posOf(secPos), 4, 20, bgcolor = secBg, frame_color = secBrd, frame_width = 1, border_color = secBrd, border_width = 1)
var table stkTbl = table.new(posOf(stkPos), 7, 24, bgcolor = stkBg, frame_color = stkBrd, frame_width = 1, border_color = stkBrd, border_width = 1)
var table mktTbl = table.new(posOf(mktPos), 3, 15, bgcolor = mktBg, frame_color = mktBrd, frame_width = 1, border_color = mktBrd, border_width = 1)

secTSz = sizeOf(secTS)
stkTSz = sizeOf(stkTS)
mktTSz = sizeOf(mktTS)
color NONE = na

if barstate.islast
    // ---------- Sector ranking ----------
    secBull = 0
    secBear = 0
    secSide = 0
    table.clear(secTbl, 0, 0, 3, 19)
    if useSectors
        put(secTbl, 0, 0, "#",      secHdr, NONE, secTSz, secW * 0.6, secH, false)
        put(secTbl, 1, 0, "Sector", secHdr, NONE, secTSz, secW * 2.2, secH, true)
        put(secTbl, 2, 0, "Chg %",  secHdr, NONE, secTSz, secW, secH, false)
        put(secTbl, 3, 0, "Trend",  secHdr, NONE, secTSz, secW * 1.8, secH, false)
        sIdx = sortDesc(secChg)
        for r = 0 to sIdx.size() - 1
            k = sIdx.get(r)
            v = secChg.get(k)
            t = trendOf(secScore.get(k), secAdx.get(k))
            secBull += str.contains(t, "Bullish") ? 1 : 0
            secBear += str.contains(t, "Bearish") ? 1 : 0
            secSide += t == "Sideways" ? 1 : 0
            put(secTbl, 0, r + 1, str.tostring(r + 1), secTxt, NONE, secTSz, secW * 0.6, secH, false)
            put(secTbl, 1, r + 1, secNames.get(k), secTxt, NONE, secTSz, secW * 2.2, secH, true)
            put(secTbl, 2, r + 1, fmt(v), clr(v), NONE, secTSz, secW, secH, false)
            put(secTbl, 3, r + 1, t, trTxtCol, trendCol(t), secTSz, secW * 1.8, secH, false)

    // ---------- Stock table ----------
    table.clear(stkTbl, 0, 0, 6, 23)
    key     = sortBy == "OI %" and showBU ? ois : sortBy == "Volume x" ? vrs : sortBy == "Trend score" ? scs : pcs
    sortLbl = sortBy == "OI %" and showBU ? "OI %" : sortBy == "Volume x" ? "Volume x" : sortBy == "Trend score" ? "Trend score" : "Price %"
    put(stkTbl, 1, 0, sector, stkHdr, NONE, stkTSz, stkW * 1.8, stkH, true)
    pgHdr = flipOK ? int(math.floor(timenow / 1000 / flipSec)) % pages + 1 : pg
    put(stkTbl, 2, 0, "Page " + str.tostring(pgHdr) + " / " + str.tostring(pages), stkHdr, NONE, stkTSz, stkW, stkH, false)
    if flipOK and not barstate.isrealtime
        put(stkTbl, 3, 0, "Auto-flip paused: no live ticks (market closed)", volHiCol, NONE, stkTSz, stkW, stkH, false)
    if pageTooBig and not flipOK
        put(stkTbl, 3, 0, "Only " + str.tostring(pages) + " page(s) - lower 'Rows per page'", volHiCol, NONE, stkTSz, stkW, stkH, false)
    put(stkTbl, 6, 0, sortLbl + " ↓", color.gray, NONE, stkTSz, stkW * 1.8, stkH, false)
    hdr  = array.from("#", "Symbol", "Price %", "OI %", "Buildup", "Vol x", "Trend")
    wMul = array.from(0.6, 1.8, 1.0, 1.0, 1.9, 0.8, 1.8)
    for c = 0 to 6
        put(stkTbl, c, 1, hdr.get(c), stkHdr, NONE, stkTSz, stkW * wMul.get(c), stkH, c == 1)

    // Counts over everything fetched (whole sector, or the current page)
    up = 0
    dn = 0
    stBull = 0
    stBear = 0
    stSide = 0
    cLB = 0
    cSB = 0
    cSC = 0
    cLU = 0
    nF = pcs.size()
    if nF > 0
        for j = 0 to nF - 1
            pcj = pcs.get(j)
            tj  = trendOf(scs.get(j), adxs.get(j))
            up += pcj > 0 ? 1 : 0
            dn += pcj < 0 ? 1 : 0
            stBull += str.contains(tj, "Bullish") ? 1 : 0
            stBear += str.contains(tj, "Bearish") ? 1 : 0
            stSide += tj == "Sideways" ? 1 : 0
            bj = bus.get(j)
            cLB += bj == "Long Buildup" ? 1 : 0
            cSB += bj == "Short Buildup" ? 1 : 0
            cSC += bj == "Short Covering" ? 1 : 0
            cLU += bj == "Long Unwinding" ? 1 : 0

        // Rows to display on this page
        kIdx   = sortDesc(key)
        dStart = pageFetch ? 0 : (pgHdr - 1) * effRows
        dEnd   = pageFetch ? nF - 1 : math.min(dStart + effRows, nF) - 1
        if dStart <= dEnd
            for r = dStart to dEnd
                k   = kIdx.get(r)
                pc  = pcs.get(k)
                oic = ois.get(k)
                vr  = vrs.get(k)
                t   = trendOf(scs.get(k), adxs.get(k))
                row = r - dStart + 2
                put(stkTbl, 0, row, str.tostring(r + 1), stkTxt, NONE, stkTSz, stkW * 0.6, stkH, false)
                put(stkTbl, 1, row, syms.get(k), stkTxt, NONE, stkTSz, stkW * 1.8, stkH, true)
                put(stkTbl, 2, row, fmt(pc), clr(pc), NONE, stkTSz, stkW, stkH, false)
                b   = bus.get(k)
                put(stkTbl, 3, row, showBU ? fmt(oic) : "-", showBU ? clr(oic) : color.gray, NONE, stkTSz, stkW, stkH, false)
                put(stkTbl, 4, row, b, showBU ? trTxtCol : color.gray, buildupCol(b), stkTSz, stkW * 1.9, stkH, false)
                put(stkTbl, 5, row, na(vr) ? "n/a" : str.tostring(vr, "0.00"), vr >= 1.5 ? volHiCol : stkTxt, NONE, stkTSz, stkW * 0.8, stkH, false)
                put(stkTbl, 6, row, t, trTxtCol, trendCol(t), stkTSz, stkW * 1.8, stkH, false)
            footer = dEnd - dStart + 3
            put(stkTbl, 1, footer, "Up " + str.tostring(up) + " | Down " + str.tostring(dn), stkHdr, NONE, stkTSz, stkW * 1.8, stkH, true)
            if pgHdr < pages
                put(stkTbl, 2, footer, "Next: Page " + str.tostring(pgHdr + 1), color.gray, NONE, stkTSz, stkW, stkH, false)
            if lite and not isAll
                put(stkTbl, 4, footer, "Ranked within page", color.gray, NONE, stkTSz, stkW * 1.9, stkH, false)

    // ---------- Market trend panel ----------
    table.clear(mktTbl, 0, 0, 2, 14)
    if showMkt
        secN    = secBull + secBear + secSide
        breadth = useSectors and secN > 0 ? (secBull - secBear) / float(secN) * 5 : na
        buBreadth = showBU and nF > 0 ? (cLB + 0.5 * cSC - cSB - 0.5 * cLU) / float(nF) * 5 : na
        // Overall = average of: Nifty score, sector breadth, stock buildup breadth (whichever are available)
        overall = (nScore + nz(breadth) + nz(buBreadth)) / (1 + (na(breadth) ? 0 : 1) + (na(buBreadth) ? 0 : 1))
        verdict = na(overall) ? "n/a" : nAdx < adxMin and math.abs(overall) < 3 ? "Sideways" : overall >= 3.5 ? "Strong Bullish" : overall >= 1.5 ? "Bullish" : overall <= -3.5 ? "Strong Bearish" : overall <= -1.5 ? "Bearish" : "Sideways"
        view    = verdict == "Strong Bullish" ? "Trend up - buy dips" : verdict == "Bullish" ? "Mild uptrend - prefer longs" : verdict == "Strong Bearish" ? "Trend down - sell rallies" : verdict == "Bearish" ? "Mild downtrend - be cautious" : "Range-bound - trade levels"
        w0 = mktW * 1.8
        w1 = mktW * 2.2
        w2 = mktW * 1.4
        put(mktTbl, 0, 0, "MARKET TREND", mktHdr, NONE, mktTSz, w0, mktH, true)
        put(mktTbl, 1, 0, verdict, trTxtCol, trendCol(verdict), mktTSz, w1, mktH, false)
        put(mktTbl, 2, 0, "Score " + (na(overall) ? "n/a" : str.tostring(overall, "0.0")) + " / 5", mktTxt, NONE, mktTSz, w2, mktH, false)
        put(mktTbl, 0, 1, "Nifty 50", mktTxt, NONE, mktTSz, w0, mktH, true)
        put(mktTbl, 1, 1, fmt(nPc), clr(nPc), NONE, mktTSz, w1, mktH, false)
        put(mktTbl, 2, 1, nTrend, trTxtCol, trendCol(nTrend), mktTSz, w2, mktH, false)
        put(mktTbl, 0, 2, "Price vs " + str.tostring(emaFast) + " EMA", mktTxt, NONE, mktTSz, w0, mktH, true)
        put(mktTbl, 1, 2, yesNo(n1, "Above", "Below"), voteCol(n1), NONE, mktTSz, w1, mktH, false)
        put(mktTbl, 0, 3, str.tostring(emaFast) + " vs " + str.tostring(emaSlow) + " EMA", mktTxt, NONE, mktTSz, w0, mktH, true)
        put(mktTbl, 1, 3, yesNo(n2, "Above", "Below"), voteCol(n2), NONE, mktTSz, w1, mktH, false)
        put(mktTbl, 0, 4, "RSI " + str.tostring(rsiLen), mktTxt, NONE, mktTSz, w0, mktH, true)
        put(mktTbl, 1, 4, na(nR) ? "n/a" : str.tostring(nR, "0.0"), voteCol(n3), NONE, mktTSz, w1, mktH, false)
        put(mktTbl, 2, 4, yesNo(n3, "Bullish", "Bearish"), voteCol(n3), NONE, mktTSz, w2, mktH, false)
        put(mktTbl, 0, 5, "Supertrend", mktTxt, NONE, mktTSz, w0, mktH, true)
        put(mktTbl, 1, 5, yesNo(n4, "Up", "Down"), voteCol(n4), NONE, mktTSz, w1, mktH, false)
        put(mktTbl, 0, 6, "+DI vs -DI", mktTxt, NONE, mktTSz, w0, mktH, true)
        put(mktTbl, 1, 6, yesNo(n5, "Buyers", "Sellers"), voteCol(n5), NONE, mktTSz, w1, mktH, false)
        put(mktTbl, 0, 7, "ADX " + str.tostring(adxLen), mktTxt, NONE, mktTSz, w0, mktH, true)
        put(mktTbl, 1, 7, na(nAdx) ? "n/a" : str.tostring(nAdx, "0.0"), mktTxt, NONE, mktTSz, w1, mktH, false)
        put(mktTbl, 2, 7, nAdx >= adxMin ? "Trending" : "Weak / range", nAdx >= adxMin ? volHiCol : color.gray, NONE, mktTSz, w2, mktH, false)
        put(mktTbl, 0, 8, "Nifty Fut OI", mktTxt, NONE, mktTSz, w0, mktH, true)
        put(mktTbl, 1, 8, showBU ? fmt(nOi) : "off", showBU ? clr(nOi) : color.gray, NONE, mktTSz, w1, mktH, false)
        put(mktTbl, 2, 8, nBU, showBU ? trTxtCol : color.gray, buildupCol(nBU), mktTSz, w2, mktH, false)
        put(mktTbl, 0, 9, "Sector breadth", mktTxt, NONE, mktTSz, w0, mktH, true)
        put(mktTbl, 1, 9, useSectors ? str.tostring(secBull) + " Bull / " + str.tostring(secBear) + " Bear" : "off", mktTxt, NONE, mktTSz, w1, mktH, false)
        put(mktTbl, 2, 9, useSectors ? str.tostring(secSide) + " Sideways" : "", color.gray, NONE, mktTSz, w2, mktH, false)
        put(mktTbl, 0, 10, sector + " stocks", mktTxt, NONE, mktTSz, w0, mktH, true)
        put(mktTbl, 1, 10, str.tostring(stBull) + " Bull / " + str.tostring(stBear) + " Bear", mktTxt, NONE, mktTSz, w1, mktH, false)
        put(mktTbl, 2, 10, str.tostring(stSide) + " Sideways", color.gray, NONE, mktTSz, w2, mktH, false)
        put(mktTbl, 0, 11, sector + " buildup", mktTxt, NONE, mktTSz, w0, mktH, true)
        put(mktTbl, 1, 11, showBU ? "LB " + str.tostring(cLB) + " | SC " + str.tostring(cSC) : "off", showBU ? upCol : color.gray, NONE, mktTSz, w1, mktH, false)
        put(mktTbl, 2, 11, showBU ? "SB " + str.tostring(cSB) + " | LU " + str.tostring(cLU) : "", dnCol, NONE, mktTSz, w2, mktH, false)
        put(mktTbl, 0, 12, "View", mktHdr, NONE, mktTSz, w0, mktH, true)
        put(mktTbl, 1, 12, view, mktTxt, NONE, mktTSz, w1, mktH, false)
````
