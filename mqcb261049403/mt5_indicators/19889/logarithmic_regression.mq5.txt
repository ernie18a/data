//+------------------------------------------------------------------+
//|                                       Logarithmic_Regression.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   3
//--- plot Upper
#property indicator_label1  "Upper"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Middle
#property indicator_label2  "Middle"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Lower
#property indicator_label3  "Lower"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint                 InpLength         =  50;            // Length
input double               InpDeviation      =  1.0;           // Deviation
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferUpper[];
double         BufferMiddle[];
double         BufferLower[];
double         BufferMA[];
//--- global variables
int            handle_ma;
int            length;
double         deviation;
double         summ_y_value[4],
constant[4],
matrix[4][4],
summ_x_value[8];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   length=int(InpLength<3 ? 3 : InpLength);
   deviation=(InpDeviation<0.01 ? 0.01 : InpDeviation);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUpper,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMiddle,INDICATOR_DATA);
   SetIndexBuffer(2,BufferLower,INDICATOR_DATA);
   SetIndexBuffer(3,BufferMA,INDICATOR_CALCULATIONS);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUpper,true);
   ArraySetAsSeries(BufferMiddle,true);
   ArraySetAsSeries(BufferLower,true);
   ArraySetAsSeries(BufferMA,true);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Logarithmic Regression("+(string)length+","+DoubleToString(deviation,2)+")");
//--- create MA's handle
   ResetLastError();
   handle_ma=iMA(Symbol(),PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA object was not created: Error ",GetLastError());
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
//--- Проверка на минимальное количество баров для расчёта
   if(rates_total<length) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferUpper,EMPTY_VALUE);
      ArrayInitialize(BufferMiddle,EMPTY_VALUE);
      ArrayInitialize(BufferLower,EMPTY_VALUE);
      ArrayInitialize(BufferMA,EMPTY_VALUE);
     }
//--- Подготовка данных
   int count=(limit==0 ? 1 : rates_total);
   int copied_ma=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied_ma!=count) return 0;

   ArrayInitialize(summ_x_value,0);
   ArrayInitialize(summ_y_value,0);
   ArrayInitialize(constant,0);
   ArrayInitialize(matrix,0);

   double summ_x=0,summ_y=0,summ=0;
   summ_x_value[0]=length;
   for(int exp_n=1; exp_n<=2; exp_n++)
     {
      summ_x=0;
      summ_y=0;
      for(int k=1; k<=length; k++)
        {
         double lnx=MathLog(k);
         summ_x+=MathPow(lnx,exp_n);
         if(exp_n==1)
            summ_y+=MathLog(BufferMA[length-k]);
         else
            summ_y+=MathLog(BufferMA[length-k])*MathPow(lnx,exp_n-1);
        }
      summ_x_value[exp_n]=summ_x;
      if(summ_y!=0)
         summ_y_value[exp_n-1]=summ_y;
     }

   for(int row=0; row<=1; row++)
      for(int col=0; col<=1; col++)
         matrix[row][col]=summ_x_value[row+col];
//---
   summ_y_value[1]=summ_y_value[1]-(matrix[1][0]/matrix[0][0])*summ_y_value[0];
   matrix[1][1]=matrix[1][1]-(matrix[1][0]/matrix[0][0])*matrix[0][1];

   constant[1]=summ_y_value[1]/matrix[1][1];
   double a=(summ_y_value[0]-constant[1]*matrix[0][1])/matrix[0][0];
   constant[0]=MathExp(a);
//--- Расчёт индикатора
   int k=1;
   summ=0;
   for(int i=length-1;i>=0;i--)
     {
      BufferMiddle[i]=constant[0]*MathPow(k,constant[1]);
      summ+=MathPow(BufferMA[i]-BufferMiddle[i],2);
      k++;
     }
   BufferMiddle[length]=EMPTY_VALUE;

   double variance=MathSqrt(summ/length);
   for(int i=length-1; i>=0; i--)
     {
      BufferUpper[i]=BufferMiddle[i]+deviation*variance;
      BufferLower[i]=BufferMiddle[i]-deviation*variance;
     }
   BufferUpper[length]=EMPTY_VALUE;
   BufferLower[length]=EMPTY_VALUE;
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
