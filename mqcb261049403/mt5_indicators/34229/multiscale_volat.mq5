//+------------------------------------------------------------------+
//|                                            multi_scale_volat.mq5 |
//|                                     Copyright 2021, Yossy Nakata |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Yossy Nakata"
#property link      "https://www.mql5.com/ja/users/yossy_nkt"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers    15
#property indicator_plots   8

#property indicator_label1  "Multi-scale volatility"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_width1  3

#property indicator_label2  "lag-3"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_width2  1

#property indicator_label3  "lag-4"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkOrange
#property indicator_width3  1

#property indicator_label4  "lag-5"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDarkGoldenrod
#property indicator_width4  1

#property indicator_label5  "lag-6"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGreen
#property indicator_width5  1

#property indicator_label6  "lag-8"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrTurquoise
#property indicator_width6  1

#property indicator_label7  "lag-10"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrDodgerBlue
#property indicator_width7  1

#property indicator_label8  "lag-13"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrBlue
#property indicator_width8  1

//--- input parameter
input int InpPeriod=14; // Smoothing Period
//--- buffers

double df3[];
double df4[];
double df5[];
double df6[];
double df8[];
double df10[];
double df13[];

double adf3[];
double adf4[];
double adf5[];
double adf6[];
double adf8[];
double adf10[];
double adf13[];

double adf[];

const double Alpha=2.0/(InpPeriod+1.0);
const double Sqrt3=sqrt(3);
const double Sqrt4=sqrt(4);
const double Sqrt5=sqrt(5);
const double Sqrt6=sqrt(6);
const double Sqrt8=sqrt(8);
const double Sqrt10=sqrt(10);
const double Sqrt13=sqrt(13);


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping   
   SetIndexBuffer(0,adf,INDICATOR_DATA);
   SetIndexBuffer(1,adf3,INDICATOR_DATA);
   SetIndexBuffer(2,adf4,INDICATOR_DATA);
   SetIndexBuffer(3,adf5,INDICATOR_DATA);
   SetIndexBuffer(4,adf6,INDICATOR_DATA);
   SetIndexBuffer(5,adf8,INDICATOR_DATA);
   SetIndexBuffer(6,adf10,INDICATOR_DATA);
   SetIndexBuffer(7,adf13,INDICATOR_DATA);
   SetIndexBuffer(8,df3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,df4,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,df5,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,df6,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,df8,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,df10,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,df13,INDICATOR_CALCULATIONS);

   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(8,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(9,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(10,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(11,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(12,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(13,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(14,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
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
  
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      // initialize
      ArrayInitialize(adf,EMPTY_VALUE);
      ArrayInitialize(adf3,EMPTY_VALUE);
      ArrayInitialize(adf4,EMPTY_VALUE);
      ArrayInitialize(adf5,EMPTY_VALUE);
      ArrayInitialize(adf6,EMPTY_VALUE);
      ArrayInitialize(adf8,EMPTY_VALUE);
      ArrayInitialize(adf10,EMPTY_VALUE);
      ArrayInitialize(adf13,EMPTY_VALUE);
      ArrayInitialize(df3,EMPTY_VALUE);
      ArrayInitialize(df4,EMPTY_VALUE);
      ArrayInitialize(df5,EMPTY_VALUE);
      ArrayInitialize(df6,EMPTY_VALUE);
      ArrayInitialize(df8,EMPTY_VALUE);
      ArrayInitialize(df10,EMPTY_VALUE);
      ArrayInitialize(df13,EMPTY_VALUE);
     }

//--- 
   int    i,pos;
   pos=(int)MathMax(prev_calculated-1,0);
//--- the main loop of calculations
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      //---  calcurate Absolute value of lag(3-13)
      diff(i,3,Sqrt3,close,df3);
      diff(i,4,Sqrt4,close,df4);
      diff(i,5,Sqrt5,close,df5);
      diff(i,6,Sqrt6,close,df6);
      diff(i,8,Sqrt8,close,df8);
      diff(i,10,Sqrt10,close,df10);
      diff(i,13,Sqrt13,close,df13);
      if(i>2)
        {
        //---  calcurate EMA
         double total=0.0;
         int n=0;
         ema(i,Alpha,df3,adf3);
         ema(i,Alpha,df4,adf4);
         ema(i,Alpha,df5,adf5);
         ema(i,Alpha,df6,adf6);
         ema(i,Alpha,df8,adf8);
         ema(i,Alpha,df10,adf10);
         ema(i,Alpha,df13,adf13);
        }
        
      if (i>InpPeriod+13){
         //--- calcurate averages 
         double total=adf3[i]+adf4[i]+adf5[i]+adf6[i]+adf8[i]+adf10[i]+adf13[i];
         adf[i]=total/7.0;
     
      }else{
         adf[i]=EMPTY_VALUE;      
      }   
     }
  
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|calcurate Absolute value of lag N                                                                  |
//+------------------------------------------------------------------+
void diff(const int i,const int lag,const double w, const double &close[],double &buf[])
  {
   if(i<=lag)
     {
      buf[i]=EMPTY_VALUE;
     }
   else
     {
      buf[i]=MathAbs(close[i-lag]-close[i])/w;
//      buf[i]=MathAbs(close[i-lag]-close[i])/(double)lag;
     }
  }
//+------------------------------------------------------------------+
//|calcurate EMA                                                                  |
//+------------------------------------------------------------------+
void ema(const int i, const double alpha,const double &buf[],double &ema[])
  {
   if(buf[i-1]!=EMPTY_VALUE && buf[i]!=EMPTY_VALUE)
     {
      if(ema[i-1]==EMPTY_VALUE)
        {
         ema[i-1]=buf[i-1];
        }
      ema[i]=alpha*buf[i]+(1.0-alpha)*ema[i-1];
     }
   else
     {
      ema[i]=EMPTY_VALUE;
     }
  }
//+------------------------------------------------------------------+

