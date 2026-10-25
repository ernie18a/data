//+------------------------------------------------------------------+
//|                                                  COG_Channel.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Center of Gravity Channel indicator"
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   6
//--- plot UL
#property indicator_label1  "Top Deviation"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot LL
#property indicator_label2  "Bottom Deviation"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot ULS
#property indicator_label3  "Top ATR"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLightBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot LLS
#property indicator_label4  "Bottom ATR"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrLightBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot Basis
#property indicator_label5  "Basis"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGreen
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot AL
#property indicator_label6  "Contraction"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrBlue
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- input parameters
input uint                 InpPeriod         =  34;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input double               InpMultiplierDev  =  2.5;           // Deviation multiplier
input double               InpMultiplierATR  =  2.0;           // ATR multiplier
//--- indicator buffers
double         BufferUL[];
double         BufferLL[];
double         BufferULS[];
double         BufferLLS[];
double         BufferBasis[];
double         BufferAL[];
double         BufferTR[];
double         BufferDev[];
double         BufferMA[];
//--- global variables
double         mult_dev;
double         mult_atr;
int            period_ind;
int            handle_ma;
int            handle_dev;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ind=int(InpPeriod<1 ? 1 : InpPeriod);
   mult_dev=InpMultiplierDev;
   mult_atr=InpMultiplierATR;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUL,INDICATOR_DATA);
   SetIndexBuffer(1,BufferLL,INDICATOR_DATA);
   SetIndexBuffer(2,BufferULS,INDICATOR_DATA);
   SetIndexBuffer(3,BufferLLS,INDICATOR_DATA);
   SetIndexBuffer(4,BufferBasis,INDICATOR_DATA);
   SetIndexBuffer(5,BufferAL,INDICATOR_DATA);
   SetIndexBuffer(6,BufferTR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferDev,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferMA,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(5,PLOT_ARROW,159);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"COG Channel ("+(string)period_ind+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUL,true);
   ArraySetAsSeries(BufferLL,true);
   ArraySetAsSeries(BufferULS,true);
   ArraySetAsSeries(BufferLLS,true);
   ArraySetAsSeries(BufferBasis,true);
   ArraySetAsSeries(BufferAL,true);
   ArraySetAsSeries(BufferTR,true);
   ArraySetAsSeries(BufferDev,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_dev=iStdDev(NULL,PERIOD_CURRENT,period_ind,0,MODE_SMA,InpAppliedPrice);
   if(handle_dev==INVALID_HANDLE)
     {
      Print("The iStdDev(",(string)period_ind,") by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_ind,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ind-2;
      ArrayInitialize(BufferUL,EMPTY_VALUE);
      ArrayInitialize(BufferLL,EMPTY_VALUE);
      ArrayInitialize(BufferULS,EMPTY_VALUE);
      ArrayInitialize(BufferLLS,EMPTY_VALUE);
      ArrayInitialize(BufferBasis,EMPTY_VALUE);
      ArrayInitialize(BufferAL,EMPTY_VALUE);
      ArrayInitialize(BufferTR,0);
      ArrayInitialize(BufferDev,0);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_dev,0,0,count,BufferDev);
   if(copied!=count) return 0;

   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double x1=high[i]-low[i];
      double x2=fabs(high[i]-close[i+1]);
      double x3=fabs(low[i]-close[i+1]);
      BufferTR[i]=fmax(x1,fmax(x2,x3));
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double x=0,y=0,xy=0,x2=0;
      for(int j=0; j<period_ind; j++)
        {
         y+=BufferMA[i+j];
         xy+=BufferMA[i+j]*j;
         x+=j;
         x2+=j*j;
        }
      double temp=period_ind*x2-x*x;
      double m=(temp!=0 ? (period_ind*xy-x*y)/temp : 0);
      double yint=(y+m*x)/period_ind;
      BufferBasis[i]=yint-m*period_ind;

      double dev=BufferDev[i]*mult_dev;
      BufferUL[i]=BufferBasis[i]+dev;
      BufferLL[i]=BufferBasis[i]-dev;

      double atr=GetSMA(rates_total,i,period_ind,BufferTR)*mult_atr;
      BufferULS[i]=BufferBasis[i]+atr;
      BufferLLS[i]=BufferBasis[i]-atr;
      BufferAL[i]=(BufferULS[i]>BufferUL[i] && BufferLLS[i]<BufferLL[i] ? BufferBasis[i] : EMPTY_VALUE);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double GetSMA(const int rates_total,const int index,const int period,const double &price[],const bool as_series=true)
  {
//---
   double result=0.0;
//--- check position
   bool check_index=(as_series ? index<=rates_total-period-1 : index>=period-1);
   if(period<1 || !check_index)
      return 0;
//--- calculate value
   for(int i=0; i<period; i++)
      result=result+(as_series ? price[index+i]: price[index-i]);
//---
   return(result/period);
  }
//+------------------------------------------------------------------+
