//+------------------------------------------------------------------+
//|                                      SpreadPerHourStatistics.mq5 |
//|                               Copyright 2016, Alexander Sinitsyn |
//|                              https://www.mql5.com/en/users/wongv |
//+------------------------------------------------------------------+
//---- indicator settings
#property copyright "Copyright 2016, Alexander Sinitsyn"
#property link      "https://www.mql5.com/en/users/wongv"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0
//---- extended DOW enum
enum ENUM_DAY_OF_WEEK__
  {
   ANY_=-1,// Any
   MONDAY_=MONDAY,// Monday
   TUESDAY_=TUESDAY,// Tuesday
   WEDNESDAY_=WEDNESDAY,// Wednesday
   THURSDAY_=THURSDAY,// Thursday
   FRIDAY_=FRIDAY,// Friday
   SATURDAY_=SATURDAY,// Saturday
   SUNDAY_=SUNDAY,// Sunday
  };

//---- input parameters
input color                InpColor=clrDarkGray;      // Color
input ENUM_DAY_OF_WEEK__   InpDayOfWeek=ANY_;         // Day of week
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() 
  {
//---- add line objects for output
   DebugAddLine(0);
   DebugAddLine(1);
   DebugAddLine(2);
   DebugAddLine(3);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|  OnDeinit function                                               |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---- cleanup on exit
   DebugRemoveLines();
  }
//+------------------------------------------------------------------+
//|  OnCalculate function                                            |
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
   FillSpread();

   ShowSpread();

   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Add debug line object method                                    |
//+------------------------------------------------------------------+
void DebugAddLine(int num)
  {
//---- limit count of lines
   if(num>15 || num<-1){ return; }
   int line_height=14;
   string lname=StringFormat("__lbl_w_%d",num);

//---- delete object if already exists
   if(ObjectFind(0,lname)!=-1){ ObjectDelete(0,lname); }

//---- create new text object
   ObjectCreate(0,lname,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,lname,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,lname,OBJPROP_XDISTANCE,288);
   ObjectSetInteger(0,lname,OBJPROP_YDISTANCE,20+((line_height)*num));
   ObjectSetInteger(0,lname,OBJPROP_COLOR,(num==-1?clrRed:InpColor));
   ObjectSetString(0,lname,OBJPROP_FONT,"Tahoma");
   ObjectSetString(0,lname,OBJPROP_TEXT," ");
  }
//+------------------------------------------------------------------+
//|  Print message method                                            |
//+------------------------------------------------------------------+
void DebugPrint(int line,string msg)
  {
   string lname=StringFormat("__lbl_w_%d",line);

   ObjectSetString(0,lname,OBJPROP_TEXT,msg!=""?msg:" ");
  }
void DebugPrint(string msg){ DebugPrint(0,msg); }
//+------------------------------------------------------------------+
//|  Debug cleanup method                                            |
//+------------------------------------------------------------------+
void DebugRemoveLines()
  {
   for(int num=-1;num<16;num++)
     {
      string lname=StringFormat("__lbl_w_%d",num);
      if(ObjectFind(0,lname)!=-1){ ObjectDelete(0,lname); }
     }
  }
//+------------------------------------------------------------------+
//|  Join array to string method                                     |
//+------------------------------------------------------------------+
string StringJoin(const double &in_array[],int precision=2,int idx_from=0,int idx_to=-1,string separator=" ") 
  {
   string result="";

   int __size=ArraySize(in_array)-1;
   int __idx_to=idx_to==-1?__size:MathMin(__size,idx_to);

   if(__idx_to<idx_from){return "error"; }

   for(int i=idx_from;i<=__idx_to;i++) 
     {
      StringAdd(result,DoubleToString(in_array[i],precision));
      StringAdd(result,separator);
     }
   StringTrimRight(result); return result;
  }
//+------------------------------------------------------------------+
//| Store spread statistics to array method                          |
//+------------------------------------------------------------------+
//---- ticks count
double spread_c[24];
//---- accumulated spread
double spread_a[24];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FillSpread()
  {
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);
   double __points=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
//---- determine current spread from tick Ask-Bid difference
   int __spread=(int)MathRound((tick.ask-tick.bid)/__points);

   MqlDateTime __mdt;
   TimeToStruct(TimeCurrent(),__mdt);

//---- store tick count and accumulated spread in arrays
   if(InpDayOfWeek==ANY_ || __mdt.day_of_week==(int)InpDayOfWeek)
     {
      spread_c[__mdt.hour]++;
      spread_a[__mdt.hour]+=__spread;
     }
  }
//+------------------------------------------------------------------+
//| Display per-hour spreads                                         |
//+------------------------------------------------------------------+
void ShowSpread()
  {
   double avg_sp[24];
   for(int i=0;i<24;i++)
     {
      if(spread_c[i]>0){ avg_sp[i]=spread_a[i]/spread_c[i]; } else avg_sp[i]=0;
     }

   DebugPrint(0,"spreads for "+(InpDayOfWeek!=ANY_?EnumToString(InpDayOfWeek):"all days"));
   DebugPrint(1,"0-7    "+StringJoin(avg_sp,1,0,7,"  "));
   DebugPrint(2,"8-15  "+StringJoin(avg_sp,1,8,15,"  "));
   DebugPrint(3,"16-23 "+StringJoin(avg_sp,1,16,23,"  "));
  }
//+------------------------------------------------------------------+
