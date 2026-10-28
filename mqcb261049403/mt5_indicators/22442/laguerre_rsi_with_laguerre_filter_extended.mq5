//------------------------------------------------------------------
#property copyright   "© mladen"
#property link        "mladenfx@gmail.com"
#property description "Laguerre RSI with Laguerre filter - extended"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "No trade zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'255,238,210',C'255,238,210';
#property indicator_label2  "Laguerre RSI"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDodgerBlue,clrPaleVioletRed
#property indicator_width2  2
#property indicator_label3  "Laguerre filter signal"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDimGray
#property indicator_style3  STYLE_DASHDOTDOT
//
//---
//
enum enColorDisplay
{
   change_onNoTrade, // Change colors on no trade zones crossing
   change_onOuter,   // Change colors on outer levels crossing
   change_onSlope,   // Change colors on Laguerre RSI slope
   change_onSignal   // Change colors on signal line crossing
};
input double             RsiGamma             = 0.80;           // Laguerre RSI gamma
input ENUM_APPLIED_PRICE RsiPrice             = PRICE_CLOSE;    // Price
input double             RsiSmoothGamma       = 0.001;          // Laguerre RSI smooth gamma
input int                RsiSmoothSpeed       = 2;              // Laguerre RSI smooth speed (min 0, max 6)
input double             FilterGamma          = 0.60;           // Laguerre filter gamma
input int                FilterSpeed          = 2;              // Laguerre filter speed (min 0, max 6)
input double             LevelUp              = 0.85;           // Level up
input double             LevelDown            = 0.15;           // Level down
input double             NoTradeZoneUp        = 0.65;           // No trade zone up
input double             NoTradeZoneDown      = 0.35;           // No trade zone down
input enColorDisplay     inpColorDisplay      = change_onOuter; // Color change mode :
//
//--- buffers and global variables declarations
//
double osc[],oscc[],oscs[],levu[],levd[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0,levu,INDICATOR_DATA);
   SetIndexBuffer(1,levd,INDICATOR_DATA);
   SetIndexBuffer(2,osc  ,INDICATOR_DATA); 
   SetIndexBuffer(3,oscc ,INDICATOR_COLOR_INDEX); 
   SetIndexBuffer(4,oscs ,INDICATOR_DATA); 
      IndicatorSetInteger(INDICATOR_LEVELS,2);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,LevelUp);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1,LevelDown);
   
      IndicatorSetString(INDICATOR_SHORTNAME,"Laguerre RSI with Laguerre filter ("+(string)RsiGamma+","+(string)FilterGamma+")");
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total && !_StopFlag; i++)
   {
      osc[i]  = iLaGuerreRsi(getPrice(RsiPrice,open,close,high,low,i,rates_total),RsiGamma,RsiSmoothGamma,RsiSmoothSpeed,i);
      oscs[i] = iLaGuerreFil(osc[i],FilterGamma,FilterSpeed,i);
      levu[i] = NoTradeZoneUp;
      levd[i] = NoTradeZoneDown;
      switch (inpColorDisplay)
      {
         case change_onNoTrade : oscc[i] = (osc[i]>NoTradeZoneUp) ? 1 : (osc[i]<NoTradeZoneDown) ? 2 : 0; break;
         case change_onOuter   : oscc[i] = (osc[i]>LevelUp) ? 1 : (osc[i]<LevelDown) ? 2 : 0; break;
         case change_onSlope   : oscc[i] = (i>0) ? (osc[i]>osc[i-1]) ? 1 : (osc[i]<osc[i-1]) ? 2 : oscc[i-1] : 0; break;
         default               : oscc[i] = (osc[i]>oscs[i]) ? 1 : (osc[i]<oscs[i]) ? 2 : 0; break;
      }         
   }
   return(i);
}
//------------------------------------------------------------------
//    custom functions
//------------------------------------------------------------------
#define _lagRsiInstances 1
#define _lagRsiInstancesSize 5
#define _lagRsiRingSize 5
double workLagRsi[_lagRsiRingSize][_lagRsiInstances*_lagRsiInstancesSize];
double iLaGuerreRsi(double price, double gamma, double smooth, double smoothSpeed, int i, int instance=0)
{
   int _indP = (i-1)%_lagRsiRingSize;
   int _indC = (i  )%_lagRsiRingSize;
   int _inst = instance*_lagRsiInstancesSize;

   //
   //---
   //

      workLagRsi[_indC][_inst  ] = (i>0) ? (1.0 - gamma)*price                                            + gamma*workLagRsi[_indP][_inst  ] : price;
	   workLagRsi[_indC][_inst+1] = (i>0) ? -gamma*workLagRsi[_indC][_inst  ] + workLagRsi[_indP][_inst  ] + gamma*workLagRsi[_indP][_inst+1] : price;
	   workLagRsi[_indC][_inst+2] = (i>0) ? -gamma*workLagRsi[_indC][_inst+1] + workLagRsi[_indP][_inst+1] + gamma*workLagRsi[_indP][_inst+2] : price;
	   workLagRsi[_indC][_inst+3] = (i>0) ? -gamma*workLagRsi[_indC][_inst+2] + workLagRsi[_indP][_inst+2] + gamma*workLagRsi[_indP][_inst+3] : price;

      double CU = 0.00;
      double CD = 0.00;
      if (i>0)
      {   
            if (workLagRsi[_indC][_inst] >= workLagRsi[_indC][_inst+1])
            			CU =      workLagRsi[_indC][_inst  ] - workLagRsi[_indC][_inst+1];
            else	   CD =      workLagRsi[_indC][_inst+1] - workLagRsi[_indC][_inst  ];
            if (workLagRsi[_indC][_inst+1] >= workLagRsi[_indC][_inst+2])
            			CU = CU + workLagRsi[_indC][_inst+1] - workLagRsi[_indC][_inst+2];
            else	   CD = CD + workLagRsi[_indC][_inst+2] - workLagRsi[_indC][_inst+1];
            if (workLagRsi[_indC][_inst+2] >= workLagRsi[_indC][_inst+3])
   	       		   CU = CU + workLagRsi[_indC][_inst+2] - workLagRsi[_indC][_inst+3];
            else	   CD = CD + workLagRsi[_indC][_inst+3] - workLagRsi[_indC][_inst+2];
         }            
         workLagRsi[_indC][_inst+4] = (CU + CD != 0) ? CU / (CU + CD) : 0;

   //
   //---
   //

   return(iLaGuerreFil(workLagRsi[_indC][_inst+4],smooth,(int)smoothSpeed,i,1));
}
//
//---
//
#define _lagFilInstances 2
#define _lagFilInstancesSize 4
#define _lagFilRingSize 5
double workLagFil[_lagFilRingSize][_lagFilInstances*_lagFilInstancesSize];
double iLaGuerreFil(double price, double gamma, int smoothSpeed, int i, int instance=0)
{
   if (gamma<=0) return(price);
   int _indP = (i-1)%_lagFilRingSize;
   int _indC = (i  )%_lagFilRingSize;
   int _inst = instance*_lagFilInstancesSize;

   //
   //---
   //
      
      workLagFil[_indC][_inst  ] = (i>0) ? (1.0 - gamma)*price                                            + gamma*workLagFil[_indP][_inst  ] : price;
	   workLagFil[_indC][_inst+1] = (i>0) ? -gamma*workLagFil[_indC][_inst  ] + workLagFil[_indP][_inst  ] + gamma*workLagFil[_indP][_inst+1] : price;
	   workLagFil[_indC][_inst+2] = (i>0) ? -gamma*workLagFil[_indC][_inst+1] + workLagFil[_indP][_inst+1] + gamma*workLagFil[_indP][_inst+2] : price;
	   workLagFil[_indC][_inst+3] = (i>0) ? -gamma*workLagFil[_indC][_inst+2] + workLagFil[_indP][_inst+2] + gamma*workLagFil[_indP][_inst+3] : price;

      //
      //---
      //
 
      static double coeffs[]={-1,0,0,0};
      if (coeffs[0]==-1)
      {
         smoothSpeed = MathMax(MathMin(smoothSpeed,6),0);   
         switch (smoothSpeed)
         {
            case 0: coeffs[0] = 1; coeffs[1] = 1; coeffs[2] = 1; coeffs[3] = 1; break;
            case 1: coeffs[0] = 1; coeffs[1] = 1; coeffs[2] = 2; coeffs[3] = 1; break;
            case 2: coeffs[0] = 1; coeffs[1] = 2; coeffs[2] = 2; coeffs[3] = 1; break;
            case 3: coeffs[0] = 2; coeffs[1] = 2; coeffs[2] = 2; coeffs[3] = 1; break;
            case 4: coeffs[0] = 2; coeffs[1] = 3; coeffs[2] = 2; coeffs[3] = 1; break;
            case 5: coeffs[0] = 3; coeffs[1] = 3; coeffs[2] = 2; coeffs[3] = 1; break;
            case 6: coeffs[0] = 4; coeffs[1] = 3; coeffs[2] = 2; coeffs[3] = 1; break;
         }
      }      
      double sumc = 0; for (int k=0; k<4; k++) sumc += coeffs[k];
   return((coeffs[0]*workLagFil[_indC][_inst+0]+coeffs[1]*workLagFil[_indC][_inst+1]+coeffs[2]*workLagFil[_indC][_inst+2]+coeffs[3]*workLagFil[_indC][_inst+3])/sumc);
}
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   switch(tprice)
     {
      case PRICE_CLOSE:     return(close[i]);
      case PRICE_OPEN:      return(open[i]);
      case PRICE_HIGH:      return(high[i]);
      case PRICE_LOW:       return(low[i]);
      case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
      case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
      case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
     }
   return(0);
  }
//------------------------------------------------------------------
