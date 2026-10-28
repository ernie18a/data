//+-----------------------------------------------------------+
//| Updated                 DVO - David Varadi Oscillator.mq4 |
//|                                                           |
//| www.tradingview.com/script/m5lVzOkh-Varadi-Oscillator/    |
//+-----------------------------------------------------------+
#property description "MT4 Code by  Max Michael 2022"
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 2
#property indicator_color1 Aqua
#property indicator_levelcolor DimGray
#property indicator_levelwidth 1
#property indicator_levelstyle 2
#property indicator_level1 80
#property indicator_level2 20
#property strict

extern int     Length = 21;
extern int       Rank = 21;
extern int    MaxBars = 1000;

double        DVObuffer[];  
double        SMAbuffer[];  


int init()
{
   SetIndexBuffer(0,DVObuffer); SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,SMAbuffer); SetIndexStyle(1,DRAW_NONE);
   string sShortName="DVO("+string(Length)+","+string(Rank)+")";
   IndicatorShortName(sShortName);
   SetIndexLabel(0,sShortName);
   SetIndexDrawBegin(0,Length);
   SetIndexLabel(1,"");
   IndicatorDigits(2);
   return(0);
}

int start()
{
   int limit=Bars-IndicatorCounted();
   if (limit < 0) return(-1);
   if (limit > 0) limit--;
   if (limit > MaxBars) limit=MaxBars;
   
   for(int i=limit; i>=0; i--)
   {
      SMAbuffer[i]= SMA(Length,i); // sum the ratio between close and median
      DVObuffer[i]= PercentRank(Rank,i);
   }
   return(0);
}

double SMA(int period, int bar)
{
   double sum=0;
   for (int x=bar; x<(bar+period); x++) sum += (Close[x]/((High[x]+Low[x])/2.0));
   return(sum/period);
}

//+------------------------------------------------------------------+
//| PercentRank                                                      |
//+------------------------------------------------------------------+
double PercentRank(int period_rnk, int index)
{
   double count=0;
   for(int i=1; i<=period_rnk; i++) if(SMAbuffer[index]>SMAbuffer[index+i]) count++;
   return 100.0*count/(double)period_rnk;
}
