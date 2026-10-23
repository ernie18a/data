//+------------------------------------------------------------------+
//|                               https://www.facebook.com/traderknj |
//|                                      Copyright 2016, KNJ company |
//|                                              TraderKNJ@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "TraderKNJ@yahoo.com"
#property link      "https://www.facebook.com/traderknj"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red


//---- input parameters
extern string       CornerNote1="0 = top left, 1 = top right";
extern string       CornerNote2="2 = bottom left, 3 = bottom right";
extern int          corner=1;
extern int          Space=0;
extern color        labelColor=DeepSkyBlue;
extern color        clockColor=DeepSkyBlue;
extern color        PriceColor=Blue;
extern color        SymbolColor=Blue;
extern string       YourLocation="Viet Nam";
extern string       TraderName="TraderKNJ (^_^)";
extern color        tradernamecolor=DeepSkyBlue;// Màu tên trader
extern int          tradernamesize=10;// Cỡ chữ tên trader
extern string       tradernamefont="Arial";// Font chữ tên trader

//---- buffers
int    topOff=270+Space;
double s1[];
double stoploss=100;//-- % risk/free margin
double ExtMapBuffer1[];
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start()
  {
   int TimeFrame=Period();
   switch(TimeFrame)
     {
      case 1  : string TimeFrameStr="1 Minute";  break;
      case 5  :     TimeFrameStr=   "5 Minutes";  break;
      case 15 :     TimeFrameStr=   "15 Minutes";   break;
      case 30 :     TimeFrameStr=   "30 Minutes";   break;
      case 60 :     TimeFrameStr=   "1 Hour";  break;
      case 240  :   TimeFrameStr=   "4 Hours";  break;
      case 1440 :   TimeFrameStr=   "1 Day";  break;
      case 10080 :  TimeFrameStr=   "1 Week";  break;
      case 43200 :  TimeFrameStr=   "1 Month";   break;
      default  :    TimeFrameStr=   "CurrTF";
     }
   switch(DayOfWeek()) // Header of the 'switch'
     {
      case 0 : string thu="Sunday";     break;  // Start of the 'switch' body
      case 1 : thu="Monday";     break;
      case 2 : thu="Tuesday";     break;
      case 3 : thu="Wednesday";     break;
      case 4 : thu="Thursday";     break;
      case 5 : thu="Friday";     break;
      case 6 : thu="Saturday";     break;
      default : thu="Holiday";
     }
   double Lots=MathFloor(AccountFreeMargin()/MarketInfo(Symbol(),MODE_MARGINREQUIRED)
                         /MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP);

// Time remain & spread
     {
      int m,s;
      m=Time[0]+Period()*60-CurTime();
      s=m%60;
      m=(m-s)/60;
      int spread=MarketInfo(Symbol(), MODE_SPREAD);
      string _sp="",_m="",_s="";
      if(spread<10) _sp=" ";
      else if(spread<100) _sp=" ";
      if(m<10) _m="0";
      if(s<10) _s="0";
     }

// Set Object
   ObjectSetText("stopout1","StopOut Level:",10,"Arial",labelColor);
   ObjectSetText("stopout2",(AccountStopoutLevel()+"%"),10,"Arial",clockColor);
   ObjectSetText("swaplong1","Swap Long:",10,"Arial",labelColor);
   ObjectSetText("swaplong2",MarketInfo(Symbol(),MODE_SWAPLONG),10,"Arial",clockColor);
   ObjectSetText("swapshort1","Swap Short:",10,"Arial",labelColor);
   ObjectSetText("swapshort2",MarketInfo(Symbol(),MODE_SWAPSHORT),10,"Arial",clockColor);
   ObjectSetText("lv1","Leverage:",10,"Arial",labelColor);
   ObjectSetText("lv2",AccountLeverage(),10,"Arial",clockColor);
   ObjectSetText("tf","TF: "+TimeFrameStr,15,"Arial",labelColor);
   ObjectSetText("trader",TraderName,tradernamesize,tradernamefont,tradernamecolor);
   ObjectSetText("thungay",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),10,"Arial",labelColor);
   ObjectSetText("vndate",TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),10,"Arial",labelColor);
   ObjectSetText("vn2",YourLocation+" Time Zone",10,"Arial",clockColor);
   ObjectSetText("br2","Broker: "+thu,10,"Arial",clockColor);
   ObjectSetText("brol","Full margin:",10,"Arial",labelColor);
   ObjectSetText("brot",Lots,10,"Arial",clockColor);
   ObjectSetText("locl","Time remain:",10,"Arial",labelColor);
   ObjectSetText("loct",(_m+DoubleToStr(m,0)+":"+_s+DoubleToStr(s,0)),10,"Arial",clockColor);
   ObjectSetText("gmtl","Spread:",10,"Arial",labelColor);
   ObjectSetText("gmtt",DoubleToStr(spread,0)+_sp,10,"Arial",clockColor);
   ObjectSetText("symbt",Symbol(),18,"Arial Bold",SymbolColor);
   ObjectSetText("mprice",Bid,28,"Arial Bold",PriceColor);

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void ObjectMakeLabel(string n,int xoff,int yoff)
  {
   ObjectCreate(n,OBJ_LABEL,0,0,0);
   ObjectSet(n,OBJPROP_CORNER,corner);
   ObjectSet(n,OBJPROP_XDISTANCE,xoff);
   ObjectSet(n,OBJPROP_YDISTANCE,yoff);
   ObjectSet(n,OBJPROP_BACK,true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {

//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
//----
   int top=topOff;
   int left=50;
   int offset=15;
   ObjectMakeLabel("trader",5,top-offset);
   offset+=15;
   ObjectMakeLabel("locl",left,top-offset);
   ObjectMakeLabel("loct",5,top-offset);
   offset+=15;
   ObjectMakeLabel("lv1",left,top-offset);
   ObjectMakeLabel("lv2",5,top-offset);
   offset+=15;
   ObjectMakeLabel("stopout1",left,top-offset);
   ObjectMakeLabel("stopout2",5,top-offset);
   offset+=15;
   ObjectMakeLabel("swaplong1",left,top-offset);
   ObjectMakeLabel("swaplong2",5,top-offset);
   offset+=15;
   ObjectMakeLabel("swapshort1",left,top-offset);
   ObjectMakeLabel("swapshort2",5,top-offset);
   offset+=15;
   ObjectMakeLabel("brol",left,top-offset);
   ObjectMakeLabel("brot",5,top-offset);
   offset+=15;
   ObjectMakeLabel("gmtl",left,top-offset);
   ObjectMakeLabel("gmtt",5,top-offset);
   offset+=15;
   ObjectMakeLabel("thungay",5,top-offset);
   offset+=15;
   ObjectMakeLabel("br2",5,top-offset);
   offset+=15;
   ObjectMakeLabel("vndate",5,top-offset);
   offset+=15;
   ObjectMakeLabel("vn2",5,top-offset);
   offset+=25;
   ObjectMakeLabel("tf",5,top-offset);
   offset+=25;
   ObjectMakeLabel("symbt",5,top-offset);
   offset+=40;
   ObjectMakeLabel("mprice",5,top-offset);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Delete             |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("locl");
   ObjectDelete("loct");
   ObjectDelete("brol");
   ObjectDelete("brot");
   ObjectDelete("gmtl");
   ObjectDelete("gmtt");
   ObjectDelete("symbt");
   ObjectDelete("mprice");
   ObjectDelete("br2");
   ObjectDelete("vn1");
   ObjectDelete("vn2");
   ObjectDelete("thungay");
   ObjectDelete("vndate");
   ObjectDelete("tf");
   ObjectDelete("trader");
   ObjectDelete("lv1");
   ObjectDelete("lv2");
   ObjectDelete("swaplong1");
   ObjectDelete("swaplong2");
   ObjectDelete("swapshort1");
   ObjectDelete("swapshort2");
   ObjectDelete("stopout1");
   ObjectDelete("stopout2");
   return(0);
  }


//----
