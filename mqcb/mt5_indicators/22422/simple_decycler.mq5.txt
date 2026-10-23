//+------------------------------------------------------------------+
//|                                              Simple_Decycler.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "John F.Ehlers Simple Decycler indicator"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   3
//--- plot Decicle
#property indicator_label1  "Decicler"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Top
#property indicator_label2  "Top"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Bottom
#property indicator_label3  "Bottom"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input double               InpPeriodHP       =  125.0;         // HP period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferDecicle[];
double         BufferTop[];
double         BufferBottom[];
double         BufferHP[];
double         BufferMA[];
//--- global variables
double         period_hp;
double         angle1;
double         angle2;
double         alpha1;
double         alpha2;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_hp=(InpPeriodHP<2 ? 2 : InpPeriodHP);
   angle1=1.414*M_PI/period_hp;
   angle2=2.0*angle1;
   alpha1=(cos(angle1)+sin(angle1)-1.0)/cos(angle1);
   alpha2=(cos(angle2)+sin(angle2)-1.0)/cos(angle2);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDecicle,INDICATOR_DATA);
   SetIndexBuffer(1,BufferTop,INDICATOR_DATA);
   SetIndexBuffer(2,BufferBottom,INDICATOR_DATA);
   SetIndexBuffer(3,BufferHP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Simple Decycler ("+DoubleToString(period_hp,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferDecicle,true);
   ArraySetAsSeries(BufferTop,true);
   ArraySetAsSeries(BufferBottom,true);
   ArraySetAsSeries(BufferHP,true);
   ArraySetAsSeries(BufferMA,true);
//--- create handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-3;
      ArrayInitialize(BufferDecicle,0);
      ArrayInitialize(BufferTop,0);
      ArrayInitialize(BufferBottom,0);
      ArrayInitialize(BufferHP,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1);
   int copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double a1=1.0-alpha1;
      double a2=1.0-alpha1/2.0;
      double a3=a1*a1;
      double a4=a2*a2;
      double pr2=2.0*BufferMA[i+1];
      double pr3=BufferMA[i]-pr2+BufferMA[i+2];
      BufferHP[i]=a4*pr3+(2.0*a1*BufferHP[i+1])-(a3*BufferHP[i+2]);
      BufferDecicle[i]=BufferMA[i]-BufferHP[i];
      BufferTop[i]=BufferDecicle[i]*1.005;
      BufferBottom[i]=BufferDecicle[i]*0.995;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
