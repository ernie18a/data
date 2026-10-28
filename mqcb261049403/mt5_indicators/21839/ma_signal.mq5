//+------------------------------------------------------------------+
//|                                                    MA_Signal.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "MA signal indicator"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   2
//--- plot UP
#property indicator_label1  "Bullish signal"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN
#property indicator_label2  "Bearish signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint                 InpPeriod1        =  10;            // First MA period
input ENUM_APPLIED_PRICE   InpAppliedPrice1  =  PRICE_CLOSE;   // First MA applied price
input ENUM_MA_METHOD       InpMethod1        =  MODE_EMA;      // First MA method

input uint                 InpPeriod2        =  50;            // Second MA period
input ENUM_APPLIED_PRICE   InpAppliedPrice2  =  PRICE_CLOSE;   // Second MA applied price
input ENUM_MA_METHOD       InpMethod2        =  MODE_EMA;      // Second MA method

input uint                 InpPeriod3        =  20;            // Third MA period
input ENUM_APPLIED_PRICE   InpAppliedPrice3  =  PRICE_CLOSE;   // Third MA applied price
input ENUM_MA_METHOD       InpMethod3        =  MODE_SMA;      // Third MA method

input uint                 InpPeriod4        =  40;            // Fourth MA period
input ENUM_APPLIED_PRICE   InpAppliedPrice4  =  PRICE_CLOSE;   // Fourth MA applied price
input ENUM_MA_METHOD       InpMethod4        =  MODE_SMA;      // Fourth MA method

input ENUM_INPUT_YES_NO    InpUseSwing       =  INPUT_YES;     // Use swing signals

//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferMA1[];
double         BufferMA2[];
double         BufferMA3[];
double         BufferMA4[];
double         BufferLast[];
//--- global variables
typedef double (*TFunc) (const int);
TFunc          ma_func;
int            period_1;
int            period_2;
int            period_3;
int            period_4;
int            period_max;
int            handle_ma1;
int            handle_ma2;
int            handle_ma3;
int            handle_ma4;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_1=int(InpPeriod1<1 ? 1 : InpPeriod1);
   period_2=int(InpPeriod2<1 ? 1 : InpPeriod2);
   period_3=int(InpPeriod3<1 ? 1 : InpPeriod3);
   period_4=int(InpPeriod4<1 ? 1 : InpPeriod4);
   period_max=fmax(period_1,fmax(period_2,fmax(period_3,period_4)));
   int array[4][2]={0,0};
   array[0][0]=period_1; array[0][1]=1;
   array[1][0]=period_2; array[1][1]=2;
   array[2][0]=period_3; array[2][1]=3;
   array[3][0]=period_4; array[3][1]=4;
   ArraySort(array);
   int max_period=array[3][1];
   switch(max_period)
     {
      case 1 : ma_func=MA1; break;
      case 2 : ma_func=MA2; break;
      case 3 : ma_func=MA3; break;
      default: ma_func=MA4; break;
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferMA3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMA4,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferLast,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW and colors
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,(!InpUseSwing ? indicator_color1 : clrGreen));
   PlotIndexSetInteger(0,PLOT_ARROW,(InpUseSwing ? 233 : 158));
   PlotIndexSetInteger(1,PLOT_ARROW,(InpUseSwing ? 234 : 158));
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"MA signal ("+MethodToString(InpMethod1)+"("+(string)period_1+"),"+MethodToString(InpMethod2)+"("+(string)period_2+"),"+MethodToString(InpMethod3)+"("+(string)period_3+"),"+MethodToString(InpMethod4)+"("+(string)period_4+"))");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferMA2,true);
   ArraySetAsSeries(BufferMA3,true);
   ArraySetAsSeries(BufferMA4,true);
   ArraySetAsSeries(BufferLast,true);
//--- create MA's handles
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,period_1,0,InpMethod1,InpAppliedPrice1);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_1,") by ",EnumToString(InpAppliedPrice1)," object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma2=iMA(NULL,PERIOD_CURRENT,period_2,0,InpMethod2,InpAppliedPrice2);
   if(handle_ma2==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_2,") by ",EnumToString(InpAppliedPrice2)," object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma3=iMA(NULL,PERIOD_CURRENT,period_3,0,InpMethod3,InpAppliedPrice3);
   if(handle_ma3==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_3,") by ",EnumToString(InpAppliedPrice3)," object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma4=iMA(NULL,PERIOD_CURRENT,period_4,0,InpMethod4,InpAppliedPrice4);
   if(handle_ma4==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_4,") by ",EnumToString(InpAppliedPrice4)," object was not created: Error ",GetLastError());
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
   ArraySetAsSeries(open,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferUP,EMPTY_VALUE);
      ArrayInitialize(BufferDN,EMPTY_VALUE);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferMA2,0);
      ArrayInitialize(BufferMA3,0);
      ArrayInitialize(BufferMA4,0);
      ArrayInitialize(BufferLast,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma2,0,0,count,BufferMA2);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma3,0,0,count,BufferMA3);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma4,0,0,count,BufferMA4);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferUP[i]=BufferDN[i]=EMPTY_VALUE;
      double MA1=BufferMA1[i];
      double MA2=BufferMA2[i];
      double MA3=BufferMA3[i];
      double MA4=BufferMA4[i];
      BufferLast[i]=BufferLast[i+1];
      if(MA1>MA2 && MA3>MA4 && (BufferLast[i+1]!=1 || !InpUseSwing))
        {
         BufferUP[i]=(InpUseSwing ? open[i] : ma_func(i));
         BufferLast[i]=1;
        }
      if(MA1<MA2 && MA3<MA4 && (BufferLast[i+1]!=-1 || !InpUseSwing))
        {
         BufferDN[i]=(InpUseSwing ? open[i] : ma_func(i));
         BufferLast[i]=-1;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Возвращает метод расчёта как текст                               |
//+------------------------------------------------------------------+
string MethodToString(const ENUM_MA_METHOD method)
  {
   return StringSubstr(EnumToString(method),5);
  }
//+------------------------------------------------------------------+
//| Возвращает значение МА1                                          |
//+------------------------------------------------------------------+
double MA1(const int index) { return BufferMA1[index]; }
//+------------------------------------------------------------------+
//| Возвращает значение МА2                                          |
//+------------------------------------------------------------------+
double MA2(const int index) { return BufferMA2[index]; }
//+------------------------------------------------------------------+
//| Возвращает значение МА3                                          |
//+------------------------------------------------------------------+
double MA3(const int index) { return BufferMA3[index]; }
//+------------------------------------------------------------------+
//| Возвращает значение МА4                                          |
//+------------------------------------------------------------------+
double MA4(const int index) { return BufferMA4[index]; }
//+------------------------------------------------------------------+
