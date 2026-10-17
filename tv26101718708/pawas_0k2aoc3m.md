# Pawas

- url: https://www.tradingview.com/script/0K2AoC3M-Pawas/
- type: indicator
- pine_id: PUB;e017a1a71b49446ba03d71a47c5b11f6
- version: 1.0

## Description

“📈 Premium forex signals with accurate entries, solid TP targets, and smart risk management. Trade smarter, not harder.”
“Consistent profits start with quality signals. Join now and get daily market setups 🔥”
“Daily forex signals complete with entry, SL, and TP. Perfect for beginners and serious traders.”
“No time to analyze the market? Let us provide you with real-time, high-accuracy forex signals 💹”
“Trade with more confidence using clear signals, simple setups, and active community support.”
“From beginner to consistent trader 🚀 Get the best forex signals delivered straight to your Telegram.”
“Trusted forex signals for scalping and swing trading. Focus on the best market opportunities every day.”
“More than just signals — includes market analysis, risk control, and guidance to help grow your account.”
“Precise entries, strong TP targets, and solid support 🔥 Join a trading team focused on real results.”
“Forex signals for traders who want results, not guesses. Fast updates, clear setups, and easy execution.”

## Source Code

````pine
//@version=5

indicator("SNR Predictive Orders M5 + Clean Lines + Price Labels", overlay=true)



// ===== INPUT =====

lookback   = input.int(30, "SNR Lookback")

atrMult    = input.float(0.5)

lotSize    = input.float(0.01)

cooldown   = input.int(10)



// ===== ATR =====

atr = ta.atr(14)



// ===== OFFSET =====

offset = atr * 0.6



// ===== SNR =====

support    = ta.lowest(low, lookback)

resistance = ta.highest(high, lookback)



// ===== SIGNAL =====

buyTrigger  = low <= support + atr * atrMult and close > open

sellTrigger = high >= resistance - atr * atrMult and close < open



// ===== ENTRY =====

buyLimit  = support

sellLimit = resistance



// ===== SL TP =====

tpDist = atr * 1

slDist = atr * 2



buySL = buyLimit - slDist

buyTP = buyLimit + tpDist



sellSL = sellLimit + slDist

sellTP = sellLimit - tpDist



// ===== STATE =====

var float entryPrice = na

var float slPrice = na

var float tpPrice = na

var string dir = ""



var bool active = false

var bool entered = false



var int lastSignalBar = na

canSignal = na(lastSignalBar) or (bar_index - lastSignalBar > cooldown)



// ===== OBJECTS =====

var label entryLabel = na

var label statusLabel = na



var line tpLine = na

var line slLine = na

var line entryLine = na



// ===== PRICE LABELS ON LINES =====

var label tpPriceLabel = na

var label slPriceLabel = na

var label entryPriceLabel = na



// ================= CLEAN FUNCTION =================

f_clearAll() =>

    if not na(entryLabel)

        label.delete(entryLabel)

    if not na(statusLabel)

        label.delete(statusLabel)

    if not na(tpPriceLabel)

        label.delete(tpPriceLabel)

    if not na(slPriceLabel)

        label.delete(slPriceLabel)

    if not na(entryPriceLabel)

        label.delete(entryPriceLabel)

    if not na(tpLine)

        line.delete(tpLine)

    if not na(slLine)

        line.delete(slLine)

    if not na(entryLine)

        line.delete(entryLine)



// ================= BUY =================

if buyTrigger and canSignal



    f_clearAll()



    entryPrice := buyLimit

    slPrice := buySL

    tpPrice := buyTP

    dir := "BUY"

    active := true

    entered := false



    entryLabel := label.new(bar_index, buyLimit - offset,

     "BUY LIMIT (SNR)\n@" + str.tostring(buyLimit, format.mintick),

     color=color.green, textcolor=color.white,

     style=label.style_label_up)



    tpLine := line.new(bar_index, buyTP, bar_index + 20, buyTP, color=color.green, width=2)

    slLine := line.new(bar_index, buySL, bar_index + 20, buySL, color=color.red, width=2)

    entryLine := line.new(bar_index, buyLimit, bar_index + 20, buyLimit,

     color=color.blue, width=2, style=line.style_dotted)



    // ===== PRICE LABELS =====

    entryPriceLabel := label.new(bar_index + 20, buyLimit,

     str.tostring(buyLimit, format.mintick),

     color=color.blue, textcolor=color.white,

     style=label.style_label_left, size=size.tiny)



    tpPriceLabel := label.new(bar_index + 20, buyTP,

     str.tostring(buyTP, format.mintick),

     color=color.green, textcolor=color.white,

     style=label.style_label_left, size=size.tiny)



    slPriceLabel := label.new(bar_index + 20, buySL,

     str.tostring(buySL, format.mintick),

     color=color.red, textcolor=color.white,

     style=label.style_label_left, size=size.tiny)



    lastSignalBar := bar_index



// ================= SELL =================

if sellTrigger and canSignal



    f_clearAll()



    entryPrice := sellLimit

    slPrice := sellSL

    tpPrice := sellTP

    dir := "SELL"

    active := true

    entered := false



    entryLabel := label.new(bar_index, sellLimit + offset,

     "SELL LIMIT (SNR)\n@" + str.tostring(sellLimit, format.mintick),

     color=color.red, textcolor=color.white,

     style=label.style_label_down)



    tpLine := line.new(bar_index, sellTP, bar_index + 20, sellTP, color=color.green, width=2)

    slLine := line.new(bar_index, sellSL, bar_index + 20, sellSL, color=color.red, width=2)

    entryLine := line.new(bar_index, sellLimit, bar_index + 20, sellLimit,

     color=color.blue, width=2, style=line.style_dotted)



    // ===== PRICE LABELS =====

    entryPriceLabel := label.new(bar_index + 20, sellLimit,

     str.tostring(sellLimit, format.mintick),

     color=color.blue, textcolor=color.white,

     style=label.style_label_left, size=size.tiny)



    tpPriceLabel := label.new(bar_index + 20, sellTP,

     str.tostring(sellTP, format.mintick),

     color=color.green, textcolor=color.white,

     style=label.style_label_left, size=size.tiny)



    slPriceLabel := label.new(bar_index + 20, sellSL,

     str.tostring(sellSL, format.mintick),

     color=color.red, textcolor=color.white,

     style=label.style_label_left, size=size.tiny)



    lastSignalBar := bar_index



// ================= ENTRY HIT =================

if active and not entered

    if dir == "BUY" and low <= entryPrice

        entered := true



        if not na(entryLabel)

            label.delete(entryLabel)



        statusLabel := label.new(bar_index, entryPrice - offset,

         "BUYING\n@" + str.tostring(entryPrice, format.mintick),

         color=color.green, textcolor=color.white)



    if dir == "SELL" and high >= entryPrice

        entered := true



        if not na(entryLabel)

            label.delete(entryLabel)



        statusLabel := label.new(bar_index, entryPrice + offset,

         "SELLING\n@" + str.tostring(entryPrice, format.mintick),

         color=color.red, textcolor=color.white)



// ===== TP / SL =====

buyTPhit  = entered and dir == "BUY" and high >= tpPrice

buySLhit  = entered and dir == "BUY" and low <= slPrice



sellTPhit = entered and dir == "SELL" and low <= tpPrice

sellSLhit = entered and dir == "SELL" and high >= slPrice



// ===== USD =====

pip = syminfo.mintick * 10

usdPerPip = lotSize * 10



profitUSD = math.abs(tpPrice - entryPrice) / pip * usdPerPip

lossUSD   = math.abs(entryPrice - slPrice) / pip * usdPerPip



// ===== CLOSE TRADE =====

if buyTPhit or sellTPhit

    if not na(statusLabel)

        label.delete(statusLabel)

    f_clearAll()



    label.new(bar_index, high,

     "TP HIT\n" + dir +

     "\n+" + str.tostring(profitUSD, "#.##") + "$",

     color=color.green, textcolor=color.white)



    active := false

    entered := false



if buySLhit or sellSLhit

    if not na(statusLabel)

        label.delete(statusLabel)

    f_clearAll()



    label.new(bar_index, low,

     "SL HIT\n" + dir +

     "\n-" + str.tostring(lossUSD, "#.##") + "$",

     color=color.red, textcolor=color.white)



    active := false

    entered := false
````
