//+------------------------------------------------------------------+
//|                                                    RocketRSI.mq5 |
//|                                  Copyright 2018, Samuel Williams |
//|                          https://www.mql5.com/en/users/sambo3261 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Samuel Williams"
#property link      "https://www.mql5.com/en/users/sambo3261"
#property description "swilliamsforex@gmail.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_maximum 4
#property indicator_minimum -4

//--- plot RocketRSI
#property indicator_label1  "RocketRSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- input parameters
 
input int      RSILength=10; //Period of the RSI indicator - Needs to be half the dominant cycle
input int      Smooth=10; //Smoothing of the indictor - not set above RSILength 
//--- indicator buffers
double         RSIBuffer[];
double         RocketRSIBuffer[];
double         RSITestBuffer[];
double         Filter[];
double         Mom[];
//Filter coefficiants once here 
double         a1,b1,c1,c2,c3;

int            rsiHandle=0;
//---

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,RocketRSIBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,RSIBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,Filter,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,Mom,INDICATOR_CALCULATIONS);
   rsiHandle=iRSI(_Symbol,_Period,RSILength,PRICE_CLOSE);
   if(rsiHandle==INVALID_HANDLE) PrintFormat("Failed to get handle of RSI indicator, code: %d",GetLastError());
//---Compute filter coefficiants once here
   double rad=M_PI/180;
   a1=MathExp((-1.414*M_PI/Smooth));
   b1=2*a1*MathCos((1.414*180/Smooth)*rad);
   c2=b1;
   c3=-a1*a1;
   c1=1-c2-c3;


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
//---
   if(CopyBuffer(rsiHandle,0,0,rates_total,RSIBuffer)<0) PrintFormat("Error copying rsi data from handle, code: %d",GetLastError());
   int i=(int)MathMax(prev_calculated-1,RSILength+1); for(; i<rates_total && !_StopFlag; i++)
     {
      //RSITestBuffer[i]=RSIBuffer[i];
      double CU =0;
      double CD =0;
      //---Half dominant cycle momentum 
      Mom[i]=close[i]-close[i-(RSILength+1)];
      //---Super smoother filter
      Filter[i]=c1*((Mom[i]+Mom[i-1])/2)+c2*Filter[i-1]+c3*Filter[i-2];
      int j=i-(RSILength+1); for(;j<i;j++)
        {
         if(Filter[j]-Filter[j+1]>0) CU=CU+Filter[j]-Filter[j+1];
         if(Filter[j]-Filter[j+1]<0) CD=CD+Filter[j+1]-Filter[j];

        }
      double MyRSI=0.0;
      double denom= CU+CD;
      if(denom==0)denom=-1;
      if(CU+CD!=0)MyRSI=(CU-CD)/denom;
      if(denom==-1)MyRSI=50;
      //---Limit Rocket RSI output to +- 3 standard deviations 
      if(MyRSI>.999)MyRSI=.999;
      if(MyRSI<-.999)MyRSI=-.999;

      //---Apply Fisher transform to establish Gaussian Probability Distribution 
      RocketRSIBuffer[i]=0.5*MathLog((1+MyRSI)/(1-MyRSI));

     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
