//+------------------------------------------------------------------+
//|                                                 i-OrdersMQL5.mq5 |
//|                                         Copyright 2010, hasayama |
//|                                             mrhasayama@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, hasayama"
#property link      "mrhasayama@gmail.com"
#property version   "2.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
#property strict

//+------------------------------------------------------------------ENUMERATIONS------------------------------------------------------------------+
//--available languages
enum ENUM_LANGUAGE_PACK { ENG,RUS };

//+------------------------------------------------------------------INPUT-VARIABLES------------------------------------------------------------------+
input ENUM_LANGUAGE_PACK   Language=ENG;
input bool                 ShowCurrentPostion=true;
input bool                 CompactPositionInfo=true;
input bool                 ShowDealHistory=true;
input datetime             StartTime= D'2010.01.01';
input color                BuyColor = Lime;
input color                SellColor = Red;
input color                InfoColor = Orange;
input int                  FontSize=8;

//+------------------------------------------------------------------COMMON-VARIABLES------------------------------------------------------------------+
uint     pre_total_deals   = 0;
long     pre_chart_scale   = 0;
string   msg_str           = "";
//+------------------------------------------------------------------+
//| Indicator initialization function                                |
//+------------------------------------------------------------------+
int OnInit()
  {
   int attempt=0;
//--we have 5 attempts to init Timer
   while(!IsStopped())
     {
      ResetLastError();
      //--if we fail and limit is not reached, we wait and try again
      if(!EventSetTimer(1))
        {
         msg_str=get_lang("Timer initialization attempt #"+(string)(attempt+1)+"failed. Error #","Неудачная попытка инициализации Таймера №"+(string)(attempt+1)+". Ошибка №");
         Print(msg_str,GetLastError());

         attempt++;
        }
      else { break; }

      //--if limit is reached - we exit with no success
      if(attempt>5)
        {
         msg_str=get_lang("Impossible to initialize Timer.","Невозможно инициализировать Таймер.");
         Print(msg_str);

         break;
        }
      //--wait time is 5 seconds
      Sleep(5000);
     }

   return(0);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//| to get fresh data we use Timer                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(!ShowDealHistory) { obj_delete("!##_"); return; }

   ResetLastError();
//--get deals history first
   if(!HistorySelect(StartTime,TimeCurrent()))
     {
      msg_str=get_lang("Failed to initialize deals history. Error#","Не удалось инициализировать историю сделок. Ошибка №");
      Print(msg_str,GetLastError());
      return;
     }

//--start working on them
//--will redraw if scale or amount of deals changed
   int   total_deals=HistoryDealsTotal();
   long   chart_scale=ChartGetInteger(0,CHART_SCALE);

//--if nothing happend since last time, exit
   if((total_deals!=pre_total_deals) || (pre_chart_scale!=chart_scale))
     {
      pre_total_deals = total_deals;
      pre_chart_scale = chart_scale;
      obj_delete("!##_");

      //--show what we've got
      ShowDeals(total_deals);
     }

   return;
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//| delete all objects and release timer                             |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   obj_delete("!##_");
   obj_delete("#!#_");
   EventKillTimer();

   return;
  }
//--our chart artist is here
//+------------------------------------------------------------------+
//| ShowDeals                                                        |
//| our chart artist is here                                         |
//+------------------------------------------------------------------+
void ShowDeals(uint total_deals)
  {
   ulong      ticket=0;

   double     price;
   datetime   time;
   string     symbol;
   long       type;
   long       entry;
   long       id;

   long       ID=0;
   double     PRICE=0;
   datetime   TIME=0;

   string   name;

   for(uint i=0; i<=total_deals-1; i++)
     {
      ResetLastError();
      ticket=HistoryDealGetTicket(i);
      if(ticket<=0)
        {
         msg_str=get_lang("Imposible to select deal #"+string(i)+". Error #","Невозможно выбрать сделку №"+string(i)+". Ошибка №");
         Print(msg_str,GetLastError());
         //continue;
         return;
        }

      symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
      if(symbol!=Symbol()) { continue; }

      price=HistoryDealGetDouble(ticket,DEAL_PRICE);
      time=(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);

      if(price<=0 || time<=0) { continue; }

      type  = HistoryDealGetInteger(ticket,DEAL_TYPE);
      entry = HistoryDealGetInteger   ( ticket, DEAL_ENTRY );
      id    = HistoryDealGetInteger   ( ticket, DEAL_POSITION_ID );

      name="!##_"+MQL5InfoString(MQL5_PROGRAM_NAME)+"_"+string(ticket)+"_"+string(id);

      ObjectCreate(0,name,OBJ_ARROW,0,time,price,0,0);

      if(entry==DEAL_ENTRY_IN) { ObjectSetInteger(0,name,OBJPROP_ARROWCODE,220); }
      else if(entry==DEAL_ENTRY_INOUT) { ObjectSetInteger(0,name,OBJPROP_ARROWCODE,type?221:222); }
      else { ObjectSetInteger(0,name,OBJPROP_ARROWCODE,219); }

      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,name,OBJPROP_BACK,0);

      ObjectSetInteger(0,name,OBJPROP_COLOR,type?SellColor:BuyColor);

      if(id==ID)
        {
         ObjectCreate(0,name+"_trend",OBJ_TREND,0,TIME,PRICE,time,price);
         ObjectSetInteger(0,name+"_trend",OBJPROP_COLOR,DodgerBlue);
         ObjectSetInteger(0,name+"_trend",OBJPROP_STYLE,STYLE_DOT);
        }

      if(entry==DEAL_ENTRY_IN || entry==DEAL_ENTRY_INOUT)
        {
         ID=id;
         TIME=time;
         PRICE=price;
        }
     }

   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| ShowPosition                                                     |
//+------------------------------------------------------------------+
void ShowPosition()
  {
   long     pos_id=0;
   double   volume = 0;
   double   pos_op = 0;
   double   curr_p = 0;
   double   profit = 0;

   string   name="#!#_"+MQL5InfoString(MQL5_PROGRAM_NAME)+"_"+string(pos_id);

   obj_delete("#!#_");

   if(!PositionSelect(_Symbol)) { return; }

   pos_id = PositionGetInteger( POSITION_IDENTIFIER );
   volume = PositionGetDouble ( POSITION_VOLUME );
   pos_op = PositionGetDouble ( POSITION_PRICE_OPEN );
   curr_p = PositionGetDouble ( POSITION_PRICE_CURRENT );
   profit = PositionGetDouble ( POSITION_PROFIT ) + PositionGetDouble( POSITION_SWAP );

   int shift=5;
   int add_shift=(int)NormalizeDouble((ChartGetDouble(0,CHART_PRICE_MAX)-ChartGetDouble(0,CHART_PRICE_MIN))/(40*_Point),0)+FontSize;

   double   PRICE=curr_p;
   datetime TIME=(datetime)SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE)+PeriodSeconds(_Period);

   if(!CompactPositionInfo)
     {
      shift=shift+add_shift;
      msg_str=get_lang("Position ID: "+(string)pos_id,"ID Позиции: "+(string)pos_id,false);

      ObjectCreate(0,name,OBJ_TEXT,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_TIME,TIME);
      ObjectSetInteger(0,name,OBJPROP_COLOR,InfoColor);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FontSize);
      ObjectSetDouble(0,name,OBJPROP_PRICE,PRICE-shift*_Point);
      ObjectSetString(0,name,OBJPROP_TEXT,msg_str);

      shift=shift+add_shift;
      msg_str=get_lang("Close Volume: "+DoubleToString(volume,2),"Объем закрытия: "+DoubleToString(volume,2),false);

      ObjectCreate(0,name+"1",OBJ_TEXT,0,0,0);
      ObjectSetInteger(0,name+"1",OBJPROP_TIME,TIME);
      ObjectSetInteger(0,name+"1",OBJPROP_COLOR,InfoColor);
      ObjectSetInteger(0,name+"1",OBJPROP_FONTSIZE,FontSize);
      ObjectSetDouble(0,name+"1",OBJPROP_PRICE,PRICE-shift*_Point);
      ObjectSetString(0,name+"1",OBJPROP_TEXT,msg_str);

      shift=shift+add_shift;
      msg_str=get_lang("Position OP: "+DoubleToString(pos_op,_Digits),"Цена открытия: "+DoubleToString(pos_op,_Digits),false);

      ObjectCreate(0,name+"2",OBJ_TEXT,0,0,0);
      ObjectSetInteger(0,name+"2",OBJPROP_TIME,TIME);
      ObjectSetInteger(0,name+"2",OBJPROP_COLOR,InfoColor);
      ObjectSetInteger(0,name+"2",OBJPROP_FONTSIZE,FontSize);
      ObjectSetDouble(0,name+"2",OBJPROP_PRICE,PRICE-shift*_Point);
      ObjectSetString(0,name+"2",OBJPROP_TEXT,msg_str);

      shift=shift+add_shift;
      msg_str=get_lang("Current Price: "+DoubleToString(curr_p,_Digits),"Текущая цена: "+DoubleToString(curr_p,_Digits),false);

      ObjectCreate(0,name+"0",OBJ_TEXT,0,0,0);
      ObjectSetInteger(0,name+"0",OBJPROP_TIME,TIME);
      ObjectSetInteger(0,name+"0",OBJPROP_COLOR,InfoColor);
      ObjectSetInteger(0,name+"0",OBJPROP_FONTSIZE,FontSize);
      ObjectSetDouble(0,name+"0",OBJPROP_PRICE,PRICE-shift*_Point);
      ObjectSetString(0,name+"0",OBJPROP_TEXT,msg_str);
     }

   shift=shift+add_shift*2;
   msg_str=get_lang("Position Profit: "+DoubleToString(profit,2),"Прибыль позиции: "+DoubleToString(profit,2),false);

   ObjectCreate(0,name+"4",OBJ_TEXT,0,0,0);
   ObjectSetInteger(0,name+"4",OBJPROP_TIME,TIME);
   ObjectSetInteger(0,name+"4",OBJPROP_COLOR,InfoColor);
   ObjectSetInteger(0,name+"4",OBJPROP_FONTSIZE,FontSize+2);
   ObjectSetDouble(0,name+"4",OBJPROP_PRICE,PRICE-shift*_Point);
   ObjectSetString(0,name+"4",OBJPROP_TEXT,msg_str);

   if(profit>0) { ObjectSetInteger(0,name+"4",OBJPROP_COLOR,BuyColor); }
   else if(profit<0) { ObjectSetInteger(0,name+"4",OBJPROP_COLOR,SellColor); }

   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| OnChart event handler                                            |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id != CHARTEVENT_OBJECT_CLICK)   { return; }
   if(StringFind(sparam,"!##_") < 0)   { return; }
   if(StringFind(sparam,"trend") > 0 ) { return; }
   if(StringFind(sparam, "text") > 0 ) { return; }

   ulong    ticket=0;
   string   tmp_locker="";

   tmp_locker = StringSubstr(sparam, 5 + StringLen( MQL5InfoString( MQL5_PROGRAM_NAME)));
   tmp_locker = StringSubstr(tmp_locker, 0, StringFind( tmp_locker, "_"));

   ticket=(ulong)tmp_locker;

   double   PRICE=0;
   datetime TIME=0;

   ResetLastError();
   if(!HistoryDealSelect(ticket))
     {
      msg_str=get_lang("Cannot select deal #"+tmp_locker+". Error #","Невозможно выбрать сделку №"+tmp_locker+". Ошибка №");
      Print(msg_str,GetLastError());

      return;
     }

   PRICE= HistoryDealGetDouble(ticket,DEAL_PRICE);
   TIME =(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);

   string            name=sparam+"_text";
   int               shift=15;
   int               add_shift=0;

   int               pos_id=(int)HistoryDealGetInteger(ticket,DEAL_POSITION_ID);
   double            dprofit=HistoryDealGetDouble(ticket,DEAL_PROFIT)+HistoryDealGetDouble(ticket,DEAL_SWAP);
   ENUM_DEAL_ENTRY   entry=0;
   double            volume = 0;
   double            pos_op = 0;
   double            pos_cp = 0;
   double            profit = 0;

   ResetLastError();
   if(!HistorySelectByPosition(pos_id))
     {
      msg_str=get_lang("Failed to get position data. Error#","Не удалось получить данные о позиции. Ошибка №");
      Print(msg_str,GetLastError());
      return;
     }

   for(int i=0; i<HistoryDealsTotal(); i++)
     {
      ResetLastError();
      ticket=HistoryDealGetTicket(i);
      if(ticket<=0)
        {
         msg_str=get_lang("Imposible to select deal #"+string(i)+". Error #","Невозможно выбрать сделку №"+string(i)+". Ошибка №");
         Print(msg_str,GetLastError());
         continue;
        }

      entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket,DEAL_ENTRY);

      if(entry==DEAL_ENTRY_IN   ) { pos_op = HistoryDealGetDouble( ticket, DEAL_PRICE   ); continue; }
      if(entry==DEAL_ENTRY_INOUT) { profit = profit + HistoryDealGetDouble( ticket, DEAL_PROFIT   ) + HistoryDealGetDouble( ticket, DEAL_SWAP ); continue; }

      if(entry==DEAL_ENTRY_OUT)
        {
         volume = HistoryDealGetDouble( ticket, DEAL_VOLUME );
         pos_cp = HistoryDealGetDouble( ticket, DEAL_PRICE   );
         profit = profit + HistoryDealGetDouble( ticket, DEAL_PROFIT   ) + HistoryDealGetDouble( ticket, DEAL_SWAP );
         continue;
        }
     }

//--if we didn't open the menu before
   if(ObjectFind(0,name)<0)
     {
      add_shift=(int)NormalizeDouble((ChartGetDouble(0,CHART_PRICE_MAX)-ChartGetDouble(0,CHART_PRICE_MIN))/(40*_Point),0)+FontSize;

      shift=shift+add_shift;
      msg_str=get_lang("Position ID: "+(string)pos_id,"ID Позиции: "+(string)pos_id,false);

      ObjectCreate(0,name,OBJ_TEXT,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_TIME,TIME);
      ObjectSetInteger(0,name,OBJPROP_COLOR,InfoColor);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FontSize);
      ObjectSetDouble(0,name,OBJPROP_PRICE,PRICE-shift*_Point);
      ObjectSetString(0,name,OBJPROP_TEXT,msg_str);

      shift=shift+add_shift;
      msg_str=get_lang("Close Volume: "+DoubleToString(volume,2),"Объем закрытия: "+DoubleToString(volume,2),false);

      ObjectCreate(0,name+"1",OBJ_TEXT,0,0,0);
      ObjectSetInteger(0,name+"1",OBJPROP_TIME,TIME);
      ObjectSetInteger(0,name+"1",OBJPROP_COLOR,InfoColor);
      ObjectSetInteger(0,name+"1",OBJPROP_FONTSIZE,FontSize);
      ObjectSetDouble(0,name+"1",OBJPROP_PRICE,PRICE-shift*_Point);
      ObjectSetString(0,name+"1",OBJPROP_TEXT,msg_str);

      shift=shift+add_shift;
      msg_str=get_lang("Position OP: "+DoubleToString(pos_op,_Digits),"Цена открытия: "+DoubleToString(pos_op,_Digits),false);

      ObjectCreate(0,name+"2",OBJ_TEXT,0,0,0);
      ObjectSetInteger(0,name+"2",OBJPROP_TIME,TIME);
      ObjectSetInteger(0,name+"2",OBJPROP_COLOR,InfoColor);
      ObjectSetInteger(0,name+"2",OBJPROP_FONTSIZE,FontSize);
      ObjectSetDouble(0,name+"2",OBJPROP_PRICE,PRICE-shift*_Point);
      ObjectSetString(0,name+"2",OBJPROP_TEXT,msg_str);

      shift=shift+add_shift;
      msg_str=get_lang("Position CP: "+DoubleToString(pos_cp,_Digits),"Цена закрытия: "+DoubleToString(pos_cp,_Digits),false);

      ObjectCreate(0,name+"0",OBJ_TEXT,0,0,0);
      ObjectSetInteger(0,name+"0",OBJPROP_TIME,TIME);
      ObjectSetInteger(0,name+"0",OBJPROP_COLOR,InfoColor);
      ObjectSetInteger(0,name+"0",OBJPROP_FONTSIZE,FontSize);
      ObjectSetDouble(0,name+"0",OBJPROP_PRICE,PRICE-shift*_Point);
      ObjectSetString(0,name+"0",OBJPROP_TEXT,msg_str);

      shift=shift+add_shift*2;
      msg_str=get_lang("Deal Profit: "+DoubleToString(dprofit,2),"Прибыль сделки: "+DoubleToString(dprofit,2),false);

      ObjectCreate(0,name+"4",OBJ_TEXT,0,0,0);
      ObjectSetInteger(0,name+"4",OBJPROP_TIME,TIME);
      ObjectSetInteger(0,name+"4",OBJPROP_COLOR,InfoColor);
      ObjectSetInteger(0,name+"4",OBJPROP_FONTSIZE,FontSize);
      ObjectSetDouble(0,name+"4",OBJPROP_PRICE,PRICE-shift*_Point);
      ObjectSetString(0,name+"4",OBJPROP_TEXT,msg_str);

      if(dprofit>0) { ObjectSetInteger(0,name+"4",OBJPROP_COLOR,BuyColor); }
      else if(dprofit<0) { ObjectSetInteger(0,name+"4",OBJPROP_COLOR,SellColor); }

      shift=shift+add_shift;
      msg_str=get_lang("Position Profit: "+DoubleToString(profit,2),"Прибыль позиции: "+DoubleToString(profit,2),false);

      ObjectCreate(0,name+"3",OBJ_TEXT,0,0,0);
      ObjectSetInteger(0,name+"3",OBJPROP_TIME,TIME);
      ObjectSetInteger(0,name+"3",OBJPROP_COLOR,InfoColor);
      ObjectSetInteger(0,name+"3",OBJPROP_FONTSIZE,FontSize+2);
      ObjectSetDouble(0,name+"3",OBJPROP_PRICE,PRICE-shift*_Point);
      ObjectSetString(0,name+"3",OBJPROP_TEXT,msg_str);

      if(profit>0) { ObjectSetInteger(0,name+"3",OBJPROP_COLOR,BuyColor); }
      else if(profit<0) { ObjectSetInteger(0,name+"3",OBJPROP_COLOR,SellColor); }
     }
//--if opened - delete it
   else
     { obj_delete(sparam+"_text"); }

   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| obj_delete                                                       |
//+------------------------------------------------------------------+
void obj_delete(string prefix)
  {
   string   name="";
   int      total=ObjectsTotal(0)-1;

   for(int i=total; i>=0; i --)
     {
      name=ObjectName(0,i);
      if(StringFind(name,prefix)>=0) { ObjectDelete(0,name); }
     }
  }
//+------------------------------------------------------------------+
//| get_lang                                                         |
//+------------------------------------------------------------------+
string get_lang(string eng,string rus,bool add_info=true)
  {
   string info="";
   if(add_info) { info=MQL5InfoString(MQL5_PROGRAM_NAME)+"("+Symbol()+"): "; }

   if( Language == ENG ) { return(info+eng); }
   if( Language == RUS ) { return(info+rus); }

//--default is english
   return(info+eng);
  }
//+------------------------------------------------------------------+
//| Indicator iteration function                                     |
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
   if(!ShowCurrentPostion) { obj_delete("#!#_"); return(rates_total); }
   ShowPosition();
   return(rates_total);
  }
//+------------------------------------------------------------------+
