# GLI Trend Analysis | Astral Vision 

- url: https://www.tradingview.com/script/5x02aINU/
- type: indicator
- pine_id: PUB;791e539426554b86acdd1712e1686bbe
- version: 1.0

## Description

[b]GLI Trend Analysis | Astral Vision 🌠💠[/b]

This indicator plots the Global Liquidity Index and its exponential moving average, using the EMA crossover as a directional trend signal for the global monetary environment. The GLI is constructed from the same comprehensive 21-source aggregation used across the Astral Vision liquidity suite: 17 major central bank balance sheets converted to USD via live FX rates, minus the Fed's non-stimulative liabilities (Reverse Repo Facility and Treasury General Account), plus M2 money supply for the US, EU, China, and Japan.

[b]Calculation ⚙️[/b]

The GLI is computed as:

Fed balance sheet, minus RRP (Reverse Repo: overnight cash parked at the Fed by money market funds, which drains liquidity from the financial system), minus TGA (Treasury General Account: the US government's cash balance at the Fed, which also drains liquidity when it grows), plus the balance sheets of the Bank of Japan, People's Bank of China, Bank of England, ECB, Reserve Bank of India, Bank of Canada, Reserve Bank of Australia, Swiss National Bank, Central Bank of Russia, Central Bank of Brazil, Bank of Korea, Reserve Bank of New Zealand, Sveriges Riksbank, and Bank Negara Malaysia, each converted to USD by multiplying by the corresponding live FX rate, plus M2 money supply for the US, EU (converted via EURUSD), China (converted via CNYUSD), and Japan (converted via JPYUSD).

The subtraction of RRP and TGA from the Fed balance sheet is a critical correction absent from simpler GLI implementations. The Fed's balance sheet includes liabilities that do not actually inject money into the financial system: when RRP balances are high, money market funds are lending cash back to the Fed overnight, effectively withdrawing it from circulation. Similarly, a growing TGA means the government is holding more cash at the Fed rather than spending it into the economy. Subtracting both produces a more accurate measure of net liquidity actually available to financial markets.

An EMA of configurable length is applied to the resulting GLI series. When GLI is above its EMA, global liquidity is in an uptrend relative to its own smoothed baseline, historically associated with expanding risk appetite and upward pressure on Bitcoin and other risk assets. When GLI is below its EMA, the trend is contractionary.

Both the GLI line and the background color on the price chart are shifted forward in time by a configurable offset in bars, operationalizing the empirically documented lead-lag relationship between global liquidity inflections and Bitcoin price response.

[b]Plots 📊[/b]
[list]
[*]GLI line colored by its position relative to the EMA, shifted forward by the configurable offset
[*]EMA line as a neutral reference
[*]Background color on the price chart reflecting GLI trend direction, shifted forward by the same offset
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]EMA Length: smoothing period for the GLI trend baseline
[*]Lead Offset: bars to shift both the GLI signal and the background color forward in time
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Infinito.

[b]Purpose 🎯[/b]
A standard EMA crossover applied to Bitcoin price measures Bitcoin's own momentum without any external reference. This indicator applies the same crossover logic to global central bank liquidity, producing a regime signal that is causally upstream of Bitcoin price rather than derived from it. The forward shift separates this tool from coincident liquidity indicators by explicitly positioning the signal as a leading reference, reflecting the time lag between liquidity creation and its transmission into asset prices. The RRP and TGA correction further distinguishes it from simpler GLI charts available elsewhere, which overstate liquidity by including Fed liabilities that do not reach financial markets.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("GLI Trend Analysis | Astral Vision 🌠💠")

group1 = "Settings"
group2 = "Colors"

int    emalen = input.int(300, "EMA Length",  group=group1)
int    offset = input.int(100,  "Lead Offset", group=group1)

string theme      = input.string("Infinito", "Color Theme", ["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group2)
color  custom_pos = input.color(color.rgb(255,255,255), "Custom Positive", group=group2)
color  custom_neg = input.color(color.rgb(100,100,100), "Custom Negative", group=group2)

color poscol = usecustom ? custom_pos :
     theme == "Paradiso" ? color.rgb(0,210,255)   :
     theme == "Futura"   ? color.rgb(0,255,180)   :
     theme == "Infinito" ? color.rgb(180,120,255) :
     theme == "Hermes"   ? color.rgb(255,160,0)   :
     color.rgb(255,0,0)

color negcol = usecustom ? custom_neg :
     theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)  :
     theme == "Infinito" ? color.rgb(255,220,80) :
     theme == "Hermes"   ? color.rgb(0,180,120)  :
     color.rgb(120,0,0)

fed   = request.security('ECONOMICS:USCBBS',                 'D', close, currency=currency.USD)
rrp   = request.security('FRED:RRPONTSYD',                   'D', close, currency=currency.USD)
tga   = request.security('FRED:WTREGEN',                     'D', close, currency=currency.USD)
ecb   = request.security('ECONOMICS:EUCBBS * FX_IDC:EURUSD', 'D', close, currency=currency.USD)
pbc   = request.security('ECONOMICS:CNCBBS * FX_IDC:CNYUSD', 'D', close, currency=currency.USD)
boj   = request.security('ECONOMICS:JPCBBS * FX_IDC:JPYUSD', 'D', close, currency=currency.USD)
boe   = request.security('ECONOMICS:GBCBBS * FX_IDC:GBPUSD', 'D', close, currency=currency.USD)
boc   = request.security('ECONOMICS:CACBBS * FX_IDC:CADUSD', 'D', close, currency=currency.USD)
rba   = request.security('ECONOMICS:AUCBBS * FX_IDC:AUDUSD', 'D', close, currency=currency.USD)
rbi   = request.security('ECONOMICS:INCBBS * FX_IDC:INRUSD', 'D', close, currency=currency.USD)
snb   = request.security('ECONOMICS:CHCBBS * FX_IDC:CHFUSD', 'D', close, currency=currency.USD)
cbr   = request.security('ECONOMICS:RUCBBS * FX_IDC:RUBUSD', 'D', close, currency=currency.USD)
bcb   = request.security('ECONOMICS:BRCBBS * FX_IDC:BRLUSD', 'D', close, currency=currency.USD)
bok   = request.security('ECONOMICS:KRCBBS * FX_IDC:KRWUSD', 'D', close, currency=currency.USD)
rbzn  = request.security('ECONOMICS:NZCBBS * FX_IDC:NZDUSD', 'D', close, currency=currency.USD)
sr    = request.security('ECONOMICS:SECBBS * FX_IDC:SEKUSD', 'D', close, currency=currency.USD)
bnm   = request.security('ECONOMICS:MYCBBS * FX_IDC:MYRUSD', 'D', close, currency=currency.USD)
usa   = request.security('ECONOMICS:USM2',                   'D', close, currency=currency.USD)
eu    = request.security('ECONOMICS:EUM2 * FX_IDC:EURUSD',   'D', close, currency=currency.USD)
china = request.security('ECONOMICS:CNM2 * FX_IDC:CNYUSD',   'D', close, currency=currency.USD)
japan = request.security('ECONOMICS:JPM2 * FX_IDC:JPYUSD',   'D', close, currency=currency.USD)

gli    = fed - rrp - tga + boj + pbc + boe + ecb + rbi + boc + rba + snb + cbr + bcb + bok + rbzn + sr + bnm + usa + eu + china + japan
gliema = ta.ema(gli, emalen)

color glic = gli >= gliema ? negcol : poscol

plot(gli,    "GLI",     color=glic,                       linewidth=2, offset=offset)
plot(gliema, "GLI EMA", color=color.new(color.white, 50), linewidth=1, offset=offset)

bgcolor(gli >= gliema ? color.new(negcol, 60) : color.new(poscol, 60), offset=offset, force_overlay=true)
````
