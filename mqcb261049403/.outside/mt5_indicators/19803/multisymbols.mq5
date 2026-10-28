//+------------------------------------------------------------------+
//|                                                 MultiSymbols.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#define   TOTAL_BUFFER      8
#property indicator_buffers TOTAL_BUFFER*2
#property indicator_plots   8
//--- plot Symbol_0
#property indicator_label1  "Symbol 1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Symbol_1
#property indicator_label2  "Symbol 2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Symbol_2
#property indicator_label3  "Symbol 3"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Symbol_3
#property indicator_label4  "Symbol 4"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrNavy
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot Symbol_4
#property indicator_label5  "Symbol 5"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrCyan
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot Symbol_5
#property indicator_label6  "Symbol 6"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrMagenta
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot Symbol_6
#property indicator_label7  "Symbol 7"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrGold
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- plot Symbol_7
#property indicator_label8  "Symbol 8"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrTomato
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
//--- input parameters
input uint                 InpPeriod   =  1;          // Period of MA
input ENUM_MA_METHOD       InpMethod   =  MODE_SMA;   // Calculation method
input ENUM_APPLIED_PRICE   InpPrice    =  PRICE_CLOSE;// Applied price
input int                  InpShift    =  1000;       // Vertical shift
input string               InpSymbol1  =  "EURUSD";   // Symbol 1
input string               InpSymbol2  =  "EURJPY";   // Symbol 2
input string               InpSymbol3  =  "USDJPY";   // Symbol 3
input string               InpSymbol4  =  "EURGBP";   // Symbol 4
input string               InpSymbol5  =  "GBPUSD";   // Symbol 5
input string               InpSymbol6  =  "EURCHF";   // Symbol 6
input string               InpSymbol7  =  "USDCHF";   // Symbol 7
input string               InpSymbol8  =  "USDCAD";   // Symbol 8
input color                InpColor1   =  clrBlue;    // Color of symbols line 1
input color                InpColor2   =  clrRed;     // Color of symbols line 2
input color                InpColor3   =  clrGreen;   // Color of symbols line 3
input color                InpColor4   =  clrNavy;    // Color of symbols line 4
input color                InpColor5   =  clrCyan;    // Color of symbols line 5
input color                InpColor6   =  clrMagenta; // Color of symbols line 6
input color                InpColor7   =  clrGold;    // Color of symbols line 7
input color                InpColor8   =  clrTomato;  // Color of symbols line 8
//--- global variables
struct SDataMA
  {
   string            symbol_name;
   color             line_color;
   int               handle;
   bool              use_flag;
   double            point;
   double            BufferTMP[];
   double            BufferMA[];
  } DataMA[];
int period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- settings parameters
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   ArrayResize(DataMA,TOTAL_BUFFER);
   DataMA[0].symbol_name=InpSymbol1; DataMA[0].line_color=InpColor1; DataMA[1].symbol_name=InpSymbol2; DataMA[1].line_color=InpColor2;
   DataMA[2].symbol_name=InpSymbol3; DataMA[2].line_color=InpColor3; DataMA[3].symbol_name=InpSymbol4; DataMA[3].line_color=InpColor4;
   DataMA[4].symbol_name=InpSymbol5; DataMA[4].line_color=InpColor5; DataMA[5].symbol_name=InpSymbol6; DataMA[5].line_color=InpColor6;
   DataMA[6].symbol_name=InpSymbol7; DataMA[6].line_color=InpColor7; DataMA[7].symbol_name=InpSymbol8; DataMA[7].line_color=InpColor8;
//--- settings indicators buffers mapping and parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Multi symbols("+(string)period+")");
   for(uchar i=0; i<TOTAL_BUFFER; i++)
     {
      SetIndexBuffer(i,DataMA[i].BufferMA,INDICATOR_DATA);
      SetIndexBuffer(i+TOTAL_BUFFER,DataMA[i].BufferTMP,INDICATOR_CALCULATIONS);
      PlotIndexSetString(i,PLOT_LABEL,DataMA[i].symbol_name);
      PlotIndexSetInteger(i,PLOT_LINE_COLOR,DataMA[i].line_color);
      ArraySetAsSeries(DataMA[i].BufferMA,true);
      ArraySetAsSeries(DataMA[i].BufferTMP,true);
      DataMA[i].use_flag=true;
      if(!(bool)SymbolInfoInteger(DataMA[i].symbol_name,SYMBOL_SELECT))
        {
         if(!SymbolSelect(DataMA[i].symbol_name,true))
           {
            Print("Could not select ",DataMA[i].symbol_name," in MarketWatch");
            DataMA[i].use_flag=false;
            continue;
           }
        }
      DataMA[i].point=SymbolInfoDouble(DataMA[i].symbol_name,SYMBOL_POINT);
      if(DataMA[i].use_flag)
         DataMA[i].handle=iMA(DataMA[i].symbol_name,PERIOD_CURRENT,period,0,InpMethod,InpPrice);
      if(DataMA[i].handle==INVALID_HANDLE)
        {
         Print("Error creating MA",i," handle for ",DataMA[i].symbol_name);
         return INIT_FAILED;
        }
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<period+1) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int   limit=rates_total-prev_calculated;
   uchar total=0;
   if(limit>1)
     {
      limit=rates_total-2;
      total=(uchar)ArraySize(DataMA);
      for(uchar i=0; i<total; i++)
        {
         ArrayInitialize(DataMA[i].BufferMA,EMPTY_VALUE);
         ArrayInitialize(DataMA[i].BufferTMP,EMPTY_VALUE);
         int copied=CopyBuffer(DataMA[i].handle,0,0,rates_total,DataMA[i].BufferTMP);
        }
     }
//--- Цикл расчёта индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      total=(uchar)ArraySize(DataMA);
      for(uchar j=0; j<total; j++)
        {
         if(BarsCalculated(DataMA[j].handle)<0) return 0;
         if(CopyBuffer(DataMA[j].handle,0,0,(limit==0 ? 1 : limit+1),DataMA[j].BufferTMP)<0) continue;
         if(DataMA[j].point>0)
            DataMA[j].BufferMA[i]=(DataMA[j].BufferTMP[i]-DataMA[j].BufferTMP[i+1])/DataMA[j].point-j*InpShift;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
