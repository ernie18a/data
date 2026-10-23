//+------------------------------------------------------------------+
//|                                          iChartsSwitchSymbol.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright     "Integer"
#property link          "https://www.mql5.com/ru/users/integer"
#property description   " "
#property description   "      http://dmffx.com"
#property description   " "
#property description   "      mailto:for-good-letters@yandex.ru"
#property description   " "
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Label1
#property indicator_label1  "Label1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int      Input1;
//--- indicator buffers
double         Label1Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,Label1Buffer,INDICATOR_DATA);
   EventSetTimer(1);
   Comment("Drag symbol here");
//---
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int r)
  {
   Comment("");
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
//---

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   Func();
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   Func();
  }
//+------------------------------------------------------------------+
//| Func function                                                    |
//+------------------------------------------------------------------+
void Func()
  {
   long List[];
   ChartsList(List);
   for(int i=0;i<ArraySize(List);i++)
     {
      if(ChartSymbol(List[i])!=Symbol())
        {
         ChartSetSymbolPeriod(List[i],Symbol(),ChartPeriod(List[i]));
        }
     }
  }
//+------------------------------------------------------------------+
//| ChartsList function                                              |
//+------------------------------------------------------------------+
int ChartsList(long  &aList[])
  {
   ArrayResize(aList,0);
   long tmp=ChartFirst();
   while(tmp!=-1)
     {
      ArrayResize(aList,ArraySize(aList)+1);
      aList[ArraySize(aList)-1]=tmp;
      tmp=ChartNext(tmp);
     }
   return(ArraySize(aList));
  }
//+------------------------------------------------------------------+
