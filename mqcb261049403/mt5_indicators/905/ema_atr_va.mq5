//+------------------------------------------------------------------+
//|                                                   EMA_ATR_VA.mq5 |
//|                                                          Integer |
//|                            https://www.mql5.com/en/users/integer |
//+------------------------------------------------------------------+
#property copyright "Integer"
#property link      "https://www.mql5.com/en/users/integer"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot Label1
#property indicator_label1  "Label1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int                ATRPeriod   = 14;           // ATR Period
input double             EMAPeriod  = 14;            // EMA period
input double             Sensitivity = 100;          // Sensitivity (-100 to 100)
input ENUM_APPLIED_PRICE Price       = PRICE_CLOSE;  // Price

int ATRHand;
int MAHand;
double sens;
//--- indicator buffers
double Label1Buffer[];
double ATRBuf[];
double MABuf[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   sens=Sensitivity/100.0;

   SetIndexBuffer(0,Label1Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,ATRBuf,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,MABuf,INDICATOR_CALCULATIONS);

   ATRHand=iATR(NULL,PERIOD_CURRENT,ATRPeriod);
   MAHand=iMA(NULL,PERIOD_CURRENT,1,0,0,Price);
   if(ATRHand==INVALID_HANDLE || MAHand==INVALID_HANDLE)
     {
      Alert("Error in creation of indicator, please try again");
      return(-1);
     }

   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,ATRPeriod*2);
   PlotIndexSetString(0,PLOT_LABEL,MQL5InfoString(MQL5_PROGRAM_NAME));

   return(0);
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
   static bool error=true;
   int start;
   if(prev_calculated==0)
     {
      error=true;
     }
   if(error)
     {
      start=ATRPeriod*2;
      Label1Buffer[start-1]=close[start-1];
      error=false;
     }
   else
     {
      start=prev_calculated-1;
     }
   if(CopyBuffer(ATRHand,0,0,rates_total-start,ATRBuf)==-1 || 
      CopyBuffer(MAHand,0,0,rates_total-start,MABuf)==-1
      )
     {
      error=true;
      return(0);
     }
   for(int i=start;i<rates_total;i++)
     {
      double mxv=ATRBuf[ArrayMaximum(ATRBuf,i-ATRPeriod+1,ATRPeriod)];
      double mnv=ATRBuf[ArrayMinimum(ATRBuf,i-ATRPeriod+1,ATRPeriod)];
      double r=mxv-mnv;
      if(r==0)
        {
         Label1Buffer[i]=Label1Buffer[i-1];
         continue;
        }
      double ATRvlty=(ATRBuf[i]-mnv)/r;
      double multi;
      if(ATRvlty<=0.5)
        {
         multi=10.0*MathPow(ATRvlty,3.4739)+0.1;
        }
      else
        {
         multi=10*MathPow(ATRvlty,3.32)+0.000001;
        }
      if(sens>0)
        {
         multi=1.0/multi;
        }
      if(multi<1.0)
        {
         multi=1.0-(1.0-multi)*MathAbs(sens);
        }
      else
        {
         multi=(multi-1.0)*MathAbs(sens)+1.0;
        }
      double pdsx=EMAPeriod*multi;
      if(pdsx<1.0)
        {
         pdsx=1.0;
        }
      Label1Buffer[i]=MABuf[i]*2.0/(pdsx+1.0)+Label1Buffer[i-1]*(1.0-2.0/(pdsx+1.0));
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
