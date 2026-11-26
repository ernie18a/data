# ProTrader Specific version of the toodegrees indicator

- url: https://www.tradingview.com/script/vrKEhtHB-ProTrader-Specific-version-of-the-toodegrees-indicator/
- type: indicator
- pine_id: PUB;6b7081db4cee43e7a98eaca53470843a
- version: 2.0

## Description

News indicator specifically built for Luke Lawson's day trading strategies.

Fully crediting the original source code upon which this indicator is built to "toodegrees":
https://www.tradingview.com/u/toodegrees/

Original indicator upon which this indicator is based:
https://www.tradingview.com/script/JjgkjuMY-Live-Economic-Calendar-by-toodegrees/

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © toodegrees (modified)
import toodegrees/forex_factory_utility/16 as ffUtil
import toodegrees/forex_factory_decoding/39 as ffDec

//@version=5
indicator("My News Lines"
         , shorttitle="News Lines"
         , overlay=true
         , max_lines_count=500
         , max_labels_count=500)


//#region[Timeframe Limitations]
if timeframe.in_seconds(timeframe.period)>86400
    runtime.error("Go to the Daily Timeframe or lower!")
else if timeframe.in_seconds(timeframe.period)<30
    runtime.error("Go to the 30-Second Timeframe or higher!")
//#endregion


//#region[Global, Functions, Methods]
var mdnCheck = false
if hour(time,"America/New_York")==0 and hour(time[1],"America/New_York")!=0 and not mdnCheck
    mdnCheck := true
newDay = mdnCheck ? hour(time,"America/New_York")==0 and hour(time[1],"America/New_York")!=0 : timeframe.change("D")

requestData() =>
    [request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_1",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_2",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_3",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_4",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_5",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_6",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_7",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_8",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_9",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume))]

method processData(ffUtil.News[] N, string S1, string S2, string S3, string S4, string S5, string S6, string S7, string S8, string S9) =>
    ffDec.readNews(N,S1), ffDec.readNews(N,S2), ffDec.readNews(N,S3)
    ffDec.readNews(N,S4), ffDec.readNews(N,S5), ffDec.readNews(N,S6)
    ffDec.readNews(N,S7), ffDec.readNews(N,S8), ffDec.readNews(N,S9)

isKeyEvent(string ttl) =>
    t = str.lower(ttl)
    isRates = str.contains(t, "interest rate") or str.contains(t, "rate decision") or str.contains(t, "rate statement") or str.contains(t, "cash rate") or str.contains(t, "federal funds") or str.contains(t, "fomc") or str.contains(t, "bank rate") or str.contains(t, "refi") or str.contains(t, "monetary policy") or str.contains(t, "official cash") or str.contains(t, "overnight rate") or str.contains(t, "policy rate") or str.contains(t, "deposit facility") or str.contains(t, "mpc ") or str.contains(t, "ecb ") or str.contains(t, "boe ") or str.contains(t, "boc ") or str.contains(t, "boj ") or str.contains(t, "snb ") or str.contains(t, "rba ") or str.contains(t, "rbnz ") or str.contains(t, "press conf")
    isEmploy = str.contains(t, "employ") or str.contains(t, "unemploy") or str.contains(t, "nfp") or str.contains(t, "non-farm") or str.contains(t, "nonfarm") or str.contains(t, "payroll") or str.contains(t, "jobless") or str.contains(t, "adp") or str.contains(t, "jolts") or str.contains(t, "labor") or str.contains(t, "labour") or str.contains(t, "wage") or str.contains(t, "earnings") or str.contains(t, "jobs")
    isInfl = str.contains(t, "cpi") or str.contains(t, "ppi") or str.contains(t, "pce") or str.contains(t, "inflation") or str.contains(t, "consumer price") or str.contains(t, "producer price") or str.contains(t, "price index") or str.contains(t, "rpi")
    isRates or isEmploy or isInfl

eventDetail(string ttl) =>
    t = str.lower(ttl)
    d = ""
    if str.contains(t, "cpi") or str.contains(t, "consumer price")
        d := "Consumer Price Index — core inflation gauge. Higher than forecast = hawkish = currency bullish."
    else if str.contains(t, "nfp") or str.contains(t, "non-farm") or str.contains(t, "nonfarm")
        d := "Non-Farm Payrolls — US monthly jobs added. Higher = USD bullish, strong labor market."
    else if str.contains(t, "fomc") or str.contains(t, "federal funds") or str.contains(t, "rate decision") or str.contains(t, "interest rate")
        d := "Central bank rate decision — top-tier volatility. Hawkish surprise = currency bullish."
    else if str.contains(t, "unemployment rate")
        d := "Unemployment Rate — lower = bullish for currency, signals tight labor market."
    else if str.contains(t, "gdp")
        d := "Gross Domestic Product — broad economic growth. Higher = bullish."
    else if str.contains(t, "retail sales")
        d := "Retail Sales — consumer spending gauge. Higher = bullish."
    else if str.contains(t, "ppi") or str.contains(t, "producer price")
        d := "Producer Price Index — wholesale inflation, tends to lead CPI."
    else if str.contains(t, "pce")
        d := "PCE — Fed's preferred inflation measure. Watch Core PCE closely."
    else if str.contains(t, "ism manufacturing")
        d := "ISM Manufacturing PMI — factory activity. Above 50 = expansion."
    else if str.contains(t, "ism services") or str.contains(t, "ism non-manufacturing")
        d := "ISM Services PMI — service sector activity. Above 50 = expansion."
    else if str.contains(t, "jobless claims") or str.contains(t, "unemployment claims")
        d := "Weekly jobless claims — labor market pulse. Lower = bullish currency."
    else if str.contains(t, "jolts")
        d := "JOLTS Job Openings — labor demand indicator."
    else if str.contains(t, "adp")
        d := "ADP Employment — private payrolls, often seen as NFP preview."
    else if str.contains(t, "consumer confidence") or str.contains(t, "consumer sentiment")
        d := "Consumer sentiment — leading indicator for spending."
    else if str.contains(t, "durable goods")
        d := "Durable Goods Orders — business investment gauge."
    else if str.contains(t, "housing") or str.contains(t, "building permits") or str.contains(t, "new home")
        d := "Housing data — interest-rate sensitive, reflects credit conditions."
    else if str.contains(t, "pmi")
        d := "Purchasing Managers Index — business activity. Above 50 = expansion."
    else if str.contains(t, "trade balance")
        d := "Trade Balance — exports minus imports. Surplus = currency bullish."
    d

drawLines(ffUtil.News[] N, int T, string S) =>
    tfms = timeframe.in_seconds(timeframe.period)*1000
    keyCol = #8b0000
    if N.size() > 0
        for i = 0 to N.size() - 1
            n = N.get(i)
            adj = (n.tmst - time) % tfms != 0 ? n.tmst - tfms : n.tmst
            c   = isKeyEvent(n.ttl) ? keyCol : n.imp
            line.new(adj, low, adj, high, xloc.bar_time, extend.both, color.new(c, T), style=S)

redrawLabels(ffUtil.News[] N, label[] lbls, float yFuture) =>
    if lbls.size() > 0
        for i = 0 to lbls.size() - 1
            label.delete(lbls.get(i))
        lbls.clear()
    tfms = timeframe.in_seconds(timeframe.period)*1000
    keyCol = #8b0000
    if N.size() > 0
        for i = 0 to N.size() - 1
            n = N.get(i)
            adj = (n.tmst - time) % tfms != 0 ? n.tmst - tfms : n.tmst
            baseTT = n.ttl + " (" + n.cur + ")\n" + n.dow + " " + n.dat + " " + n.tod
            det    = eventDetail(n.ttl)
            tt     = str.length(det) > 0 ? baseTT + "\n\n" + det : baseTT
            dotCol = isKeyEvent(n.ttl) ? keyCol : n.imp
            label l = na
            if n.tmst <= time
                l := label.new(adj, na, text="●",
                     xloc=xloc.bar_time, yloc=yloc.abovebar,
                     style=label.style_none,
                     color=dotCol, textcolor=dotCol,
                     size=size.tiny,
                     tooltip=tt)
            else
                l := label.new(adj, yFuture, text="●",
                     xloc=xloc.bar_time, yloc=yloc.price,
                     style=label.style_none,
                     color=color.new(dotCol, 30), textcolor=color.new(dotCol, 30),
                     size=size.tiny,
                     tooltip=tt)
            lbls.push(l)
//#endregion


//#region[Tooltips]
var custom_timezoneTT = "The original Time and Date of the News is based on New York EST. Adjust the Timezone "
                      + "by matching this setting to the bottom-right Timezone setting on your Chart."
var expectedImpactTT  = "🔴 High Impact\n🟠 Medium Impact\n🟡 Low Impact\n⚪ Holiday"
var autoTT            = "Automatically chooses the Currencies' News based on the current symbol on Chart."
var onChartTT         = "'Today'\nAll historical news will be deleted once a new day starts, only the current day's news "
                      + "will be shown on chart.\n\n'This Week'\nAll historical news will be deleted once a new week "
                      + "starts, only the current week's news will be shown on chart.\n\n'Manual'\nWill show the current "
                      + "week's upcoming news as well as the news in the prior custom number of days (includes weekend days)."
//#endregion


//#region[User Input]
// Custom Timezone
custom_timezone = input.bool(false, title="Custom Timezone?", inline="1")
timezone_h      =  input.int(1    , title="UTC"             , inline="1", minval=-10, maxval=13)
timezone_m      =  input.int(0    , title=":"               , inline="1", minval=0  , maxval=59, step=15, tooltip=custom_timezoneTT)

// Expected Impact
var keyEventsOn = input.bool(true, title="🟥", group="Expected Impact", inline="1")
var high_impact = input.bool(true, title="🔴", group="Expected Impact", inline="1")
var med_impact  = input.bool(true, title="🟠", group="Expected Impact", inline="1")
var low_impact  = input.bool(false, title="🟡", group="Expected Impact", inline="1")
var holiday     = input.bool(false, title="⚪", group="Expected Impact", inline="1", tooltip=expectedImpactTT)

// Currencies
var AUTO = input.bool(true , title="Automatic?", group="Currencies", tooltip=autoTT)
var AUD  = input.bool(false, title="AUD"       , group="Currencies", inline="1")
var CAD  = input.bool(false, title="CAD"       , group="Currencies", inline="1")
var CHF  = input.bool(false, title="CHF"       , group="Currencies", inline="1")
var CNY  = input.bool(false, title="CNY"       , group="Currencies", inline="2")
var EUR  = input.bool(false, title="EUR"       , group="Currencies", inline="2")
var GBP  = input.bool(false, title="GBP"       , group="Currencies", inline="2")
var JPY  = input.bool(false, title="JPY "      , group="Currencies", inline="3")
var NZD  = input.bool(false, title="NZD"       , group="Currencies", inline="3")
var USD  = input.bool(false, title="USD"       , group="Currencies", inline="3")


// On Chart
var onChartT   =                  input.string("This Week", title="Chart History         ", group="News On Chart", inline="1", options=["Today", "This Week", "Manual"])
var onChartLB  =                     input.int(30         , title=""                      , group="News On Chart", inline="1", tooltip=onChartTT)
var showLabels =                    input.bool(true       , title="Show Labels?"          , group="News On Chart", inline="2")
var showLines  =                    input.bool(true       , title="Show Lines?  "         , group="News On Chart", inline="3")
var lineTime   =                  input.string("Future"   , title=""                      , group="News On Chart", inline="3", options=["Future", "Past+Future"])
var lineT      = ffUtil.lineTrnsp(input.string("Heavy"    , title=""                      , group="News On Chart", inline="3", options=["Light" , "Medium", "Heavy"]))
var lineS      = ffUtil.lineStyle(input.string("Solid"    , title=""                      , group="News On Chart", inline="3", options=["Dashed", "Dotted", "Solid"]))

// Process User Input
var impact_filter   = ffUtil.impFilter(holiday,low_impact,med_impact,high_impact)
var currency_filter = ffUtil.curFilter(AUTO,AUD,CAD,CHF,CNY,EUR,GBP,JPY,NZD,USD)
onChartT           := timeframe.period=="D" and onChartT=="Today"?"This Week":onChartT
//#endregion


//#region[Import, Decode, Save]
var currWeek = array.new<ffUtil.News>()
var nextWeek = array.new<ffUtil.News>()
var currDay  = array.new<ffUtil.News>()

// Import Forex Factory News for next week
[slot1,slot2,slot3,slot4,slot5,slot6,slot7,slot8,slot9] = requestData()

// Save Forex Factory News
if timeframe.change("W")
    nextWeek := ffUtil.bubbleSort_News(nextWeek)
    if custom_timezone
        nextWeek := ffUtil.adjustTimezone(nextWeek, timezone_h, timezone_m)
    currWeek := nextWeek.copy()
    currWeek := ffUtil.weekNews(currWeek,currency_filter,impact_filter)
    if not keyEventsOn
        filtered = array.new<ffUtil.News>()
        if currWeek.size() > 0
            for k = 0 to currWeek.size() - 1
                nk = currWeek.get(k)
                if not isKeyEvent(nk.ttl)
                    filtered.push(nk)
        currWeek := filtered
    nextWeek.clear()
if newDay
    currDay.clear()
    currDay := ffUtil.todayNews(currWeek,currDay,mdnCheck)

// Decode Forex Factory News
nextWeek.processData(slot1,slot2,slot3,slot4,slot5,slot6,slot7,slot8,slot9)
//#endregion


//#region[Drawings]
// Forex Factory News Drawings
if showLines
    if onChartT!="Today" and timeframe.change("W")
        drawLines(currWeek,lineT,lineS)
    else if onChartT=="Today" and newDay
        drawLines(currDay,lineT,lineS)
var label[] ourLabels = array.new<label>()
needRedraw = timeframe.change("W") or newDay
if not needRedraw and currWeek.size() > 0
    for i = 0 to currWeek.size() - 1
        nn = currWeek.get(i)
        if nn.tmst <= time and nn.tmst > time[1]
            needRedraw := true
            break
if showLabels and needRedraw
    if onChartT=="Today"
        redrawLabels(currDay, ourLabels, close)
    else
        redrawLabels(currWeek, ourLabels, close)

ffUtil.historical(onChartLB,onChartT=="Today",onChartT=="This Week",lineTime)
//#endregion


//#region[Daily Chart Buffer]
if timeframe.period=="D" and timeframe.change("W")
    nextWeek.processData(slot1,slot2,slot3,slot4,slot5,slot6,slot7,slot8,slot9)
//#endregion
````
