# EMA Scanner (30min Cooldown) 

- url: https://www.tradingview.com/script/l5szFNyY-EMA-Scanner-30min-Cooldown/
- type: indicator
- pine_id: PUB;9226321d695c4519b42921903034106b
- version: 1.0

## Description

creates alarms for ema crossovers. when the price gets in to desired area creates an alert for tradingview

## Source Code

````pine
//@version=6
indicator("TOTORO 1M EMA Scanner (30min Cooldown) [Enhanced]", overlay=true)

// ═════════════════════════════════════════════════════════════════════════════
// STRICT 1M ENFORCEMENT
// ═════════════════════════════════════════════════════════════════════════════
bool is1M = (timeframe.isintraday and timeframe.multiplier == 1 and timeframe.period == "1")

if not is1M
    if barstate.islast
        label.new(bar_index, high, "⚠️ SWITCH TO 1-MINUTE CHART\nThis scanner requires 1M timeframe", 
             color=color.red, textcolor=color.white, size=size.large, style=label.style_label_lower_right)
    runtime.error("Switch to 1-minute chart. This scanner is built exclusively for 1M.")

// ═════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═════════════════════════════════════════════════════════════════════════════
ema1Length  = input.int(200, title="EMA 1 Length", group="Scanner Settings")
ema2Length  = input.int(800, title="EMA 2 Length", group="Scanner Settings")
cooldownMin = input.int(30, title="Cooldown (minutes)", minval=1, group="Scanner Settings")

alertPrefix = input.string("🚨 TOTORO", title="Alert Prefix", group="Alert Settings")
includeUrl  = input.bool(true, title="Include TradingView Chart URL", 
             tooltip="Embeds a direct link to the symbol's 1M chart inside the alert message. TradingView alert banners always show the HOST chart symbol (e.g., NZDUSD) — this URL is the workaround.", 
             group="Alert Settings")

symbolListInput = input.text_area(
     "FX_IDC:EURUSD,FX_IDC:GBPUSD,FX_IDC:USDJPY,FX_IDC:USDCHF,FX_IDC:AUDUSD,FX_IDC:USDCAD," +
     "FX_IDC:NZDUSD,FX_IDC:EURGBP,FX_IDC:EURJPY,FX_IDC:GBPJPY,FX_IDC:AUDJPY,FX_IDC:EURAUD," +
     "FX_IDC:EURCHF,FX_IDC:AUDCAD,FX_IDC:NZDJPY,FX_IDC:GBPCAD,FX_IDC:GBPAUD,FX_IDC:CADJPY," +
     "FX_IDC:CHFJPY,FX_IDC:EURCAD,SP:SPX,NASDAQ:NDX,DJ:DJI,TVC:DXY,FX:UK100,TVC:NI225," +
     "TVC:DAX,TVC:CAC40,TVC:VIX,OANDA:XAUUSD,OANDA:XAGUSD,OANDA:XPTUSD,OANDA:XCUUSD," +
     "TVC:USOIL,TVC:UKOIL,TVC:NGAS,OANDA:XPDUSD,TVC:SUGARUSD,TVC:CORNUSD,TVC:WHEATUSD",
     title="Symbols (comma-separated)", group="Scanner Settings")

// ═════════════════════════════════════════════════════════════════════════════
// PARSE SYMBOLS
// ═════════════════════════════════════════════════════════════════════════════
var array<string> symbols = array.new<string>(0)

if barstate.isfirst
    raw = str.split(symbolListInput, ",")
    for i = 0 to array.size(raw) - 1
        s = str.trim(array.get(raw, i))
        if str.length(s) > 0
            array.push(symbols, s)

int maxSymbols = math.min(array.size(symbols), 40)

// ═════════════════════════════════════════════════════════════════════════════
// DASHBOARD SETUP
// ═════════════════════════════════════════════════════════════════════════════
var table dash = table.new(
     position.top_right, 5, maxSymbols + 1,
     bgcolor=color.new(color.black, 80),
     border_width=1,
     border_color=color.gray,
     frame_color=color.gray,
     frame_width=1)

if barstate.isfirst
    table.cell(dash, 0, 0, "Symbol",     text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 0, "Price",      text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 0, "EMA" + str.tostring(ema1Length), text_color=color.white, text_size=size.small)
    table.cell(dash, 3, 0, "EMA" + str.tostring(ema2Length), text_color=color.white, text_size=size.small)
    table.cell(dash, 4, 0, "Status",     text_color=color.white, text_size=size.small)

// ═════════════════════════════════════════════════════════════════════════════
// COOLDOWN TRACKING
// ═════════════════════════════════════════════════════════════════════════════
var array<int> lastAlertTime = array.new<int>(0)
int cooldownMs = cooldownMin * 60000

if barstate.isfirst
    for k = 0 to maxSymbols - 1
        array.push(lastAlertTime, 0)

// ═════════════════════════════════════════════════════════════════════════════
// MAIN SCANNER LOOP
// ═════════════════════════════════════════════════════════════════════════════
if maxSymbols > 0
    for i = 0 to maxSymbols - 1
        string sym = array.get(symbols, i)
        
        // Extract raw data first, then compute EMAs locally (removes CW10003 warning)
        [symHigh, symLow, symClose] = request.security(
             sym, "1",
             [high, low, close],
             ignore_invalid_symbol=true)
        
        float symEma1 = ta.ema(symClose, ema1Length)
        float symEma2 = ta.ema(symClose, ema2Length)
        
        bool validData = not na(symClose) and not na(symEma1) and not na(symEma2)
        bool touchingEma1 = validData and (symHigh >= symEma1) and (symLow <= symEma1)
        bool touchingEma2 = validData and (symHigh >= symEma2) and (symLow <= symEma2)
        bool anyTouch = touchingEma1 or touchingEma2
        
        // ═════════════════════════════════════════════════════════════════════
        // ALERT LOGIC
        // ═════════════════════════════════════════════════════════════════════
        if barstate.isconfirmed and anyTouch
            int lastTime = array.get(lastAlertTime, i)
            
            if (time - lastTime) >= cooldownMs
                string whichEma = touchingEma1 and touchingEma2
                     ? "BOTH EMAs"
                     : touchingEma1
                         ? "EMA" + str.tostring(ema1Length)
                         : "EMA" + str.tostring(ema2Length)
                
                string msg = alertPrefix + ": " + sym + " touched " + whichEma + " (1M)\n" +
                     "💰 Price: " + str.tostring(symClose, "#.#####") + "\n" +
                     "📐 EMA" + str.tostring(ema1Length) + ": " + str.tostring(symEma1, "#.#####") + " | " +
                     "EMA" + str.tostring(ema2Length) + ": " + str.tostring(symEma2, "#.#####")
                
                if includeUrl
                    string symEncoded = str.replace(sym, ":", "%3A")
                    string tvUrl = "https://www.tradingview.com/chart/?symbol=" + symEncoded + "&interval=1"
                    msg := msg + "\n📊 Open chart: " + tvUrl
                
                alert(msg, alert.freq_all)
                array.set(lastAlertTime, i, time)
        
        // ═════════════════════════════════════════════════════════════════════
        // DASHBOARD
        // ═════════════════════════════════════════════════════════════════════
        if barstate.islast
            string statusText = "WAITING"
            color  statusColor = color.new(color.gray, 70)
            
            if touchingEma1 and touchingEma2
                statusText := "TOUCH BOTH"
                statusColor := color.new(color.green, 20)
            else if touchingEma1
                statusText := "TOUCH " + str.tostring(ema1Length)
                statusColor := color.new(color.green, 40)
            else if touchingEma2
                statusText := "TOUCH " + str.tostring(ema2Length)
                statusColor := color.new(color.blue, 40)
            
            int msLeft = cooldownMs - (time - array.get(lastAlertTime, i))
            int minLeft = msLeft / 60000
            if anyTouch and minLeft > 0
                statusText := "🔒 " + str.tostring(minLeft) + "m left"
                statusColor := color.new(color.orange, 50)
            
            table.cell(dash, 0, i + 1, sym,                                   text_color=color.white, text_size=size.small)
            table.cell(dash, 1, i + 1, str.tostring(symClose, "#.#####"),     text_color=color.white, text_size=size.small, text_halign=text.align_right)
            table.cell(dash, 2, i + 1, str.tostring(symEma1, "#.#####"),      text_color=color.white, text_size=size.small, text_halign=text.align_right)
            table.cell(dash, 3, i + 1, str.tostring(symEma2, "#.#####"),      text_color=color.white, text_size=size.small, text_halign=text.align_right)
            table.cell(dash, 4, i + 1, statusText,                            text_color=color.white, text_size=size.small, bgcolor=statusColor)
````
