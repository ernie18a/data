//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Volume pressure"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_label1  "Zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'220,235,220',C'235,220,220'
#property indicator_label2  "Volume pressure"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrMediumSeaGreen
#property indicator_label3  "Volume pressure back"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrangeRed

//
//--- input parameters
//

enum enVolType
{
   vol_ticks, // Use tick volume
   vol_real   // Use real volume (if available)
};
input enVolType inpVolType = vol_ticks; // Volume type

//
//--- indicator buffers
//
double vala[],valp[],fillu[],filld[];

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,fillu,INDICATOR_DATA);
         SetIndexBuffer(1,filld,INDICATOR_DATA);
         SetIndexBuffer(2,vala ,INDICATOR_DATA);
         SetIndexBuffer(3,valp ,INDICATOR_DATA);
   //
   //--- indicator short name assignment
   //

   IndicatorSetString(INDICATOR_SHORTNAME,"Volume pressure ("+StringSubstr(EnumToString(inpVolType),5)+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      double _diff   = (close[i]-open[i])/(_Point*100);
      double _volume = (inpVolType==vol_ticks) ? (double)tick_volume[i] : (double)volume[i];
         valp[i] = filld[i] = (i>0) ? vala[i-1] : 0;
         vala[i] = fillu[i] = valp[i]+(_diff!=0 ? _volume/_diff : 0);
   }
   return(i);
}