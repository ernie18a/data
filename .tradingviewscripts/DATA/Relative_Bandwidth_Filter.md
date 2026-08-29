<!-- tradingview-pine-id: PUB;14b8b16db3ee4090819e0cdaaad5938a -->
<!-- tradingviewscripts-format: 1 -->
# Relative Bandwidth Filter

Source: https://www.tradingview.com/script/5egLveLn-Relative-Bandwidth-Filter/

## Description

This is a very simple script which can be used as measure to define your trading zones based on volatility.

Concept
This script tries to identify the area of low and high volatility based on comparison between Bandwidth of higher length and ATR of lower length.

Relative Bandwidth = Bandwidth / ATR

Bandwidth can be based on either Bollinger Band, Keltner Channel or Donchian Channel. Length of the bandwidth need to be ideally higher.
ATR is calculated using built in ATR method and ATR length need to be ideally lower than that used for calculating Bandwidth.

Once we got Relative Bandwidth, the next step is to apply Bollinger Band on this to measure how relatively high/low this value is. 

Overall - If relative bandwidth is higher, then volatility is comparatively low. If relative bandwidth is lower, then volatility is comparatively high.

Usage
This can be used with your own strategy to filter out your non-trading zones based on volatility. Script plots a variable called "Signal" - which is not shown on chart pane. But, it is available in the data window. This can be used in another script as external input and apply logic.

Signal values can be

[*] 1 : Allow only Long
[*] -1 : Allow only short
[*] 0 : Do not allow any trades
[*] 2 : Allow both Long and Short

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © HeWhoMustNotBeNamed

//   __    __            __       __  __                  __       __                        __      __    __              __      _______             __    __                                          __ 
//  /  |  /  |          /  |  _  /  |/  |                /  \     /  |                      /  |    /  \  /  |            /  |    /       \           /  \  /  |                                        /  |
//  $$ |  $$ |  ______  $$ | / \ $$ |$$ |____    ______  $$  \   /$$ | __    __   _______  _$$ |_   $$  \ $$ |  ______   _$$ |_   $$$$$$$  |  ______  $$  \ $$ |  ______   _____  ____    ______    ____$$ |
//  $$ |__$$ | /      \ $$ |/$  \$$ |$$      \  /      \ $$$  \ /$$$ |/  |  /  | /       |/ $$   |  $$$  \$$ | /      \ / $$   |  $$ |__$$ | /      \ $$$  \$$ | /      \ /     \/    \  /      \  /    $$ |
//  $$    $$ |/$$$$$$  |$$ /$$$  $$ |$$$$$$$  |/$$$$$$  |$$$$  /$$$$ |$$ |  $$ |/$$$$$$$/ $$$$$$/   $$$$  $$ |/$$$$$$  |$$$$$$/   $$    $$< /$$$$$$  |$$$$  $$ | $$$$$$  |$$$$$$ $$$$  |/$$$$$$  |/$$$$$$$ |
//  $$$$$$$$ |$$    $$ |$$ $$/$$ $$ |$$ |  $$ |$$ |  $$ |$$ $$ $$/$$ |$$ |  $$ |$$      \   $$ | __ $$ $$ $$ |$$ |  $$ |  $$ | __ $$$$$$$  |$$    $$ |$$ $$ $$ | /    $$ |$$ | $$ | $$ |$$    $$ |$$ |  $$ |
//  $$ |  $$ |$$$$$$$$/ $$$$/  $$$$ |$$ |  $$ |$$ \__$$ |$$ |$$$/ $$ |$$ \__$$ | $$$$$$  |  $$ |/  |$$ |$$$$ |$$ \__$$ |  $$ |/  |$$ |__$$ |$$$$$$$$/ $$ |$$$$ |/$$$$$$$ |$$ | $$ | $$ |$$$$$$$$/ $$ \__$$ |
//  $$ |  $$ |$$       |$$$/    $$$ |$$ |  $$ |$$    $$/ $$ | $/  $$ |$$    $$/ /     $$/   $$  $$/ $$ | $$$ |$$    $$/   $$  $$/ $$    $$/ $$       |$$ | $$$ |$$    $$ |$$ | $$ | $$ |$$       |$$    $$ |
//  $$/   $$/  $$$$$$$/ $$/      $$/ $$/   $$/  $$$$$$/  $$/      $$/  $$$$$$/  $$$$$$$/     $$$$/  $$/   $$/  $$$$$$/     $$$$/  $$$$$$$/   $$$$$$$/ $$/   $$/  $$$$$$$/ $$/  $$/  $$/  $$$$$$$/  $$$$$$$/ 
//                                                                                                                                                                                                          
//                                                                                                                                                                                                          
//
//@version=5
indicator("Relative Bandwidth Filter")
import HeWhoMustNotBeNamed/enhanced_ta/14 as eta

bandType = input.string("KC", title="Type", group="Bands", options=["BB", "KC", "DC"])
bmasource = input.source(close, title="Source", group="Bands")
bmatype = input.string("sma", title="Type", group="Bands", options=["sma", "ema", "hma", "rma", "wma", "vwma", "swma", "linreg", "median"])
bmalength = input.int(100, title="Length", group="Bands")
multiplier = input.float(2.0, step=0.5, title="Multiplier", group="Bands")
useTrueRange = input.bool(true, title="Use True Range (KC)", group="Bands")
useAlternateSource = input.bool(false, title="Use Alternate Source (DC)", group="Bands")
bsticky = input.bool(true, title="Sticky", group="Bands/Bandwidth/BandPercent")

atrLength = input.int(20, 'Length', group='ATR')


bbmatype = input.string("sma", title="Type", group="BBands", options=["sma", "ema", "hma", "rma", "wma", "vwma", "linreg", "median"])
bbmalength = input.int(100, title="Length", group="BBands")
mmultiplier = input.float(1.0, step=0.5, title="Multiplier", group="BBands")

desiredCondition = input.string("Higher Bandwidth", "Desired Condition", options=["Higher Bandwidth", "Lower Bandwidth"])
referenceBand = input.string("Middle", options=["Upper", "Lower", "Middle"])

var cloudTransparency = 90
[bbmiddle, bbupper, bblower] = eta.bb(bmasource, bmatype, bmalength, multiplier, sticky=bsticky)
[kcmiddle, kcupper, kclower] = eta.kc(bmasource, bmatype, bmalength, multiplier, useTrueRange, sticky=bsticky)
[dcmiddle, dcupper, dclower] = eta.dc(bmalength, useAlternateSource, bmasource, sticky=bsticky)

upper = bandType == "BB"? bbupper : bandType == "KC"? kcupper : dcupper
lower = bandType == "BB"? bblower : bandType == "KC"? kclower : dclower
middle = bandType == "BB"? bbmiddle : bandType == "KC"? kcmiddle : dcmiddle

atr = ta.atr(atrLength)

relativeBandwidth = (upper-lower)/atr

plot(relativeBandwidth, "Relative Bandwidth", color=color.purple)

[mmiddle, uupper, llower] = eta.bb(relativeBandwidth, bbmatype, bbmalength, mmultiplier, sticky=false)

plot(mmiddle, 'Middle', color=color.blue)
plot(uupper, 'Upper', color=color.green)
plot(llower, 'Lower', color=color.red)

reference = referenceBand == "Middle"? mmiddle : referenceBand == "Upper"? uupper : llower
signal = relativeBandwidth > reference? 2 : 0
signal := desiredCondition == "Lower Bandwidth"? math.abs(signal-2) : signal
plot(signal, "Signal", display=display.data_window)
````
