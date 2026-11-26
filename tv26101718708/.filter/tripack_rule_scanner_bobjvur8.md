# TriPack Rule Scanner

- url: https://www.tradingview.com/script/boBjVUr8/
- type: indicator
- pine_id: PUB;760be694700b412cab984463a467faed
- version: 1.0

## Description

[b]TriPack Rule Scanner[/b]

A table-based market scanner for up to 120 symbols on one chart. It is an [b]indicator[/b], not a strategy: it does not place orders, run a portfolio backtest, or report net profit.

TradingView allows a limited number of unique [i]request.security()[/i] calls per script (40 on most plans). This script packs [b]three symbols into one formula ticker[/b], then unpacks close (and uses open / high / low inside rules). Oscillators are calculated [b]inside[/b] each request on the [b]scan timeframe[/b] you choose, not on the chart's bar size. That keeps RSI and the other metrics aligned with Daily (or whatever TF you set) even if the chart is 5-minute.

[b]What you get[/b]
[list]
[*] Up to 120 user-picked symbols (defaults can be changed; any exchange TradingView supports).
[*] One metric column: RSI, StochRSI, Bollinger %B, ROC, PPO, distance from SMA, or CMO.
[*] Up to eight scan rules. Each rule is Buy or Sell, compares two fields or a field vs a number, and can use greater/less, equality, or cross up / cross down.
[*] Buy rules combine with AND or OR. Sell rules combine separately with AND or OR.
[*] Table signals: BUY, SELL, BOTH. A star (*) means the signal is [b]new[/b] on this scan bar.
[*] Banner counts and optional alerts when enough new BUY or SELL names appear on a new scan-timeframe bar.
[*] The chart's own symbol is marked in the table if it is in the list.
[/list]

[b]How to use it[/b]
[list=1]
[*] Set [b]Timeframe[/b] (Daily is a sensible default for a swing scan).
[*] Load or edit the 40 packs. In each pack, put the [b]highest-priced[/b] name in Expensive, then Mid, then Cheap. Wrong order can collide when values are unpacked.
[*] Turn on the rules you want. If no Buy rule is On, nothing will show BUY. Same for Sell.
[*] Use [b]Show rows[/b] = New to keep only fresh signals, or Buy / Sell to hide the rest.
[*] Create a TradingView alert on this script if you want notifications. The script does not send alerts by itself until you create one.
[/list]

[quote]This tool does not tell you what to trade. It lists names that match rules you defined. Past matches do not imply future results. You are responsible for risk, costs, and whether a setup fits your account.[/quote]

[b]What to watch (important)[/b]
[list]
[*] [b]Pack order.[/b] Expensive / Mid / Cheap are digit slots in one float, not labels of quality. Mix a very cheap name into the Expensive slot (or the reverse) and unpacking can fail or look like "Invalid".
[*] [b]Close is the reliable series.[/b] Oscillators use unpacked close. High and low of a [i]spread / formula ticker[/i] are approximate. Prefer Close, RSI, StochRSI, %B, ROC, PPO, SMA distance, and CMO in rules. Treat High/Low rules as rough.
[*] [b]No volume.[/b] Spread volume is not three real volumes. There is no MFI, VWAP, or volume filter.
[*] [b]AND vs OR.[/b] AND on several Buy rules will show few rows. That is expected. OR will show many.
[*] [b]New vs still true.[/b] RSI still below 30 is BUY without a star. BUY* is the bar it became true. Alerts follow new counts on a new scan-timeframe bar, not every chart tick.
[*] [b]Plan limits.[/b] One copy of the script uses the 40-request budget. Adding the same script twice does not share settings; each copy has its own universe.
[*] [b]Memory / load.[/b] Heavy oscillator + rule work on 120 names can hitch on a weak machine or a very low chart timeframe. If TradingView reports a memory limit, reduce rules or stay on Daily.
[*] [b]Invalid rows.[/b] Delisted, halted, or badly packed names show Invalid on Close only. They are not signals.
[*] [b]Not a backtest.[/b] There is no commission, slippage, or equity curve. Do not treat the table as proof of a trading system.
[*] [b]Publication chart.[/b] If you publish, use a clean chart: this script only, table readable, no extra indicators unless the text says they are required.
[/list]

[b]Disclaimer[/b]
[quote]Information is for education and visual scanning only. It is not financial, investment, or trading advice. Securities and other instruments can result in loss of capital. TradingView and the author are not responsible for decisions you make with this script. Scripts, ideas, and third-party content on the platform are provided as-is.[/quote]

## Source Code

````pine
//@version=6
indicator("TriPack Rule Scanner", shorttitle="Tripack", overlay=true)

// =============================================================================
// Inputs
// =============================================================================

string tfInput = input.timeframe("D", "Timeframe", group="Data")
string posInput = input.string("Bottom center", "Table position", group="Table", options=[
     "Bottom center", "Top center", "Middle", "Bottom right", "Bottom left", "Top right", "Top left", "Middle right", "Middle left"])
string layoutInput = input.string("Horizontal", "Layout", group="Table", options=["Horizontal", "Vertical"])
string tblSize = input.string(size.small, "Text size", group="Table", options=[size.tiny, size.small, size.normal])
string sortMode = input.string("Close descending", "Sort", group="Table", options=[
     "Close descending", "Close ascending", "Metric descending", "Metric ascending", "RSI descending", "RSI ascending", "Buy first", "Sell first", "Symbol A-Z", "Symbol Z-A"])
string metricInput = input.string("RSI", "Metric", group="Table", options=[
     "RSI", "StochRSI", "BB %B", "ROC", "PPO", "SMA Dist %", "CMO"], tooltip="All seven are calculated on unpacked close at the selected timeframe. This input only chooses which one the third column shows.")
string signalView = input.string("All", "Show rows", group="Table", options=["All", "Buy", "Sell", "Buy or Sell", "New"])

int rsiLen = input.int(14, "Length", minval=2, maxval=200, group="RSI")
int rsiOb = input.int(70, "Overbought", minval=50, maxval=100, group="RSI")
int rsiOs = input.int(30, "Oversold", minval=0, maxval=50, group="RSI")

int stochRsiLen = input.int(14, "Stoch length", minval=2, maxval=200, group="Oscillators")
int stochSmooth = input.int(3, "Stoch smooth", minval=1, maxval=50, group="Oscillators")
int bbLen = input.int(20, "BB length", minval=2, maxval=200, group="Oscillators")
float bbMult = input.float(2.0, "BB mult", minval=0.1, step=0.1, group="Oscillators")
int rocLen = input.int(10, "ROC length", minval=1, maxval=200, group="Oscillators")
int ppoFast = input.int(12, "PPO fast", minval=2, maxval=200, group="Oscillators")
int ppoSlow = input.int(26, "PPO slow", minval=2, maxval=200, group="Oscillators")
int smaLen = input.int(20, "SMA length", minval=2, maxval=400, group="Oscillators")
int cmoLen = input.int(14, "CMO length", minval=2, maxval=200, group="Oscillators")

string buyJoin = input.string("AND", "Buy join", options=["AND", "OR"], group="Scan rules", inline="join", tooltip="AND: every active Buy rule must pass. OR: any one Buy rule is enough. No active Buy rule = no BUY.")
string sellJoin = input.string("AND", "Sell join", options=["AND", "OR"], group="Scan rules", inline="join", tooltip="AND: every active Sell rule must pass. OR: any one Sell rule is enough. No active Sell rule = no SELL.")
bool alertOn = input.bool(true, "Alert on new", group="Scan rules", inline="alrt")
int alertMin = input.int(1, "Min new", minval=1, group="Scan rules", inline="alrt", tooltip="Fires when at least this many new BUY or new SELL appear on a new scan-timeframe bar. Create an alert on this indicator.")

string rSrcTip = "High/Low of a spread ticker are approximate. Oscillators use unpacked close."
r1On = input.bool(false, "On", group="Rule 1", inline="r1h")
r1Side = input.string("Buy", "", options=["Buy", "Sell"], group="Rule 1", inline="r1h")
r1Left = input.string("RSI", "A", options=["Close", "Open", "High", "Low", "RSI", "StochRSI", "BB %B", "ROC", "PPO", "SMA Dist %", "CMO"], group="Rule 1", inline="r1c", tooltip=rSrcTip)
r1Op = input.string("<", "", options=[">", "<", ">=", "<=", "==", "!=", "Cross up", "Cross down"], group="Rule 1", inline="r1c")
r1Right = input.string("Close", "B", options=["Close", "Open", "High", "Low", "RSI", "StochRSI", "BB %B", "ROC", "PPO", "SMA Dist %", "CMO"], group="Rule 1", inline="r1c")
r1UseVal = input.bool(true, "Number", group="Rule 1", inline="r1v")
r1Val = input.float(30.0, "", group="Rule 1", inline="r1v")

r2On = input.bool(false, "On", group="Rule 2", inline="r2h")
r2Side = input.string("Sell", "", options=["Buy", "Sell"], group="Rule 2", inline="r2h")
r2Left = input.string("RSI", "A", options=["Close", "Open", "High", "Low", "RSI", "StochRSI", "BB %B", "ROC", "PPO", "SMA Dist %", "CMO"], group="Rule 2", inline="r2c", tooltip=rSrcTip)
r2Op = input.string(">", "", options=[">", "<", ">=", "<=", "==", "!=", "Cross up", "Cross down"], group="Rule 2", inline="r2c")
r2Right = input.string("Close", "B", options=["Close", "Open", "High", "Low", "RSI", "StochRSI", "BB %B", "ROC", "PPO", "SMA Dist %", "CMO"], group="Rule 2", inline="r2c")
r2UseVal = input.bool(true, "Number", group="Rule 2", inline="r2v")
r2Val = input.float(70.0, "", group="Rule 2", inline="r2v")

r3On = input.bool(false, "On", group="Rule 3", inline="r3h")
r3Side = input.string("Buy", "", options=["Buy", "Sell"], group="Rule 3", inline="r3h")
r3Left = input.string("Close", "A", options=["Close", "Open", "High", "Low", "RSI", "StochRSI", "BB %B", "ROC", "PPO", "SMA Dist %", "CMO"], group="Rule 3", inline="r3c", tooltip=rSrcTip)
r3Op = input.string(">", "", options=[">", "<", ">=", "<=", "==", "!=", "Cross up", "Cross down"], group="Rule 3", inline="r3c")
r3Right = input.string("Open", "B", options=["Close", "Open", "High", "Low", "RSI", "StochRSI", "BB %B", "ROC", "PPO", "SMA Dist %", "CMO"], group="Rule 3", inline="r3c")
r3UseVal = input.bool(false, "Number", group="Rule 3", inline="r3v")
r3Val = input.float(0.0, "", group="Rule 3", inline="r3v")

r4On = input.bool(false, "On", group="Rule 4", inline="r4h")
r4Side = input.string("Sell", "", options=["Buy", "Sell"], group="Rule 4", inline="r4h")
r4Left = input.string("Close", "A", options=["Close", "Open", "High", "Low", "RSI", "StochRSI", "BB %B", "ROC", "PPO", "SMA Dist %", "CMO"], group="Rule 4", inline="r4c", tooltip=rSrcTip)
r4Op = input.string("<", "", options=[">", "<", ">=", "<=", "==", "!=", "Cross up", "Cross down"], group="Rule 4", inline="r4c")
r4Right = input.string("Open", "B", options=["Close", "Open", "High", "Low", "RSI", "StochRSI", "BB %B", "ROC", "PPO", "SMA Dist %", "CMO"], group="Rule 4", inline="r4c")
r4UseVal = input.bool(false, "Number", group="Rule 4", inline="r4v")
r4Val = input.float(0.0, "", group="Rule 4", inline="r4v")

r5On = input.bool(false, "On", group="Rule 5", inline="r5h")
r5Side = input.string("Buy", "", options=["Buy", "Sell"], group="Rule 5", inline="r5h")
r5Left = input.string("StochRSI", "A", options=["Close", "Open", "High", "Low", "RSI", "StochRSI", "BB %B", "ROC", "PPO", "SMA Dist %", "CMO"], group="Rule 5", inline="r5c", tooltip=rSrcTip)
r5Op = input.string("<", "", options=[">", "<", ">=", "<=", "==", "!=", "Cross up", "Cross down"], group="Rule 5", inline="r5c")
r5Right = input.string("Close", "B", options=["Close", "Open", "High", "Low", "RSI", "StochRSI", "BB %B", "ROC", "PPO", "SMA Dist %", "CMO"], group="Rule 5", inline="r5c")
r5UseVal = input.bool(true, "Number", group="Rule 5", inline="r5v")
r5Val = input.float(20.0, "", group="Rule 5", inline="r5v")

r6On = input.bool(false, "On", group="Rule 6", inline="r6h")
r6Side = input.string("Sell", "", options=["Buy", "Sell"], group="Rule 6", inline="r6h")
r6Left = input.string("StochRSI", "A", options=["Close", "Open", "High", "Low", "RSI", "StochRSI", "BB %B", "ROC", "PPO", "SMA Dist %", "CMO"], group="Rule 6", inline="r6c", tooltip=rSrcTip)
r6Op = input.string(">", "", options=[">", "<", ">=", "<=", "==", "!=", "Cross up", "Cross down"], group="Rule 6", inline="r6c")
r6Right = input.string("Close", "B", options=["Close", "Open", "High", "Low", "RSI", "StochRSI", "BB %B", "ROC", "PPO", "SMA Dist %", "CMO"], group="Rule 6", inline="r6c")
r6UseVal = input.bool(true, "Number", group="Rule 6", inline="r6v")
r6Val = input.float(80.0, "", group="Rule 6", inline="r6v")

r7On = input.bool(false, "On", group="Rule 7", inline="r7h")
r7Side = input.string("Buy", "", options=["Buy", "Sell"], group="Rule 7", inline="r7h")
r7Left = input.string("BB %B", "A", options=["Close", "Open", "High", "Low", "RSI", "StochRSI", "BB %B", "ROC", "PPO", "SMA Dist %", "CMO"], group="Rule 7", inline="r7c", tooltip=rSrcTip)
r7Op = input.string("<", "", options=[">", "<", ">=", "<=", "==", "!=", "Cross up", "Cross down"], group="Rule 7", inline="r7c")
r7Right = input.string("Close", "B", options=["Close", "Open", "High", "Low", "RSI", "StochRSI", "BB %B", "ROC", "PPO", "SMA Dist %", "CMO"], group="Rule 7", inline="r7c")
r7UseVal = input.bool(true, "Number", group="Rule 7", inline="r7v")
r7Val = input.float(20.0, "", group="Rule 7", inline="r7v")

r8On = input.bool(false, "On", group="Rule 8", inline="r8h")
r8Side = input.string("Sell", "", options=["Buy", "Sell"], group="Rule 8", inline="r8h")
r8Left = input.string("BB %B", "A", options=["Close", "Open", "High", "Low", "RSI", "StochRSI", "BB %B", "ROC", "PPO", "SMA Dist %", "CMO"], group="Rule 8", inline="r8c", tooltip=rSrcTip)
r8Op = input.string(">", "", options=[">", "<", ">=", "<=", "==", "!=", "Cross up", "Cross down"], group="Rule 8", inline="r8c")
r8Right = input.string("Close", "B", options=["Close", "Open", "High", "Low", "RSI", "StochRSI", "BB %B", "ROC", "PPO", "SMA Dist %", "CMO"], group="Rule 8", inline="r8c")
r8UseVal = input.bool(true, "Number", group="Rule 8", inline="r8v")
r8Val = input.float(80.0, "", group="Rule 8", inline="r8v")

// Pick symbols with search. Pack order: Expensive / Mid / Cheap (digit slots in the packed float).
e1 = input.symbol("BIST:KONYA", "Expensive", group="Pack 01", inline="p01", display=display.none)
m1 = input.symbol("BIST:ENKAI", "Mid", group="Pack 01", inline="p01", display=display.none)
c1s = input.symbol("BIST:VESTL", "Cheap", group="Pack 01", inline="p01", display=display.none)
e2 = input.symbol("BIST:ODINE", "Expensive", group="Pack 02", inline="p02", display=display.none)
m2 = input.symbol("BIST:AKSEN", "Mid", group="Pack 02", inline="p02", display=display.none)
c2s = input.symbol("BIST:OYAKC", "Cheap", group="Pack 02", inline="p02", display=display.none)
e3 = input.symbol("BIST:DSTKF", "Expensive", group="Pack 03", inline="p03", display=display.none)
m3 = input.symbol("BIST:ARDYZ", "Mid", group="Pack 03", inline="p03", display=display.none)
c3s = input.symbol("BIST:DOHOL", "Cheap", group="Pack 03", inline="p03", display=display.none)
e4 = input.symbol("BIST:BRYAT", "Expensive", group="Pack 04", inline="p04", display=display.none)
m4 = input.symbol("BIST:GESAN", "Mid", group="Pack 04", inline="p04", display=display.none)
c4s = input.symbol("BIST:AEFES", "Cheap", group="Pack 04", inline="p04", display=display.none)
e5 = input.symbol("BIST:CLEBI", "Expensive", group="Pack 05", inline="p05", display=display.none)
m5 = input.symbol("BIST:FROTO", "Mid", group="Pack 05", inline="p05", display=display.none)
c5s = input.symbol("BIST:PETKM", "Cheap", group="Pack 05", inline="p05", display=display.none)
e6 = input.symbol("BIST:BRSAN", "Expensive", group="Pack 06", inline="p06", display=display.none)
m6 = input.symbol("BIST:ECILC", "Mid", group="Pack 06", inline="p06", display=display.none)
c6s = input.symbol("BIST:EKGYO", "Cheap", group="Pack 06", inline="p06", display=display.none)
e7 = input.symbol("BIST:MGROS", "Expensive", group="Pack 07", inline="p07", display=display.none)
m7 = input.symbol("BIST:BRISA", "Mid", group="Pack 07", inline="p07", display=display.none)
c7s = input.symbol("BIST:ALTNY", "Cheap", group="Pack 07", inline="p07", display=display.none)
e8 = input.symbol("BIST:MPARK", "Expensive", group="Pack 08", inline="p08", display=display.none)
m8 = input.symbol("BIST:PNSUT", "Mid", group="Pack 08", inline="p08", display=display.none)
c8s = input.symbol("BIST:BERA", "Cheap", group="Pack 08", inline="p08", display=display.none)
e9 = input.symbol("BIST:GUBRF", "Expensive", group="Pack 09", inline="p09", display=display.none)
m9 = input.symbol("BIST:TRMET", "Mid", group="Pack 09", inline="p09", display=display.none)
c9s = input.symbol("BIST:ISCTR", "Cheap", group="Pack 09", inline="p09", display=display.none)
e10 = input.symbol("BIST:ASELS", "Expensive", group="Pack 10", inline="p10", display=display.none)
m10 = input.symbol("BIST:AKBNK", "Mid", group="Pack 10", inline="p10", display=display.none)
c10s = input.symbol("BIST:AKSA", "Cheap", group="Pack 10", inline="p10", display=display.none)
e11 = input.symbol("BIST:BIMAS", "Expensive", group="Pack 11", inline="p11", display=display.none)
m11 = input.symbol("BIST:TTKOM", "Mid", group="Pack 11", inline="p11", display=display.none)
c11s = input.symbol("BIST:TSKB", "Cheap", group="Pack 11", inline="p11", display=display.none)
e12 = input.symbol("BIST:TUPRS", "Expensive", group="Pack 12", inline="p12", display=display.none)
m12 = input.symbol("BIST:SOKM", "Mid", group="Pack 12", inline="p12", display=display.none)
c12s = input.symbol("BIST:SMRTG", "Cheap", group="Pack 12", inline="p12", display=display.none)
e13 = input.symbol("BIST:ASTOR", "Expensive", group="Pack 13", inline="p13", display=display.none)
m13 = input.symbol("BIST:KTLEV", "Mid", group="Pack 13", inline="p13", display=display.none)
c13s = input.symbol("BIST:KARSN", "Cheap", group="Pack 13", inline="p13", display=display.none)
e14 = input.symbol("BIST:OTKAR", "Expensive", group="Pack 14", inline="p14", display=display.none)
m14 = input.symbol("BIST:AVPGY", "Mid", group="Pack 14", inline="p14", display=display.none)
c14s = input.symbol("BIST:ENERY", "Cheap", group="Pack 14", inline="p14", display=display.none)
e15 = input.symbol("BIST:THYAO", "Expensive", group="Pack 15", inline="p15", display=display.none)
m15 = input.symbol("BIST:CIMSA", "Mid", group="Pack 15", inline="p15", display=display.none)
c15s = input.symbol("BIST:ODAS", "Cheap", group="Pack 15", inline="p15", display=display.none)
e16 = input.symbol("BIST:GOLTS", "Expensive", group="Pack 16", inline="p16", display=display.none)
m16 = input.symbol("BIST:KRDMD", "Mid", group="Pack 16", inline="p16", display=display.none)
c16s = input.symbol("BIST:TURSG", "Cheap", group="Pack 16", inline="p16", display=display.none)
e17 = input.symbol("BIST:TAVHL", "Expensive", group="Pack 17", inline="p17", display=display.none)
m17 = input.symbol("BIST:SISE", "Mid", group="Pack 17", inline="p17", display=display.none)
c17s = input.symbol("BIST:SKBNK", "Cheap", group="Pack 17", inline="p17", display=display.none)
e18 = input.symbol("BIST:TOASO", "Expensive", group="Pack 18", inline="p18", display=display.none)
m18 = input.symbol("BIST:RYGYO", "Mid", group="Pack 18", inline="p18", display=display.none)
c18s = input.symbol("BIST:REEDR", "Cheap", group="Pack 18", inline="p18", display=display.none)
e19 = input.symbol("BIST:TABGD", "Expensive", group="Pack 19", inline="p19", display=display.none)
m19 = input.symbol("BIST:ALFAS", "Mid", group="Pack 19", inline="p19", display=display.none)
c19s = input.symbol("BIST:OBAMS", "Cheap", group="Pack 19", inline="p19", display=display.none)
e20 = input.symbol("BIST:RALYH", "Expensive", group="Pack 20", inline="p20", display=display.none)
m20 = input.symbol("BIST:MAVI", "Mid", group="Pack 20", inline="p20", display=display.none)
c20s = input.symbol("BIST:BTCIM", "Cheap", group="Pack 20", inline="p20", display=display.none)
e21 = input.symbol("BIST:SELEC", "Expensive", group="Pack 21", inline="p21", display=display.none)
m21 = input.symbol("BIST:EREGL", "Mid", group="Pack 21", inline="p21", display=display.none)
c21s = input.symbol("BIST:KONTR", "Cheap", group="Pack 21", inline="p21", display=display.none)
e22 = input.symbol("BIST:TKFEN", "Expensive", group="Pack 22", inline="p22", display=display.none)
m22 = input.symbol("BIST:CWENE", "Mid", group="Pack 22", inline="p22", display=display.none)
c22s = input.symbol("BIST:HEKTS", "Cheap", group="Pack 22", inline="p22", display=display.none)
e23 = input.symbol("BIST:GRTHO", "Expensive", group="Pack 23", inline="p23", display=display.none)
m23 = input.symbol("BIST:YKBNK", "Mid", group="Pack 23", inline="p23", display=display.none)
c23s = input.symbol("BIST:SASA", "Cheap", group="Pack 23", inline="p23", display=display.none)
e24 = input.symbol("BIST:KCHOL", "Expensive", group="Pack 24", inline="p24", display=display.none)
m24 = input.symbol("BIST:BSOKE", "Mid", group="Pack 24", inline="p24", display=display.none)
c24s = input.symbol("BIST:AGROT", "Cheap", group="Pack 24", inline="p24", display=display.none)
e25 = input.symbol("BIST:IEYHO", "Expensive", group="Pack 25", inline="p25", display=display.none)
m25 = input.symbol("BIST:HALKB", "Mid", group="Pack 25", inline="p25", display=display.none)
c25s = input.symbol("BIST:ZOREN", "Cheap", group="Pack 25", inline="p25", display=display.none)
e26 = input.symbol("BIST:DOAS", "Expensive", group="Pack 26", inline="p26", display=display.none)
m26 = input.symbol("BIST:MAGEN", "Mid", group="Pack 26", inline="p26", display=display.none)
c26s = input.symbol("BIST:CANTE", "Cheap", group="Pack 26", inline="p26", display=display.none)
e27 = input.symbol("BIST:PASEU", "Expensive", group="Pack 27", inline="p27", display=display.none)
m27 = input.symbol("BIST:AHGAZ", "Mid", group="Pack 27", inline="p27", display=display.none)
c27s = input.symbol("BIST:GSRAY", "Cheap", group="Pack 27", inline="p27", display=display.none)
e28 = input.symbol("BIST:PGSUS", "Expensive", group="Pack 28", inline="p28", display=display.none)
m28 = input.symbol("BIST:ISMEN", "Mid", group="Pack 28", inline="p28", display=display.none)
c28s = input.symbol("BIST:BJKAS", "Cheap", group="Pack 28", inline="p28", display=display.none)
e29 = input.symbol("BIST:GARAN", "Expensive", group="Pack 29", inline="p29", display=display.none)
m29 = input.symbol("BIST:AGHOL", "Mid", group="Pack 29", inline="p29", display=display.none)
c29s = input.symbol("BIST:ALBRK", "Cheap", group="Pack 29", inline="p29", display=display.none)
e30 = input.symbol("BIST:QNBTR", "Expensive", group="Pack 30", inline="p30", display=display.none)
m30 = input.symbol("BIST:MIATK", "Mid", group="Pack 30", inline="p30", display=display.none)
c30s = input.symbol("BIST:AKFGY", "Cheap", group="Pack 30", inline="p30", display=display.none)
e31 = input.symbol("BIST:ANHYT", "Expensive", group="Pack 31", inline="p31", display=display.none)
m31 = input.symbol("BIST:VAKBN", "Mid", group="Pack 31", inline="p31", display=display.none)
c31s = input.symbol("BIST:INDES", "Cheap", group="Pack 31", inline="p31", display=display.none)
e32 = input.symbol("BIST:ENJSA", "Expensive", group="Pack 32", inline="p32", display=display.none)
m32 = input.symbol("BIST:TRALT", "Mid", group="Pack 32", inline="p32", display=display.none)
c32s = input.symbol("BIST:TSGYO", "Cheap", group="Pack 32", inline="p32", display=display.none)
e33 = input.symbol("BIST:TCELL", "Expensive", group="Pack 33", inline="p33", display=display.none)
m33 = input.symbol("BIST:BAGFS", "Mid", group="Pack 33", inline="p33", display=display.none)
c33s = input.symbol("BIST:TATGD", "Cheap", group="Pack 33", inline="p33", display=display.none)
e34 = input.symbol("BIST:ALARK", "Expensive", group="Pack 34", inline="p34", display=display.none)
m34 = input.symbol("BIST:DEVA", "Mid", group="Pack 34", inline="p34", display=display.none)
c34s = input.symbol("BIST:KERVT", "Cheap", group="Pack 34", inline="p34", display=display.none)
e35 = input.symbol("BIST:ARCLK", "Expensive", group="Pack 35", inline="p35", display=display.none)
m35 = input.symbol("BIST:NTHOL", "Mid", group="Pack 35", inline="p35", display=display.none)
c35s = input.symbol("BIST:VESBE", "Cheap", group="Pack 35", inline="p35", display=display.none)
e36 = input.symbol("BIST:EUPWR", "Expensive", group="Pack 36", inline="p36", display=display.none)
m36 = input.symbol("BIST:SARKY", "Mid", group="Pack 36", inline="p36", display=display.none)
c36s = input.symbol("BIST:AYDEM", "Cheap", group="Pack 36", inline="p36", display=display.none)
e37 = input.symbol("BIST:SAHOL", "Expensive", group="Pack 37", inline="p37", display=display.none)
m37 = input.symbol("BIST:CVKMD", "Mid", group="Pack 37", inline="p37", display=display.none)
c37s = input.symbol("BIST:ISGYO", "Cheap", group="Pack 37", inline="p37", display=display.none)
e38 = input.symbol("BIST:ULKER", "Expensive", group="Pack 38", inline="p38", display=display.none)
m38 = input.symbol("BIST:GWIND", "Mid", group="Pack 38", inline="p38", display=display.none)
c38s = input.symbol("BIST:EUREN", "Cheap", group="Pack 38", inline="p38", display=display.none)
e39 = input.symbol("BIST:LOGO", "Expensive", group="Pack 39", inline="p39", display=display.none)
m39 = input.symbol("BIST:ANSGR", "Mid", group="Pack 39", inline="p39", display=display.none)
c39s = input.symbol("BIST:PSGYO", "Cheap", group="Pack 39", inline="p39", display=display.none)
e40 = input.symbol("BIST:CCOLA", "Expensive", group="Pack 40", inline="p40", display=display.none)
m40 = input.symbol("BIST:LMKDC", "Mid", group="Pack 40", inline="p40", display=display.none)
c40s = input.symbol("BIST:PAHOL", "Cheap", group="Pack 40", inline="p40", display=display.none)

// Formula-ticker multipliers (string: scientific notation breaks the formula).
const string N_MID_STR = "10000000"
const string N_CHEAP_STR = "1000000000000"
const float N_MID = 10000000.0
const float N_CHEAP = 1000000000000.0
const int DECIMALS = 2
const int SYM_COUNT = 120
const int PACK_COUNT = 40
const int CELL_COLS = 4
const int HORIZ_BLOCKS = 6
const int HORIZ_ROWS = 20
const int VERT_BLOCKS = 3
const int VERT_ROWS = 40
const int TAB_COLS = 24
const int TAB_ROWS = 42
const int BANNER_ROW = 0
const int HEADER_ROW = 1
const int DATA_ROW0 = 2
// Oscillator packing uses integer hundredths. Offset 500 keeps signed metrics positive.
// Slot 99999 = na. Multipliers 1e5 / 1e10 leave no overlap between legs.
const float OSC_OFF = 500.0
const float OSC_NA_I = 99999.0
const float OSC_MID = 100000.0
const float OSC_CHEAP = 10000000000.0

// Packed open/close, seven oscillators, and a packed buy/sell code per three legs.
// High/low of a spread ticker are approximate; they are used only inside scan rules.
type PackBar
    float o
    float c
    float rsi
    float stoch
    float bb
    float roc
    float ppo
    float sma
    float cmo
    float sig

var array<string> tickers = array.new<string>(120, "")
var array<float> opens = array.new<float>(120, na)
var array<float> closes = array.new<float>(120, na)
var array<float> rsis = array.new<float>(120, na)
var array<float> stochs = array.new<float>(120, na)
var array<float> bbs = array.new<float>(120, na)
var array<float> rocs = array.new<float>(120, na)
var array<float> ppos = array.new<float>(120, na)
var array<float> smas = array.new<float>(120, na)
var array<float> cmos = array.new<float>(120, na)
var array<float> signals = array.new<float>(120, 0.0)
var array<float> signalPrev = array.new<float>(120, 0.0)

// =============================================================================
// Helpers
// =============================================================================

// Turns input.symbol() into a clean EXCHANGE:TICKER for the spread formula.
// raw: "BIST:THYAO" or a longer ticker id. Empty string if missing.
// Return: "BIST:THYAO" or "".
spreadTicker(raw) =>
    string t = str.trim(raw)
    t := str.replace_all(t, "\"", "")
    t := str.replace_all(t, " ", "")
    array<string> byComma = str.split(t, ",")
    t := byComma.get(0)
    array<string> byPipe = str.split(t, "|")
    t := byPipe.get(0)
    t := str.replace_all(t, "!", "")
    array<string> parts = str.split(t, ":")
    string result = ""
    if parts.size() >= 2
        result := str.upper(parts.get(parts.size() - 2)) + ":" + str.upper(parts.get(parts.size() - 1))
    else if str.length(t) > 0
        result := "BIST:" + str.upper(t)
    result

// Packs three symbols into one TradingView formula ticker.
// tExpensive: remainder slot (highest-priced of the three), tMid: mid slot, tCheap: large multiplier.
// Return: "EXCHANGE:A+EXCHANGE:B*10000000+EXCHANGE:C*1000000000000".
compose3(tExpensive, tMid, tCheap) =>
    spreadTicker(tExpensive) + "+" + spreadTicker(tMid) + "*" + N_MID_STR + "+" + spreadTicker(tCheap) + "*" + N_CHEAP_STR

// Splits one packed number into three prices (call separately for open/high/low/close).
// packed: that field of the formula ticker. If packed is na, all three are na.
// Return: [expensive, mid, cheap] prices (2 decimals).
split3(packed) =>
    float expensive = na
    float mid = na
    float cheap = na
    if not na(packed)
        float n = packed
        cheap := math.round(n / N_CHEAP, DECIMALS)
        n -= nz(cheap * N_CHEAP)
        mid := math.round(n / N_MID, DECIMALS)
        n -= nz(mid * N_MID)
        expensive := math.round(n, DECIMALS)
    [expensive, mid, cheap]

// Maps one oscillator into integer hundredths (0..99998). na becomes 99999.
// v: RSI / StochRSI / %B / ROC / PPO / SMA% / CMO. Return: stored slot.
storeOsc(v) =>
    na(v) ? OSC_NA_I : math.round(math.min(math.max(v + OSC_OFF, 0.0), 999.98) * 100.0)

// Reverses storeOsc. Slot 99999 (and missing packs) become na.
// stored: integer hundredths. Return: original oscillator or na.
loadOsc(stored) =>
    na(stored) or stored >= OSC_NA_I - 0.5 ? na : stored / 100.0 - OSC_OFF

// Packs three oscillator values into one float via integer slots (exact in IEEE-754 here).
// eVal/mVal/cVal: expensive/mid/cheap legs. Return: packed float.
pack3osc(eVal, mVal, cVal) =>
    storeOsc(eVal) + storeOsc(mVal) * OSC_MID + storeOsc(cVal) * OSC_CHEAP

// Splits one packed oscillator float into three values.
// packed: PackBar oscillator field. Return: [expensive, mid, cheap] or na.
split3osc(packed) =>
    float expensive = na
    float mid = na
    float cheap = na
    if not na(packed)
        float n = packed
        cheap := math.floor(n / OSC_CHEAP + 1.0e-6)
        n -= cheap * OSC_CHEAP
        mid := math.floor(n / OSC_MID + 1.0e-6)
        n -= mid * OSC_MID
        expensive := math.round(n)
        expensive := loadOsc(expensive)
        mid := loadOsc(mid)
        cheap := loadOsc(cheap)
    [expensive, mid, cheap]

// Stochastic RSI %K from an already-computed RSI, then SMA smooth.
// rsiVal: ta.rsi of one unpacked close. Return: 0..100 or na.
stochFromRsi(rsiVal) =>
    ta.sma(ta.stoch(rsiVal, rsiVal, rsiVal, stochRsiLen), stochSmooth)

// Bollinger %B as 0..100 (can exceed that band). Close only.
// src: unpacked close of one leg. Return: percent-B * 100 or na.
bbPctLeg(src) =>
    [bbBasis, upper, lower] = ta.bb(src, bbLen, bbMult)
    float den = upper - lower
    na(bbBasis) or na(den) or den == 0.0 ? na : (src - lower) / den * 100.0

// Percent Price Oscillator. Close only; comparable across different price levels.
// src: unpacked close of one leg. Return: PPO % or na.
ppoLeg(src) =>
    float fast = ta.ema(src, ppoFast)
    float slow = ta.ema(src, ppoSlow)
    na(slow) or slow == 0.0 ? na : (fast - slow) / slow * 100.0

// Distance from SMA as percent of the average. Close only.
// src: unpacked close of one leg. Return: (close-sma)/sma*100 or na.
smaDistLeg(src) =>
    float ma = ta.sma(src, smaLen)
    na(ma) or ma == 0.0 ? na : (src - ma) / ma * 100.0

// Picks one series for a rule operand. name: Close/Open/High/Low or an oscillator label.
// Return: that series for one unpacked pack leg.
pickSeries(name, o, h, l, c, rsi, stoch, bb, roc, ppo, sma, cmo) =>
    switch name
        "Open" => o
        "High" => h
        "Low" => l
        "RSI" => rsi
        "StochRSI" => stoch
        "BB %B" => bb
        "ROC" => roc
        "PPO" => ppo
        "SMA Dist %" => sma
        "CMO" => cmo
        => c

// Compares two series. Cross detections always run so their history stays aligned.
// a/b: operands, op: comparison label from inputs. Return: true when the comparison holds.
cmpOp(a, op, b) =>
    bool gt = a > b
    bool lt = a < b
    bool ge = a >= b
    bool le = a <= b
    bool eq = a == b
    bool ne = a != b
    bool xUp = ta.crossover(a, b)
    bool xDn = ta.crossunder(a, b)
    switch op
        ">" => gt
        "<" => lt
        ">=" => ge
        "<=" => le
        "==" => eq
        "!=" => ne
        "Cross up" => xUp
        => xDn

// One scan rule for a single pack leg. Inactive rules return false.
// Return: true if the rule is on and the comparison holds.
ruleTrue(active, left, op, useNum, right, num, o, h, l, c, rsi, stoch, bb, roc, ppo, sma, cmo) =>
    float lhs = pickSeries(left, o, h, l, c, rsi, stoch, bb, roc, ppo, sma, cmo)
    float rhsSeries = pickSeries(right, o, h, l, c, rsi, stoch, bb, roc, ppo, sma, cmo)
    float rhs = useNum ? num : rhsSeries
    bool hit = cmpOp(lhs, op, rhs)
    hit and active

// Combines up to eight rule hits for Buy or Sell. Inactive rules on this side are skipped.
// joinAnd: AND vs OR. nOn: how many rules belong to this side.
// Return: true if this side fires.
sideFire(joinAnd, nOn, h1, on1, h2, on2, h3, on3, h4, on4, h5, on5, h6, on6, h7, on7, h8, on8) =>
    bool fired = false
    if nOn > 0
        if joinAnd
            fired := (not on1 or h1) and (not on2 or h2) and (not on3 or h3) and (not on4 or h4) and (not on5 or h5) and (not on6 or h6) and (not on7 or h7) and (not on8 or h8)
        else
            fired := (on1 and h1) or (on2 and h2) or (on3 and h3) or (on4 and h4) or (on5 and h5) or (on6 and h6) or (on7 and h7) or (on8 and h8)
    fired

// Encodes one leg: 0 none, 1 buy, 2 sell, 3 both.
// Return: 0..3
sigCode(isBuy, isSell) =>
    (isBuy ? 1.0 : 0.0) + (isSell ? 2.0 : 0.0)

// Packs three signal codes into one float (codes are 0..3).
// Return: e + m*10 + c*100
pack3sig(eVal, mVal, cVal) =>
    eVal + mVal * 10.0 + cVal * 100.0

// Splits pack3sig. packed: PackBar.sig. Return: [expensive, mid, cheap] codes.
split3sig(packed) =>
    float expensive = 0.0
    float mid = 0.0
    float cheap = 0.0
    if not na(packed)
        float n = packed
        cheap := math.floor(n / 100.0 + 1.0e-6)
        n -= cheap * 100.0
        mid := math.floor(n / 10.0 + 1.0e-6)
        expensive := math.round(n - mid * 10.0)
    [expensive, mid, cheap]

// Buy/sell for one unpacked leg from the eight rules.
// Return: 0..3 signal code.
legSignal(o, h, l, c, rsi, stoch, bb, roc, ppo, sma, cmo) =>
    bool t1 = ruleTrue(r1On, r1Left, r1Op, r1UseVal, r1Right, r1Val, o, h, l, c, rsi, stoch, bb, roc, ppo, sma, cmo)
    bool t2 = ruleTrue(r2On, r2Left, r2Op, r2UseVal, r2Right, r2Val, o, h, l, c, rsi, stoch, bb, roc, ppo, sma, cmo)
    bool t3 = ruleTrue(r3On, r3Left, r3Op, r3UseVal, r3Right, r3Val, o, h, l, c, rsi, stoch, bb, roc, ppo, sma, cmo)
    bool t4 = ruleTrue(r4On, r4Left, r4Op, r4UseVal, r4Right, r4Val, o, h, l, c, rsi, stoch, bb, roc, ppo, sma, cmo)
    bool t5 = ruleTrue(r5On, r5Left, r5Op, r5UseVal, r5Right, r5Val, o, h, l, c, rsi, stoch, bb, roc, ppo, sma, cmo)
    bool t6 = ruleTrue(r6On, r6Left, r6Op, r6UseVal, r6Right, r6Val, o, h, l, c, rsi, stoch, bb, roc, ppo, sma, cmo)
    bool t7 = ruleTrue(r7On, r7Left, r7Op, r7UseVal, r7Right, r7Val, o, h, l, c, rsi, stoch, bb, roc, ppo, sma, cmo)
    bool t8 = ruleTrue(r8On, r8Left, r8Op, r8UseVal, r8Right, r8Val, o, h, l, c, rsi, stoch, bb, roc, ppo, sma, cmo)
    bool b1 = r1On and r1Side == "Buy"
    bool b2 = r2On and r2Side == "Buy"
    bool b3 = r3On and r3Side == "Buy"
    bool b4 = r4On and r4Side == "Buy"
    bool b5 = r5On and r5Side == "Buy"
    bool b6 = r6On and r6Side == "Buy"
    bool b7 = r7On and r7Side == "Buy"
    bool b8 = r8On and r8Side == "Buy"
    bool s1 = r1On and r1Side == "Sell"
    bool s2 = r2On and r2Side == "Sell"
    bool s3 = r3On and r3Side == "Sell"
    bool s4 = r4On and r4Side == "Sell"
    bool s5 = r5On and r5Side == "Sell"
    bool s6 = r6On and r6Side == "Sell"
    bool s7 = r7On and r7Side == "Sell"
    bool s8 = r8On and r8Side == "Sell"
    int nBuy = (b1 ? 1 : 0) + (b2 ? 1 : 0) + (b3 ? 1 : 0) + (b4 ? 1 : 0) + (b5 ? 1 : 0) + (b6 ? 1 : 0) + (b7 ? 1 : 0) + (b8 ? 1 : 0)
    int nSell = (s1 ? 1 : 0) + (s2 ? 1 : 0) + (s3 ? 1 : 0) + (s4 ? 1 : 0) + (s5 ? 1 : 0) + (s6 ? 1 : 0) + (s7 ? 1 : 0) + (s8 ? 1 : 0)
    bool isBuy = sideFire(buyJoin == "AND", nBuy, t1, b1, t2, b2, t3, b3, t4, b4, t5, b5, t6, b6, t7, b7, t8, b8)
    bool isSell = sideFire(sellJoin == "AND", nSell, t1, s1, t2, s2, t3, s3, t4, s4, t5, s5, t6, s6, t7, s7, t8, s8)
    sigCode(isBuy, isSell)

// Packed open/close, seven oscillators, and buy/sell codes at the selected timeframe.
// High/low are used only inside rules (spread H/L is approximate). Return: PackBar.
packCalc() =>
    [oE, oM, oC] = split3(open)
    [hE, hM, hC] = split3(high)
    [lE, lM, lC] = split3(low)
    [cE, cM, cC] = split3(close)
    float rE = ta.rsi(cE, rsiLen)
    float rM = ta.rsi(cM, rsiLen)
    float rC = ta.rsi(cC, rsiLen)
    float kE = stochFromRsi(rE)
    float kM = stochFromRsi(rM)
    float kC = stochFromRsi(rC)
    float bbE = bbPctLeg(cE)
    float bbM = bbPctLeg(cM)
    float bbC = bbPctLeg(cC)
    float rocE = ta.roc(cE, rocLen)
    float rocM = ta.roc(cM, rocLen)
    float rocC = ta.roc(cC, rocLen)
    float ppoE = ppoLeg(cE)
    float ppoM = ppoLeg(cM)
    float ppoC = ppoLeg(cC)
    float smaE = smaDistLeg(cE)
    float smaM = smaDistLeg(cM)
    float smaC = smaDistLeg(cC)
    float cmoE = ta.cmo(cE, cmoLen)
    float cmoM = ta.cmo(cM, cmoLen)
    float cmoC = ta.cmo(cC, cmoLen)
    float sigE = legSignal(oE, hE, lE, cE, rE, kE, bbE, rocE, ppoE, smaE, cmoE)
    float sigM = legSignal(oM, hM, lM, cM, rM, kM, bbM, rocM, ppoM, smaM, cmoM)
    float sigC = legSignal(oC, hC, lC, cC, rC, kC, bbC, rocC, ppoC, smaC, cmoC)
    float prevE = nz(sigE[1], 0.0)
    float prevM = nz(sigM[1], 0.0)
    float prevC = nz(sigC[1], 0.0)
    PackBar.new(
         open,
         close,
         pack3osc(rE, rM, rC),
         pack3osc(kE, kM, kC),
         pack3osc(bbE, bbM, bbC),
         pack3osc(rocE, rocM, rocC),
         pack3osc(ppoE, ppoM, ppoC),
         pack3osc(smaE, smaM, smaC),
         pack3osc(cmoE, cmoM, cmoC),
         pack3sig(sigE, sigM, sigC) + pack3sig(prevE, prevM, prevC) * 1000.0)

// Fetches pack data in one request (UDT; does not hit the tuple cap).
// packedTicker: compose3 output. Invalid legs return an na PackBar; the script keeps running.
// Return: PackBar.
getPack(packedTicker) =>
    PackBar incoming = request.security(packedTicker, tfInput, packCalc(), ignore_invalid_symbol=true)
    na(incoming) ? PackBar.new(na, na, na, na, na, na, na, na, na, na) : incoming

// Maps the position input label to a TradingView table position.
// choice: "Bottom center" etc. Return: position.* constant.
tablePos(choice) =>
    switch choice
        "Bottom center" => position.bottom_center
        "Top center" => position.top_center
        "Middle" => position.middle_center
        "Bottom right" => position.bottom_right
        "Bottom left" => position.bottom_left
        "Top right" => position.top_right
        "Top left" => position.top_left
        "Middle right" => position.middle_right
        => position.middle_left

// Formats a number for the table. Invalid or na prints a dash.
// value: unpacked/RSI value, bad: pack is na, fmt: str.tostring format.
// Return: formatted text or "—".
fmtNum(value, bad, fmt) =>
    bad or na(value) ? "—" : str.tostring(value, fmt)

// Numeric sort keys. na values are pushed to the end for both directions.
// src: closes or rsis, descending: true if larger values should rank first.
// Return: float key array for array.sort_indices.
numSortKeys(src, descending) =>
    array<float> keys = array.copy(src)
    for i = 0 to SYM_COUNT - 1
        if na(keys.get(i))
            keys.set(i, descending ? -1.0e20 : 1.0e20)
    keys

// Rank keys so Buy/Sell rows float to the top. buyFirst: BUY before SELL (BOTH in between).
// Return: float key array for array.sort_indices.
sigSortKeys(buyFirst) =>
    array<float> keys = array.new<float>(SYM_COUNT, 0.0)
    for i = 0 to SYM_COUNT - 1
        float s = nz(signals.get(i), 0.0)
        float k = 0.0
        if buyFirst
            if s == 1.0
                k := 3.0
            else if s == 3.0
                k := 2.0
            else if s == 2.0
                k := 1.0
        else
            if s == 2.0
                k := 3.0
            else if s == 3.0
                k := 2.0
            else if s == 1.0
                k := 1.0
        keys.set(i, k)
    keys

// Whether a 0..3 code includes a buy (1 or 3).
hasBuy(sig) =>
    sig == 1.0 or sig == 3.0

// Whether a 0..3 code includes a sell (2 or 3).
hasSell(sig) =>
    sig == 2.0 or sig == 3.0

// True when buy is on this bar and was not on the previous scan bar.
isFreshBuy(sig, prev) =>
    hasBuy(sig) and not hasBuy(prev)

// True when sell is on this bar and was not on the previous scan bar.
isFreshSell(sig, prev) =>
    hasSell(sig) and not hasSell(prev)

// Whether a row survives the Show rows filter.
// sig/prev: current and previous 0..3 codes. Return: true if the row should be drawn.
keepRow(sig, prev) =>
    bool keep = true
    if signalView == "Buy"
        keep := hasBuy(sig)
    else if signalView == "Sell"
        keep := hasSell(sig)
    else if signalView == "Buy or Sell"
        keep := hasBuy(sig) or hasSell(sig)
    else if signalView == "New"
        keep := isFreshBuy(sig, prev) or isFreshSell(sig, prev)
    keep

// Short label for the Signal column. Fresh entries get a star.
// sig/prev: 0..3 codes. Return: "—", "BUY", "BUY*", "SELL", "SELL*", "BOTH", "BOTH*".
sigText(sig, prev) =>
    string txt = "—"
    bool star = isFreshBuy(sig, prev) or isFreshSell(sig, prev)
    if sig == 1.0
        txt := star ? "BUY*" : "BUY"
    else if sig == 2.0
        txt := star ? "SELL*" : "SELL"
    else if sig == 3.0
        txt := star ? "BOTH*" : "BOTH"
    txt

// Text color for the Signal column (on top of sigBg).
// sig: 0..3 code. Return: white on a fill, muted on empty.
sigColor(sig) =>
    sig == 0.0 ? color.new(#64748b, 0) : color.new(#f8fafc, 0)

// Neutral zebra for Symbol / Metric cells.
// zebra: even data row. Return: dark navy.
rowBg(zebra) =>
    zebra ? color.new(#0f172a, 0) : color.new(#111827, 0)

// Close-cell tint from the candle only (not the whole row).
// openPx/closePx: unpacked prices, bad: invalid pack. Return: green / red / gray / muted red.
closeBg(openPx, closePx, bad) =>
    color result = color.new(#1e293b, 0)
    if bad
        result := color.new(#7f1d1d, 40)
    else if not na(openPx) and not na(closePx)
        if closePx > openPx
            result := color.new(#14532d, 20)
        else if closePx < openPx
            result := color.new(#7f1d1d, 20)
        else
            result := color.new(#3f3f46, 25)
    result

// Signal-cell fill. Fresh signals are more opaque.
// sig/prev: 0..3 codes, zebra: fallback when there is no signal.
// Return: green / red / orange / zebra.
sigBg(sig, prev, zebra) =>
    color result = rowBg(zebra)
    bool star = isFreshBuy(sig, prev) or isFreshSell(sig, prev)
    if sig == 1.0
        result := star ? color.new(#16a34a, 0) : color.new(#166534, 15)
    else if sig == 2.0
        result := star ? color.new(#dc2626, 0) : color.new(#991b1b, 15)
    else if sig == 3.0
        result := star ? color.new(#ea580c, 0) : color.new(#9a3412, 15)
    result

// One rule as "RSI < 30" or "Close > Open". Empty when the rule is off or the other side.
// on/side/left/op/useNum/right/num: that rule's inputs, want: "Buy" or "Sell".
// Return: fragment or "".
ruleFrag(on, want, side, left, op, useNum, right, num) =>
    string txt = ""
    if on and side == want
        string rhs = useNum ? str.tostring(num, "#.##") : right
        txt := left + " " + op + " " + rhs
    txt

// Joins up to eight fragments with AND/OR. Empty fragments are skipped.
// joinWord: "AND" or "OR". Return: combined text or "".
joinFrags(joinWord, a, b, c, d, e, f, g, h) =>
    string out = a
    if str.length(b) > 0
        out := str.length(out) == 0 ? b : out + " " + joinWord + " " + b
    if str.length(c) > 0
        out := str.length(out) == 0 ? c : out + " " + joinWord + " " + c
    if str.length(d) > 0
        out := str.length(out) == 0 ? d : out + " " + joinWord + " " + d
    if str.length(e) > 0
        out := str.length(out) == 0 ? e : out + " " + joinWord + " " + e
    if str.length(f) > 0
        out := str.length(out) == 0 ? f : out + " " + joinWord + " " + f
    if str.length(g) > 0
        out := str.length(out) == 0 ? g : out + " " + joinWord + " " + g
    if str.length(h) > 0
        out := str.length(out) == 0 ? h : out + " " + joinWord + " " + h
    out

// Single-line summary of the active scan rules for the table banner.
// Return: "BUY [AND] ... | SELL [OR] ..." or "No scan rules on".
strategyLine() =>
    string buyBody = joinFrags(buyJoin, ruleFrag(r1On, "Buy", r1Side, r1Left, r1Op, r1UseVal, r1Right, r1Val), ruleFrag(r2On, "Buy", r2Side, r2Left, r2Op, r2UseVal, r2Right, r2Val), ruleFrag(r3On, "Buy", r3Side, r3Left, r3Op, r3UseVal, r3Right, r3Val), ruleFrag(r4On, "Buy", r4Side, r4Left, r4Op, r4UseVal, r4Right, r4Val), ruleFrag(r5On, "Buy", r5Side, r5Left, r5Op, r5UseVal, r5Right, r5Val), ruleFrag(r6On, "Buy", r6Side, r6Left, r6Op, r6UseVal, r6Right, r6Val), ruleFrag(r7On, "Buy", r7Side, r7Left, r7Op, r7UseVal, r7Right, r7Val), ruleFrag(r8On, "Buy", r8Side, r8Left, r8Op, r8UseVal, r8Right, r8Val))
    string sellBody = joinFrags(sellJoin, ruleFrag(r1On, "Sell", r1Side, r1Left, r1Op, r1UseVal, r1Right, r1Val), ruleFrag(r2On, "Sell", r2Side, r2Left, r2Op, r2UseVal, r2Right, r2Val), ruleFrag(r3On, "Sell", r3Side, r3Left, r3Op, r3UseVal, r3Right, r3Val), ruleFrag(r4On, "Sell", r4Side, r4Left, r4Op, r4UseVal, r4Right, r4Val), ruleFrag(r5On, "Sell", r5Side, r5Left, r5Op, r5UseVal, r5Right, r5Val), ruleFrag(r6On, "Sell", r6Side, r6Left, r6Op, r6UseVal, r6Right, r6Val), ruleFrag(r7On, "Sell", r7Side, r7Left, r7Op, r7UseVal, r7Right, r7Val), ruleFrag(r8On, "Sell", r8Side, r8Left, r8Op, r8UseVal, r8Right, r8Val))
    string line = ""
    if str.length(buyBody) > 0
        line := "BUY [" + buyJoin + "] " + buyBody
    if str.length(sellBody) > 0
        string sellPart = "SELL [" + sellJoin + "] " + sellBody
        line := str.length(line) == 0 ? sellPart : line + "  |  " + sellPart
    string tfTxt = str.length(tfInput) == 0 ? "chart" : tfInput
    str.length(line) == 0 ? tfTxt + "  ·  No scan rules on" : tfTxt + "  ·  " + line

// Selected oscillator series for the Metric column and Metric sort.
// Return: one of the 120-length oscillator arrays.
metricValues() =>
    array<float> out = rsis
    if metricInput == "StochRSI"
        out := stochs
    else if metricInput == "BB %B"
        out := bbs
    else if metricInput == "ROC"
        out := rocs
    else if metricInput == "PPO"
        out := ppos
    else if metricInput == "SMA Dist %"
        out := smas
    else if metricInput == "CMO"
        out := cmos
    out

// Text color for the Metric cell (OB/OS or sign).
// val: oscillator, bad: invalid pack. Return: highlight or white.
metricColor(val, bad) =>
    color txt = color.white
    if not bad and not na(val)
        if metricInput == "RSI" or metricInput == "StochRSI"
            if val >= rsiOb
                txt := color.new(#fef08a, 0)
            else if val <= rsiOs
                txt := color.new(#bfdbfe, 0)
        else if metricInput == "BB %B"
            if val >= 80.0
                txt := color.new(#fef08a, 0)
            else if val <= 20.0
                txt := color.new(#bfdbfe, 0)
        else if metricInput == "CMO"
            if val >= 50.0
                txt := color.new(#fef08a, 0)
            else if val <= -50.0
                txt := color.new(#bfdbfe, 0)
        else
            if val > 0.0
                txt := color.new(#86efac, 0)
            else if val < 0.0
                txt := color.new(#fca5a5, 0)
    txt

// Table row order from the Sort input.
// Return: index array of length SYM_COUNT.
sortIndices() =>
    array<int> idx = array.new<int>(SYM_COUNT, 0)
    if sortMode == "Close descending"
        idx := array.sort_indices(numSortKeys(closes, true), order.descending)
    else if sortMode == "Close ascending"
        idx := array.sort_indices(numSortKeys(closes, false), order.ascending)
    else if sortMode == "Metric descending"
        idx := array.sort_indices(numSortKeys(metricValues(), true), order.descending)
    else if sortMode == "Metric ascending"
        idx := array.sort_indices(numSortKeys(metricValues(), false), order.ascending)
    else if sortMode == "RSI descending"
        idx := array.sort_indices(numSortKeys(rsis, true), order.descending)
    else if sortMode == "RSI ascending"
        idx := array.sort_indices(numSortKeys(rsis, false), order.ascending)
    else if sortMode == "Buy first"
        idx := array.sort_indices(sigSortKeys(true), order.descending)
    else if sortMode == "Sell first"
        idx := array.sort_indices(sigSortKeys(false), order.descending)
    else if sortMode == "Symbol A-Z"
        idx := array.sort_indices(tickers, order.ascending)
    else
        idx := array.sort_indices(tickers, order.descending)
    idx

// Short code shown in the table.
// fullTicker: "THYAO" or "BIST:THYAO". Return: "THYAO".
shortCode(fullTicker) =>
    string t = spreadTicker(fullTicker)
    array<string> parts = str.split(t, ":")
    parts.get(parts.size() - 1)

// Writes three consecutive array slots from one pack leg triple.
// arr: target series, i0: first index, a/b/c: expensive/mid/cheap values. Return: 0.
setTriple(arr, i0, a, b, c) =>
    arr.set(i0, a)
    arr.set(i0 + 1, b)
    arr.set(i0 + 2, c)
    0

// Unpacks packed open/close and seven oscillators into three symbols.
// i0: first index, eSym/mSym/cSym: input symbols, pk: getPack output.
// Return: 0 (side effect).
fillPack(i0, eSym, mSym, cSym, pk) =>
    [oE, oM, oC] = split3(pk.o)
    [cE, cM, cC] = split3(pk.c)
    [rE, rM, rC] = split3osc(pk.rsi)
    [sE, sM, sC] = split3osc(pk.stoch)
    [bE, bM, bC] = split3osc(pk.bb)
    [kE, kM, kC] = split3osc(pk.roc)
    [pE, pM, pC] = split3osc(pk.ppo)
    [mE, mM, mC] = split3osc(pk.sma)
    [nE, nM, nC] = split3osc(pk.cmo)
    tickers.set(i0, shortCode(eSym))
    tickers.set(i0 + 1, shortCode(mSym))
    tickers.set(i0 + 2, shortCode(cSym))
    setTriple(opens, i0, oE, oM, oC)
    setTriple(closes, i0, cE, cM, cC)
    setTriple(rsis, i0, rE, rM, rC)
    setTriple(stochs, i0, sE, sM, sC)
    setTriple(bbs, i0, bE, bM, bC)
    setTriple(rocs, i0, kE, kM, kC)
    setTriple(ppos, i0, pE, pM, pC)
    setTriple(smas, i0, mE, mM, mC)
    setTriple(cmos, i0, nE, nM, nC)
    float sigPack = nz(pk.sig, 0.0)
    float prevPack = math.floor(sigPack / 1000.0 + 1.0e-6)
    float curPack = sigPack - prevPack * 1000.0
    [gE, gM, gC] = split3sig(curPack)
    [hE, hM, hC] = split3sig(prevPack)
    setTriple(signals, i0, gE, gM, gC)
    setTriple(signalPrev, i0, hE, hM, hC)
    0

// =============================================================================
// 40 unique request.security calls (packed OHLC + close-only oscillators)
// =============================================================================
string p1 = compose3(e1, m1, c1s)
string p2 = compose3(e2, m2, c2s)
string p3 = compose3(e3, m3, c3s)
string p4 = compose3(e4, m4, c4s)
string p5 = compose3(e5, m5, c5s)
string p6 = compose3(e6, m6, c6s)
string p7 = compose3(e7, m7, c7s)
string p8 = compose3(e8, m8, c8s)
string p9 = compose3(e9, m9, c9s)
string p10 = compose3(e10, m10, c10s)
string p11 = compose3(e11, m11, c11s)
string p12 = compose3(e12, m12, c12s)
string p13 = compose3(e13, m13, c13s)
string p14 = compose3(e14, m14, c14s)
string p15 = compose3(e15, m15, c15s)
string p16 = compose3(e16, m16, c16s)
string p17 = compose3(e17, m17, c17s)
string p18 = compose3(e18, m18, c18s)
string p19 = compose3(e19, m19, c19s)
string p20 = compose3(e20, m20, c20s)
string p21 = compose3(e21, m21, c21s)
string p22 = compose3(e22, m22, c22s)
string p23 = compose3(e23, m23, c23s)
string p24 = compose3(e24, m24, c24s)
string p25 = compose3(e25, m25, c25s)
string p26 = compose3(e26, m26, c26s)
string p27 = compose3(e27, m27, c27s)
string p28 = compose3(e28, m28, c28s)
string p29 = compose3(e29, m29, c29s)
string p30 = compose3(e30, m30, c30s)
string p31 = compose3(e31, m31, c31s)
string p32 = compose3(e32, m32, c32s)
string p33 = compose3(e33, m33, c33s)
string p34 = compose3(e34, m34, c34s)
string p35 = compose3(e35, m35, c35s)
string p36 = compose3(e36, m36, c36s)
string p37 = compose3(e37, m37, c37s)
string p38 = compose3(e38, m38, c38s)
string p39 = compose3(e39, m39, c39s)
string p40 = compose3(e40, m40, c40s)

PackBar pk1 = getPack(p1)
PackBar pk2 = getPack(p2)
PackBar pk3 = getPack(p3)
PackBar pk4 = getPack(p4)
PackBar pk5 = getPack(p5)
PackBar pk6 = getPack(p6)
PackBar pk7 = getPack(p7)
PackBar pk8 = getPack(p8)
PackBar pk9 = getPack(p9)
PackBar pk10 = getPack(p10)
PackBar pk11 = getPack(p11)
PackBar pk12 = getPack(p12)
PackBar pk13 = getPack(p13)
PackBar pk14 = getPack(p14)
PackBar pk15 = getPack(p15)
PackBar pk16 = getPack(p16)
PackBar pk17 = getPack(p17)
PackBar pk18 = getPack(p18)
PackBar pk19 = getPack(p19)
PackBar pk20 = getPack(p20)
PackBar pk21 = getPack(p21)
PackBar pk22 = getPack(p22)
PackBar pk23 = getPack(p23)
PackBar pk24 = getPack(p24)
PackBar pk25 = getPack(p25)
PackBar pk26 = getPack(p26)
PackBar pk27 = getPack(p27)
PackBar pk28 = getPack(p28)
PackBar pk29 = getPack(p29)
PackBar pk30 = getPack(p30)
PackBar pk31 = getPack(p31)
PackBar pk32 = getPack(p32)
PackBar pk33 = getPack(p33)
PackBar pk34 = getPack(p34)
PackBar pk35 = getPack(p35)
PackBar pk36 = getPack(p36)
PackBar pk37 = getPack(p37)
PackBar pk38 = getPack(p38)
PackBar pk39 = getPack(p39)
PackBar pk40 = getPack(p40)

fillPack(0, e1, m1, c1s, pk1)
fillPack(3, e2, m2, c2s, pk2)
fillPack(6, e3, m3, c3s, pk3)
fillPack(9, e4, m4, c4s, pk4)
fillPack(12, e5, m5, c5s, pk5)
fillPack(15, e6, m6, c6s, pk6)
fillPack(18, e7, m7, c7s, pk7)
fillPack(21, e8, m8, c8s, pk8)
fillPack(24, e9, m9, c9s, pk9)
fillPack(27, e10, m10, c10s, pk10)
fillPack(30, e11, m11, c11s, pk11)
fillPack(33, e12, m12, c12s, pk12)
fillPack(36, e13, m13, c13s, pk13)
fillPack(39, e14, m14, c14s, pk14)
fillPack(42, e15, m15, c15s, pk15)
fillPack(45, e16, m16, c16s, pk16)
fillPack(48, e17, m17, c17s, pk17)
fillPack(51, e18, m18, c18s, pk18)
fillPack(54, e19, m19, c19s, pk19)
fillPack(57, e20, m20, c20s, pk20)
fillPack(60, e21, m21, c21s, pk21)
fillPack(63, e22, m22, c22s, pk22)
fillPack(66, e23, m23, c23s, pk23)
fillPack(69, e24, m24, c24s, pk24)
fillPack(72, e25, m25, c25s, pk25)
fillPack(75, e26, m26, c26s, pk26)
fillPack(78, e27, m27, c27s, pk27)
fillPack(81, e28, m28, c28s, pk28)
fillPack(84, e29, m29, c29s, pk29)
fillPack(87, e30, m30, c30s, pk30)
fillPack(90, e31, m31, c31s, pk31)
fillPack(93, e32, m32, c32s, pk32)
fillPack(96, e33, m33, c33s, pk33)
fillPack(99, e34, m34, c34s, pk34)
fillPack(102, e35, m35, c35s, pk35)
fillPack(105, e36, m36, c36s, pk36)
fillPack(108, e37, m37, c37s, pk37)
fillPack(111, e38, m38, c38s, pk38)
fillPack(114, e39, m39, c39s, pk39)
fillPack(117, e40, m40, c40s, pk40)

// Tally current vs previous-bar signals for the banner, New filter, and alerts.
int nBuyCnt = 0
int nSellCnt = 0
int nBothCnt = 0
int nNewBuyCnt = 0
int nNewSellCnt = 0
string newBuyNames = ""
string newSellNames = ""
for i = 0 to SYM_COUNT - 1
    float s = nz(signals.get(i), 0.0)
    float p = nz(signalPrev.get(i), 0.0)
    if s == 1.0
        nBuyCnt := nBuyCnt + 1
    else if s == 2.0
        nSellCnt := nSellCnt + 1
    else if s == 3.0
        nBothCnt := nBothCnt + 1
    if isFreshBuy(s, p)
        nNewBuyCnt := nNewBuyCnt + 1
        if nNewBuyCnt <= 15
            newBuyNames := str.length(newBuyNames) == 0 ? tickers.get(i) : newBuyNames + "," + tickers.get(i)
    if isFreshSell(s, p)
        nNewSellCnt := nNewSellCnt + 1
        if nNewSellCnt <= 15
            newSellNames := str.length(newSellNames) == 0 ? tickers.get(i) : newSellNames + "," + tickers.get(i)

string chartCode = shortCode(syminfo.tickerid)
bool tfPulse = str.length(tfInput) == 0 ? barstate.isnew : timeframe.change(tfInput)
bool fireBuy = alertOn and tfPulse and nNewBuyCnt >= alertMin
bool fireSell = alertOn and tfPulse and nNewSellCnt >= alertMin
if fireBuy or fireSell
    alert("BIST120 new BUY " + str.tostring(nNewBuyCnt) + " [" + newBuyNames + "]  SELL " + str.tostring(nNewSellCnt) + " [" + newSellNames + "]", alert.freq_once_per_bar)
alertcondition(fireBuy, "BIST120 new BUY", "New BUY in BIST120 scanner")
alertcondition(fireSell, "BIST120 new SELL", "New SELL in BIST120 scanner")

// =============================================================================
// Table: Horizontal 6x20 or Vertical 3x40 (Symbol, Close, metric, signal)
// =============================================================================

var table tab = table.new(
     tablePos(posInput)
     , TAB_COLS
     , TAB_ROWS
     , border_width=1
     , border_color=color.new(#334155, 20)
     , frame_color=color.new(#1e293b, 0)
     , frame_width=1)

if barstate.islast
    table.clear(tab, 0, 0, TAB_COLS - 1, TAB_ROWS - 1)
    table.set_position(tab, tablePos(posInput))

    bool horiz = layoutInput == "Horizontal"
    int blockCount = horiz ? HORIZ_BLOCKS : VERT_BLOCKS
    int blockRows = horiz ? HORIZ_ROWS : VERT_ROWS

    array<int> orderIdx = sortIndices()
    array<float> oscShown = metricValues()

    color headerBg = color.new(#0f172a, 0)
    color headerFg = color.new(#94a3b8, 0)
    color bannerBg = color.new(#020617, 0)
    color ruleFg = color.new(#94a3b8, 0)
    color buyChip = color.new(#166534, 0)
    color sellChip = color.new(#991b1b, 0)
    color bothChip = color.new(#9a3412, 0)
    color chipFg = color.new(#f8fafc, 0)
    int ruleLastCol = TAB_COLS - 4
    for c = 0 to ruleLastCol
        table.cell(tab, c, BANNER_ROW, "", bgcolor=bannerBg)
    table.cell(tab, 0, BANNER_ROW, strategyLine(), text_color=ruleFg, bgcolor=bannerBg, text_size=tblSize, text_halign=text.align_left)
    table.merge_cells(tab, 0, BANNER_ROW, ruleLastCol, BANNER_ROW)
    table.cell(tab, TAB_COLS - 3, BANNER_ROW, "BUY " + str.tostring(nBuyCnt) + " (" + str.tostring(nNewBuyCnt) + "*)", text_color=chipFg, bgcolor=buyChip, text_size=tblSize, text_halign=text.align_center)
    table.cell(tab, TAB_COLS - 2, BANNER_ROW, "SELL " + str.tostring(nSellCnt) + " (" + str.tostring(nNewSellCnt) + "*)", text_color=chipFg, bgcolor=sellChip, text_size=tblSize, text_halign=text.align_center)
    table.cell(tab, TAB_COLS - 1, BANNER_ROW, "BOTH " + str.tostring(nBothCnt), text_color=chipFg, bgcolor=bothChip, text_size=tblSize, text_halign=text.align_center)

    for b = 0 to blockCount - 1
        int col0 = b * CELL_COLS
        table.cell(tab, col0, HEADER_ROW, "Symbol", text_color=headerFg, bgcolor=headerBg, text_size=tblSize, text_halign=text.align_center)
        table.cell(tab, col0 + 1, HEADER_ROW, "Close", text_color=headerFg, bgcolor=headerBg, text_size=tblSize, text_halign=text.align_center)
        table.cell(tab, col0 + 2, HEADER_ROW, metricInput, text_color=headerFg, bgcolor=headerBg, text_size=tblSize, text_halign=text.align_center)
        table.cell(tab, col0 + 3, HEADER_ROW, "Signal", text_color=headerFg, bgcolor=headerBg, text_size=tblSize, text_halign=text.align_center)

    array<int> shown = array.new<int>(0)
    for i = 0 to SYM_COUNT - 1
        int idx = orderIdx.get(i)
        if keepRow(nz(signals.get(idx), 0.0), nz(signalPrev.get(idx), 0.0))
            array.push(shown, idx)

    int nShow = shown.size()
    if nShow > 0
        for i = 0 to nShow - 1
            int idx = shown.get(i)
            int block = int(i / blockRows)
            int row = i % blockRows + DATA_ROW0
            int col0 = block * CELL_COLS
            bool zebra = row % 2 == 0
            string code = tickers.get(idx)
            float openPx = opens.get(idx)
            float closePx = closes.get(idx)
            float oscVal = oscShown.get(idx)
            float sig = nz(signals.get(idx), 0.0)
            float prev = nz(signalPrev.get(idx), 0.0)
            bool bad = na(closePx)
            bool isChart = str.upper(code) == str.upper(chartCode)
            color baseBg = rowBg(zebra)
            color nameBg = isChart ? color.new(#854d0e, 10) : baseBg
            color nameFg = isChart ? color.new(#fde68a, 0) : color.new(#e2e8f0, 0)
            color pxBg = closeBg(openPx, closePx, bad)
            color pxFg = bad ? color.new(#fca5a5, 0) : color.new(#f8fafc, 0)
            color oscColor = metricColor(oscVal, bad)
            string nameTxt = isChart ? "► " + code : code
            string closeTxt = bad ? "Invalid" : fmtNum(closePx, false, "#.00")
            string oscTxt = bad ? "—" : fmtNum(oscVal, false, "#.00")
            table.cell(tab, col0, row, nameTxt, text_color=nameFg, bgcolor=nameBg, text_size=tblSize, text_halign=text.align_left)
            table.cell(tab, col0 + 1, row, closeTxt, text_color=pxFg, bgcolor=pxBg, text_size=tblSize, text_halign=text.align_right)
            table.cell(tab, col0 + 2, row, oscTxt, text_color=oscColor, bgcolor=baseBg, text_size=tblSize, text_halign=text.align_right)
            table.cell(tab, col0 + 3, row, bad ? "—" : sigText(sig, prev), text_color=sigColor(sig), bgcolor=sigBg(sig, prev, zebra), text_size=tblSize, text_halign=text.align_center)
````
