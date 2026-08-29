<!-- tradingview-pine-id: PUB;3964967b15f04f12b6a9521ff8765a44 -->
<!-- tradingviewscripts-format: 1 -->
# Synthetic Price Action Generator

Source: https://www.tradingview.com/script/uqelSkN1-Synthetic-Price-Action-Generator/

## Description

NOTICE:
First thing you need to know, it "DOES NOT" reflect the price of the ticker you will load it on. THIS IS NOT AN INDICATOR FOR TRADING! It's a developer tool solely generating random values that look exactly like the fractals we observe every single day. This script's generated candles are as fake as the never ending garbage news cycles we are often force fed and expected to believe by using carefully scripted narratives peddled as hypnotic truth to psychologically and emotionally influence you to the point of control by coercion and subjugation. I wanted to make the script's synthetic nature very clear using that analogy, it's dynamically artificial. Do not accidentally become disillusioned by this scripts values, make trading decisions from it, and lastly don't become victim to predatory media magic ministry parrots with pretty, handsome smiles, compelling you to board their ferris wheel of fear. Now, on to the good stuff...

BACKSTORY:
Occasionally I find myself in situations where I have to build analyzers in Pine to actually build novel quantitative analytic indicators and tools worthy of future use. These analyzers certainly don't exist on this platform, but usually are required to engineer and tweak algorithms of the highest quality with the finest computational caliber. I have numerous other synthesizers to publish besides this one.

For many reasons, I needed a synthetic environment to utilize the analyzers I built in Pine, to even pursue building some exotic indicators and algorithms. Pine doesn't allow sourcing of tuples. Not to mention, I required numerous Pine advancements to make long held dreams into tangible realities. Many Pine upgrades have arrived and MANY, MANY more are in need of implementation for all. Now that I have this, intending to use it in the future often when in need, you can now use it too. I do anticipate some skilled Pine poets will employ this intended handy utility to design and/or improved indicators for trading.
 
ORIGIN:
This was inspired by the brilliance from the world renowned ALGOmist John F. Ehlers, but it's taken on a completely alien form from its original DNA. Browsing on the internet for something else, I came across an article with a small code snippet, and I remembered an old wish of mine. I have long known that by flipping back and forth on specific tickers and timeframes in my Watchlist is not the most efficient way to evaluate indicators in multiple theatres of price action. I realized, I always wanted to possess and use this sort of tool, so... I put it into Pine form, but now have decided to inject it with Pine Script steroids. The outcome is highly mutable candle formations in a reusable mutagenic package, observable above and masquerading as genuine looking price candles.
 
OVERVIEW:
I guess you could call it a price action synthesizer, but I entitled it "Synthetic Price Action Generator" for those who may be searching for such a thing. You may find this more useful on the All or 5Y charts initially to witness indication from beginning (barstate.isfirst === barindex==0) to end (last_bar_index), but you may also use keyboard shortcuts [ ALT ] + [ SHIFT ] + [ ◀ ] to view the earliest plottable bars on any timeframe. I often use that keyboard shortcut to qualify an indicator through the entirety of it's runtime.

A lot can go wrong unexpectedly with indicator initialization, and you will never know it if you don't inspect it. Many recursively endowed Infinite Impulse Response (IIR) Filters can initialize with unintended results that minutely ring in slightly erroneous fashion for the entire runtime, beginning to end, causing deviations from "what should of been..." values with false signals. Looking closely at spg(), you will recognize that 3 EMAs are employed to manage and maintain randomness of CLOSE, HIGH, and LOW. In fact, any indicator's barindex==0 initialization can be inspected with the keyboard shortcuts above. If you see anything obviously strange in an authors indicator, please contact the developer if possible and respectfully notify them.
 
PURPOSE:
The primary intended application of this script, is to offer developers from advanced to even novice skill levels assistance with building next generation indicators. Mostly, it's purpose is for testing and troubleshooting indicators AND evaluating how they perform in a "manageable" randomized environment. Some times indicators flake out on rare but problematic price fluctuations, and this may help you with finding your issues/errata sooner than later. While the candles upon initial loading look pristine, by tweaking it to the minval/maxval parameters limits OR beyond with a few code modifications, you can generate unusual volatility, for instance... huge wicks. Limits of minval= and maxval= of are by default set to a comfort zone of operation. Massive wicks or candle bodies will undoubtedly affect your indication and often render them useless on tickers that exhibit that behavior, like WGMCF intraday currently.

Copy/paste boundaries are provided for relevant insertion into another script. Paste placement should happen at the very top of a script. Note that by overwriting the close, open, high, etc... values, your compiler will give you generous warnings of "variable shadowing" in abundance, but this is an expected part of applying it to your novel script, no worries. plotcandle() can be copied over too and enabled/disabled in Settings->Style. Always remember to fully remove this scripts' code and those assignments properly before actual trading use of your script occurs, AND specifically when publishing. The entirety of this provided code should never, never exist in a published indicator.
 
OTHER INTENTIONS:
Even though these are 100% synthetic generated price points, you will notice ALL of the fractal pseudo-patterns that commonly exist in the markets, are naturally occurring with this generator too. You can also swiftly immerse yourself in pattern recognition exercises with increased efficiency in real time by clicking any SPAG Setting in focus and then using the up/down arrow keys. I hope I explained potential uses adequately...

On a personal note, the existence of fractal symmetry often makes me wonder, do we truly live in a totality chaotic universe or is it ordered mathematically for some outcomes to a certain extent. I think both. My observations, it's a pre-deterministic reality completely influenced by infinitesimal amounts of sentient free will with unimaginable existing and emerging quantities. Some how an unknown mysterious mechanism governing the totality of universal physics and mathematics counts this 100.0% flawlessly and perpetually. Anyways, you can't change the past that long existed before your birth or even yesterday, but you can choose to dream, create, and forge the future into your desires and hopes. As always, shite always happens when your not looking for it. What you choose to do after stepping in it unintentionally... is totally up to you. :) Maybe this tool and tips provided will aid you in not stepping in an algo cachucha up to your ankles somehow.

SCRIPTING LESSONS PORTRAYED IN THIS SCRIPT:
Pine etiquette and code cleanliness
Overwrite capabilities of built-in Pine variables for testing indicators
Various techniques to organize Settings panel while providing ease of adjustment utility
Use of tooltip= to provide users adequate valuable information. Most people want to trade with indicators, not blindly make adjustments to them without any knowledge of their intended operation/effects

When available time provides itself, I will consider your inquiries, thoughts, and concepts presented below in the comments section, should you have any questions or comments regarding this indicator. When my indicators achieve more prevalent use by TV members , I may implement more ideas when they present themselves as worthy additions. Have a profitable future everyone!

---

## Source Code

````pine
//@version=5
indicator("Synthetic Price Action Generator", "SPAG", precision=3)

// ############################################ START COPY BOUNDARY ############################################

GROUP1 = "================ SPAG Close Controls ================"
GROUP2 = "============= Additional SPAG Controls =============="
nptIV  = input.int  (   50,                  "Initial Value", group=GROUP1, tooltip="This will be the starting value at\nbar_index==0, eventually gravitating\ntowards ≅50 at last_bar_index.\n\nOn the All chart you may influence\nthe trend of price values using this")
nptMPA = input.float( 0.45,       "Manipulate Price Action*", group=GROUP1, minval=-0.0 , maxval=0.95 , step=0.01   , tooltip="This acts as a randomness reset capability,\nenabling quick cycling through synthetic\nwaveforms of interest with your keyboard keys")
nptPCR = input.float(0.004,    "Perturbate close Randomness", group=GROUP1, minval=0.002, maxval=0.013, step=0.00005, tooltip="Just another way to manipulate randomness\nof close. Adjustments approaching minval\nor maxval values will diminish randomness")
nptPM  = input.float(  1.0,               "Price Multiplier", group=GROUP2,                             step=0.005  , tooltip="This can reduce the values of price action. For\ninstance, you can see what an indicator does\non open/high/low/close values of less than 1.0.\nUse of a negative number will yield an oscilator")
nptPHL = input.float( 0.19, "Perturbate high/low Volatility", group=GROUP2, minval= 0.07, maxval=0.27 , step=0.01   , tooltip="Increasing this value will lengthen the\naverage wick length, while decreasing it\nwill result in reduced average wick length")
nptOCV = input.float( 0.07,      "Variability of open/close", group=GROUP2, minval=-0.07, maxval=0.07 , step=0.01   , tooltip="A value of 0.0 will result\nin close equating to open[1]")

spg( float        InitialCloseValue=50.0 ,
     float    ManipulatePriceAction=0.45 ,
     float PertubateCloseRandomness=0.004,
     float  PerturbateHighLowValues=0.19 ,
     float     OpenCloseVariability=0.07 ,
     float          PriceMultiplier=1.0  ) => // Synthetic Price Generator Function
    var PRICE_MULT = PriceMultiplier==0 ? 0.001 : PriceMultiplier
    var SIGN_OF_PM = -1 == math.sign(PriceMultiplier)
    temp = 1.0 - PertubateCloseRandomness
    float CLOSE = na, CLOSE := PertubateCloseRandomness * math.random(100) + temp * nz(CLOSE[1])
    if bar_index == 0
        CLOSE := InitialCloseValue
	temp := 1 - ManipulatePriceAction
    rand4High  = math.random(.25)
    HighValue  = 0.0, HighValue := ManipulatePriceAction * rand4High + temp * nz(HighValue[1], rand4High)
    HighValue -= nz(HighValue[1]) - HighValue
    HIGH       = math.max(CLOSE, CLOSE + HighValue * PerturbateHighLowValues)
    rand4Low  = math.random(.25)
    LowValue  = 0.0, LowValue := ManipulatePriceAction * rand4Low + temp * nz(LowValue[1], rand4Low)
    LowValue -= nz(LowValue[1]) - LowValue
    LOW       = math.min(CLOSE, CLOSE - LowValue * PerturbateHighLowValues)
    OPEN  = CLOSE[1] + math.avg(rand4High, rand4Low) * (bar_index % 2 ? -1 : 1) * nptOCV
    Open  = SIGN_OF_PM ? ( OPEN - 50) * PriceMultiplier :  OPEN * PRICE_MULT
    High  = SIGN_OF_PM ? ( HIGH - 50) * PriceMultiplier :  HIGH * PRICE_MULT
    Low   = SIGN_OF_PM ? (  LOW - 50) * PriceMultiplier :   LOW * PRICE_MULT
    Close = SIGN_OF_PM ? (CLOSE - 50) * PriceMultiplier : CLOSE * PRICE_MULT
    [Open, High, Low, Close] // Tuple return

[Open, High, Low, Close] = spg(nptIV, nptMPA, nptPCR, nptPHL, nptOCV, nptPM)

HCC3  = math.avg( High, Close, Close) // Bonus calculation that a curious few may eventually find a use for
OCC3  = math.avg( Open, Close, Close) // Bonus calculation that a curious few may eventually find a use for
//===== How TV calculates the    ====//
//===== built-in variables below ====//
HL2   = math.avg( High,   Low)
HLC3  = math.avg( High,   Low, Close)
HLCC4 = math.avg( Open,  High, Close, Close)
OHLC4 = math.avg( Open,  High,   Low, Close)

//    NOTE: Overwrites existing built-in variables to provide ease of indicator evaluation once inserted into your script
// PURPOSE: This exists so you don't have to modify a tremendous amount of your existing code, inducing potential errata
//   USAGE: Uncomment the following lines to apply these synthetic values to your indicator after placement in the very top of your script
// open  = Open
// high  = High
// low   = Low
// close = Close
// hl2   = HL2
// hlc3  = HLC3
// hlcc4 = HLCC4
// ohlc4 = OHLC4

// ############################################# END COPY BOUNDARY #############################################

plotcandle(Open, High, Low, Close, "", Close>Open ? #00CC00 : #CC0000, #FFFF0080, bordercolor=#00000000)
plot(math.sign(nptPM)==-1 ? 0.0 : na, "", #808080, trackprice=true, show_last=1)
````
