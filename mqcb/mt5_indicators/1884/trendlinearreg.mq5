//+------------------------------------------------------------------+ 
//|                                               TrendLinearReg.mq5 | 
//|                               Copyright © 2008, Sergej Solujanov | 
//|                                                     irasol@bk.ru | 
//+------------------------------------------------------------------+  
#property copyright "Copyright © 2008, Sergej Solujanov"
#property link "irasol@bk.ruu" 
//---- Indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- colors of the five-color histogram are as follows
#property indicator_color1 clrRed,clrHotPink,clrGray,clrYellowGreen,clrSeaGreen
//---- Indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- indicator line width is 2
#property indicator_width1 2
//---- displaying of the the indicator label
#property indicator_label1 "TrendLinearReg"
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_ //Type of constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input uint Length=34;                           // Period of averaging
input Applied_price_ AppliedPrice=PRICE_CLOSE_; // Price constant
//+-----------------------------------+
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of dynamic arrays that will further be 
// will be used as indicator buffers
double IndBuffer[],ColorIndBuffer[];
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=int(Length);

//---- Set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- Setting a dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);

//---- Initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"TrendLinearReg( ",Length," )");
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
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
//---- Checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- Declaration of integer variables
   int first,bar;
//---- Declaring floating point variables  
   double  b,c,sumy,sumx,sumxy,sumx2,current;

//---- Initialization of the indicator in the OnCalculate() block
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      first=min_rates_total-1; // starting index for calculation of all bars
     }
   else // starting number for calculation of new bars
     {
      first=prev_calculated-1;
     }

//---- The main loop of the indicator calculation
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      sumy=0.0;
      sumx=0.0;
      sumxy=0.0;
      sumx2=0.0;

      for(int iii=0; iii<int(Length); iii++)
        {
         sumy+=PriceSeries(AppliedPrice,bar-iii,open,low,high,close);
         sumxy+=PriceSeries(AppliedPrice,bar-iii,open,low,high,close)*iii;
         sumx+=iii;
         sumx2+=iii*iii;
        }

      c=sumx2*Length-sumx*sumx;
      if(c==0) c=0.1;
      b=(sumxy*Length-sumx*sumy)/c;
      current=-1000*b;

      //---- loading the obtained values in the indicator buffer
      IndBuffer[bar]=current;
     }

   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
      first++;
//---- main cycle of the indicator coloring
   for(bar=first; bar<rates_total; bar++)
     {
      int clr=2;

      if(IndBuffer[bar]>0)
        {
         if(IndBuffer[bar]>IndBuffer[bar-1]) clr=4;
         if(IndBuffer[bar]<IndBuffer[bar-1]) clr=3;
        }

      if(IndBuffer[bar]<0)
        {
         if(IndBuffer[bar]<IndBuffer[bar-1]) clr=0;
         if(IndBuffer[bar]>IndBuffer[bar-1]) clr=1;
        }

      ColorIndBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+   
//| Getting values of a price time series                            |
//+------------------------------------------------------------------+ 
double PriceSeries(uint applied_price,  // Price constant
                   uint   bar,          // Index of shift relative to the current bar for a specified number of periods back or forward).
                   const double &Open[],
                   const double &Low[],
                   const double &High[],
                   const double &Close[])
  {
//----
   switch(applied_price)
     {
      //---- price constants from the ENUM_APPLIED_PRICE enumeration
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
      case 12:
        {
         double res=High[bar]+Low[bar]+Close[bar];

         if(Close[bar]<Open[bar]) res=(res+Low[bar])/2;
         if(Close[bar]>Open[bar]) res=(res+High[bar])/2;
         if(Close[bar]==Open[bar]) res=(res+Close[bar])/2;
         return(((res-Low[bar])+(res-High[bar]))/2);
        }
      //----
      default: return(Close[bar]);
     }
//----
  }
//+------------------------------------------------------------------+
