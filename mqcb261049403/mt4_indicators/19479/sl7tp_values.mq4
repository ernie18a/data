//+------------------------------------------------------------------+
//|                                                 SL&TP Values.mq4 |
//|                                          Copyright © 2017, MhFx7 |
//|                              https://www.mql5.com/en/users/mhfx7 |
//+------------------------------------------------------------------+
#property copyright  "Copyright © 2017, MhFx7"
#property link       "https://www.mql5.com/en/users/mhfx7"
#property version    "1.01"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Select Colors                                                    |
//+------------------------------------------------------------------+
enum ColorSelect
  {
   COLOR_RED_GREEN,//Red/Green
   COLOR_FOREGROUND,//Foreground
  };
//--
input ColorSelect Colors=COLOR_RED_GREEN;//Colors
input int Offset=25;//Offset
//--
color COLOR_SL=clrNONE;
color COLOR_TP=clrNONE;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   EventSetMillisecondTimer(250);
//-- Initialize Colors
   if(Colors!=COLOR_RED_GREEN)
     {
      COLOR_SL=ChartForeColor();
      COLOR_TP=ChartForeColor();
     }
   else
     {
      COLOR_SL=clrRed;
      COLOR_TP=clrLimeGreen;
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   EventKillTimer();
//-- Delete Objects (Opened Orders)
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==_Symbol)
           {
            //--
            if(ObjectFind(0,"#"+IntegerToString(OrderTicket(),0,0)+" sl")==0)ObjectDelete(0,"#"+IntegerToString(OrderTicket(),0,0)+" sl");
            if(ObjectFind(0,"#"+IntegerToString(OrderTicket(),0,0)+" tp")==0)ObjectDelete(0,"#"+IntegerToString(OrderTicket(),0,0)+" tp");
            //--
           }
        }
     }
//---
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
//---

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//----
   double sl_dist=0,sl_val=0,tp_dist=0,tp_val=0,tick_val=0;
   string sl_name="", tp_name="", sl_pn="";
   ENUM_ANCHOR_POINT anchor=0;
//--
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==_Symbol)
           {
            //--- 
            tick_val=MarketInfo(_Symbol,MODE_TICKVALUE);//GetTickValue
            //--
            if(ChartGetInteger(0,CHART_SHIFT,0))anchor=ANCHOR_LEFT;else anchor=ANCHOR_RIGHT;//SetAnchor
            //-- Sell Orders
            if(OrderType()==OP_SELL || OrderType()==OP_SELLLIMIT || OrderType()==OP_SELLSTOP)
              {
               //-- StopLoss
               sl_name="#"+IntegerToString(OrderTicket(),0,0)+" sl";//SetName
               if(OrderStopLoss()>0)//StopLoss is active
                 {
                  if(OrderStopLoss()<=OrderOpenPrice())sl_pn="   +";else sl_pn="   -";//SetPos/Negative
                  sl_dist=(OrderStopLoss()-OrderOpenPrice())/_Point;//CalcDistance
                  sl_val=(sl_dist*tick_val)*OrderLots();//CalcValue
                  TextCreate(0,sl_name,0,Time[0],OrderStopLoss()+Offset*_Point,sl_pn+DoubleToString(MathAbs(sl_val),2)+_AccountCurrency()+" / "+DoubleToString(MathAbs(sl_dist),0)+"p","Tahoma",8,COLOR_SL,0,anchor,false,false,true,0);//ObjectCreate
                  //-- ObjectSet SL
                  if(ObjectFind(0,sl_name)==0)//Object is present
                    {
                     if((ObjectGetDouble(0,sl_name,OBJPROP_PRICE,0)-(OrderStopLoss()+Offset*_Point))!=0 || ObjectGetInteger(0,sl_name,OBJPROP_TIME,0)!=Time[0])//Price or Time has changed
                       {
                        ObjectSetDouble(0,sl_name,OBJPROP_PRICE,OrderStopLoss()+Offset*_Point);//SetPrice
                        ObjectSetString(0,sl_name,OBJPROP_TEXT,0,sl_pn+DoubleToString(MathAbs(sl_val),2)+_AccountCurrency()+" / "+DoubleToString(MathAbs(sl_dist),0)+"p");//SetText
                        ObjectSetInteger(0,sl_name,OBJPROP_TIME,Time[0]);//SetTime
                       }
                    }
                  //--
                 }
               //--
               else if(ObjectFind(0,sl_name)==0)ObjectDelete(0,sl_name);//Canceled
               //-- TakeProfit
               tp_name="#"+IntegerToString(OrderTicket(),0,0)+" tp";//SetName
               if(OrderTakeProfit()>0)//TakeProfit is active
                 {
                  tp_dist=(OrderOpenPrice()-OrderTakeProfit())/_Point;//CalcDistance
                  tp_val=(tp_dist*tick_val)*OrderLots();//CalcValue
                  TextCreate(0,tp_name,0,Time[0],OrderTakeProfit()-Offset*_Point,"   +"+DoubleToString(tp_val,2)+_AccountCurrency()+" / "+DoubleToString(tp_dist,0)+"p","Tahoma",8,COLOR_TP,0,anchor,false,false,true,0);//ObjectCreate
                  //-- ObjectSet TP
                  if(ObjectFind(0,tp_name)==0)//Object is present
                    {
                     if((ObjectGetDouble(0,tp_name,OBJPROP_PRICE,0)-(OrderTakeProfit()-Offset*_Point))!=0 || ObjectGetInteger(0,tp_name,OBJPROP_TIME,0)!=Time[0])//Price or Time has changed
                       {
                        ObjectSetDouble(0,tp_name,OBJPROP_PRICE,OrderTakeProfit()-Offset*_Point);//SetPrice
                        ObjectSetString(0,tp_name,OBJPROP_TEXT,0,"   +"+DoubleToString(tp_val,2)+_AccountCurrency()+" / "+DoubleToString(tp_dist,0)+"p");//SetText
                        ObjectSetInteger(0,tp_name,OBJPROP_TIME,Time[0]);//SetTime
                       }
                    }
                 }
               //--
               else if(ObjectFind(0,tp_name)==0)ObjectDelete(0,tp_name);//Canceled
               //--
              }
            //--- Buy Orders
            if(OrderType()==OP_BUY || OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP)
              {
               //-- StopLoss
               sl_name="#"+IntegerToString(OrderTicket(),0,0)+" sl";//SetName
               if(OrderStopLoss()>0)//StopLoss is active
                 {
                  if(OrderStopLoss()>=OrderOpenPrice())sl_pn="   +";else sl_pn="   -";//SetPos/Negative
                  sl_dist=(OrderOpenPrice()-OrderStopLoss())/_Point;//CalcDistance
                  sl_val=(sl_dist*tick_val)*OrderLots();//CalcValue
                  TextCreate(0,sl_name,0,Time[0],OrderStopLoss()-Offset*_Point,sl_pn+DoubleToString(MathAbs(sl_val),2)+_AccountCurrency()+" / "+DoubleToString(MathAbs(sl_dist),0)+"p","Tahoma",8,COLOR_SL,0,anchor,false,false,true,0);//ObjectCreate
                  //-- ObjectSet SL
                  if(ObjectFind(0,sl_name)==0)//Object is present
                    {
                     if((ObjectGetDouble(0,sl_name,OBJPROP_PRICE,0)-(OrderStopLoss()-Offset*_Point))!=0 || ObjectGetInteger(0,sl_name,OBJPROP_TIME,0)!=Time[0])//Price or Time has changed
                       {
                        ObjectSetDouble(0,sl_name,OBJPROP_PRICE,OrderStopLoss()-Offset*_Point);//SetPrice
                        ObjectSetString(0,sl_name,OBJPROP_TEXT,0,sl_pn+DoubleToString(MathAbs(sl_val),2)+_AccountCurrency()+" / "+DoubleToString(MathAbs(sl_dist),0)+"p");//SetText
                        ObjectSetInteger(0,sl_name,OBJPROP_TIME,Time[0]);//SetTime
                       }
                    }
                  //--
                 }
               //--
               else if(ObjectFind(0,sl_name)==0)ObjectDelete(0,sl_name);//Canceled
               //-- TakeProfit
               tp_name="#"+IntegerToString(OrderTicket(),0,0)+" tp";//SetName
               if(OrderTakeProfit()>0)//TakeProfit is active
                 {
                  tp_dist=(OrderTakeProfit()-OrderOpenPrice())/_Point;//CalcDistance
                  tp_val=(tp_dist*tick_val)*OrderLots();//CalcValue
                  TextCreate(0,tp_name,0,Time[0],OrderTakeProfit()+Offset*_Point,"   +"+DoubleToString(tp_val,2)+_AccountCurrency()+" / "+DoubleToString(tp_dist,0)+"p","Tahoma",8,COLOR_TP,0,anchor,false,false,true,0);//ObjectCreate
                  //-- ObjectSet TP
                  if(ObjectFind(0,tp_name)==0)//Object is present
                    {
                     if((ObjectGetDouble(0,tp_name,OBJPROP_PRICE,0)-(OrderTakeProfit()+Offset*_Point))!=0 || ObjectGetInteger(0,tp_name,OBJPROP_TIME,0)!=Time[0])//Price or Time has changed
                       {
                        ObjectSetDouble(0,tp_name,OBJPROP_PRICE,OrderTakeProfit()+Offset*_Point);//SetPrice
                        ObjectSetString(0,tp_name,OBJPROP_TEXT,0,"   +"+DoubleToString(tp_val,2)+_AccountCurrency()+" / "+DoubleToString(tp_dist,0)+"p");//SetText
                        ObjectSetInteger(0,tp_name,OBJPROP_TIME,Time[0]);//SetTime
                       }
                    }
                 }
               //--
               else if(ObjectFind(0,tp_name)==0)ObjectDelete(0,tp_name);//Canceled
               //--
              }
            //---
           }
        }
     }
//-- Delete Objects (Closed Orders)
   for(int x=0; x<ObjectsTotal(); x++)
     {
      string obj_name=ObjectName(x);
      if(StringSubstr(obj_name,StringLen(obj_name)-2,2)=="sl" || StringSubstr(obj_name,StringLen(obj_name)-2,2)=="tp")
        {
         for(int i=0; i<OrdersHistoryTotal(); i++)
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
              {
               if(OrderSymbol()==_Symbol)
                 {
                  //-- Closed Order found
                  if(ObjectFind(0,"#"+IntegerToString(OrderTicket(),0,0)+" sl")==0)ObjectDelete(0,"#"+IntegerToString(OrderTicket(),0,0)+" sl");
                  if(ObjectFind(0,"#"+IntegerToString(OrderTicket(),0,0)+" tp")==0)ObjectDelete(0,"#"+IntegerToString(OrderTicket(),0,0)+" tp");
                  //--
                 }
              }
           }
         //--
        }
     }
//----
  }
//+------------------------------------------------------------------+
//| ChartForeColor                                                   |
//+------------------------------------------------------------------+
color ChartForeColor()
  {
   long result=clrNONE;
   ChartGetInteger(0,CHART_COLOR_FOREGROUND,0,result);
   return((color)result);
  }
//+------------------------------------------------------------------+
//| AccountCurrency                                                  |
//+------------------------------------------------------------------+
string _AccountCurrency()
  {
   string txt="";
   if(AccountCurrency()=="EUR")txt="€";
   if(AccountCurrency()=="USD")txt="$";
   if(AccountCurrency()=="GBP")txt="£";
   if(AccountCurrency()=="CHF")txt="Fr.";
   return(txt);
  }
//+------------------------------------------------------------------+ 
//| Creating Text object                                             | 
//+------------------------------------------------------------------+ 
bool TextCreate(const long              chart_ID=0,               // chart's ID 
                const string            name="Text",              // object name 
                const int               sub_window=0,             // subwindow index 
                datetime                time=0,                   // anchor point time 
                double                  price=0,                  // anchor point price 
                const string            text="Text",              // the text itself 
                const string            font="Arial",             // font 
                const int               font_size=10,             // font size 
                const color             clr=clrRed,               // color 
                const double            angle=0.0,                // text slope 
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type 
                const bool              back=false,               // in the background 
                const bool              selection=false,          // highlight to move 
                const bool              hidden=true,              // hidden in the object list 
                const long              z_order=0)                // priority for mouse click 
  {
   if(ObjectFind(chart_ID,name)!=0)
     {
      ResetLastError();
      if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price))
        {
         Print(__FUNCTION__,
               ": failed to create \"Text\" object! Error code = ",GetLastError());
         return(false);
        }
      ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
      ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
      ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
     }
   return(true);
  }
//+------------------------------------------------------------------+ 
//| End of the code                                                  | 
//+------------------------------------------------------------------+ 
