//------------------------------------------------------------------
#property strict
#property copyright   "Copyright 2019, Soewono Effendi"
#property link        "https://www.mql5.com/en/users/seffx"
#property version     "1.01"
#property description "Rsi candles - inspired by"
#property description "https://www.mql5.com/en/code/20968"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   8

#property indicator_label1  "RSI"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrGray
#property indicator_width1  8

#property indicator_label2  "RSI"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrDodgerBlue
#property indicator_width2  8

#property indicator_label3  "RSI"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrCrimson
#property indicator_width3  8

#property indicator_label4  "RSI"
#property indicator_type4   DRAW_HISTOGRAM
#property indicator_color4  clrBlack
#property indicator_width4  8

#property indicator_label5  "RSI"
#property indicator_type5   DRAW_HISTOGRAM
#property indicator_color5  clrGray
#property indicator_width5  2

#property indicator_label6  "RSI"
#property indicator_type6   DRAW_HISTOGRAM
#property indicator_color6  clrDodgerBlue
#property indicator_width6  2

#property indicator_label7  "RSI"
#property indicator_type7   DRAW_HISTOGRAM
#property indicator_color7  clrCrimson
#property indicator_width7  2

#property indicator_label8  "RSI"
#property indicator_type8   DRAW_HISTOGRAM
#property indicator_color8  clrBlack
#property indicator_width8  2

#property indicator_level1  70.0 
#property indicator_level2  30.0 
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT

input int inpRsiPeriod=14;      // RSI period

                                //
//--- indicator buffers
//

double rsih1[],rsih2[],rsih3[];
double rsib1[],rsib2[],rsib3[];
double rsif[],rsil[];
int last_bars=0;
//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
  {
// body
   SetIndexBuffer(0,rsib1);
   SetIndexBuffer(1,rsib2);
   SetIndexBuffer(2,rsib3);
   SetIndexBuffer(3,rsif);
// wick
   SetIndexBuffer(4,rsih1);
   SetIndexBuffer(5,rsih2);
   SetIndexBuffer(6,rsih3);
   SetIndexBuffer(7,rsil);

   IndicatorSetString(INDICATOR_SHORTNAME,"Rsi candles ("+(string)inpRsiPeriod+")");
   return(INIT_SUCCEEDED);
  }
//------------------------------------------------------------------
// Custom indicator de-initialization function
//------------------------------------------------------------------
void OnDeinit(const int reason) { return; }
//------------------------------------------------------------------
// Custom iteration function
//------------------------------------------------------------------
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
   if(rates_total<inpRsiPeriod)
     {
      return(0);
     }
   double _rsi[4],rsiC,rsiO,rsiH,rsiL,diff;
   int clr=0;
   int i=rates_total-prev_calculated;
   if (prev_calculated == 0)
      i = rates_total - 1;
   for(; i>=0 && !_StopFlag; i--)
     {
      _rsi[0] = iRSI(NULL, 0, inpRsiPeriod, PRICE_OPEN, i);
      _rsi[1] = iRSI(NULL, 0, inpRsiPeriod, PRICE_HIGH, i);
      _rsi[2] = iRSI(NULL, 0, inpRsiPeriod, PRICE_LOW, i);
      _rsi[3] = iRSI(NULL, 0, inpRsiPeriod, PRICE_CLOSE, i);

      rsih1[i] = EMPTY_VALUE;
      rsih2[i] = EMPTY_VALUE;
      rsih3[i] = EMPTY_VALUE;
      rsib1[i] = EMPTY_VALUE;
      rsib2[i] = EMPTY_VALUE;
      rsib3[i] = EMPTY_VALUE;

      rsiO = _rsi[0];
      rsiC = _rsi[3];
      rsiH = _rsi[ArrayMaximum(_rsi)];
      rsiL = _rsi[ArrayMinimum(_rsi)];

      diff=MathAbs(rsiO-rsiC);
      if(diff<DBL_MIN)
        {
         clr=0;
         diff=0.5;
        }
      else if(rsiC>rsiO)
        {
         clr=1;
         if(diff<1)
            diff=0.5;
        }
      else if(rsiC<rsiO)
        {
         clr=2;
         if(diff<1)
            diff=0.5;
        }
      if(clr==1)
        {
         // clrDodgerBlue
         rsih2[i] = rsiH;
         rsib2[i] = rsiC + diff;
         rsif[i]=rsiO;
        }
      else if(clr==2)
        {
         // clrCrimson
         rsih3[i] = rsiH;
         rsib3[i] = rsiO + diff;
         rsif[i]=rsiC;
        }
      else if(clr==0)
        {
         // clrGray
         rsih1[i] = rsiH;
         rsib1[i] = rsiO + diff;
         rsif[i]=rsiC;
        }
      rsil[i]=rsiL;
     }
   return(rates_total - 1);
  }
//+------------------------------------------------------------------+
