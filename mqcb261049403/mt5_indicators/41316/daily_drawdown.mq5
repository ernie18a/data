//+------------------------------------------------------------------+
//|                                                           DD.mq5 |
//|                                            kambiz shahriarynasab |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2021, SAI_Programmer."
#property description "Speed, Accuracy, Intelligence"
#property description "Three Essential Components for Scalp Trading"
#property description "Using this tool, we allow you to manage capital, send orders quickly and save automatic profits. "
#property description "\nStay in touch with us"
#property description "\nWe are programming for you for free"
#property description "\nTelegram(@SAI_Programmer)"
#property description "WhatsApp(+989198824764)"
#property description "Instagram(@SAI_Forex)"
#property link        "https://www.mql5.com/en/users/sai_programmer/seller"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
//+------------------------------------------------------------------+
input bool InpDDD=true; //Daily drowdown active:
//+------------------------------------------------------------------+
int OnInit()
  {
   CreateEdit("Daily DD",200,68,98,30,"Daily DD",clrWhite,clrBlack,12);
   CreateEdit("Daily DD V",100,68,98,30,"",clrWhite,clrBlack,12);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0,"Daily DD");
   ObjectDelete(0,"Daily DD V");
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
   MqlDateTime w;
   TimeToStruct(TimeCurrent(),w);
   string md=IntegerToString(w.year)+"."+IntegerToString(w.mon)+".01";
   double historyProfit=0,deposit=0;
   HistorySelect(0,TimeCurrent());
   ulong ticket_history_deal=0;
   for(int i=0; i<HistoryDealsTotal(); i++)
      if((ticket_history_deal=HistoryDealGetTicket(i))>0)
        {
         datetime timeeee=(datetime)HistoryDealGetInteger(ticket_history_deal,DEAL_TIME);
         if(timeeee>StringToTime(TimeToString(TimeCurrent(),TIME_DATE)))
            if(HistoryDealGetInteger(ticket_history_deal,DEAL_TYPE)==DEAL_TYPE_BUY || HistoryDealGetInteger(ticket_history_deal,DEAL_TYPE)==DEAL_TYPE_SELL)
               historyProfit+=HistoryDealGetDouble(ticket_history_deal,DEAL_PROFIT)+HistoryDealGetDouble(ticket_history_deal,DEAL_COMMISSION)+HistoryDealGetDouble(ticket_history_deal,DEAL_SWAP);
            else
               deposit+=HistoryDealGetDouble(ticket_history_deal,DEAL_PROFIT);
        }
   double startBalnce=AccountInfoDouble(ACCOUNT_BALANCE)-historyProfit;
   string text="";
   double dd=(historyProfit+AccountInfoDouble(ACCOUNT_PROFIT))*100/startBalnce;
   text=DoubleToString(dd,2)+" %";
   ObjectSetString(0,"Daily DD V",OBJPROP_TEXT,text);
   ChartRedraw();
   return(rates_total);
  }
//+------------------------------------------------------------------+
bool CreateEdit(string name,int x=0,int y=0,int width=50,int height=18,string text="Text",color clr=clrWhite,color back_clr=clrBlack,
                int fontSize=8,ENUM_ALIGN_MODE align=ALIGN_CENTER,
                color border_clr=clrBlack,bool back=false)
  {
   int chartID=0,windowID=0;
   ObjectDelete(chartID,name);
   ResetLastError();
   if(!ObjectCreate(chartID,name,OBJ_EDIT,windowID,0,0))
     {
      Print(__FUNCTION__,": failed to create \"Edit\" object! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(chartID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartID,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chartID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chartID,name,OBJPROP_YSIZE,height);
   ObjectSetString(chartID,name,OBJPROP_TEXT,text);
   ObjectSetString(chartID,name,OBJPROP_FONT,"Arial");
   ObjectSetInteger(chartID,name,OBJPROP_FONTSIZE,fontSize);
   ObjectSetInteger(chartID,name,OBJPROP_ALIGN,align);
   ObjectSetInteger(chartID,name,OBJPROP_READONLY,true);
   ObjectSetInteger(chartID,name,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetInteger(chartID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chartID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chartID,name,OBJPROP_BORDER_COLOR,border_clr);
   ObjectSetInteger(chartID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chartID,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chartID,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(chartID,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(chartID,name,OBJPROP_ZORDER,0);
   return(true);
  }
//+------------------------------------------------------------------+
bool CreateRectLabel(string name,int x=0,int y=0,int width=50,int height=18,color back_clr=clrBlack,
                     ENUM_BORDER_TYPE border=BORDER_SUNKEN,color clr=clrWhite,ENUM_LINE_STYLE style=STYLE_SOLID,
                     int line_width=0,bool back=false)
  {
   int chartID=0,windowID=0;
   ObjectDelete(chartID,name);
   ResetLastError();
   if(!ObjectCreate(chartID,name,OBJ_RECTANGLE_LABEL,windowID,0,0))
     {
      Print(__FUNCTION__,": failed to create a rectangle label! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(chartID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartID,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chartID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chartID,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(chartID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chartID,name,OBJPROP_BORDER_TYPE,border);
   ObjectSetInteger(chartID,name,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetInteger(chartID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chartID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chartID,name,OBJPROP_WIDTH,line_width);
   ObjectSetInteger(chartID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chartID,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chartID,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(chartID,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(chartID,name,OBJPROP_ZORDER,0);
   return(true);
  }
//+------------------------------------------------------------------+
