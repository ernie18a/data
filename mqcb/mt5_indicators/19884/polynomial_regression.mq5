//+------------------------------------------------------------------+
//|                                        Polynomial_Regression.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   3
//--- plot Regression
#property indicator_label1  "Regression"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot BandUP
#property indicator_label2  "Band Up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot BandDN
#property indicator_label3  "Band Down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLimeGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint                 InpLength         =  50;            // Length
input uint                 InpPower          =  2;             // Power
input double               InpDeviation      =  1.0;           // Deviation
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferRegression[];
double         BufferBandUP[];
double         BufferBandDN[];
double         BufferMA[];
//--- global variables
int            handle_ma;
int            length;
int            power;
double         deviation;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   length=int(InpLength<5 ? 5 : InpLength);
   power=int(InpPower>9 ? 9 : InpPower);
   deviation=(InpDeviation<0.01 ? 0.01 : InpDeviation);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferRegression,INDICATOR_DATA);
   SetIndexBuffer(1,BufferBandUP,INDICATOR_DATA);
   SetIndexBuffer(2,BufferBandDN,INDICATOR_DATA);
   SetIndexBuffer(3,BufferMA,INDICATOR_CALCULATIONS);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRegression,true);
   ArraySetAsSeries(BufferBandUP,true);
   ArraySetAsSeries(BufferBandDN,true);
   ArraySetAsSeries(BufferMA,true);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Polynomial regression("+(string)length+","+(string)power+","+DoubleToString(deviation,2)+")");
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
      limit=length-1;
      ArrayInitialize(BufferRegression,EMPTY_VALUE);
      ArrayInitialize(BufferBandUP,EMPTY_VALUE);
      ArrayInitialize(BufferBandDN,EMPTY_VALUE);
      ArrayInitialize(BufferMA,EMPTY_VALUE);
     }
//--- Подготовка данных
   int count=(limit==0 ? 1 : length);
   int copied_ma=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied_ma!=count) return 0;
   double summ_x_value[21],summ_y_value[11],constant[11],matrix[11][11];
   ArrayInitialize(summ_x_value,0);
   ArrayInitialize(summ_y_value,0);
   ArrayInitialize(constant,0);
   ArrayInitialize(matrix,0);

   double summ=0,summ_x=0,summ_y=0;
   int pos=length-1;
   summ_x_value[0]=length;
   for(int exp_n=1; exp_n<=2*power; exp_n++)
     {
      summ_x=0;
      summ_y=0;
      for(int k=1; k<=length; k++)
        {
         summ_x+=MathPow(k,exp_n);
         if(exp_n==1)
            summ_y+=BufferMA[pos-k+1];
         else if(exp_n<=power+1)
                        summ_y+=BufferMA[pos-k+1]*MathPow(k,exp_n-1);
        }
      summ_x_value[exp_n]=summ_x;
      if(summ_y!=0)
         summ_y_value[exp_n-1]=summ_y;
     }

   for(int row=0; row<=power; row++)
      for(int col=0; col<=power; col++)
         matrix[row][col]=summ_x_value[row+col];

   int initial_row=1;
   int initial_col=1;
   for(int i=1; i<=power; i++)
     {
      for(int row=initial_row; row<=power; row++)
        {
         summ_y_value[row]=summ_y_value[row]-(matrix[row][i-1]/matrix[i-1][i-1])*summ_y_value[i-1];
         for(int col=initial_col; col<=power; col++)
            matrix[row][col]=matrix[row][col]-(matrix[row][i-1]/matrix[i-1][i-1])*matrix[i-1][col];
        }
      initial_col++;
      initial_row++;
     }
   int j=0;
   for(int i=power; i>=0; i--)
     {
      if(j==0)
         constant[i]=summ_y_value[i]/matrix[i][i];
      else
        {
         summ=0;
         for(int k=j; k>=1; k--)
            summ+=constant[i+k]*matrix[i][i+k];
         constant[i]=(summ_y_value[i]-summ)/matrix[i][i];
        }
      j++;
     }
   int k=1;
   for(int i=length-1; i>=0; i--)
     {
      summ=0;
      for(int n=0; n<=power; n++)
         summ+=constant[n]*MathPow(k,n);
      BufferRegression[i]=summ;
      k++;
     }
//--- Расчёт индикатора
   BufferRegression[length]=EMPTY_VALUE;
   summ=0;
   for(int i=length-1; i>=0; i--)
      summ+=MathPow(BufferMA[i]-BufferRegression[i],2);
   double variance=MathSqrt(summ/length);
   for(int i=length-1; i>=0; i--)
     {
      BufferBandUP[i]=BufferRegression[i]+deviation*variance;
      BufferBandDN[i]=BufferRegression[i]-deviation*variance;
     }
   BufferBandUP[length]=EMPTY_VALUE;
   BufferBandDN[length]=EMPTY_VALUE;

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
