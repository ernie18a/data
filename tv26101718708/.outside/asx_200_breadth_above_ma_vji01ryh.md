# ASX 200 Breadth - % Above MA

- url: https://www.tradingview.com/script/vJi01ryH-ASX-200-Breadth-Above-MA/
- type: indicator
- pine_id: PUB;7b10db4cda784951980fe9bc36dc7e3c
- version: 1.0

## Description

[b]ASX 200 Breadth - % Above MA[/b]

[b]Overview[/b]
This indicator measures market breadth for the ASX 200 by tracking the percentage of a representative basket of 40 large- and mid-cap ASX-listed stocks trading above a chosen moving average. It helps gauge whether strength (or weakness) in the index is broad-based across the market or concentrated in just a handful of large stocks.

[b]How It Works[/b]
- Pine Script limits a single indicator to 40, so true 200-stock breadth isn't possible directly. Instead, this script uses a diversified 40-stock sample spanning the major ASX sectors:
  - Financials: CBA, NAB, WBC, ANZ, MQG, SUN, QBE, IAG, ASX
  - Materials/Resources: BHP, RIO, FMG, S32, NEM, STO, WDS
  - Healthcare: CSL, RMD, COH, SHL, PME
  - Consumer: WES, WOW, COL, TWE, JHX, AMC
  - Industrials/Infrastructure: TCL, APA, BXB, CPU
  - Property (REITs): GMG, SCG, MGR, VCX
  - Tech/Other: XRO, REA, ALL, ORG
- For each stock, the script checks whether the current closing price is above its 20-, 50-, 100-, and 200-period Simple Moving Average (SMA).
- The indicator then plots the percentage of the basket trading above each selected MA, e.g. a reading of 75% on the 50-day line means 30 of the 40 sample stocks are above their 50-day SMA.
[b]
Inputs[/b]
- MA to Display: Choose which breadth line(s) to show - 20, 50, 100, 200, or All (shows all four together). Default: All
- Overbought Level: Upper reference line - readings above this suggest broad-based strength / potential overextension. Default: 80
- Oversold Level: Lower reference line - readings below this suggest broad-based weakness / potential capitulation. Default: 20

[b]Reading the Indicator[/b]
- **Above 50%**: more than half the sample is trending above the selected MA — generally bullish breadth.
- **Below 50%**: more than half the sample is trending below the selected MA — generally bearish breadth.
- **Near 80%+ (Overbought)**: market strength is broad and stretched — watch for breadth divergences if price keeps rising but this line rolls over.
- **Near 20% or below (Oversold)**: broad-based weakness — often associated with capitulation lows or the start of a recovery once breadth turns back up.
- **Divergences**: if the ASX 200 index makes a new high/low but breadth fails to confirm (doesn't reach a corresponding extreme), it can signal weakening participation behind the move.
- **Multiple timeframes ("All")**: comparing the 20-day line against the 100/200-day lines shows whether short-term moves are aligned with the longer-term trend — e.g., a sharp pop in the 20-day line while the 200-day line stays low suggests a short-term bounce within a longer downtrend.

[b]Notes & Limitations[/b]
- This is a **sample-based proxy** for ASX 200 breadth, not an exact count across all 200 constituents — actual index breadth may differ, especially when small-caps move independently of large-caps.
- All four MA lengths are calculated from a single data request per stock, so adding more MA options does not increase the symbol count or hit Pine's 40-symbol request limit.
- Works on any timeframe — the moving averages are calculated on that chart's timeframe (e.g., daily MAs on a daily chart, weekly MAs on a weekly chart).

## Source Code

````pine
//@version=6
indicator("ASX 200 Breadth - % Above MA", shorttitle="ASX200 Breadth", format=format.percent, max_bars_back=50)

maSelect = input.string("All", "MA to Display", options=["20", "50", "100", "200", "All"])
obLevel  = input.int(80, "Overbought Level", minval=50, maxval=100)
osLevel  = input.int(20, "Oversold Level", minval=0, maxval=50)

f_aboveMAs(sym) =>
    [c, s20, s50, s100, s200] = request.security(sym, timeframe.period, [close, ta.sma(close, 20), ta.sma(close, 50), ta.sma(close, 100), ta.sma(close, 200)])
    [c > s20 ? 1 : 0, c > s50 ? 1 : 0, c > s100 ? 1 : 0, c > s200 ? 1 : 0]

// Representative basket of 40 ASX 200 constituents across sectors
[a01_20,a01_50,a01_100,a01_200] = f_aboveMAs("ASX:CBA")
[a02_20,a02_50,a02_100,a02_200] = f_aboveMAs("ASX:BHP")
[a03_20,a03_50,a03_100,a03_200] = f_aboveMAs("ASX:CSL")
[a04_20,a04_50,a04_100,a04_200] = f_aboveMAs("ASX:NAB")
[a05_20,a05_50,a05_100,a05_200] = f_aboveMAs("ASX:WBC")
[a06_20,a06_50,a06_100,a06_200] = f_aboveMAs("ASX:ANZ")
[a07_20,a07_50,a07_100,a07_200] = f_aboveMAs("ASX:MQG")
[a08_20,a08_50,a08_100,a08_200] = f_aboveMAs("ASX:WES")
[a09_20,a09_50,a09_100,a09_200] = f_aboveMAs("ASX:WOW")
[a10_20,a10_50,a10_100,a10_200] = f_aboveMAs("ASX:TLS")
[a11_20,a11_50,a11_100,a11_200] = f_aboveMAs("ASX:FMG")
[a12_20,a12_50,a12_100,a12_200] = f_aboveMAs("ASX:RIO")
[a13_20,a13_50,a13_100,a13_200] = f_aboveMAs("ASX:GMG")
[a14_20,a14_50,a14_100,a14_200] = f_aboveMAs("ASX:TCL")
[a15_20,a15_50,a15_100,a15_200] = f_aboveMAs("ASX:WDS")
[a16_20,a16_50,a16_100,a16_200] = f_aboveMAs("ASX:STO")
[a17_20,a17_50,a17_100,a17_200] = f_aboveMAs("ASX:ALL")
[a18_20,a18_50,a18_100,a18_200] = f_aboveMAs("ASX:REA")
[a19_20,a19_50,a19_100,a19_200] = f_aboveMAs("ASX:COL")
[a20_20,a20_50,a20_100,a20_200] = f_aboveMAs("ASX:RMD")
[a21_20,a21_50,a21_100,a21_200] = f_aboveMAs("ASX:JHX")
[a22_20,a22_50,a22_100,a22_200] = f_aboveMAs("ASX:SUN")
[a23_20,a23_50,a23_100,a23_200] = f_aboveMAs("ASX:QBE")
[a24_20,a24_50,a24_100,a24_200] = f_aboveMAs("ASX:IAG")
[a25_20,a25_50,a25_100,a25_200] = f_aboveMAs("ASX:AMC")
[a26_20,a26_50,a26_100,a26_200] = f_aboveMAs("ASX:ORG")
[a27_20,a27_50,a27_100,a27_200] = f_aboveMAs("ASX:APA")
[a28_20,a28_50,a28_100,a28_200] = f_aboveMAs("ASX:SCG")
[a29_20,a29_50,a29_100,a29_200] = f_aboveMAs("ASX:MGR")
[a30_20,a30_50,a30_100,a30_200] = f_aboveMAs("ASX:VCX")
[a31_20,a31_50,a31_100,a31_200] = f_aboveMAs("ASX:NEM")
[a32_20,a32_50,a32_100,a32_200] = f_aboveMAs("ASX:S32")
[a33_20,a33_50,a33_100,a33_200] = f_aboveMAs("ASX:ASX")
[a34_20,a34_50,a34_100,a34_200] = f_aboveMAs("ASX:BXB")
[a35_20,a35_50,a35_100,a35_200] = f_aboveMAs("ASX:COH")
[a36_20,a36_50,a36_100,a36_200] = f_aboveMAs("ASX:SHL")
[a37_20,a37_50,a37_100,a37_200] = f_aboveMAs("ASX:TWE")
[a38_20,a38_50,a38_100,a38_200] = f_aboveMAs("ASX:XRO")
[a39_20,a39_50,a39_100,a39_200] = f_aboveMAs("ASX:PME")
[a40_20,a40_50,a40_100,a40_200] = f_aboveMAs("ASX:CPU")

total20  = a01_20+a02_20+a03_20+a04_20+a05_20+a06_20+a07_20+a08_20+a09_20+a10_20+a11_20+a12_20+a13_20+a14_20+a15_20+a16_20+a17_20+a18_20+a19_20+a20_20+a21_20+a22_20+a23_20+a24_20+a25_20+a26_20+a27_20+a28_20+a29_20+a30_20+a31_20+a32_20+a33_20+a34_20+a35_20+a36_20+a37_20+a38_20+a39_20+a40_20
total50  = a01_50+a02_50+a03_50+a04_50+a05_50+a06_50+a07_50+a08_50+a09_50+a10_50+a11_50+a12_50+a13_50+a14_50+a15_50+a16_50+a17_50+a18_50+a19_50+a20_50+a21_50+a22_50+a23_50+a24_50+a25_50+a26_50+a27_50+a28_50+a29_50+a30_50+a31_50+a32_50+a33_50+a34_50+a35_50+a36_50+a37_50+a38_50+a39_50+a40_50
total100 = a01_100+a02_100+a03_100+a04_100+a05_100+a06_100+a07_100+a08_100+a09_100+a10_100+a11_100+a12_100+a13_100+a14_100+a15_100+a16_100+a17_100+a18_100+a19_100+a20_100+a21_100+a22_100+a23_100+a24_100+a25_100+a26_100+a27_100+a28_100+a29_100+a30_100+a31_100+a32_100+a33_100+a34_100+a35_100+a36_100+a37_100+a38_100+a39_100+a40_100
total200 = a01_200+a02_200+a03_200+a04_200+a05_200+a06_200+a07_200+a08_200+a09_200+a10_200+a11_200+a12_200+a13_200+a14_200+a15_200+a16_200+a17_200+a18_200+a19_200+a20_200+a21_200+a22_200+a23_200+a24_200+a25_200+a26_200+a27_200+a28_200+a29_200+a30_200+a31_200+a32_200+a33_200+a34_200+a35_200+a36_200+a37_200+a38_200+a39_200+a40_200

breadth20  = total20  / 40.0 * 100
breadth50  = total50  / 40.0 * 100
breadth100 = total100 / 40.0 * 100
breadth200 = total200 / 40.0 * 100

show20   = maSelect == "20"  or maSelect == "All"
show50   = maSelect == "50"  or maSelect == "All"
show100  = maSelect == "100" or maSelect == "All"
show200  = maSelect == "200" or maSelect == "All"

plot(show20  ? breadth20  : na, title="% Above 20 SMA",  color=color.new(color.aqua,   0), linewidth=2)
plot(show50  ? breadth50  : na, title="% Above 50 SMA",  color=color.new(color.blue,   0), linewidth=2)
plot(show100 ? breadth100 : na, title="% Above 100 SMA", color=color.new(color.orange, 0), linewidth=2)
plot(show200 ? breadth200 : na, title="% Above 200 SMA", color=color.new(color.purple, 0), linewidth=2)

hline(obLevel, "Overbought", color=color.new(color.red, 0), linestyle=hline.style_dashed)
hline(osLevel, "Oversold", color=color.new(color.green, 0), linestyle=hline.style_dashed)
hline(50, "Midline", color=color.new(color.gray, 0), linestyle=hline.style_dotted)
````
