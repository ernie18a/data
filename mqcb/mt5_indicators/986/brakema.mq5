//+------------------------------------------------------------------+
//|                                                      BrakeMA.mq5 |
//|                                  Copyright © 2012, Ivan Kornilov | 
//|                                                 excelf@gmail.com | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Ivan Kornilov"
#property link "excelf@gmail.com"
#property description ""
//---- indicator version number
#property version   "1.10"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//----five buffers are used for calculation of drawing of the indicator
#property indicator_buffers 5
//---- four plots are used in total
#property indicator_plots   4
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- DodgerBlue color is used for the indicator
#property indicator_color1  DodgerBlue
//---- indicator 1 width is equal to 1
#property indicator_width1  1
//---- displaying of the bullish label of the indicator
#property indicator_label1  "Lower BrakeMA"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- Magenta color is used for the indicator
#property indicator_color2  Magenta
//---- indicator 2 width is equal to 1
#property indicator_width2  1
//---- displaying of the bearish label of the indicator
#property indicator_label2 "Upper BrakeMA"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator 3 as a symbol
#property indicator_type3   DRAW_ARROW
//---- DodgerBlue color is used for the indicator
#property indicator_color3  DodgerBlue
//---- indicator 3 width is equal to 4
#property indicator_width3  4
//---- displaying of the bullish label of the indicator
#property indicator_label3  "BrakeMA Buy"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator 4 as a symbol
#property indicator_type4   DRAW_ARROW
//---- Magenta color is used for the indicator
#property indicator_color4  Magenta
//---- indicator 4 width is equal to 4
#property indicator_width4  4
//---- displaying of the bearish label of the indicator
#property indicator_label4 "BrakeMA Sell"
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int       ma = 34;
input double speed = 0.00;
input ENUM_MA_METHOD maType=MODE_LWMA;
//+----------------------------------------------+
double maxPrice_,minPrice_,beginPrice_;
bool isLong_;
int beginBar_;
//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double MABuffer[];
double BuyBuffer[],SellBuffer[];
double UpBuffer[],DnBuffer[];
//---- declaration of the integer variables for the start of data calculation
int  min_rates_total;
//----Declaration of variables for storing the indicators handles
int MA_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Initialization of variables    
   min_rates_total=ma+2;
   MA_Handle=iMA(NULL,0,ma,0,maType,PRICE_CLOSE);
   if(MA_Handle==INVALID_HANDLE)Print(" Failed to get handle of the MA indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,158);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(UpBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- shifting the beginning of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,158);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(DnBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,SellBuffer,INDICATOR_DATA);
//---- shifting the beginning of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,174);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SellBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(3,BuyBuffer,INDICATOR_DATA);
//---- shifting the beginning of drawing of the indicator 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,174);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(BuyBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(4,MABuffer,INDICATOR_CALCULATIONS);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(MABuffer,true);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="BrakeMA";
   short_name="BrakeMa("+string(ma)+","+EnumToString(maType)+")";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate
(const int rates_total,
 const int prev_calculated,
 const datetime &Time[],
 const double &Open[],
 const double &High[],
 const double &Low[],
 const double &Close[],
 const long &Tick_Volume[],
 const long &Volume[],
 const int &Spread[]
 )
  {
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(MA_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int to_copy,limit,bar,maxbar;
   double maxPrice,minPrice,beginPrice;
   bool isLong;
   int beginBar;

   maxbar=rates_total-min_rates_total-1;

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);

//--- calculations of the necessary amount of data to be copied and
//----the limit starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=maxbar; // starting index for calculation of all bars
      maxPrice_=-999999;
      minPrice_=+999999;
      beginBar_=0;
      beginPrice_=Low[limit];
      isLong_=true;
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars
//----
   beginBar=beginBar_+limit;
   if(beginBar>maxbar)
     {
      limit=maxbar; // starting index for calculation of all bars
      maxPrice_=-999999;
      minPrice_=+999999;
      beginBar_=0;
      beginPrice_=Low[limit];
      isLong_=true;
     }
//----   
   to_copy=limit+1;
   isLong=isLong_;
   maxPrice=maxPrice_;
   minPrice=minPrice_;
   beginPrice=beginPrice_;

   if(prev_calculated>rates_total || prev_calculated<=0) to_copy++;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(MA_Handle,0,0,to_copy,MABuffer)<=0) return(RESET);

//---- first indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(maxPrice < High[bar]) maxPrice = High[bar];
      if(minPrice > Low[bar])  minPrice = Low[bar];

      double value,move;
      double maShift=MABuffer[beginBar]-beginPrice;

      if(isLong)
        {
         if(MABuffer[bar+1]>MABuffer[bar])
           {
            move=(MABuffer[bar+1]-MABuffer[bar])*speed;
            value=MABuffer[bar+1]+move-maShift;
            beginPrice+=move;
            MABuffer[bar]=MABuffer[bar+1];
           }
         else value=MABuffer[bar]-maShift;
        }
      else
        {
         if(MABuffer[bar+1]<MABuffer[bar])
           {
            move=(MABuffer[bar]-MABuffer[bar+1])*speed;
            value=MABuffer[bar+1]-move-maShift;
            beginPrice-=move;
            MABuffer[bar]=MABuffer[bar+1];
           }
         else value=MABuffer[bar]-maShift;
        }

      if(isLong && value>Low[bar])
        {
         isLong=false;
         beginPrice=maxPrice;
         value=beginPrice;
         beginBar=bar;
         maxPrice = -999999;
         minPrice = +999999;
        }
      else
      if(!isLong && value<High[bar])
        {
         isLong=true;
         beginPrice=minPrice;
         value=beginPrice;
         beginBar=bar;
         maxPrice = -999999;
         minPrice = +999999;
        }

      if(isLong)
        {
         UpBuffer[bar]=value;
         DnBuffer[bar]=0;
        }
      else
        {
         UpBuffer[bar]=0;
         DnBuffer[bar]=value;
        }

      if(bar==1)
        {
         isLong_=isLong;
         maxPrice_=maxPrice;
         minPrice_=minPrice;
         beginPrice_=beginPrice;
         beginBar_=beginBar;
        }
     }

//---- recalculation of the starting index for calculation of all bars
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator     
      limit--;

//---- the second indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- zero out the contents of the indicator buffers for calculation
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;

      if(UpBuffer[bar+1]>0.0&&DnBuffer[bar]>0.0) BuyBuffer [bar]=DnBuffer[bar];
      if(DnBuffer[bar+1]>0.0&&UpBuffer[bar]>0.0) SellBuffer[bar]=UpBuffer[bar];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
