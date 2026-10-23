//+------------------------------------------------------------------+
//|                                                 slqtp_values.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window

#include <Trade\PositionInfo.mqh>
CPositionInfo  m_position; 
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
   for(int i=0; i<(int)PositionsTotal(); i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(m_position.SelectByIndex(i))   
        {
         if(m_position.Symbol()==_Symbol)
           {
            //--
            if(ObjectFind(0,"#"+IntegerToString(ticket,0,0)+" sl")==0)ObjectDelete(0,"#"+IntegerToString(ticket,0,0)+" sl");
            if(ObjectFind(0,"#"+IntegerToString(ticket,0,0)+" tp")==0)ObjectDelete(0,"#"+IntegerToString(ticket,0,0)+" tp");
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
   if(AccountInfoString(ACCOUNT_CURRENCY)=="EUR")txt="€";
   if(AccountInfoString(ACCOUNT_CURRENCY)=="USD")txt="$";
   if(AccountInfoString(ACCOUNT_CURRENCY)=="GBP")txt="£";
   if(AccountInfoString(ACCOUNT_CURRENCY)=="CHF")txt="Fr.";
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
    for(int i=0; i<(int)PositionsTotal(); i++)
     {
     
      ulong ticket=PositionGetTicket(i);
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
        {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol)
           {
            //---
            tick_val=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);//GetTickValue
            //--
            if(ChartGetInteger(0,CHART_SHIFT,0))anchor=ANCHOR_LEFT;else anchor=ANCHOR_RIGHT;//SetAnchor
            
            datetime Time[];
            CopyTime(_Symbol,PERIOD_CURRENT,0,1, Time);
            
            //-- Sell Orders
            if(PositionGetInteger(POSITION_TYPE)  == POSITION_TYPE_SELL)
              {
               //-- StopLoss
               sl_name="#"+IntegerToString(ticket,0,0)+" sl";//SetName
               if(m_position.StopLoss()>0)//StopLoss is active
                 {
                  if(m_position.StopLoss()<m_position.PriceOpen())sl_pn="   +";else sl_pn="   -";//SetPos/Negative
                  sl_dist=(m_position.StopLoss()-m_position.PriceOpen())/_Point;//CalcDistance
                  sl_val=(sl_dist*tick_val)*m_position.Volume();//CalcValue

                  TextCreate(0,sl_name,0,Time[0],m_position.StopLoss()+Offset*_Point,sl_pn+DoubleToString(MathAbs(sl_val),2)+_AccountCurrency()+" / "+DoubleToString(MathAbs(sl_dist),0)+"p","Tahoma",8,COLOR_SL,0,anchor,false,false,true,0);//ObjectCreate
                  //-- ObjectSet SL
                  if(ObjectFind(0,sl_name)==0)//Object is present
                    {
                     if((ObjectGetDouble(0,sl_name,OBJPROP_PRICE,0)-(m_position.StopLoss()+Offset*_Point))!=0 || ObjectGetInteger(0,sl_name,OBJPROP_TIME,0)!=Time[0])//Price or Time has changed
                       {
                        ObjectSetDouble(0,sl_name,OBJPROP_PRICE,m_position.StopLoss()+Offset*_Point);//SetPrice
                        ObjectSetString(0,sl_name,OBJPROP_TEXT,0,sl_pn+DoubleToString(MathAbs(sl_val),2)+_AccountCurrency()+" / "+DoubleToString(MathAbs(sl_dist),0)+"p");//SetText
                        ObjectSetInteger(0,sl_name,OBJPROP_TIME,Time[0]);//SetTime
                       }
                    }
                  //--
                 }
               //--
               else if(ObjectFind(0,sl_name)==0)ObjectDelete(0,sl_name);//Canceled
               //-- TakeProfit
               tp_name="#"+IntegerToString(ticket,0,0)+" tp";//SetName
               if(m_position.TakeProfit()>0)//TakeProfit is active
                 {
                  tp_dist=(m_position.PriceOpen()-m_position.TakeProfit())/_Point;//CalcDistance
                  tp_val=(tp_dist*tick_val)*m_position.Volume();//CalcValue
                  TextCreate(0,tp_name,0,Time[0],m_position.TakeProfit()-Offset*_Point,"   +"+DoubleToString(tp_val,2)+_AccountCurrency()+" / "+DoubleToString(tp_dist,0)+"p","Tahoma",8,COLOR_TP,0,anchor,false,false,true,0);//ObjectCreate
                  //-- ObjectSet TP
                  if(ObjectFind(0,tp_name)==0)//Object is present
                    {
                     if((ObjectGetDouble(0,tp_name,OBJPROP_PRICE,0)-(m_position.TakeProfit()-Offset*_Point))!=0 || ObjectGetInteger(0,tp_name,OBJPROP_TIME,0)!=Time[0])//Price or Time has changed
                       {
                        ObjectSetDouble(0,tp_name,OBJPROP_PRICE,m_position.TakeProfit()-Offset*_Point);//SetPrice
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
            if(PositionGetInteger(POSITION_TYPE)  == POSITION_TYPE_BUY)
              {
               //-- StopLoss
               sl_name="#"+IntegerToString(ticket,0,0)+" sl";//SetName
               if(m_position.StopLoss()>0)//StopLoss is active
                 {
                  if(m_position.StopLoss()>=m_position.PriceOpen())sl_pn="   +";else sl_pn="   -";//SetPos/Negative
                  sl_dist=(m_position.PriceOpen()-m_position.StopLoss())/_Point;//CalcDistance
                  sl_val=(sl_dist*tick_val)*m_position.Volume();//CalcValue
                  TextCreate(0,sl_name,0,Time[0],m_position.StopLoss()-Offset*_Point,sl_pn+DoubleToString(MathAbs(sl_val),2)+_AccountCurrency()+" / "+DoubleToString(MathAbs(sl_dist),0)+"p","Tahoma",8,COLOR_SL,0,anchor,false,false,true,0);//ObjectCreate
                  //-- ObjectSet SL
                  if(ObjectFind(0,sl_name)==0)//Object is present
                    {
                     if((ObjectGetDouble(0,sl_name,OBJPROP_PRICE,0)-(m_position.StopLoss()-Offset*_Point))!=0 || ObjectGetInteger(0,sl_name,OBJPROP_TIME,0)!=Time[0])//Price or Time has changed
                       {
                        ObjectSetDouble(0,sl_name,OBJPROP_PRICE,m_position.StopLoss()-Offset*_Point);//SetPrice
                        ObjectSetString(0,sl_name,OBJPROP_TEXT,0,sl_pn+DoubleToString(MathAbs(sl_val),2)+_AccountCurrency()+" / "+DoubleToString(MathAbs(sl_dist),0)+"p");//SetText
                        ObjectSetInteger(0,sl_name,OBJPROP_TIME,Time[0]);//SetTime
                       }
                    }
                  //--
                 }
               //--
               else if(ObjectFind(0,sl_name)==0)ObjectDelete(0,sl_name);//Canceled
               //-- TakeProfit
               tp_name="#"+IntegerToString(ticket,0,0)+" tp";//SetName
               if(m_position.TakeProfit()>0)//TakeProfit is active
                 {
                  tp_dist=(m_position.TakeProfit()-m_position.PriceOpen())/_Point;//CalcDistance
                  tp_val=(tp_dist*tick_val)*m_position.Volume();//CalcValue
                  TextCreate(0,tp_name,0,Time[0],m_position.TakeProfit()+Offset*_Point,"   +"+DoubleToString(tp_val,2)+_AccountCurrency()+" / "+DoubleToString(tp_dist,0)+"p","Tahoma",8,COLOR_TP,0,anchor,false,false,true,0);//ObjectCreate
                  //-- ObjectSet TP
                  if(ObjectFind(0,tp_name)==0)//Object is present
                    {
                     if((ObjectGetDouble(0,tp_name,OBJPROP_PRICE,0)-(m_position.TakeProfit()+Offset*_Point))!=0 || ObjectGetInteger(0,tp_name,OBJPROP_TIME,0)!=Time[0])//Price or Time has changed
                       {
                        ObjectSetDouble(0,tp_name,OBJPROP_PRICE,m_position.TakeProfit()+Offset*_Point);//SetPrice
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
   ulong ticket;
   for(int x=0; x<ObjectsTotal(0); x++)
     {
      string obj_name=ObjectName(0, x);
      if(StringSubstr(obj_name,StringLen(obj_name)-2,2)=="sl" || StringSubstr(obj_name,StringLen(obj_name)-2,2)=="tp")
        {
         for(int i=0; i<HistoryOrdersTotal(); i++)
           {
           
            if((ticket=HistoryDealGetTicket(i))>0)
              {
               if(HistoryDealGetString(ticket,DEAL_SYMBOL)==_Symbol)
                 {
                  //-- Closed Order found
                  if(ObjectFind(0,"#"+IntegerToString(ticket,0,0)+" sl")==0)ObjectDelete(0,"#"+IntegerToString(ticket,0,0)+" sl");
                  if(ObjectFind(0,"#"+IntegerToString(ticket,0,0)+" tp")==0)ObjectDelete(0,"#"+IntegerToString(ticket,0,0)+" tp");
                  //--
                 }
              }
           }
         //--
        }
     }
//----
  }

