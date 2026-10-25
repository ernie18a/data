//+------------------------------------------------------------------+
//|                                                          Box.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrRed
#property indicator_color2 clrGreen
#property indicator_width1 2
#property indicator_width2 2
input int period = 20;
input int overlook =  10;

bool Box = false;
double ResBuffer[];
double SuppBuffer[];

double Resistance(int starting)
{
      double High1 = High[ArrayMaximum(High,period,starting)];
      double High2 = High[ArrayMaximum(High, period + overlook,starting)];
      if (High1 == High2) return High1;
      else return 0;
}

double Support(int starting)
{
      double Low1 = Low[ArrayMinimum(Low,period, starting)];
      double Low2 = Low[ArrayMinimum(Low,period+overlook,starting)];
      if (Low1 == Low2) return Low1;
      else return 0;
}

int OnInit()
   {
   SetIndexBuffer(0,ResBuffer);
   SetIndexBuffer(1,SuppBuffer);
   string short_name="Box("+IntegerToString(period)+")";
   IndicatorShortName(short_name);
   SetIndexDrawBegin(0,0);
   SetIndexDrawBegin(1,0);
   return(INIT_SUCCEEDED);
  }
  
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
   int i, limit;
   static double Savedmin = 0.0, Savedmax = 0.0;
   if((rates_total<= period + overlook) || (period <= 0) || (overlook < 0))
      return(0);
   ArraySetAsSeries(ResBuffer,false);
   ArraySetAsSeries(SuppBuffer,false);
   ArrayInitialize(ResBuffer,0);
   ArrayInitialize(SuppBuffer,0);
   if(prev_calculated<=period + overlook)
         {
            SuppBuffer[i] = 0;
            ResBuffer[i] = 0;
            
         }
   else limit = prev_calculated;
   i = MathMax(rates_total-5000,period+overlook);
   for(i; i<rates_total; i++)
      {
      bool BounceUp = (Support(rates_total-i)*2 + Resistance(rates_total-i))/3 < Close[rates_total-i];
      bool BounceBack = (Support(rates_total-i) + Resistance(rates_total-i)*2)/3 > Close[rates_total-i];
      if ((Support(rates_total-i) != NULL) && (Resistance(rates_total-i) != NULL) && !Box && BounceBack && BounceUp)
      {
      SuppBuffer[i] = Support(rates_total-i);
      ResBuffer[i] = Resistance(rates_total-i);
      Savedmin = Support(rates_total-i);
      Savedmax = Resistance(rates_total-i);
      Box = true;
      }
      else if ((Low[rates_total-i] > Savedmin) && (High[rates_total-i] < Savedmax) && Box)
         { 
            SuppBuffer[i] = Savedmin;
            ResBuffer[i] = Savedmax;
            Box = true;
         }    
      else
         {
         SuppBuffer[i] = EMPTY_VALUE;
         ResBuffer[i] = EMPTY_VALUE;
         Box = false;   
         } 
      }
      
   return(rates_total);
  }
