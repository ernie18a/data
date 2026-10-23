//+------------------------------------------------------------------+
//|                                         candlestick_patterns.mq5 |
//|                             Copyright 2024-2025, globus2008      |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2024-2025, globus2008"
#property description "Candlestick Patterns"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers    20
#property indicator_plots      20
#property indicator_type1      DRAW_ARROW
#property indicator_color1     clrRoyalBlue

#property indicator_type2      DRAW_ARROW
#property indicator_color2     clrDeepPink

#property indicator_type3      DRAW_NONE
#property indicator_type4      DRAW_NONE
#property indicator_type5      DRAW_NONE
#property indicator_type6      DRAW_NONE
#property indicator_type7      DRAW_NONE
#property indicator_type8      DRAW_NONE
#property indicator_type9      DRAW_NONE
#property indicator_type10      DRAW_NONE
#property indicator_type11      DRAW_NONE
#property indicator_type12      DRAW_NONE
#property indicator_type13      DRAW_NONE
#property indicator_type14      DRAW_NONE
#property indicator_type15      DRAW_NONE
#property indicator_type16      DRAW_NONE
#property indicator_type17      DRAW_NONE
#property indicator_type18      DRAW_NONE
#property indicator_type19      DRAW_NONE
#property indicator_type20      DRAW_NONE

//--- indicator buffer
double    bullish_patterns[];
double    bearish_patterns[];
double    Value_bullish[];
double    Value_bearish[];
double    be_three_black_cows[];
double    bu_three_white_soldiers[];
double    bu_bullish_kicker[];
double    be_bearish_kicker[];
double    bu_bullish_engulfing[];
double    be_bearish_engulfing[];
double    bu_bullish_harami[];
double    be_bearish_harami[];
double    bu_three_line_strike[];
double    be_three_line_strike[];
double    bu_three_inside_up[];
double    be_three_inside_down[];
double    bu_three_outside_up[];
double    be_three_outside_down[];
double    bu_tweezer_bottom[];
double    be_tweezer_top[];

#property indicator_label1  "Bullish_patterns"
#property indicator_label2  "Bearish_patterns"
#property indicator_label3  "Value_bullish"
#property indicator_label4  "Value_bearish"
#property indicator_label5  "be_three_black_cows"
#property indicator_label6  "bu_three_white_soldiers"
#property indicator_label7  "bu_bullish_kicker"
#property indicator_label8  "be_bearish_kicker"
#property indicator_label9  "bu_bullish_engulfing"
#property indicator_label10  "be_bearish_engulfing"
#property indicator_label11  "bu_bullish_harami"
#property indicator_label12  "be_bearish_harami"
#property indicator_label13  "bu_three_line_strike"
#property indicator_label14  "be_three_line_strike"
#property indicator_label15  "bu_three_inside_up"
#property indicator_label16  "be_three_inside_down"
#property indicator_label17  "bu_three_outside_up"
#property indicator_label18  "be_three_outside_down"
#property indicator_label19  "bu_tweezer_bottom"
#property indicator_label20  "be_tweezer_top"

input int Minimal_Value = 2;

enum ENUM_PATTERN_IMPORTANCE
  {
   NONE,
   LOW,
   MODERATE,
   HIGH
  };

input ENUM_PATTERN_IMPORTANCE imp_3C_three_white_soldiers_black_cows = MODERATE;
input ENUM_PATTERN_IMPORTANCE imp_2C_bullish_bearish_kicker = MODERATE;
input ENUM_PATTERN_IMPORTANCE imp_2C_bullish_bearish_engulfing = MODERATE;
input ENUM_PATTERN_IMPORTANCE imp_2C_bullish_bearish_harami = MODERATE;
input ENUM_PATTERN_IMPORTANCE imp_4C_three_line_strike = HIGH;
input ENUM_PATTERN_IMPORTANCE imp_3C_three_inside = MODERATE;
input ENUM_PATTERN_IMPORTANCE imp_3C_three_outside = MODERATE;
input ENUM_PATTERN_IMPORTANCE imp_2C_tweezer = MODERATE;


//+------------------------------------------------------------------+
//| Candlestick Patterns initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,bullish_patterns,INDICATOR_DATA);
   SetIndexBuffer(1,bearish_patterns,INDICATOR_DATA);
   SetIndexBuffer(2,Value_bullish,INDICATOR_DATA);
   SetIndexBuffer(3,Value_bearish,INDICATOR_DATA);
   SetIndexBuffer(4,be_three_black_cows,INDICATOR_DATA);
   SetIndexBuffer(5,bu_three_white_soldiers,INDICATOR_DATA);
   SetIndexBuffer(6,bu_bullish_kicker,INDICATOR_DATA);
   SetIndexBuffer(7,be_bearish_kicker,INDICATOR_DATA);
   SetIndexBuffer(8,bu_bullish_engulfing,INDICATOR_DATA);
   SetIndexBuffer(9,be_bearish_engulfing,INDICATOR_DATA);
   SetIndexBuffer(10,bu_bullish_harami,INDICATOR_DATA);
   SetIndexBuffer(11,be_bearish_harami,INDICATOR_DATA);
   SetIndexBuffer(12,bu_three_line_strike,INDICATOR_DATA);
   SetIndexBuffer(13,be_three_line_strike,INDICATOR_DATA);
   SetIndexBuffer(14,bu_three_inside_up,INDICATOR_DATA);
   SetIndexBuffer(15,be_three_inside_down,INDICATOR_DATA);
   SetIndexBuffer(16,bu_three_outside_up,INDICATOR_DATA);
   SetIndexBuffer(17,be_three_outside_down,INDICATOR_DATA);
   SetIndexBuffer(18,bu_tweezer_bottom,INDICATOR_DATA);
   SetIndexBuffer(19,be_tweezer_top,INDICATOR_DATA);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- set style STYLE_DOT for second line
   PlotIndexSetInteger(0,PLOT_ARROW,161);
   PlotIndexSetInteger(1,PLOT_ARROW,164);
//--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"Candlestick Patterns");
   PlotIndexSetString(0,PLOT_LABEL,"Bullish_patterns");
   PlotIndexSetString(1,PLOT_LABEL,"Bearish_patterns");
//--- sets drawing line to empty value

   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(8,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(9,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(10,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(11,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(12,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(13,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(14,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(15,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(16,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(17,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(18,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(19,PLOT_EMPTY_VALUE,0.0);


//--- initialization done
  }
  
void OnDeinit(const int reason)
{
   ArrayFree(bullish_patterns);
   ArrayFree(bearish_patterns);
   ArrayFree(Value_bullish);
   ArrayFree(Value_bearish);
   ArrayFree(be_three_black_cows);
   ArrayFree(bu_three_white_soldiers);
   ArrayFree(bu_bullish_kicker);
   ArrayFree(be_bearish_kicker);
   ArrayFree(bu_bullish_engulfing);
   ArrayFree(be_bearish_engulfing);
   ArrayFree(bu_bullish_harami);
   ArrayFree(be_bearish_harami);
   ArrayFree(bu_three_line_strike);
   ArrayFree(be_three_line_strike);
   ArrayFree(bu_three_inside_up);
   ArrayFree(be_three_inside_down);
   ArrayFree(bu_three_outside_up);
   ArrayFree(be_three_outside_down);
   ArrayFree(bu_tweezer_bottom);
   ArrayFree(be_tweezer_top);
}

  
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
   if(rates_total<100)
      return(0);

//--- Block for calculating indicator values
   int start=1;
   if(prev_calculated>0)
      start=prev_calculated-1;
      
   start = MathMax(10, start);     
      
   //--- Calculation loop
   for(int i= start; i<rates_total;i++)
     {
         
        Value_bullish[i] = 0;
        Value_bearish[i] = 0;
        bullish_patterns[i] = 0;
        bearish_patterns[i] = 0;
        be_three_black_cows[i] = 0;
        bu_three_white_soldiers[i] = 0;
        bu_bullish_kicker[i] = 0;
        be_bearish_kicker[i] = 0;
        bu_bullish_engulfing[i] = 0;
        be_bearish_engulfing[i] = 0;
        bu_bullish_harami[i] = 0;
        be_bearish_harami[i] = 0;
        bu_three_line_strike[i] = 0;
        be_three_line_strike[i] = 0;
        bu_three_inside_up[i] = 0;
        be_three_inside_down[i] = 0;
        bu_three_outside_up[i] = 0;
        be_three_outside_down[i] = 0;
        bu_tweezer_bottom[i] = 0;
        be_tweezer_top[i] = 0;

         cal_be_three_black_cows(open,high,low,close,time,i);
         cal_bu_three_white_soldiers(open,high,low,close,time,i);
         cal_bu_bullish_kicker(open,high,low,close,time,i);
         cal_be_bearish_kicker(open,high,low,close,time,i);
         cal_bu_bullish_engulfing(open,high,low,close,time,i);
         cal_be_bearish_engulfing(open,high,low,close,time,i);
         cal_bu_bullish_harami(open,high,low,close,time,i);
         cal_be_bearish_harami(open,high,low,close,time,i);
         cal_bu_three_line_strike(open,high,low,close,time,i);
         cal_be_three_line_strike(open,high,low,close,time,i);
         cal_bu_three_inside_up(open,high,low,close,time,i);
         cal_be_three_inside_down(open,high,low,close,time,i);
         cal_bu_three_outside_up(open,high,low,close,time,i);
         cal_be_three_outside_down(open,high,low,close,time,i);
         cal_bu_tweezer_bottom(open,high,low,close,time,i);
         cal_be_tweezer_top(open,high,low,close,time,i);
         
         if(i < 10){
            continue;         
         }

         
      if(be_three_black_cows[i]>0)
        {
         if(imp_3C_three_white_soldiers_black_cows!=NONE)
            bearish_patterns[i]=be_three_black_cows[i];
         Value_bearish[i]+=importance_value(imp_3C_three_white_soldiers_black_cows);
        }
      if(bu_three_white_soldiers[i]>0)
        {
         if(imp_3C_three_white_soldiers_black_cows!=NONE)
            bullish_patterns[i]=bu_three_white_soldiers[i];
         Value_bullish[i]+=importance_value(imp_3C_three_white_soldiers_black_cows);
        }
      if(bu_bullish_kicker[i]>0)
        {
         if(imp_2C_bullish_bearish_kicker!=NONE)
            bullish_patterns[i]=bu_bullish_kicker[i];
         Value_bullish[i]+=importance_value(imp_2C_bullish_bearish_kicker);
        }
      if(be_bearish_kicker[i]>0)
        {
         if(imp_2C_bullish_bearish_kicker!=NONE)
            bearish_patterns[i]=be_bearish_kicker[i];
         Value_bearish[i]+=importance_value(imp_2C_bullish_bearish_kicker);
        }
      if(bu_bullish_engulfing[i]>0)
        {
         if(imp_2C_bullish_bearish_engulfing!=NONE)
            bullish_patterns[i]=bu_bullish_engulfing[i];
         Value_bullish[i]+=importance_value(imp_2C_bullish_bearish_engulfing);
        }
      if(be_bearish_engulfing[i]>0)
        {
         if(imp_2C_bullish_bearish_engulfing!=NONE)
            bearish_patterns[i]=be_bearish_engulfing[i];
         Value_bearish[i]+=importance_value(imp_2C_bullish_bearish_engulfing);
        }
      if(bu_bullish_harami[i]>0)
        {
         if(imp_2C_bullish_bearish_engulfing!=NONE)
            bullish_patterns[i]=bu_bullish_harami[i];
         Value_bullish[i]+=importance_value(imp_2C_bullish_bearish_harami);
        }
      if(be_bearish_harami[i]>0)
        {
         if(imp_2C_bullish_bearish_engulfing!=NONE)
            bearish_patterns[i]=be_bearish_harami[i];
         Value_bearish[i]+=importance_value(imp_2C_bullish_bearish_harami);
        }
      if(bu_three_line_strike[i]>0)
        {
         if(imp_4C_three_line_strike!=NONE)
            bullish_patterns[i]=bu_three_line_strike[i];
         Value_bullish[i]+=importance_value(imp_4C_three_line_strike);
        }
      if(be_three_line_strike[i]>0)
        {
         if(imp_4C_three_line_strike!=NONE)
            bearish_patterns[i]=be_three_line_strike[i];
         Value_bearish[i]+=importance_value(imp_4C_three_line_strike);
        }
      if(bu_three_inside_up[i]>0)
        {
         if(imp_3C_three_inside!=NONE)
            bullish_patterns[i]=bu_three_inside_up[i];
         Value_bullish[i]+=importance_value(imp_3C_three_inside);
        }
      if(be_three_inside_down[i]>0)
        {
         if(imp_3C_three_inside!=NONE)
            bearish_patterns[i]=be_three_inside_down[i];
         Value_bearish[i]+=importance_value(imp_3C_three_inside);
        }
      if(bu_three_outside_up[i]>0)
        {
         if(imp_3C_three_outside!=NONE)
            bullish_patterns[i]=bu_three_outside_up[i];
         Value_bullish[i]+=importance_value(imp_3C_three_outside);
        }
      if(be_three_outside_down[i]>0)
        {
         if(imp_3C_three_inside!=NONE)
            bearish_patterns[i]=be_three_outside_down[i];
         Value_bearish[i]+=importance_value(imp_3C_three_outside);
        }
      if(bu_tweezer_bottom[i]>0)
        {
         if(imp_2C_tweezer!=NONE)
            bullish_patterns[i]=bu_tweezer_bottom[i];
         Value_bullish[i]+=importance_value(imp_2C_tweezer);
        }
      if(be_tweezer_top[i]>0)
        {
         if(imp_2C_tweezer!=NONE)
            bearish_patterns[i]=be_tweezer_top[i];
         Value_bearish[i]+=importance_value(imp_2C_tweezer);
        }


      if(Value_bullish[i]-Value_bearish[i]>=Minimal_Value)
        {
         //Print("Value_bullish:",Value_bullish[i],", time:",time[i]);
        }
      else
         bullish_patterns[i]=0;
      if(Value_bearish[i]-Value_bullish[i]>=Minimal_Value)
        {
         //Print("Value_bearish:",Value_bearish[i],", time:",time[i]);
        }
      else
         bearish_patterns[i]=0;
      if(Value_bullish[i]>=Minimal_Value && Value_bearish[i]>=Minimal_Value)
        {
         //Print("Value_bullish:",Value_bullish[i],", Value_bearish:",Value_bearish[i],", time:",time[i]);
        }

     }
     
   
//     

//--- return value of prev_calculated for next call

//--- OnCalculate done. Return new prev_calculated
   return(rates_total);
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int importance_value(ENUM_PATTERN_IMPORTANCE importance)
  {
   if(importance == NONE)
      return 0;
   if(importance == LOW)
      return 1;
   if(importance == MODERATE)
      return 2;
   if(importance == HIGH)
      return 3;

   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cal_be_three_black_cows(const double &open[],
                             const double &high[],
                             const double &low[],
                             const double &close[],
                             const datetime &time[],
                             int i)
  {

   if(open[i-3]>close[i-3] && open[i-2]>close[i-2] && open[i-1]>close[i-1] && open[i-4]<close[i-4] &&
      high[i-3]>high[i-2] && high[i-2]>high[i-1] && close[i-3]>close[i-2] && close[i-2]>close[i-1] &&
      MathAbs((open[i-7]+close[i-7])/2)<MathAbs((open[i-4]+close[i-4])/2) && MathAbs((open[i-10]+close[i-10])/2)<MathAbs((open[i-7]+close[i-7])/2))
     {
      be_three_black_cows[i]=open[i];
      //Print("be_three_black_cows:",time[i]);
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cal_bu_three_white_soldiers(const double &open[],
                                 const double &high[],
                                 const double &low[],
                                 const double &close[],
                                 const datetime &time[],
                                 int i)
  {

   if(open[i-3]<close[i-3] && open[i-2]<close[i-2] && open[i-1]<close[i-1] && open[i-4]>close[i-4] &&
      low[i-3]<low[i-2] && low[i-2]<low[i-1] && close[i-3]<close[i-2] && close[i-2]<close[i-1] &&
      MathAbs((open[i-7]+close[i-7])/2)>MathAbs((open[i-4]+close[i-4])/2) && MathAbs((open[i-10]+close[i-10])/2)>MathAbs((open[i-7]+close[i-7])/2))
     {
      bu_three_white_soldiers[i]=open[i];
      //Print("bu_three_white_soldiers:",time[i]);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cal_bu_bullish_kicker(const double &open[],
                           const double &high[],
                           const double &low[],
                           const double &close[],
                           const datetime &time[],
                           int i)
  {

   if(open[i-2]>close[i-2] && open[i-1]<close[i-1] && high[i-2]<low[i-1])
     {
      bu_bullish_kicker[i]=open[i];
      //Print("bu_bullish_kicker:",time[i]);
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cal_be_bearish_kicker(const double &open[],
                           const double &high[],
                           const double &low[],
                           const double &close[],
                           const datetime &time[],
                           int i)
  {

   if(open[i-2]<close[i-2] && open[i-1]>close[i-1] && low[i-2]>high[i-1])
     {
      be_bearish_kicker[i]=open[i];
      //Print("be_bearish_kicker:",time[i]);
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cal_bu_bullish_engulfing(const double &open[],
                              const double &high[],
                              const double &low[],
                              const double &close[],
                              const datetime &time[],
                              int i)
  {

   if(open[i-2]>close[i-2] && open[i-1]<close[i-1] && (high[i-2]-low[i-2])<(high[i-1]-low[i-1]) &&
      open[i-2]<close[i-1] && close[i-2]>open[i-1])
     {
      bu_bullish_engulfing[i]=open[i];
      //Print("bu_bullish_engulfing:",time[i]);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cal_be_bearish_engulfing(const double &open[],
                              const double &high[],
                              const double &low[],
                              const double &close[],
                              const datetime &time[],
                              int i)
  {

   if(open[i-2]<close[i-2] && open[i-1]>close[i-1] && (high[i-2]-low[i-2])<(high[i-1]-low[i-1]) &&
      open[i-2]>close[i-1] && close[i-2]<open[i-1])
     {
      be_bearish_engulfing[i]=open[i];
      //Print("be_bearish_engulfing:",time[i]);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cal_bu_bullish_harami(const double &open[],
                           const double &high[],
                           const double &low[],
                           const double &close[],
                           const datetime &time[],
                           int i)
  {

   if(open[i-2]>close[i-2] && open[i-1]<close[i-1] && (high[i-2]-low[i-2])>(high[i-1]-low[i-1]) &&
      open[i-2]>close[i-1] && close[i-2]<open[i-1])
     {
      bu_bullish_harami[i]=open[i];
      //Print("bu_bullish_harami:",time[i]);
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cal_be_bearish_harami(const double &open[],
                           const double &high[],
                           const double &low[],
                           const double &close[],
                           const datetime &time[],
                           int i)
  {

   if(open[i-2]<close[i-2] && open[i-1]>close[i-1] && (high[i-2]-low[i-2])>(high[i-1]-low[i-1]) &&
      open[i-2]<close[i-1] && close[i-2]>open[i-1])
     {
      be_bearish_harami[i]=open[i];
      //Print("be_bearish_harami:",time[i]);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cal_bu_three_line_strike(const double &open[],
                              const double &high[],
                              const double &low[],
                              const double &close[],
                              const datetime &time[],
                              int i)
  {

   if(open[i-4]<close[i-4] && open[i-3]<close[i-3] && open[i-2]<close[i-2] && open[i-1]>close[i-1] &&
      low[i-4]>close[i-1] && close[i-4]<close[i-3] && close[i-3]<close[i-2] &&
      low[i-4]<low[i-3] && low[i-3]<low[i-2])
     {
      bu_three_line_strike[i]=open[i];
      //Print("bu_three_line_strike:",time[i]);
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cal_be_three_line_strike(const double &open[],
                              const double &high[],
                              const double &low[],
                              const double &close[],
                              const datetime &time[],
                              int i)
  {

   if(open[i-4]>close[i-4] && open[i-3]>close[i-3] && open[i-2]>close[i-2] && open[i-1]<close[i-1] &&
      high[i-4]<close[i-1] && close[i-4]>close[i-3] && close[i-3]>close[i-2] &&
      high[i-4]>high[i-3] && high[i-3]>high[i-2])
     {
      bu_three_line_strike[i]=open[i];
      //Print("be_three_line_strike:",time[i]);
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cal_bu_three_inside_up(const double &open[],
                            const double &high[],
                            const double &low[],
                            const double &close[],
                            const datetime &time[],
                            int i)
  {

   if(open[i-3]>close[i-3] && open[i-2]<close[i-2] && open[i-1]<close[i-1] &&
      MathAbs((open[i-3]+close[i-3])/2)<close[i-2] && open[i-3]<close[i-1] && close[i-2]<open[i-3])
     {
      bu_three_inside_up[i]=open[i];
      //Print("bu_three_inside_up:",time[i]);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cal_be_three_inside_down(const double &open[],
                              const double &high[],
                              const double &low[],
                              const double &close[],
                              const datetime &time[],
                              int i)
  {

   if(open[i-3]<close[i-3] && open[i-2]>close[i-2] && open[i-1]>close[i-1] &&
      MathAbs((open[i-3]+close[i-3])/2)>close[i-2] && close[i-3]>open[i-1] && close[i-2]>open[i-3])
     {
      be_three_inside_down[i]=open[i];
      //Print("be_three_inside_down:",time[i]);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cal_bu_three_outside_up(const double &open[],
                             const double &high[],
                             const double &low[],
                             const double &close[],
                             const datetime &time[],
                             int i)
  {

   if(open[i-3]>close[i-3] && open[i-2]<close[i-2] && open[i-1]<close[i-1] && (high[i-3]-low[i-3])<(high[i-2]-low[i-2]) &&
      open[i-3]<close[i-2] && close[i-3]>open[i-2] && close[i-2]<close[i-1])
     {
      bu_three_outside_up[i]=open[i];
      //Print("bu_three_outside_up:",time[i]);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cal_be_three_outside_down(const double &open[],
                               const double &high[],
                               const double &low[],
                               const double &close[],
                               const datetime &time[],
                               int i)
  {

   if(open[i-3]<close[i-3] && open[i-2]>close[i-2] && open[i-1]>close[i-1] && (high[i-3]-low[i-3])<(high[i-2]-low[i-2]) &&
      open[i-3]>close[i-2] && close[i-3]<open[i-2] && close[i-2]>close[i-1])
     {
      be_three_outside_down[i]=open[i];
      //Print("be_three_outside_down:",time[i]);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cal_bu_tweezer_bottom(const double &open[],
                           const double &high[],
                           const double &low[],
                           const double &close[],
                           const datetime &time[],
                           int i)
  {

   if(open[i-2]>close[i-2] && open[i-1]<close[i-1] && low[i-2]==close[i-2] && low[i-1]==open[i-1])
     {
      bu_tweezer_bottom[i]=open[i];
      //Print("bu_tweezer_bottom:",time[i]);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cal_be_tweezer_top(const double &open[],
                        const double &high[],
                        const double &low[],
                        const double &close[],
                        const datetime &time[],
                        int i)
  {

   if(open[i-2]<close[i-2] && open[i-1]>close[i-1] && high[i-2]==close[i-2] && high[i-1]==open[i-1])
     {
      be_tweezer_top[i]=open[i];
      //Print("be_tweezer_top:",time[i]);
     }
  }
//+-------------------------------
//+------------------------------------------------------------------+
