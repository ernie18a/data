//+------------------------------------------------------------------+
//|                                              XLineRegression.mq5 | 
//|                                  Copyright © 2012, Ivan Kornilov | 
//|                                                 excelf@gmail.com | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Ivan Kornilov"
#property link "excelf@gmail.com"
#property description ""
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers 8
#property indicator_buffers 8 
//---- Only 8 graphical plots are used
#property indicator_plots   8
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+--------------------------------------------+
//|  Levels drawing parameters                 |
//+--------------------------------------------+
//---- drawing the levels as lines
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
#property indicator_type8   DRAW_LINE
//---- selection of levels colors
#property indicator_color1  DarkSlateGray
#property indicator_color2  Purple
#property indicator_color3  Red
#property indicator_color4  Blue
#property indicator_color5  Blue
#property indicator_color6  Red
#property indicator_color7  Purple
#property indicator_color8  DarkSlateGray
//---- levels are dott-dash curves
#property indicator_style1 STYLE_DASHDOTDOT
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_DASHDOTDOT
#property indicator_style4 STYLE_DASHDOTDOT
#property indicator_style5 STYLE_DASHDOTDOT
#property indicator_style6 STYLE_DASHDOTDOT
#property indicator_style7 STYLE_DASHDOTDOT
#property indicator_style8 STYLE_DASHDOTDOT
//---- Bollinger Bands width is equal to 1
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  1
#property indicator_width6  1
#property indicator_width7  1
#property indicator_width8  1
//---- display the labels of Bollinger Bands levels
#property indicator_label2  "+4Sigma"
#property indicator_label3  "+3Sigma"
#property indicator_label4  "+2Sigma"
#property indicator_label5  "+1Sigma"
#property indicator_label6  "-1Sigma"
#property indicator_label7  "-2Sigma"
#property indicator_label8  "-3Sigma"
#property indicator_label9  "-4Sigma"
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_ //Type od constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
//+-----------------------------------+
//|  Input parameters of the indicator|
//+-----------------------------------+
input int days=90; // number of days for average
input int period1 = 40; // period of the linear regression
input double step = 0.3; // step between the lines
input int degree=1; // regression degree
input Applied_price_ price=PRICE_CLOSE;//price constant
/* , used for calculation of the indicator ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of dynamic arrays that further 
//---- will be used as Bollinger Bands indicator buffers
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[],ExtLineBuffer4[];
double ExtLineBuffer5[],ExtLineBuffer6[],ExtLineBuffer7[],ExtLineBuffer8[];

//---- Declaration of variables
ENUM_TIMEFRAMES myPeriod=PERIOD_D1;
double a[10][10];
double b[10];
double x[10];
double sx[20];
int period;
double avgDayRange;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//----Declaration of variables for storing the indicators handles
int SMA_Handle,LWMA_Handle;
//+------------------------------------------------------------------+   
//| Regression indicator initialization function                     | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables
   period=period1*50*5*60/PeriodSeconds();
   
//---- Initialization of variables of the start of data calculation
   min_rates_total=period+1;

//---- obtaining the indicators handles  
   LWMA_Handle=iMA(NULL,0,period,0,MODE_LWMA,price);
   if(LWMA_Handle==INVALID_HANDLE)Print(" Failed to get handle of the LWMA indicator");
   SMA_Handle=iMA(NULL,0,period,0,MODE_SMA,price);
   if(SMA_Handle==INVALID_HANDLE)Print(" Failed to get handle of the SMA indicator");

//---- set dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLineBuffer5,INDICATOR_DATA);
   SetIndexBuffer(5,ExtLineBuffer6,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer7,INDICATOR_DATA);
   SetIndexBuffer(7,ExtLineBuffer8,INDICATOR_DATA);
//---- set the position, from which the levels drawing starts
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,min_rates_total);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);
   ArraySetAsSeries(ExtLineBuffer3,true);
   ArraySetAsSeries(ExtLineBuffer4,true);
   ArraySetAsSeries(ExtLineBuffer5,true);
   ArraySetAsSeries(ExtLineBuffer6,true);
   ArraySetAsSeries(ExtLineBuffer7,true);
   ArraySetAsSeries(ExtLineBuffer8,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"XLinesReg(",days,", ",period1,", ",step,", ",EnumToString(price),")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+ 
//| Regression iteration function                                    | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(SMA_Handle)<rates_total
      || BarsCalculated(LWMA_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);
//---- declaration of local variables 
   int limit,bar;
   double PP;

//--- calculations of the necessary amount of data to be copied and
//----the limit starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars

      double summ=0;
      for(int i=days-1; i>=0; i--)
        {
         double O[1],C[1];
         //--- copy newly appeared data in the array  
         if(CopyOpen(Symbol(),myPeriod,i,1,O)<=0) return(RESET);
         if(CopyClose(Symbol(),myPeriod,i,1,C)<=0) return(RESET);
         summ+=MathAbs(C[0]-O[0]);
        }
      avgDayRange=summ/days;
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars 

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);

//---- first indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(degree==1) PP=regression_LRMA(bar);
      else if(degree==2) PP=regression_QRMA(bar,open,low,high,close);
      else PP=regressionPolynomial(bar,open,low,high,close);
      
      if(PP==EMPTY_VALUE)  return(RESET);

      ExtLineBuffer1[bar]=PP + (avgDayRange * step * 4);
      ExtLineBuffer2[bar]=PP + (avgDayRange * step * 3);
      ExtLineBuffer3[bar]=PP + (avgDayRange * step * 2);
      ExtLineBuffer4[bar]=PP + (avgDayRange * step * 1);
      ExtLineBuffer5[bar]=PP - (avgDayRange * step * 1);
      ExtLineBuffer6[bar]=PP - (avgDayRange * step * 2);
      ExtLineBuffer7[bar]=PP - (avgDayRange * step * 3);
      ExtLineBuffer8[bar]=PP - (avgDayRange * step * 4);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+  
//| PriceSeries() function                                           |
//+------------------------------------------------------------------+
double PriceSeries
(
 uint applied_price,// Price constant
 uint   bar, // Index of shift relative to the current bar for a specified number of periods back or forward).
 const double &Open[],
 const double &Low[],
 const double &High[],
 const double &Close[]
 )
//PriceSeries(applied_price, bar, open, low, high, close)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   switch(applied_price)
     {
      //---- Price constants from the ENUM_APPLIED_PRICE enumeration
      case  PRICE_CLOSE: return(Close[bar]);
      case  PRICE_OPEN: return(Open [bar]);
      case  PRICE_HIGH: return(High [bar]);
      case  PRICE_LOW: return(Low[bar]);
      case  PRICE_MEDIAN: return((High[bar]+Low[bar])/2.0);
      case  PRICE_TYPICAL: return((Close[bar]+High[bar]+Low[bar])/3.0);
      case  PRICE_WEIGHTED: return((2*Close[bar]+High[bar]+Low[bar])/4.0);

      //----                            
      case  8: return((Open[bar] + Close[bar])/2.0);
      case  9: return((Open[bar] + Close[bar] + High[bar] + Low[bar])/4.0);
      //----                                
      case 10:
        {
         if(Close[bar]>Open[bar])return(High[bar]);
         else
           {
            if(Close[bar]<Open[bar])
               return(Low[bar]);
            else return(Close[bar]);
           }
        }
      //----         
      case 11:
        {
         if(Close[bar]>Open[bar])return((High[bar]+Close[bar])/2.0);
         else
           {
            if(Close[bar]<Open[bar])
               return((Low[bar]+Close[bar])/2.0);
            else return(Close[bar]);
           }
         break;
        }
      //----
      default: return(Close[bar]);
     }
//----
//return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
double ma_qwma(int shift,const double &Open[],const double &Low[],const double &High[],const double &Close[])
  {
//----
   double sum=0;
   int j,i;
   for(j=shift,i=1; j<shift+period; j++,i++) sum+=PriceSeries(price,j,Open,Low,High,Close)*MathPow(period-i+1,2);
   double value=6.0/(period *(period+1) *(2*period+1));
//----
   return(value*sum);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
double regression_QRMA(int shift,const double &Open[],const double &Low[],const double &High[],const double &Close[])
  {
//----
   double sma[1],lwma[1];
//---- copy newly appeared data into the arrays
   if(CopyBuffer(SMA_Handle,0,shift,1,sma)<=0) return(EMPTY_VALUE);
   if(CopyBuffer(LWMA_Handle,0,shift,1,lwma)<=0) return(EMPTY_VALUE);

   double qwma=ma_qwma(shift,Open,Low,High,Close);
   double value=3.0*sma[0]+qwma *(10-15/(period+2))-lwma[0]*(12-15/(period+2));
//----
   return(value);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
double regressionPolynomial(int shift,const double &Open[],const double &Low[],const double &High[],const double &Close[])
  {
//----
   sx[1]=period+1;
   int degree1=degree+1;

   int max=degree1*2-2;
   for(int i=1; i<=max; i++)
     {
      sx[i+1]=0;
      for(int n=0;n<=period; n++) sx[i+1]+=MathPow(n,i);
     }
   double t;
   for(int i=1; i<=degree1; i++)
     {
      b[i]=0;
      for(int n=0; n<=period; n++)
        {
         if(i==1) b[i]+=PriceSeries(price,n+shift,Open,Low,High,Close);
         else b[i]+=PriceSeries(price,n+shift,Open,Low,High,Close)*MathPow(n,i-1);
        }
     }

   for(int j=1;j<=degree1; j++)
     {
      for(int i=1; i<=degree1; i++)
        {
         int k=i+j-1;
         a[i][j]=sx[k];
        }
     }

   for(int k=1; k<=degree1-1; k++)
     {
      int l=0;
      double mm=0;
      for(int i=k; i<=degree1; i++)
        {
         if(MathAbs(a[i][k])>mm)
           {
            mm= MathAbs(a[i][k]);
            l = i;
           }
        }
      if(l==0) return(0);

      if(l!=k)
        {
         for(int j=1; j<=degree1; j++)
           {
            t=a[k][j];
            a[k][j] = a[l][j];
            a[l][j] = t;
           }
         t=b[k];
         b[k] = b[l];
         b[l] = t;
        }
      double div=0;
      for(int i=k+1;i<=degree1; i++)
        {
         div=a[i][k]/a[k][k];
         for(int j=1;j<=degree1; j++)
           {
            if(j==k) a[i][j]=0;
            else a[i][j]=a[i][j]-div*a[k][j];
           }

         b[i]=b[i]-div*b[k];
        }
     }

   x[degree1]=b[degree1]/a[degree1][degree1];
   for(int i=degree; i>=1; i--)
     {
      t=0;
      for(int j=1; j<=degree1-i; j++)
        {
         t+=a[i][i+j]*x[i+j];
         x[i]=(1/a[i][i]) *(b[i]-t);
        }
     }

   double value=x[1];
   for(int i=1; i<=degree; i++) value+=x[i+1]*MathPow(period,i);
//----
   return(value);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
double regression_LRMA(int shift)
  {
//----
   double sma[1],lwma[1];
//---- copy newly appeared data into the arrays
   if(CopyBuffer(SMA_Handle,0,shift,1,sma)<=0) return(EMPTY_VALUE);
   if(CopyBuffer(LWMA_Handle,0,shift,1,lwma)<=0) return(EMPTY_VALUE);
//----   
   return(3*lwma[0]-2*sma[0]);
  }
//+------------------------------------------------------------------+
