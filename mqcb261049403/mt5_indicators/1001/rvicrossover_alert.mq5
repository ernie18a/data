//+------------------------------------------------------------------+
//|                                          RVI-Crossover_Alert.mq5 |
//|         Copyright © 2005, Jason Robinson (jnrtrading)            |
//|                   http://www.jnrtading.co.uk                     |
//+------------------------------------------------------------------+

/*
  +------------------------------------------------------------------+
  | Allows you to enter two RVI periods and it will then show you at |
  | Which point they crossed over. It is more usful on the shorter   |
  | periods that get obscured by the bars / candlesticks and when    |
  | the zoom level is out. Also allows you then to remove the  RVIs  |
  | from the chart. (eRVIs are initially set at 5 and 20)            |
  +------------------------------------------------------------------+
*/
#property copyright "Copyright © 2005, Jason Robinson (jnrtrading)"
#property link      "http://www.jnrtrading.co.uk"

//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//----two buffers are used for calculation of drawing of the indicator
#property indicator_buffers 2
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- MediumVioletRed color is used for the indicator bearish line
#property indicator_color1  MediumVioletRed
//---- thickness of line of the indicator 1 is equal to 4
#property indicator_width1  4
//---- displaying the bearish label of the indicator line
#property indicator_label1  "RVI-Crossover_Alert Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- LightSeaGreen color is used as the color of the bullish indicator line
#property indicator_color2  LightSeaGreen
//---- thickness of the indicator line 2 is equal to 4
#property indicator_width2  4
//---- displaying of the bullish label of the indicator
#property indicator_label2 "RVI-Crossover_Alert Buy"
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input uint RVI_Period=5; //Period of averaging for RVI
extern bool SoundON=true; //Allow alert
extern bool EMailON=false; //Allow mailing signal
extern bool PushON=false; //Allow to send a signal to the mobile
input uint NumberofAlerts=2;
//+----------------------------------------------+

//---- declaration of dynamic arrays that
// will be used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
//----
uint counter=0;
//----Declaration of variables for storing the indicators handles
int RVI_Handle;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=int(RVI_Period+3+9);

//---- obtaining the indicators handles
   RVI_Handle=iRVI(NULL,0,RVI_Period);
   if(RVI_Handle==INVALID_HANDLE) Print(" Failed to get handle of the RVI indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SellBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(BuyBuffer,true);

//---- Setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="RVI-Crossover_Alert";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
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
   if(rates_total<min_rates_total || BarsCalculated(RVI_Handle)<rates_total) return(RESET);

//---- declaration of local variables 
   int limit,count;
   double RVInow,Signalnow,RVIprevious,Signalprevious,Range,AvgRange,RVI[],Ask,Bid;
   string text,sAsk,sBid,sPeriod;

//---- calculations of the necessary amount of data to be copied
//---- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total;       // starting index for calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for calculation of new bars
     }

//---- indexing elements in arrays as time series 
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(RVI,true);
   ArraySetAsSeries(RVI,true);

//---- main loop of the indicator calculation
   for(int bar=limit; bar>=0; bar--)
     {
      count=bar;
      Range=0;
      AvgRange=0;
      for(count=bar;count<=bar+9;count++) AvgRange=AvgRange+MathAbs(high[count]-low[count]);
      Range=AvgRange/10;

      //--- copy newly appeared data in the array
      if(CopyBuffer(RVI_Handle,MAIN_LINE,bar,2,RVI)<=0) return(RESET);
      RVInow=RVI[0];
      RVIprevious=RVI[1];

      //--- copy newly appeared data in the array
      if(CopyBuffer(RVI_Handle,SIGNAL_LINE,bar,2,RVI)<=0) return(RESET);
      Signalnow=RVI[0];
      Signalprevious=RVI[1];

      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;

      if(RVInow>Signalnow && RVIprevious<Signalprevious) BuyBuffer[bar]=low[bar]-Range*0.75;
      if(RVInow<Signalnow && RVIprevious>Signalprevious) SellBuffer[bar]=high[bar]+Range*0.75;
     }

   if(rates_total!=prev_calculated) counter=0;

   if(BuyBuffer[1] && counter<=NumberofAlerts)
     {
      counter++;
      MqlDateTime tm;
      TimeToStruct(TimeCurrent(),tm);
      text=TimeToString(TimeCurrent(),TIME_DATE)+" "+string(tm.hour)+":"+string(tm.min);
      Ask=close[0];
      Bid=close[0]+spread[0];
      sAsk=DoubleToString(Ask,_Digits);
      sBid=DoubleToString(Bid,_Digits);
      sPeriod=EnumToString(ChartPeriod());
      if(SoundON) Alert("BUY signal at Ask=",Ask,"\n Bid=",Bid,"\n currtime=",text,"\n Symbol=",Symbol()," Period=",sPeriod);
      if(EMailON) SendMail("RVI-Crossover_Alert: BUY signal alert","BUY signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
      if(PushON) SendNotification("RVI-Crossover_Alert: BUY signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
     }

   if(SellBuffer[1] && counter<=NumberofAlerts)
     {
      counter++;
      MqlDateTime tm;
      TimeToStruct(TimeCurrent(),tm);
      text=TimeToString(TimeCurrent(),TIME_DATE)+" "+string(tm.hour)+":"+string(tm.min);
      Ask=close[0];
      Bid=close[0]+spread[0];
      sAsk=DoubleToString(Ask,_Digits);
      sBid=DoubleToString(Bid,_Digits);
      sPeriod=EnumToString(ChartPeriod());
      if(SoundON) Alert("SELL signal at Ask=",sAsk,"\n Bid=",sBid,"\n Date=",text,"\n Symbol=",Symbol()," Period=",sPeriod);
      if(EMailON) SendMail("RVI-Crossover_Alert: SELL signal alert","SELL signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
      if(PushON) SendNotification("RVI-Crossover_Alert: SELL signal at Ask="+sAsk+", Bid="+sBid+", Date="+text+" Symbol="+Symbol()+" Period="+sPeriod);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
