# Financial Data Table

- url: https://www.tradingview.com/script/6GlSalGe-Financial-Data-Table/
- type: indicator
- pine_id: PUB;9a3d3fb14e754afd8ae54f5a0d4b8527
- version: 1.0

## Description

# Financial Data Table

## English

### Overview

Financial Data Table is a clean and practical TradingView indicator that displays key fundamental and financial metrics directly on your chart in a structured table format.

The script is designed for traders and investors who want to combine technical analysis with financial data without leaving the chart screen.

### Features

* Displays important company financial metrics
* Simple and minimal table design
* Easy-to-read layout
* Works directly on the chart
* Supports multilingual labels
* Useful for stock analysis and long-term investing

### Included Metrics

The table may include:

* Current Ratio
* Current Assets
* Non-Current Assets
* Short-Term Liabilities
* Long-Term Liabilities
* Price / Book Ratio
* P/E Ratio
* Shareholders Equity
* Float Shares
* Return on Equity
* Revenue
* Net Sales
* Gross Profit
* And more...

### Use Cases

* Quick company health overview
* Fundamental confirmation for technical setups
* Comparing stocks visually
* Long-term portfolio analysis

### Notes

* Financial data depends on TradingView data availability.
* Some values may vary depending on the exchange and reporting period.
* Best used on stock charts.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © GoldenAlgoTrader

//@version=5
indicator(title="Financial Data Table", shorttitle="Financial Data Table", overlay=true)//****** Label ***************
//****** Label ***************

show_screener2 = input.bool(true, 'Finansal Tablo')
SenelikDegisim = (close-close[365])/close[365]*100
d6ay=(close-close[182])/close[182]*100
d18ay=(close-close[567])/close[567]*100
d24ay=(close-close[730])/close[730]*100
BVPS = request.financial(syminfo.tickerid,"BOOK_VALUE_PER_SHARE", "FY")
PriceBookRatio = close/BVPS     //**************pddd*********
Number_of_shares = request.financial(syminfo.tickerid,  "TOTAL_SHARES_OUTSTANDING","FQ")

EPS = request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE", "TTM")
PriceEarningsRatio = close / EPS
TSO = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ") //******sermaye*****
FCF= request.financial(syminfo.tickerid, "FREE_CASH_FLOW", "FQ")
GrowthQ=request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE_BASIC_ONE_YEAR_GROWTH", "FQ")
GrowthY=request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE_BASIC_ONE_YEAR_GROWTH", "FY")
PEGQ=PriceEarningsRatio/GrowthQ*100 //Price/Earnings-to-Growth
PEGY=PriceEarningsRatio/GrowthY*100 //Price/Earnings-to-Growth
MarketCap = TSO * close
PriceToFreeCashFlowRatio = MarketCap / FCF
text_hizala = text.align_left
SHE = request.financial(syminfo.tickerid, "SHRHLDRS_EQUITY", "FQ")  //*****ozsermaye******
TLSHE = request.financial(syminfo.tickerid, "TOTAL_LIABILITIES_SHRHLDRS_EQUITY", "FQ")
FSO = request.financial(syminfo.tickerid, "FLOAT_SHARES_OUTSTANDING", "FY") //****dolasimdakipay
DolasimYuzde= FSO/TSO*100
CRatio = request.financial(syminfo.tickerid, "CURRENT_RATIO", "FY") //cari oran
CRatioQ = request.financial(syminfo.tickerid, "CURRENT_RATIO", "FQ") //cari oran çeyrek
NetSatislarYillik = request.financial(syminfo.tickerid, "COST_OF_GOODS", "FY")*-1
CiroYillik = request.financial(syminfo.tickerid, "TOTAL_REVENUE", "FY")
BrutKar =CiroYillik-NetSatislarYillik
DonenVarliklar = request.financial(syminfo.tickerid, "TOTAL_CURRENT_ASSETS", "FY")
DuranVarliklar = request.financial(syminfo.tickerid, "TOTAL_NON_CURRENT_ASSETS", "FY")


ROE= request.financial(syminfo.tickerid, "RETURN_ON_EQUITY", "FY")//Öz Sermaye karlılığı
KVYK=request.financial(syminfo.tickerid, "TOTAL_CURRENT_LIABILITIES", "FY") //kısa vadeli yabancı kaynaklar
UVYK=request.financial(syminfo.tickerid, "TOTAL_NON_CURRENT_LIABILITIES", "FY") //uzun vadeli yabancı kaynaklar
KVYKQ=request.financial(syminfo.tickerid, "TOTAL_CURRENT_LIABILITIES", "FQ") //kısa vadeli yabancı kaynaklar CEYREK
UVYKQ=request.financial(syminfo.tickerid, "TOTAL_NON_CURRENT_LIABILITIES", "FQ") //uzun vadeli yabancı kaynaklar CEYREK

// Screener//
default_bg = #cccccc
//var tbl = table.new(position.middle_right, 2, 17,   bgcolor = color.black, frame_width = 1, frame_color = color.black, border_color = color.black, border_width = 1)
var tbl = table.new(position.middle_right, 3, 17, bgcolor=color.black, frame_width=1, frame_color=color.black, border_color=color.black, border_width=1)


if show_screener2
    if barstate.islast
        
        table.cell(tbl, 0, 0, 'Current Ratio (Yearly)', bgcolor=default_bg)
        table.cell(tbl, 1, 0, str.tostring(CRatio, format.mintick), bgcolor=default_bg)
        table.cell(tbl, 2, 0, 'Cari Oranı Yıllık', bgcolor=default_bg)

        table.cell(tbl, 0, 1, 'Current Assets', bgcolor=default_bg)
        table.cell(tbl, 1, 1, str.tostring(DonenVarliklar, format.volume), bgcolor=default_bg)
        table.cell(tbl, 2, 1, 'Dönen Varlıklar', bgcolor=default_bg)

        table.cell(tbl, 0, 2, 'Non-Current Assets', bgcolor=default_bg)
        table.cell(tbl, 1, 2, str.tostring(DuranVarliklar, format.volume), bgcolor=default_bg)
        table.cell(tbl, 2, 2, 'Duran Varlıklar', bgcolor=default_bg)

        table.cell(tbl, 0, 3, 'Short-Term Liabilities', bgcolor=default_bg)
        table.cell(tbl, 1, 3, str.tostring(KVYK, format.volume), bgcolor=default_bg)
        table.cell(tbl, 2, 3, 'KVYK Yıllık', bgcolor=default_bg)

        table.cell(tbl, 0, 4, 'Long-Term Liabilities', bgcolor=default_bg)
        table.cell(tbl, 1, 4, str.tostring(UVYK, format.volume), bgcolor=default_bg)
        table.cell(tbl, 2, 4, 'UVYK Yıllık', bgcolor=default_bg)

        table.cell(tbl, 0, 5, 'Price / Book Ratio', bgcolor=default_bg)
        table.cell(tbl, 1, 5, str.tostring(PriceBookRatio, format.mintick), bgcolor=default_bg)
        table.cell(tbl, 2, 5, 'PD/DD Oranı', bgcolor=default_bg)

        table.cell(tbl, 0, 6, 'P/E Ratio', bgcolor=default_bg)
        table.cell(tbl, 1, 6, str.tostring(PriceEarningsRatio, format.mintick), bgcolor=default_bg)
        table.cell(tbl, 2, 6, 'F/K Oranı', bgcolor=default_bg)

        table.cell(tbl, 0, 7, 'Shareholders Equity', bgcolor=default_bg)
        table.cell(tbl, 1, 7, str.tostring(SHE, format.volume), bgcolor=default_bg)
        table.cell(tbl, 2, 7, 'Öz Sermaye', bgcolor=default_bg)

        table.cell(tbl, 0, 8, 'Total Shares', bgcolor=default_bg)
        table.cell(tbl, 1, 8, str.tostring(TSO, format.volume), bgcolor=default_bg)
        table.cell(tbl, 2, 8, 'Sermaye', bgcolor=default_bg)

        table.cell(tbl, 0, 9, 'Float Shares', bgcolor=default_bg)
        table.cell(tbl, 1, 9, str.tostring(FSO, format.volume), bgcolor=default_bg)
        table.cell(tbl, 2, 9, 'Dolaşımdaki Pay', bgcolor=default_bg)

        table.cell(tbl, 0, 10, 'Float %', bgcolor=default_bg)
        table.cell(tbl, 1, 10, str.tostring(DolasimYuzde, format.percent), bgcolor=default_bg)
        table.cell(tbl, 2, 10, 'Dolaşım % si', bgcolor=default_bg)

        table.cell(tbl, 0, 11, 'Return on Equity', bgcolor=default_bg)
        table.cell(tbl, 1, 11, str.tostring(ROE, format.percent), bgcolor=default_bg)
        table.cell(tbl, 2, 11, 'Öz Sermaye Karlılığı', bgcolor=default_bg)

        table.cell(tbl, 0, 12, 'Total Shares Outstanding', bgcolor=default_bg)
        table.cell(tbl, 1, 12, str.tostring(TSO, format.volume), bgcolor=default_bg)
        table.cell(tbl, 2, 12, 'Toplam Hisse Adedi', bgcolor=default_bg)

        table.cell(tbl, 0, 13, 'PEG Ratio', bgcolor=default_bg)
        table.cell(tbl, 1, 13, str.tostring(PEGY, format.mintick), bgcolor=default_bg)
        table.cell(tbl, 2, 13, 'PEG Oranı', bgcolor=default_bg)

        table.cell(tbl, 0, 14, 'Revenue', bgcolor=default_bg)
        table.cell(tbl, 1, 14, str.tostring(CiroYillik, format.volume), bgcolor=default_bg)
        table.cell(tbl, 2, 14, 'Ciro', bgcolor=default_bg)

        table.cell(tbl, 0, 15, 'Net Sales', bgcolor=default_bg)
        table.cell(tbl, 1, 15, str.tostring(NetSatislarYillik, format.volume), bgcolor=default_bg)
        table.cell(tbl, 2, 15, 'Net Satışlar', bgcolor=default_bg)

        table.cell(tbl, 0, 16, 'Gross Profit', bgcolor=default_bg)
        table.cell(tbl, 1, 16, str.tostring(BrutKar, format.volume), bgcolor=default_bg)
        table.cell(tbl, 2, 16, 'Brüt Kar', bgcolor=default_bg)



// if  show_screener2
//     if barstate.islast
//         table.cell(tbl, 0, 0, 'Cari Oranı Yıllık', bgcolor=default_bg)
//         table.cell(tbl, 1, 0, str.tostring(CRatio,format.mintick) , bgcolor=default_bg)

//         table.cell(tbl, 0, 1, 'Dönen Varlıklar', bgcolor=default_bg)
//         table.cell(tbl, 1, 1, str.tostring(DonenVarliklar,format.volume) , bgcolor=default_bg)

//         table.cell(tbl, 0, 2, 'Duran Varlıklar', bgcolor=default_bg)
//         table.cell(tbl, 1, 2, str.tostring(DuranVarliklar,format.volume) , bgcolor=default_bg)
        
//         table.cell(tbl, 0, 3, 'KVYK Yıllık', bgcolor=default_bg)
//         table.cell(tbl, 1, 3, str.tostring(KVYK, format.volume) , bgcolor=default_bg)

//         table.cell(tbl, 0, 4, 'UVYK Yıllık', bgcolor=default_bg)
//         table.cell(tbl, 1, 4, str.tostring(UVYK, format.volume) , bgcolor=default_bg)
        
//         table.cell(tbl, 0, 5, 'PD/DD Oranı ', bgcolor=default_bg)
//         table.cell(tbl, 1, 5, str.tostring(PriceBookRatio,format.mintick) , bgcolor=default_bg)

//         table.cell(tbl, 0, 6, 'F/K Oranı  ', bgcolor=default_bg)
//         table.cell(tbl, 1, 6, str.tostring(PriceEarningsRatio,format.mintick) , bgcolor=default_bg)

//         table.cell(tbl, 0, 7, 'Öz Sermaye ', bgcolor=default_bg)
//         table.cell(tbl, 1, 7, str.tostring(SHE, format.volume) , bgcolor=default_bg)

//         table.cell(tbl, 0, 8, 'Sermaye', bgcolor=default_bg)
//         table.cell(tbl, 1, 8, str.tostring(TSO, format.volume) , bgcolor=default_bg)
       
//         table.cell(tbl, 0, 9, 'Dolaşımdaki Pay', bgcolor=default_bg)
//         table.cell(tbl, 1, 9, str.tostring(FSO, format.volume) , bgcolor=default_bg)

//         table.cell(tbl, 0, 10, 'Dolaşım % si', bgcolor=default_bg)
//         table.cell(tbl, 1, 10, str.tostring(DolasimYuzde, format.percent) , bgcolor=default_bg)
        
//         table.cell(tbl, 0, 11, 'Öz Sermaye karlılığı', bgcolor=default_bg)
//         table.cell(tbl, 1, 11, str.tostring(ROE, format.percent) , bgcolor=default_bg)

//         table.cell(tbl, 0, 12, 'Toplam Hisse Adedi', bgcolor=default_bg)
//         table.cell(tbl, 1, 12, str.tostring(TSO, format.volume) , bgcolor=default_bg)

//         table.cell(tbl, 0, 13, 'PEG Oranı', bgcolor=default_bg)
//         table.cell(tbl, 1, 13, str.tostring(PEGY, format.mintick) , bgcolor=default_bg)

//         table.cell(tbl, 0, 14, 'Ciro', bgcolor=default_bg)
//         table.cell(tbl, 1, 14, str.tostring(CiroYillik,format.volume) , bgcolor=default_bg)

//         table.cell(tbl, 0, 15, 'Net Satışlar', bgcolor=default_bg)
//         table.cell(tbl, 1, 15, str.tostring(NetSatislarYillik,format.volume) , bgcolor=default_bg)

//         table.cell(tbl, 0, 16, 'Brüt Kar', bgcolor=default_bg)
//         table.cell(tbl, 1, 16, str.tostring(BrutKar,format.volume) , bgcolor=default_bg)

//         // table.cell(tbl, 0, 16, 'Cari Oranı çeyrek', bgcolor=default_bg)
//         // table.cell(tbl, 1, 16, str.tostring(CRatioQ,format.mintick) , bgcolor=default_bg)
````
