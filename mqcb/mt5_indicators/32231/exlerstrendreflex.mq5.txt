//+------------------------------------------------------------------+
//|                                            ExlersTrendReflex.mq5 |
//|                                Copyright 2020, Andrei Novichkov. |
//|                                               http://fxstill.com |
//|   Telegram: https://t.me/fxstill (Literature on cryptocurrencies,| 
//|                                   development and code. )        |
//|  Instagram: https://www.instagram.com/andreifx2020/              |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Andrei Novichkov."
#property link      "http://fxstill.com"

#property version   "1.00"

#property description "Telegram Channel: https://t.me/fxstill\n"
#property description "Reflex: A New Zero-Lag Indicator. John Ehlers, \"Stocks & Commodities. Feb.2020 pg. 6-8\""


#define NAME (string)"ExlersTrendReflex"

#property indicator_separate_window

#property indicator_buffers 5
#property indicator_plots   2
//
#property indicator_label1  "RefLex"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//
#property indicator_label2  "Trendflex"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

input int Length = 20;

//--- indicator buffers
double         rf[];
double         tf[];
double         fl[];
double         ts[];
double         rs[];

static const int MINBAR = Length + 1;

double c1, c2, c3;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()   {

//--- indicator buffers mapping
   SetIndexBuffer(0,rf,INDICATOR_DATA);
   SetIndexBuffer(1,tf,INDICATOR_DATA);
   SetIndexBuffer(2,fl,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ts,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,rs,INDICATOR_CALCULATIONS);
   ArraySetAsSeries(rf,true);
   ArraySetAsSeries(tf,true); 
   ArraySetAsSeries(fl,true); 
   ArraySetAsSeries(ts,true);    
   ArraySetAsSeries(rs,true); 
   
   IndicatorSetString(INDICATOR_SHORTNAME, NAME);
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);     
   
   double a1 = MathExp(-M_SQRT2 * M_PI / (0.5 * Length));
   double b1 = 2 * a1 * MathCos(M_SQRT2 * M_PI / (0.5 * Length));
	c2 = b1;
	c3 = -a1 * a1;
	c1 = 1 - c2 - c3;   
	
//---
   return(INIT_SUCCEEDED);
  }

  
  
void GetValue(const double& data[], int i) {

   fl[i] = c1 * (data[i] + data[i + 1]) / 2 + c2 * fl[i + 1] + c3 * fl[i + 2];

   double sum0 = 0, sum1 = 0;
   double slope = (fl[i + Length] - fl[i]) / Length;
	for(int k = 1; k <= Length; k++) {
		sum0 += fl[i] - fl[i + k];
		sum1 += (fl[i] + k * slope) - fl[i + k];
	}
			
	sum0 /= Length;
	sum1 /= Length;
			
	ts[i] = 0.04 * sum0 * sum0 + 0.96 * ts[i + 1];
	rs[i] = 0.04 * sum1 * sum1 + 0.96 * rs[i + 1];
			
	if(ts[i] != 0) tf[i] = sum0/MathSqrt(ts[i]);
	if(rs[i] != 0) rf[i] = sum1/MathSqrt(rs[i]);
	
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
      if(rates_total < MINBAR) return 0;
      ArraySetAsSeries(close,true); 
      int limit = rates_total - prev_calculated;
      if (limit == 0)        {   
      } else if (limit == 1) {   
         GetValue(close, 1);
         return(rates_total); 
      } else if (limit > 1)  {   
         ArrayInitialize(rf, EMPTY_VALUE);
         ArrayInitialize(tf, EMPTY_VALUE);
         ArrayInitialize(fl, 0);
         ArrayInitialize(ts, 0);
         ArrayInitialize(rs, 0);
         limit = rates_total - MINBAR;
         for(int i = limit; i >= 1 && !IsStopped(); i--){
            GetValue(close, i);
         }//for(int i = limit + 1; i >= 0 && !IsStopped(); i--)
         return(rates_total);         
      }
      GetValue(close, 0);          
   return(rates_total);
}
