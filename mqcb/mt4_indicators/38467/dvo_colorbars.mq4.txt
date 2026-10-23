//+-----------------------------------------------------------+
//|                         DVO - David Varadi Oscillator.mq4 |
//|                                                           |
//| www.tradingview.com/script/m5lVzOkh-Varadi-Oscillator/    |
//+-----------------------------------------------------------+
#property description "MT4 Code by  Max Michael 2022"
#property indicator_chart_window
//#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 6
#property indicator_color1 LimeGreen //wick
#property indicator_color2 Red       //wick
#property indicator_color3 LimeGreen //candle
#property indicator_color4 Red       //candle
#property indicator_color5 Aqua
#property indicator_levelcolor DimGray
#property indicator_levelwidth 1
#property indicator_levelstyle 2
#property indicator_level1 80
#property indicator_level2 20
#property strict

extern int       Length = 21;
extern int         Rank = 21;
extern int	   BarWidth = 1;
extern int	CandleWidth = 3;
extern int     Level_UP = 60;
extern int     Level_DN = 40;
extern int      MaxBars = 1000;

double  Bar1[],
        Bar2[],
		  Candle1[],
		  Candle2[];
double  DVObuffer[];  
double  SMAbuffer[];  

int     trend;

int init()
{
	SetIndexBuffer(0,Bar1);
	SetIndexBuffer(1,Bar2);				
	SetIndexBuffer(2,Candle1);
	SetIndexBuffer(3,Candle2);
	SetIndexStyle(0,DRAW_HISTOGRAM,0,BarWidth);
	SetIndexStyle(1,DRAW_HISTOGRAM,0,BarWidth);
	SetIndexStyle(2,DRAW_HISTOGRAM,0,CandleWidth);
	SetIndexStyle(3,DRAW_HISTOGRAM,0,CandleWidth);
   SetIndexBuffer(4,DVObuffer); SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(5,SMAbuffer); SetIndexStyle(5,DRAW_NONE);
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
   if (limit > MaxBars) limit=MathMin(MaxBars,Bars-1);
   
   for(int i=limit; i>=0; i--)
   {
      SMAbuffer[i] = SMA(Length,i); // sum the ratio between close and median
      // Rank average between close and median
      DVObuffer[i]= PercentRank(Rank,i);
      if (trend<=0 && DVObuffer[i] >= Level_UP) trend= 1;
      if (trend>=0 && DVObuffer[i] <= Level_DN) trend=-1;
      if      (trend== 1) SetCandleColor(1,i);
      else if (trend==-1) SetCandleColor(2,i);
   }
   return(0);
}

double SMA(int period, int bar)
{
   double sum=0;
   for (int x=bar; x<(bar+period); x++) sum += (Close[x]/((High[x]+Low[x])/2.0));
   return(sum/period);
}

void SetCandleColor(int col, int i)
{
	double high,low,bodyHigh,bodyLow;
	{
		bodyHigh = MathMax(Open[i],Close[i]);
		bodyLow  = MathMin(Open[i],Close[i]);
		high		= High[i];
		low		= Low[i];
	}
	Bar1[i]= low;	Candle1[i]= bodyLow;
	Bar2[i]= low;	Candle2[i]= bodyLow;
	
	switch(col)
	{
		case 1: 	Bar1[i]= high;	Candle1[i]= bodyHigh;	break;
		case 2: 	Bar2[i]= high;	Candle2[i]= bodyHigh;	break;
	}
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
