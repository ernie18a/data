# OKX Signal BOT - Strategy Scanner & Orderer

- url: https://www.tradingview.com/script/o3i7HB05/
- type: indicator
- pine_id: PUB;e78eaba64c77452d86b950eb6861c6ba
- version: 1.0

## Description

[b]Hello traders,
With the OKX Signal BOT - Strategy Scanner & Orderer, you can now design your own strategy, scan over 20 cryptocurrencies, and send orders for futures trades on the OKX exchange.[/b]

[b]How to Use:[/b]

🌐 First, log into your account on the OKX exchange and create a signal bot.

📝 While creating the signal bot, note down the webhook URL and signal token variables given to you; they'll be needed later.

🔍 Select the trading pairs that the bot will work on.

📈 Add this indicator to your chart.

⚙️ Adjust the values of the indicators you will use in your strategy.

📊 Set your entry conditions and indicator setups according to your preference.

🚀 Decide which condition will generate a LONG signal and which will generate a SHORT signal.

🔗 Then, link these conditions with either an AND or OR connector.

🛠️ This also serves as a strategy designer.

🆔 Paste the signal token value you got from OKX into the OKX Signal ID section in the indicator.

➕ Add the cryptocurrency pairs you added to the bot on OKX to this design tool as well.

💾 Save and exit.

🚨 Set an alarm and paste the webhook URL link you got from OKX.

[i]Congratulations, you can now send signals from Tradingview to the OKX exchange without needing any other platform.[/i]

[image]https://www.tradingview.com/x/4mWHM6cZ/[/image]


[b]Warnings:[/b]
⚠️ Works only for futures trades.
📈 Make your leverage settings through the exchange.
🛑 It is recommended to set take profit and stop loss through the exchange.
🚫 If too many alarms are triggered, Tradingview may stop your alarms.
💡 Ensure that the coins you add in the symbol section are from the OKX exchange.
🔍 For futures trades, make sure the symbols end with ".P".
🎉 Enjoy using it!

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © only_fibonacci

//@version=5
indicator("OKX Signal BOT - Scanner & Orderer", overlay = true)


// FUNCTIONS
operatorReturn(i1,selected,i2)=>
    switch selected
        ">" => i1 > i2
        "<" => i1 < i2
        ">=" => i1 >= i2
        "<=" => i1 <= i2
        "=" => i1 == i2
        "!=" => i1 != i2
        "CROSS ABOVE" => ta.crossover(i1, i2)
        "CROSS BELOW" => ta.crossunder(i1,i2)



maTypeToMa(maType,maPeriod,src)=>
    switch maType
        "EMA" => ta.ema(src, maPeriod)
        "SMA" => ta.sma(src, maPeriod)
        "RMA" => ta.rma(src, maPeriod)
        => ta.wma(src, maPeriod)

// Indicators
// ATR
atrLen      = input.int(defval = 14,minval = 1, title = "ATR Length", group = "ATR")
atr         = ta.atr(atrLen) // ATR

// BB
bbMiddle    = input.source(defval = close, title = "BB Middle", group = "BB")
bbLen       = input.int(defval = 5, title = "BB Length",minval = 1, group = "BB")
bbMult      = input.int(defval = 4, title = "BB Mult",minval = 1, group = "BB" )
[middle, upper, lower] = ta.bb(bbMiddle, bbLen, bbMult) // BB
bbw         = ta.bbw(middle, bbLen, bbMult) // BB Genişlik

// CCI
cciSrc      = input.source(defval = close, title = "CCI Source", group = "CCI")
cciLen      = input.int(defval = 10, title = "CCI Len", minval = 1, group = "CCI")
cci         = ta.cci(cciSrc,cciLen) // CCI

// MA1
ma1Type = input.string("EMA", "", options = ["EMA", "SMA", "RMA", "WMA"], group = "MA 1", inline = "2ma1")
ma1Period = input.int(defval = 20, title = "Period", minval = 1, group = "MA 1", inline = "2ma1")
ma1Src = input.source(defval = close, title = "Source", group = "MA 1", inline = "2ma1")
ma1 = maTypeToMa(ma1Type,ma1Period,ma1Src)

// MA2
ma2Type = input.string("EMA", "", options = ["EMA", "SMA", "RMA", "WMA"], group = "MA 2", inline = "2ma2")
ma2Period = input.int(defval = 50, title = "Period", minval = 1, group = "MA 2", inline = "2ma2")
ma2Src = input.source(defval = close, title = "Source", group = "MA 2", inline = "2ma2")
ma2 = maTypeToMa(ma2Type,ma2Period,ma1Src)


// RSI
rsiSrc = input.source(defval = close, title = "RSI Source", group = "RSI")
rsiLen = input.int(defval = 14, title = "RSI Length", minval = 1, group = "RSI")
rsi = ta.rsi(rsiSrc,rsiLen)

// ADX
lenAdx = input.int(17, minval=1, title="DI Length", group = "ADX")
lensigAdx = input.int(14, title="ADX Smoothing", minval=1, maxval=50, group = "ADX")
[diplus, diminus, adx] = ta.dmi(lenAdx, lensigAdx)

// MFI
mfiSrc = input.source(defval = close, title = "MFI Source", group = "MFI")
mfiLen = input.int(defval = 14, title = "MFI Length", minval = 1, group = "MFI")
mfi = ta.mfi(mfiSrc,mfiLen)

// MOM
momSrc = input.source(defval = close, title = "MOM Source", group = "MOM")
momLen = input.int(defval = 14, title = "MOM Length", minval = 1, group = "MOM")
mom = ta.mom(momSrc,momLen)


indicators(selected)=>
    switch selected
        "MA 1" => ma1
        "MA 2" => ma2
        "ATR" => atr
        "CCI" => cci
        "RSI" => rsi
        "BBW" => bbw
        "ADX" => adx
        "MFI" => mfi
        "MOM" => mom
        
        


    

andORLong = input.string(defval = "AND", title = "BUY/LONG CONNECT", options = ["AND","OR"], group = "SETTINGS") 
andORShort = input.string(defval = "AND", title = "SELL/SHORT CONNECT", options = ["AND","OR"], group = "SETTINGS") 
futureOrSpot =  "FUTURE"
// futureOrSpot =  input.string(defval = "SPOT", title = "FUTURE OR SPOT ?", options = ["SPOT","FUTURE"], group = "SETTINGS") 


buyList = array.new_bool()
sellList = array.new_bool()
detect(status,series,di)=>
    if status
        if di == "BUY/LONG"
            array.push(buyList,series)
        else
            array.push(sellList,series)



s1Group     = "❗️❗️❗️❗️ CONDITION #1 ❗️❗️❗️❗️"
s1Inline    = "s1i"
s1Status    = input.bool(defval = false, title = "CONDITION Active", group = s1Group )
s1Direction = input.string(defval = "BUY/LONG", title = "Direction",options = ["BUY/LONG","SELL/SHORT"], group = s1Group)
s1Left      = input.string(defval = "CCI", title = "1️⃣", options = ["ATR","MA 1","MA 2","RSI","CCI","BBW", "ADX","MFI","MOM"], group = s1Group, inline = s1Inline)
s1Mid       = input.string(defval = ">=", title = "", options = [">","<",">=","<=","=","!=","CROSS ABOVE","CROSS BELOW"], group = s1Group, inline = s1Inline)
s1Right     = input.string(defval = "CCI", title = "2️⃣", options = ["ATR","MA 1","MA 2","RSI","CCI","BBW", "ADX","MFI","MOM"], group = s1Group, inline = s1Inline)
s1ValueBool = input.bool(defval = false, title = "VALUE ", group = s1Group, inline = "v1")
s1EndRight  = input.float(defval = 0. , title = "2️⃣", group = s1Group, inline = "v1")
s1Series    = operatorReturn(indicators(s1Left),s1Mid,s1ValueBool ? s1EndRight : indicators(s1Right))
detect(s1Status,s1Series,s1Direction)


// CONDITION 2
s2Group     = "❗️❗️❗️❗️ CONDITION #2 ❗️❗️❗️❗️"
s2Inline    = "s2i"
s2Status    = input.bool(defval = false, title = "CONDITION Active", group = s2Group )
s2Direction = input.string(defval = "BUY/LONG", title = "Direction",options = ["BUY/LONG","SELL/SHORT"], group = s2Group)
s2Left      = input.string(defval = "CCI", title = "1️⃣", options = ["ATR","MA 1","MA 2","RSI","CCI","BBW", "ADX","MFI","MOM"], group = s2Group, inline = s2Inline)
s2Mid       = input.string(defval = ">=", title = "", options = [">","<",">=","<=","=","!=","CROSS ABOVE","CROSS BELOW"], group = s2Group, inline = s2Inline)
s2Right     = input.string(defval = "CCI", title = "2️⃣", options = ["ATR","MA 1","MA 2","RSI","CCI","BBW", "ADX","MFI","MOM"], group = s2Group, inline = s2Inline)
s2ValueBool = input.bool(defval = false, title = "VALUE ", group = s2Group, inline = "v2")
s2EndRight  = input.float(defval = 0. , title = "2️⃣", group = s2Group, inline = "v2")
s2Series    = operatorReturn(indicators(s2Left),s2Mid,s2ValueBool ? s2EndRight : indicators(s2Right))
detect(s2Status,s2Series,s2Direction)




s3Group     = "❗️❗️❗️❗️ CONDITION #3 ❗️❗️❗️❗️"
s3Inline    = "s3i"
s3Status    = input.bool(defval = false, title = "CONDITION Active", group = s3Group )
s3Direction = input.string(defval = "BUY/LONG", title = "Direction",options = ["BUY/LONG","SELL/SHORT"], group = s3Group)
s3Left      = input.string(defval = "CCI", title = "1️⃣", options = ["ATR","MA 1","MA 2","RSI","CCI","BBW", "ADX","MFI","MOM"], group = s3Group, inline = s3Inline)
s3Mid       = input.string(defval = ">=", title = "", options = [">","<",">=","<=","=","!=","CROSS ABOVE","CROSS BELOW"], group = s3Group, inline = s3Inline)
s3Right     = input.string(defval = "CCI", title = "2️⃣", options = ["ATR","MA 1","MA 2","RSI","CCI","BBW", "ADX","MFI","MOM"], group = s3Group, inline = s3Inline)
s3ValueBool = input.bool(defval = false, title = "VALUE ", group = s3Group, inline = "v3")
s3EndRight  = input.float(defval = 0. , title = "2️⃣", group = s3Group, inline = "v3")
s3Series    = operatorReturn(indicators(s3Left),s3Mid,s3ValueBool ? s3EndRight : indicators(s3Right))
detect(s3Status,s3Series,s3Direction)


s4Group     = "❗️❗️❗️❗️ CONDITION #4 ❗️❗️❗️❗️"
s4Inline    = "s4i"
s4Status    = input.bool(defval = false, title = "CONDITION Active", group = s4Group )
s4Direction = input.string(defval = "BUY/LONG", title = "Direction",options = ["BUY/LONG","SELL/SHORT"], group = s4Group)
s4Left      = input.string(defval = "CCI", title = "1️⃣", options = ["ATR","MA 1","MA 2","RSI","CCI","BBW", "ADX","MFI","MOM"], group = s4Group, inline = s4Inline)
s4Mid       = input.string(defval = ">=", title = "", options = [">","<",">=","<=","=","!=","CROSS ABOVE","CROSS BELOW"], group = s4Group, inline = s4Inline)
s4Right     = input.string(defval = "CCI", title = "2️⃣", options = ["ATR","MA 1","MA 2","RSI","CCI","BBW", "ADX","MFI","MOM"], group = s4Group, inline = s4Inline)
s4ValueBool = input.bool(defval = false, title = "VALUE ", group = s4Group, inline = "v4")
s4EndRight  = input.float(defval = 0. , title = "2️⃣", group = s4Group, inline = "v4")
s4Series    = operatorReturn(indicators(s4Left),s4Mid,s4ValueBool ? s4EndRight : indicators(s4Right))
detect(s4Status,s4Series,s4Direction)

s5Group     = "❗️❗️❗️❗️ CONDITION #5 ❗️❗️❗️❗️"
s5Inline    = "s5i"
s5Status    = input.bool(defval = false, title = "CONDITION Active", group = s5Group )
s5Direction = input.string(defval = "BUY/LONG", title = "Direction",options = ["BUY/LONG","SELL/SHORT"], group = s5Group)
s5Left      = input.string(defval = "CCI", title = "1️⃣", options = ["ATR","MA 1","MA 2","RSI","CCI","BBW", "ADX","MFI","MOM"], group = s5Group, inline = s5Inline)
s5Mid       = input.string(defval = ">=", title = "", options = [">","<",">=","<=","=","!=","CROSS ABOVE","CROSS BELOW"], group = s5Group, inline = s5Inline)
s5Right     = input.string(defval = "CCI", title = "2️⃣", options = ["ATR","MA 1","MA 2","RSI","CCI","BBW", "ADX","MFI","MOM"], group = s5Group, inline = s5Inline)
s5ValueBool = input.bool(defval = false, title = "VALUE ", group = s5Group, inline = "v5")
s5EndRight  = input.float(defval = 0. , title = "2️⃣", group = s5Group, inline = "v5")
s5Series    = operatorReturn(indicators(s5Left),s5Mid,s5ValueBool ? s5EndRight : indicators(s5Right))
detect(s5Status,s5Series,s5Direction)

s6Group     = "❗️❗️❗️❗️ CONDITION #6 ❗️❗️❗️❗️"
s6Inline    = "s6i"
s6Status    = input.bool(defval = false, title = "CONDITION Active", group = s6Group )
s6Direction = input.string(defval = "BUY/LONG", title = "Direction",options = ["BUY/LONG","SELL/SHORT"], group = s6Group)
s6Left      = input.string(defval = "CCI", title = "1️⃣", options = ["ATR","MA 1","MA 2","RSI","CCI","BBW", "ADX","MFI","MOM"], group = s6Group, inline = s6Inline)
s6Mid       = input.string(defval = ">=", title = "", options = [">","<",">=","<=","=","!=","CROSS ABOVE","CROSS BELOW"], group = s6Group, inline = s6Inline)
s6Right     = input.string(defval = "CCI", title = "2️⃣", options = ["ATR","MA 1","MA 2","RSI","CCI","BBW", "ADX","MFI","MOM"], group = s6Group, inline = s6Inline)
s6ValueBool = input.bool(defval = false, title = "VALUE ", group = s6Group, inline = "v6")
s6EndRight  = input.float(defval = 0. , title = "2️⃣", group = s6Group, inline = "v6")
s6Series    = operatorReturn(indicators(s6Left),s6Mid,s6ValueBool ? s6EndRight : indicators(s6Right))
detect(s6Status,s6Series,s6Direction)

okxSignalId = input.string(defval = "", title = "OKX Signal ID")


// SCANNER
sembol1 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S1")
sembol2 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S2")
sembol3 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S3")
sembol4 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S4")
sembol5 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S5")
sembol6 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S6")
sembol7 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S7")
sembol8 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S8")
sembol9 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S9")
sembol10 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S10")
sembol11 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S11")
sembol12 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S12")
sembol13 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S13")
sembol14 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S14")
sembol15 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S15")
sembol16 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S16")
sembol17 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S17")
sembol18 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S18")
sembol19 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S19")
sembol20 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S20")
sembol21 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S21")
sembol22 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S22")
sembol23 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S23")
sembol24 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S24")
sembol25 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S25")
sembol26 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S26")
sembol27 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S27")
sembol28 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S28")
sembol29 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S29")
sembol30 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S30")
sembol31 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S31")
sembol32 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S32")
sembol33 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S33")
sembol34 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S34")
sembol35 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S35")
sembol36 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S36")
sembol37 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S37")
sembol38 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S38")
sembol39 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S39")
sembol40 = input.symbol(defval = "", title = "Symbol", group = "SCANNER",inline = "S40")



alarmTetikle(sembol_adi)=>
    long_entry_text = "ENTER_LONG"
    long_exit_text = "EXIT_LONG"
    short_entry_text = "ENTER_SHORT"
    short_exit_text = "EXIT_SHORT"
    durum_long_entry = request.security(sembol_adi,timeframe.period,andORLong == "AND" ? array.every(buyList) : array.includes(buyList,true))
    durum_short_entry = request.security(sembol_adi,timeframe.period,andORShort == "AND" ? array.every(sellList) : array.includes(sellList,true))
    long_enter_json = '{"action": "'+long_entry_text+'",   "instrument": "'+syminfo.ticker(sembol_adi)+'",    "signalToken": "'+okxSignalId+'",    "timestamp": "'+str.tostring(time)+'",    "maxLag": "60"}'
    long_exit_json = '{"action": "'+long_exit_text+'",   "instrument": "'+syminfo.ticker(sembol_adi)+'",    "signalToken": "'+okxSignalId+'",    "timestamp": "'+str.tostring(time)+'",    "maxLag": "60"}'
    short_enter_json = '{"action": "'+short_entry_text+'",   "instrument": "'+syminfo.ticker(sembol_adi)+'",    "signalToken": "'+okxSignalId+'",    "timestamp": "'+str.tostring(time)+'",    "maxLag": "60"}'
    short_exit_json = '{"action": "'+short_exit_text+'",   "instrument": "'+syminfo.ticker(sembol_adi)+'",    "signalToken": "'+okxSignalId+'",    "timestamp": "'+str.tostring(time)+'",    "maxLag": "60"}'
    if durum_long_entry and str.length(sembol_adi) > 1
        alert(short_exit_json,freq = alert.freq_once_per_bar)
        alert(long_enter_json,freq = alert.freq_once_per_bar)
    if durum_short_entry and str.length(sembol_adi) > 1
        alert(long_exit_json,freq = alert.freq_once_per_bar)
        alert(short_enter_json,freq = alert.freq_once_per_bar)




alarmTetikle(sembol1)
alarmTetikle(sembol2)
alarmTetikle(sembol3)
alarmTetikle(sembol4)
alarmTetikle(sembol5)
alarmTetikle(sembol6)
alarmTetikle(sembol7)
alarmTetikle(sembol8)
alarmTetikle(sembol9)
alarmTetikle(sembol10)
alarmTetikle(sembol11)
alarmTetikle(sembol12)
alarmTetikle(sembol13)
alarmTetikle(sembol14)
alarmTetikle(sembol15)
alarmTetikle(sembol16)
alarmTetikle(sembol17)
alarmTetikle(sembol18)
alarmTetikle(sembol19)
alarmTetikle(sembol20)
````
