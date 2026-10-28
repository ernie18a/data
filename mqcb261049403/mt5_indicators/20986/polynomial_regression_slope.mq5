//+------------------------------------------------------------------+
//|                                  Polynomial_Regression_Slope.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Polynomial Regression Slope indicator"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot PRS
#property indicator_label1  "PRS"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint                 InpPeriod         =  50;            // Period
input uint                 InpPower          =  2;             // Power
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferPRS[];
double         BufferColors[];
double         BufferMA[];
//--- global variables
double         sumxvalue[];
double         sumyvalue[];
double         constant[];
double         matrix[];
int            period;
int            power;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<3 ? 3 : InpPeriod);
   power=int(InpPower<1 ? 1 : InpPower);
   ArrayResize(sumxvalue,2*power+2);
   ArrayResize(sumyvalue,power*2);
   ArrayResize(constant,power+2);
   ArrayResize(matrix,(power+2)*(power+2));
   ArrayInitialize(sumxvalue,0);
   ArrayInitialize(sumyvalue,0);
   ArrayInitialize(constant,0);
   ArrayInitialize(matrix,0);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPRS,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Polynomial Regression Slope ("+(string)period+","+(string)power+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPRS,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA's handles
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
   if(rates_total<period || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-1;
      ArrayInitialize(BufferPRS,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   double sumx=0,sumy=0,sum=0;
   double Start=0,End=0;
   int k=0;
   int initCol=0,initRow=0,j=0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      ArrayInitialize(sumxvalue,0);
      ArrayInitialize(sumyvalue,0);
      ArrayInitialize(constant,0);
      ArrayInitialize(matrix,0);

      int p=i+period-1;

      sumxvalue[0]=period;

      for(int n=1; n<=2*power; n++)
        {
         sumx=0; sumy=0;
         for(k=1; k<=period; k++)
           {
            sumx+=pow(k,n);
            sumy=(n==1 ? sumy+BufferMA[p-k+1] : sumy+BufferMA[p-k+1]*pow(k,n-1));
           }
         sumxvalue[n]=sumx;
         if(sumy!=0)
            sumyvalue[n-1]=sumy;
        }
      for(int row=0; row<=power; row++)
         for(int col=0; col<=power; col++)
            SetM(row,col,sumxvalue[row+col]);

      initCol=initRow=1;
      for(int n=1; n<=power; n++)
        {
         for(int row=initRow; row<=power; row++)
           {
            sumyvalue[row]=sumyvalue[row]-GetM(row,n-1)*sumyvalue[n-1]/GetM(n-1,n-1);
            for(int col=initCol; col<=power; col++)
               SetM(row,col,GetM(row,col)-GetM(row,n-1)*GetM(n-1,col)/GetM(n-1,n-1));
           }
         initCol++;
         initRow++;
        }

      j=0;
      for(int n=power; n>=0; n--)
        {
         if(j==0)
            constant[n]=sumyvalue[n]/GetM(n,n);
         else
           {
            sum=0;
            for(k=j;k>=1;k--)
               sum=sum+constant[n+k]*GetM(n,n+k);
            constant[n]=(sumyvalue[n]-sum)/GetM(n,n);
           }
         j++;
        }

      k=1;
      for(int n=i+period-1; n>=i; n--)
        {
         sum=0;
         for(j=0; j<=power; j++)
            sum=sum+constant[j]*pow(k,j);
         if(n==i+period-1)
            Start=sum;
         k++;
        }
      End=sum;
      BufferPRS[i]=(End-Start)/Point();
      BufferColors[i]=(BufferPRS[i]<BufferPRS[i+1] ? 1 : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetM(int col,int row)
  {
   return (matrix[col*(power+1)+row]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetM(int col,int row,double val)
  {
   matrix[col*(power+1)+row]=val;
  }
//+------------------------------------------------------------------+
