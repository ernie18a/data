//+-----------------------------------------------------------+
//|                                      High Volume Bars.mq4 |
//|                                                           |
//| www.tradingview.com/script/ElfsaJiR-High-Volume-Bars/     |
//+-----------------------------------------------------------+
#property description "MT4 Code by  Max Michael 2022"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Blue   //wick
#property indicator_color2 Red    //wick
#property indicator_color3 Blue   //candle
#property indicator_color4 Red    //candle
#property strict

extern int      Lookback = 200;
extern double Multiplier = 1.0;
extern int	    BarWidth = 1;
extern int	 CandleWidth = 3;
extern int       MaxBars = 2000;

double  Bar1[],
        Bar2[],
		  Candle1[],
		  Candle2[];
double  volume[];

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
	SetIndexBuffer(4,volume); SetIndexStyle(4,DRAW_NONE);
   string sShortName="High Volume Bar("+string(Lookback)+","+string(Multiplier)+")";
   IndicatorShortName(sShortName);
   SetIndexLabel(0,sShortName);
   return(0);
}

int start()
{
   int limit=Bars-IndicatorCounted();
   if (limit < 0) return(-1);
   if (limit > 0) limit--;
   if (limit > MaxBars) limit=MathMin(MaxBars,Bars-1);
   double VolStdDev;
   
   for(int i=limit; i>=0; i--) volume[i]=Volume[i];
   
   for(int i=limit; i>=0; i--)
   {
      VolStdDev=iStdDevOnArray(volume,0,Lookback,0,MODE_SMA,i);
      bool HighVol = Volume[i] - Volume[i+1] > VolStdDev*Multiplier;
      if (Close[i] > Open[i] && HighVol) SetCandleColor(1,i);
      if (Close[i] < Open[i] && HighVol) SetCandleColor(2,i);
   }
   return(0);
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
