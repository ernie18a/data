//+------------------------------------------------------------------+
//|                                           TradeReporterLite.mq5  |
//|  Posts your MT5 opens and closes to a Telegram chat.              |
//|                                                                   |
//|  It never opens, closes or modifies a trade.                      |
//+------------------------------------------------------------------+
#property copyright "Amul R"
#property link      "https://www.mql5.com/en/users/amul1"
#property version   "1.00"
#property description "Posts your MT5 opens and closes to a Telegram chat: side, symbol, entry, stop, target, lots, and on close the result, pips, R-multiple and time held."
#property description "Tools > Options > Expert Advisors > Allow WebRequest for https://api.telegram.org, then reload the EA (F7 > OK). Never trades."
#property strict

input string InpTgToken  ="";    // Telegram bot token (from @BotFather)
input string InpTgChat   ="";    // Chat ID (@channel, or the -100... / numeric id)
input string InpHeader   ="";    // Line added above every message (optional)

#define MAX_TRIES 5

struct QMsg   { string text; int tries; datetime next_at; };
struct Track  { ulong pid; double isl; };

QMsg   g_q[];
Track  g_tracks[];
int    g_sent=0, g_failed=0;
string g_status="";
string g_token="", g_chat="";

//+------------------------------------------------------------------+
int OnInit()
  {
   g_token=Trim(InpTgToken);
   g_chat =Trim(InpTgChat);
   // learn what is already open so a restart doesn't re-announce it
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(PositionGetTicket(i)>0)
         Remember((ulong)PositionGetInteger(POSITION_IDENTIFIER), PositionGetDouble(POSITION_SL));
   g_status=(g_token=="" || g_chat=="") ? "set the bot token and chat ID in the inputs" : "ready";
   EventSetTimer(1);
   Show();
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason) { EventKillTimer(); ObjectsDeleteAll(0, "TRL_"); }
void OnTimer()                  { Pump(); Show(); }

//+------------------------------------------------------------------+
string Trim(string s) { StringTrimLeft(s); StringTrimRight(s); return(s); }

double PipSize(const string symbol)
  {
   int    digits=(int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double point=SymbolInfoDouble(symbol, SYMBOL_POINT);
   if(digits==3 || digits==5)
      return(point*10.0);
   string s=symbol;
   StringToUpper(s);
   if(digits==2 && (StringFind(s, "XAU")>=0 || StringFind(s, "GOLD")>=0 || StringFind(s, "XAG")>=0))
      return(point*10.0);
   return(point);
  }

string Px(const string symbol, const double p) { return(DoubleToString(p, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS))); }

string Signed(const double v, const int digits)
  {
   double r=NormalizeDouble(v, digits);
   if(r==0)
      return(DoubleToString(0, digits));
   return((r>0 ? "+" : "-")+DoubleToString(MathAbs(r), digits));
  }

string Held(const long secs)
  {
   long m=secs/60, h=m/60, d=h/24;
   if(d>0) return(StringFormat("%dd %dh", d, h%24));
   if(h>0) return(StringFormat("%dh %dm", h, m%60));
   return(StringFormat("%dm", m));
  }

string Html(string s)
  {
   StringReplace(s, "&", "&amp;");
   StringReplace(s, "<", "&lt;");
   StringReplace(s, ">", "&gt;");
   return(s);
  }

string Json(string s)
  {
   StringReplace(s, "\\", "\\\\");
   StringReplace(s, "\"", "\\\"");
   StringReplace(s, "\r", "");
   StringReplace(s, "\n", "\\n");
   return(s);
  }

void Remember(const ulong pid, const double sl)
  {
   for(int i=0; i<ArraySize(g_tracks); i++)
      if(g_tracks[i].pid==pid)
        {
         if(g_tracks[i].isl<=0) g_tracks[i].isl=sl;
         return;
        }
   int k=ArraySize(g_tracks);
   ArrayResize(g_tracks, k+1);
   g_tracks[k].pid=pid;
   g_tracks[k].isl=sl;
  }

// first stop of a tracked position; -1 when we never saw it open
double Forget(const ulong pid)
  {
   for(int i=0; i<ArraySize(g_tracks); i++)
      if(g_tracks[i].pid==pid)
        {
         double isl=g_tracks[i].isl;
         g_tracks[i]=g_tracks[ArraySize(g_tracks)-1];
         ArrayResize(g_tracks, ArraySize(g_tracks)-1);
         return(isl);
        }
   return(-1);
  }

//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &req, const MqlTradeResult &res)
  {
   if(trans.type!=TRADE_TRANSACTION_DEAL_ADD || !HistoryDealSelect(trans.deal))
      return;
   long type=HistoryDealGetInteger(trans.deal, DEAL_TYPE);
   if(type!=DEAL_TYPE_BUY && type!=DEAL_TYPE_SELL)
      return;
   long   entry=HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
   ulong  pid  =(ulong)HistoryDealGetInteger(trans.deal, DEAL_POSITION_ID);
   string sym  =HistoryDealGetString(trans.deal, DEAL_SYMBOL);

   if(entry==DEAL_ENTRY_IN)
     {
      if(!PositionSelectByTicket(pid))
         return;
      bool   buy=(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY);
      double open=PositionGetDouble(POSITION_PRICE_OPEN), sl=PositionGetDouble(POSITION_SL), tp=PositionGetDouble(POSITION_TP);
      double pip=PipSize(sym);
      Remember(pid, sl);
      string s="<b>"+(buy ? "BUY " : "SELL ")+sym+"</b> opened\nEntry "+Px(sym, open);
      s+="\nSL "+(sl>0 ? Px(sym, sl)+" ("+DoubleToString(MathAbs(open-sl)/pip, 1)+" pips)" : "none");
      if(tp>0)
         s+=" · TP "+Px(sym, tp)+" ("+DoubleToString(MathAbs(tp-open)/pip, 1)+" pips)";
      s+="\n"+DoubleToString(HistoryDealGetDouble(trans.deal, DEAL_VOLUME), 2)+" lots";
      Send(s);
      return;
     }
   if(entry!=DEAL_ENTRY_OUT && entry!=DEAL_ENTRY_OUT_BY)
      return;
   if(PositionSelectByTicket(pid))
      return;                                        // a partial close: not reported
   double isl=Forget(pid);
   if(isl<0)
      return;                                        // opened before we were watching
   //--- the whole position from its deals
   if(!HistorySelectByPosition(pid))
      return;
   double in_v=0, in_p=0, out_v=0, out_p=0, pl=0;
   datetime t_in=0, t_out=0;
   bool buy=true;
   for(int i=0; i<HistoryDealsTotal(); i++)
     {
      ulong d=HistoryDealGetTicket(i);
      long  dt=HistoryDealGetInteger(d, DEAL_TYPE);
      if(dt!=DEAL_TYPE_BUY && dt!=DEAL_TYPE_SELL)
         continue;
      double v=HistoryDealGetDouble(d, DEAL_VOLUME), p=HistoryDealGetDouble(d, DEAL_PRICE);
      pl+=HistoryDealGetDouble(d, DEAL_PROFIT)+HistoryDealGetDouble(d, DEAL_COMMISSION)+HistoryDealGetDouble(d, DEAL_SWAP);
      if(HistoryDealGetInteger(d, DEAL_ENTRY)==DEAL_ENTRY_IN)
        {
         if(t_in==0) { t_in=(datetime)HistoryDealGetInteger(d, DEAL_TIME); buy=(dt==DEAL_TYPE_BUY); }
         in_v+=v; in_p+=v*p;
        }
      else
        {
         out_v+=v; out_p+=v*p;
         t_out=(datetime)HistoryDealGetInteger(d, DEAL_TIME);
        }
     }
   if(in_v<=0 || out_v<=0)
      return;
   double en=in_p/in_v, ex=out_p/out_v, pip=PipSize(sym);
   double move=(buy ? ex-en : en-ex);
   string s="<b>"+sym+(buy ? " BUY" : " SELL")+" closed</b> "+Signed(move/pip, 1)+" pips";
   if(isl>0 && MathAbs(en-isl)>0)
      s+=" · "+Signed(move/MathAbs(en-isl), 2)+"R";
   s+="\nResult "+Signed(pl, 2)+" "+AccountInfoString(ACCOUNT_CURRENCY);
   s+="\nEntry "+Px(sym, en)+" → Exit "+Px(sym, ex)+"\nHeld "+Held((long)(t_out-t_in));
   Send(s);
  }

//+------------------------------------------------------------------+
void Send(string html)
  {
   if(Trim(InpHeader)!="")
      html="<b>"+Html(Trim(InpHeader))+"</b>\n"+html;
   if(MQLInfoInteger(MQL_TESTER))
     {
      Print("TRL[tester] ", html);                   // WebRequest isn't available in the tester
      return;
     }
   if(g_token=="" || g_chat=="")
      return;
   int k=ArraySize(g_q);
   ArrayResize(g_q, k+1);
   g_q[k].text=html;
   g_q[k].tries=0;
   g_q[k].next_at=0;
  }

// one message per second, oldest first, retries with back-off
void Pump()
  {
   if(ArraySize(g_q)==0 || g_q[0].next_at>TimeLocal())
      return;
   string body="{\"chat_id\":\""+Json(g_chat)+"\",\"text\":\""+Json(g_q[0].text)+"\",\"parse_mode\":\"HTML\"}";
   char data[], result[];
   string rh;
   int n=StringToCharArray(body, data, 0, WHOLE_ARRAY, CP_UTF8);
   ArrayResize(data, n-1);                          // drop the terminating zero
   ResetLastError();
   int code=WebRequest("POST", "https://api.telegram.org/bot"+g_token+"/sendMessage",
                       "Content-Type: application/json\r\n", 10000, data, result, rh);
   int err=GetLastError();
   if(code>=200 && code<300)
     {
      g_sent++;
      g_status="ready";
      ArrayRemove(g_q, 0, 1);
      return;
     }
   if(code==-1 && err==4014)
      g_status="allow WebRequest for https://api.telegram.org, then F7 > OK";
   else
      if(code==-1)
         g_status="no connection (error "+IntegerToString(err)+")";
      else
         g_status="Telegram HTTP "+IntegerToString(code)+" - check the token and chat ID";
   g_q[0].tries++;
   if(g_q[0].tries>=MAX_TRIES)
     {
      g_failed++;
      Print("Trade Reporter Lite: dropped a message - ", g_status);
      ArrayRemove(g_q, 0, 1);
      return;
     }
   g_q[0].next_at=TimeLocal()+5*(int)MathPow(3, g_q[0].tries-1);   // 5 s, 15 s, 45 s, 135 s
  }

// A small dark box, so the status stays readable over the candles.
void Line(const string name, const int y, const string text, const color clr)
  {
   string n="TRL_"+name;
   if(ObjectFind(0, n)<0)
     {
      ObjectCreate(0, n, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, n, OBJPROP_XDISTANCE, 20);
      ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
      ObjectSetString(0, n, OBJPROP_FONT, "Segoe UI");
      ObjectSetInteger(0, n, OBJPROP_FONTSIZE, 9);
     }
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, n, OBJPROP_TEXT, text);
   ObjectSetInteger(0, n, OBJPROP_COLOR, clr);
  }

void Show()
  {
   string bg="TRL_bg";
   if(ObjectFind(0, bg)<0)
     {
      ObjectCreate(0, bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, bg, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, bg, OBJPROP_XDISTANCE, 12);
      ObjectSetInteger(0, bg, OBJPROP_YDISTANCE, 22);
      ObjectSetInteger(0, bg, OBJPROP_XSIZE, 330);
      ObjectSetInteger(0, bg, OBJPROP_YSIZE, 64);
      ObjectSetInteger(0, bg, OBJPROP_BGCOLOR, C'22,26,34');
      ObjectSetInteger(0, bg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, bg, OBJPROP_COLOR, C'74,163,240');
      ObjectSetInteger(0, bg, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, bg, OBJPROP_HIDDEN, true);
     }
   bool ok=(g_status=="ready");
   Line("l0", 28, "TRADE REPORTER LITE  ·  "+(ok ? "READY" : "CHECK SETUP"), ok ? C'52,178,79' : clrOrange);
   Line("l1", 46, StringFormat("Sent %d  ·  Queued %d  ·  Failed %d", g_sent, ArraySize(g_q), g_failed), clrGainsboro);
   Line("l2", 64, ok ? "Watching all positions on this account" : g_status, ok ? clrSilver : clrOrange);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
