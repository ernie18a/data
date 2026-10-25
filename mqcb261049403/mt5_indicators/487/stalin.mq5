//+------------------------------------------------------------------+
//|                                                       Stalin.mq5 |
//|                   Copyright © 2011, Andrey Vassiliev (MoneyJinn) |
//|                                         http://www.vassiliev.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Andrey Vassiliev (MoneyJinn)"
#property link      "http://www.vassiliev.ru/"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- LightPink color is used as the color of the bearish indicator line
#property indicator_color1  LightPink
//---- thickness of the indicator 1 line is equal to 4
#property indicator_width1  4
//---- bullish indicator label display
#property indicator_label1  "Silver Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a symbol
#property indicator_type2   DRAW_ARROW
//---- light sky blue color is used as the color of a bullish indicator line
#property indicator_color2  LightSkyBlue
//---- thickness of the indicator 2 line is equal to 4
#property indicator_width2  4
//---- bearish indicator label display
#property indicator_label2 "Silver Buy"

//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input ENUM_MA_METHOD MAMethod=MODE_EMA;
input int    MAShift=0;
input int    Fast=14;
input int    Slow=21;
input int    RSI=17;
input double Confirm=0.0;
input double Flat=0.0;
input bool   SoundAlert=false;
input bool   EmailAlert=false;
//+----------------------------------------------+

//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
//----
double IUP,IDN,E1,E2,Confirm2,Flat2;
//---- declaration of the integer variables for the start of data calculation
int StartBars;
//---- declaration of variables for storing the indicators handles
int SLMA_Handle,FSMA_Handle,RSI_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void BU(int i,const double &Low[],const datetime &Time[])
  {
//----
   if(Low[i]>=(E1+Flat2*_Point) || Low[i]<=(E1-Flat2*_Point))
     {
      BuyBuffer[i]=Low[i];
      E1=BuyBuffer[i];
      Alerts(i,"UP "+Symbol()+" "+TimeToString(Time[i]));
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void BD(int i,const double &High[],const datetime &Time[])
  {
//----
   if(High[i]>=(E2+Flat2*_Point) || High[i]<=(E2-Flat2*_Point))
     {
      SellBuffer[i]=High[i];
      E2=SellBuffer[i];
      Alerts(i,"DN "+Symbol()+" "+TimeToString(Time[i]));
     }
//---- 
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void Alerts(int pos,string txt)
  {
//----
   if(SoundAlert==true&&pos==1){PlaySound("alert.wav");}
   if(EmailAlert==true&&pos==1){SendMail("Stalin alert signal: "+txt,txt);}
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   StartBars=MathMax(RSI,MathMax(Slow,Fast));

//---- initialization of variables
   IUP=0;
   IDN=0;
   E1=0;
   E2=0;

   if(_Digits==3 || _Digits==5)
     {
      Confirm2=Confirm*10;
      Flat2=Flat*10;
     }
   else
     {
      Confirm2=Confirm;
      Flat2=Flat;
     }

//---- getting handle of the iMA indicator
   SLMA_Handle=iMA(NULL,0,Slow,MAShift,MAMethod,PRICE_CLOSE);
   if(SLMA_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iMA indicator");
//---- getting handle of the iMA indicator
   FSMA_Handle=iMA(NULL,0,Fast,MAShift,MAMethod,PRICE_CLOSE);
   if(FSMA_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iMA indicator");
//---- getting handle of the iMA indicator
   RSI_Handle=iRSI(NULL,0,RSI,PRICE_CLOSE);
   if(RSI_Handle==INVALID_HANDLE)Print(" Failed to get handle of the iRSI indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Stalin Sell");
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(SellBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
//---- create label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Stalin Buy");
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(BuyBuffer,true);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for tooltips 
   string short_name="Stalin";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
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
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(RSI_Handle)<rates_total
      || BarsCalculated(SLMA_Handle)<rates_total
      || BarsCalculated(FSMA_Handle)<rates_total
      || rates_total<StartBars)
      return(0);

//---- declarations of local variables 
   int to_copy,limit;
   double RSI_[],SLMA_[],FSMA_[];

//---- calculations of the necessary amount of data to be copied and
//the limit starting index for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-StartBars; // starting index for calculation of all bars
      to_copy=rates_total; // calculated number of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for calculation of new bars
      to_copy=limit+2; // calculated number of new bars only
     }

//---- indexing elements in arrays as timeseries
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(SLMA_,true);
   ArraySetAsSeries(FSMA_,true);
   ArraySetAsSeries(RSI_,true);

//---- copy newly appeared data in the arrays
   if(CopyBuffer(SLMA_Handle,0,0,to_copy,SLMA_)<=0) return(0);
   if(CopyBuffer(FSMA_Handle,0,0,to_copy,FSMA_)<=0) return(0);
   if(CopyBuffer(RSI_Handle,0,0,to_copy,RSI_)<=0) return(0);

//---- main indicator calculation loop
   for(int bar=limit; bar>=0; bar--)
     {
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;

      if(FSMA_[bar+1]<SLMA_[bar+1]&&FSMA_[bar]>SLMA_[bar]&&(RSI_[bar]>50||RSI==0)){if(Confirm2==0){BU(bar,low, time);}else{IUP=low[bar]; IDN=0;}}
      if(FSMA_[bar+1]>SLMA_[bar+1]&&FSMA_[bar]<SLMA_[bar]&&(RSI_[bar]<50||RSI==0)){if(Confirm2==0){BD(bar,high,time);}else{IDN=high[bar];IUP=0;}}
      if(IUP!=0){if(((high[bar]-IUP)>=(Confirm2*_Point))&&(close[bar]<=high[bar] )){BU(bar,low,time); IUP=0;}}
      if(IDN!=0){if(((IDN- low[bar])>=(Confirm2*_Point))&&(open[bar] >=close[bar])){BD(bar,high,time);IDN=0;}}
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
