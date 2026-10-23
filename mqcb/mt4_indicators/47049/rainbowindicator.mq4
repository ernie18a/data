//+------------------------------------------------------------------+
//|                                             RainbowIndicator.mq4 |
//|                                                     Müller Péter |
//|                   https://www.mql5.com/en/users/mullerp04/seller |
//+------------------------------------------------------------------+
#property copyright "Müller Péter"
#property link      "https://www.mql5.com/en/users/mullerp04/seller"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 6   //amount of lines
#property indicator_color1 clrRed // colors of lines
#property indicator_color2 clrOrange
#property indicator_color3 clrYellow
#property indicator_color4 clrYellowGreen
#property indicator_color5 clrAliceBlue
#property indicator_color6 clrBlue

input double AtrMultiplier = 1; // distance between moving averages and levels above/belov them
input int period = 20;  // Moving average period


double FirstBuffer[];      // Buffers
double SecondBuffer[];
double ThirdBuffer[];
double FourthBuffer[];
double FifthBuffer[];
double SixthBuffer[];

int OnInit()
  {
   SetIndexBuffer(0,FirstBuffer); //Setting up Buffers
   SetIndexBuffer(1,SecondBuffer);
   SetIndexBuffer(2,ThirdBuffer);
   SetIndexBuffer(3,FourthBuffer);
   SetIndexBuffer(4,FifthBuffer);
   SetIndexBuffer(5,SixthBuffer);
   string short_name="Period( "+IntegerToString(period)+" )" + _Symbol; // Setting and indicator short name
   IndicatorShortName(short_name);
   SetIndexDrawBegin(0,0);    // Where we want the program to begin drawing the lines
   SetIndexDrawBegin(1,0);
   SetIndexDrawBegin(2,0);
   SetIndexDrawBegin(3,0);
   SetIndexDrawBegin(4,0);
   SetIndexDrawBegin(5,0);
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
   if(rates_total < period) 
      return 0;

   ArraySetAsSeries(FirstBuffer,false);
   ArraySetAsSeries(SecondBuffer,false);
   ArraySetAsSeries(ThirdBuffer,false);
   ArraySetAsSeries(FourthBuffer,false);
   ArraySetAsSeries(FifthBuffer,false);
   ArraySetAsSeries(SixthBuffer,false);
   
   for(int i = prev_calculated; i < rates_total;i++)        // easy calculations
   {
      double currAtr = iATR(_Symbol,PERIOD_CURRENT,20,rates_total-i);     // current ATR value
      double HighMa = iMA(_Symbol,PERIOD_CURRENT,20,0,MODE_SMA,PRICE_HIGH,rates_total-i); // high moving average
      double LowMa = iMA(_Symbol,PERIOD_CURRENT,20,0,MODE_SMA,PRICE_LOW,rates_total-i); // low moving average
      FirstBuffer[i] = HighMa + 2*AtrMultiplier*currAtr; 
      SecondBuffer[i] = HighMa + AtrMultiplier*currAtr;
      ThirdBuffer[i] = HighMa;
      FourthBuffer[i] = LowMa;
      FifthBuffer[i] = LowMa-AtrMultiplier*currAtr;
      SixthBuffer[i] = LowMa-2*AtrMultiplier*currAtr;      
   }
   return(rates_total);
  }
//+------------------------------------------------------------------+
