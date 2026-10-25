//+------------------------------------------------------------------+
//|                                         bollinger fibo bands.mq5 |
//|                           Copyright 2017, Sergey Pavlov (DC2008) |
//|                             https://www.mql5.com/ru/users/dc2008 |
//+------------------------------------------------------------------+
#property copyright     "Copyright 2017, Sergey Pavlov (DC2008)"
#property link          "https://www.mql5.com/ru/users/dc2008"
#property version       "1.00"
#property description   "Trade channel for the indicator and the iBand."
#property description   "The Bollinger bands are located at extended Fibonacci levels."
//--- Выводить индикатор в окно графика
#property indicator_chart_window
//--- Количество буферов для расчета индикатора
#property indicator_buffers 15
//--- Количество графических серий в индикаторе
#property indicator_plots   11
//--- plot 1
#property indicator_label1  "Upper bands: fibo 100% - 138.2%"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'255,204,204'
//--- plot 2
#property indicator_label2  "Lower bands: fibo 100% - 138.2%"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'204,204,255'
//--- plot 3
#property indicator_label3  "Upper bands: fibo 138.2% - 161.8%"
#property indicator_type3   DRAW_FILLING
#property indicator_color3  C'254,153,153'
//--- plot 4
#property indicator_label4  "Lower bands: fibo 138.2% - 161.8%"
#property indicator_type4   DRAW_FILLING
#property indicator_color4  C'153,153,254'
//--- plot 5
#property indicator_label5  "Upper bands: fibo 261.8%"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrRed
#property indicator_style5  STYLE_DOT
#property indicator_width5  1
//--- plot 6
#property indicator_label6  "Lower  bands: fibo 261.8%"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrBlue
#property indicator_style6  STYLE_DOT
#property indicator_width6  1
//--- plot 7
#property indicator_label7  "Upper bands: fibo 38.2%"
#property indicator_type7  DRAW_LINE
#property indicator_color7  clrRed
#property indicator_style7  STYLE_DOT
#property indicator_width7  1
//--- plot 8
#property indicator_label8  "Lower bands: fibo 38.2%"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrBlue
#property indicator_style8  STYLE_DOT
#property indicator_width8  1
//--- plot 9
#property indicator_label9  "Upper bands: fibo 61.8%"
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrRed
#property indicator_style9  STYLE_DOT
#property indicator_width9  1
//--- plot 10
#property indicator_label10  "Lower bands: fibo 61.8%"
#property indicator_type10   DRAW_LINE
#property indicator_color10  clrBlue
#property indicator_style10  STYLE_DOT
#property indicator_width10  1
//--- plot 11
#property indicator_label11  "Middle line"
#property indicator_type11   DRAW_LINE
#property indicator_color11  clrBlue
#property indicator_style11  STYLE_SOLID
#property indicator_width11  2
//---
input int                  BB_period=80;                 // Moving average period
input double               BB_deviation=2.0;             // Number of standard deviations 
input ENUM_APPLIED_PRICE   BB_applied_price=PRICE_CLOSE; // Price type 
input int                  BB_bands_shift=0;             // shift 
input int                  history=100;                  // History depth
//--- переменная для хранения хэндла индикатора iBands 
int         handle;
//---- indicator buffers
double         UpperBuffer[];
double         LowerBuffer[];
double         MiddleBuffer[];
//---
double         Buffer1[];
double         Buffer2[];
double         Buffer3[];
double         Buffer4[];
double         Buffer5[];
double         Buffer6[];
double         Buffer7[];
double         Buffer8[];
double         Buffer9[];
double         Buffer10[];
double         Buffer11[];
double         Buffer12[];
double         Buffer13[];
double         Buffer14[];
double         Buffer15[];
//--- Расширенные уровни Фибоначчи
double         fibo_38;
double         fibo_62;
double         fibo_138;
double         fibo_162;
double         fibo_262;
int            sd;
int            count;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   ArraySetAsSeries(Buffer1,true);
   ArraySetAsSeries(Buffer2,true);
   ArraySetAsSeries(Buffer3,true);
   ArraySetAsSeries(Buffer4,true);
   ArraySetAsSeries(Buffer5,true);
   ArraySetAsSeries(Buffer6,true);
   ArraySetAsSeries(Buffer7,true);
   ArraySetAsSeries(Buffer8,true);
   ArraySetAsSeries(Buffer9,true);
   ArraySetAsSeries(Buffer10,true);
   ArraySetAsSeries(Buffer11,true);
   ArraySetAsSeries(Buffer12,true);
   ArraySetAsSeries(Buffer13,true);
   ArraySetAsSeries(Buffer14,true);
   ArraySetAsSeries(Buffer15,true);
//---
   SetIndexBuffer(0,Buffer1,INDICATOR_DATA);
   SetIndexBuffer(1,Buffer2,INDICATOR_DATA);
   SetIndexBuffer(2,Buffer3,INDICATOR_DATA);
   SetIndexBuffer(3,Buffer4,INDICATOR_DATA);
   SetIndexBuffer(4,Buffer5,INDICATOR_DATA);
   SetIndexBuffer(5,Buffer6,INDICATOR_DATA);
   SetIndexBuffer(6,Buffer7,INDICATOR_DATA);
   SetIndexBuffer(7,Buffer8,INDICATOR_DATA);
   SetIndexBuffer(8,Buffer9,INDICATOR_DATA);
   SetIndexBuffer(9,Buffer10,INDICATOR_DATA);
   SetIndexBuffer(10,Buffer11,INDICATOR_DATA);
   SetIndexBuffer(11,Buffer12,INDICATOR_DATA);
   SetIndexBuffer(12,Buffer13,INDICATOR_DATA);
   SetIndexBuffer(13,Buffer14,INDICATOR_DATA);
   SetIndexBuffer(14,Buffer15,INDICATOR_DATA);
//--- создадим хэндл индикатора 
   handle=iBands(_Symbol,_Period,BB_period,BB_bands_shift,BB_deviation,BB_applied_price);
   ArraySetAsSeries(MiddleBuffer,true);
   ArraySetAsSeries(UpperBuffer,true);
   ArraySetAsSeries(LowerBuffer,true);
//--- Расширенные уровни Фибоначчи
   fibo_38=55.0/144.0;
   fibo_62=89.0/144.0;
   fibo_138=2.0-fibo_62;
   fibo_162=233.0/144.0;
   fibo_262=377.0/144.0;
//---
   sd=history;
   count=history+BB_period;
   ChartRedraw(0);
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
   int rt=rates_total-sd;
   for(int i=0; i<15; i++)
      PlotIndexSetInteger(i,PLOT_DRAW_BEGIN,rt);
   if(count>rates_total) sd=rates_total-BB_period;
//---
   CopyBuffer(handle,0,0,count,MiddleBuffer);
   CopyBuffer(handle,1,0,count,UpperBuffer);
   CopyBuffer(handle,2,0,count,LowerBuffer);
//---
   double mid;
   double std;
   for(int i=0;i<count;i++)
     {
      mid=MiddleBuffer[i];
      std=UpperBuffer[i]-mid;

      Buffer1[i]=mid+std*fibo_138;  // Upper bands 138%
      Buffer2[i]=UpperBuffer[i];    // Upper bands 100%

      Buffer3[i]=LowerBuffer[i];    // Lower bands 100%
      Buffer4[i]=mid-std*fibo_138;  // Upper bands 138%

      Buffer5[i]=mid+std*fibo_162;  // Upper bands 162%
      Buffer6[i]=mid+std*fibo_138;  // Upper bands 138%

      Buffer7[i]=mid-std*fibo_138;  // Lower bands 138%
      Buffer8[i]=mid-std*fibo_162;  // Lower bands 162%

      Buffer9[i]=mid+std*fibo_262;  // Upper bands 262%
      Buffer10[i]=mid-std*fibo_262; // Lower bands 262%
      Buffer11[i]=mid+std*fibo_38;  // Upper bands 61.8%
      Buffer12[i]=mid-std*fibo_38;  // Lower bands 61.8%
      Buffer13[i]=mid+std*fibo_62;  // Upper bands 38.2%
      Buffer14[i]=mid-std*fibo_62;  // Lower bands 38.2%
      Buffer15[i]=mid;              // Middle bands
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
