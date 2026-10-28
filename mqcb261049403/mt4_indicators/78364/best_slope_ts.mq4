//+------------------------------------------------------------------+
//|                                                Best Slope TS.mq4 |
//+------------------------------------------------------------------+
#property copyright   "http://www.FinanceWave.com™"

#property indicator_chart_window
#property indicator_buffers 4
#property strict

double Bar1[],
		 Bar2[],
		 Candle1[],
		 Candle2[];

int i,sit;
double cci,mfi,den,sto,hist,ad,ao,ac;
double cciAnt,mfiAnt,denAnt,stoAnt,histAnt,adAnt,aoAnt,acAnt;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   SetIndexBuffer(0,Bar1); SetIndexStyle(0,DRAW_HISTOGRAM,0,1,Red);
   SetIndexBuffer(1,Bar2); SetIndexStyle(1,DRAW_HISTOGRAM,0,1,Lime);
   SetIndexBuffer(2,Candle1); SetIndexStyle(2,DRAW_HISTOGRAM,0,3,Red);
   SetIndexBuffer(3,Candle2); SetIndexStyle(3,DRAW_HISTOGRAM,0,3,Lime);
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Best Slope TS                                                    |
//+------------------------------------------------------------------+
int start()
{

for(i = Bars-50; i>=0; i--)
{

stoAnt=iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,i+1);
cciAnt=iCCI(Symbol(),0,14,PRICE_TYPICAL,i+1);
denAnt=iDeMarker(NULL,0,14,i+1)*100;
mfiAnt=iMFI(NULL,0,14,i+1);
histAnt=iOsMA(NULL,0,12,26,9,PRICE_CLOSE,i+1);
acAnt=iAC(NULL,0,i+1);
aoAnt=iAO(NULL,0,i+1);
adAnt=iAD(NULL,0,i+1);

sto=iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,i);
cci=iCCI(Symbol(),0,14,PRICE_TYPICAL,i);
den=iDeMarker(NULL,0,14,i)*100;
mfi=iMFI(NULL,0,14,i);
hist=iOsMA(NULL,0,12,26,9,PRICE_CLOSE,i);
ac=iAC(NULL,0,i);
ao=iAO(NULL,0,i);
ad=iAD(NULL,0,i);

if(
sto>stoAnt &&
cci>cciAnt &&
den>denAnt &&
mfi>mfiAnt &&
hist>histAnt &&
ac>acAnt &&
ao>aoAnt &&
ad>adAnt 
)
{sit=1;}

else if(
sto<stoAnt &&
cci<cciAnt &&
den<denAnt &&
mfi<mfiAnt &&
hist<histAnt &&
ac<acAnt &&
ao<aoAnt &&
ad<adAnt 
)
{sit=-1;}

if(sit==1)
{SetCandleColor(2,i);}

else if(sit==-1)
{SetCandleColor(1,i);}

}

return(0);
}
//+------------------------------------------------------------------+
void SetCandleColor(int col, int k)
{
	double high,low,bodyHigh,bodyLow;

	{
		bodyHigh = MathMax(Open[k],Close[k]);
		bodyLow  = MathMin(Open[k],Close[k]);
		high		= High[k];
		low		= Low[k];
	}

	Bar1[k] = low;	Candle1[k] = bodyLow;
	Bar2[k] = low;	Candle2[k] = bodyLow;
	
	switch(col)
	{
		case 1: 	Bar1[k] = high;	Candle1[k] = bodyHigh;	break;
		case 2: 	Bar2[k] = high;	Candle2[k] = bodyHigh;	break;
	}
}
//+------------------------------------------------------------------+