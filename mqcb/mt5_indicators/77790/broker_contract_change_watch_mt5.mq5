//+------------------------------------------------------------------+
//| Broker Contract Change Watch MT5
//| Copyright 2026, Shahrukh. Open source CodeBase example.
//| Read-only trading diagnostics. No orders, DLLs or network calls.
//+------------------------------------------------------------------+
#property copyright "2026, Shahrukh"
#property link      "https://www.mql5.com/en/users/shahrukhktk"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0

// All helpers are embedded so this file has no include dependencies.
string g_scope="",g_base="",g_last_error="";
int g_lock=INVALID_HANDLE,g_csv=INVALID_HANDLE;
void Note(const string event,const string message)
  { PrintFormat("[%s][%s] %s",MQLInfoString(MQL_PROGRAM_NAME),event,message); }
string Context()
  { return AccountInfoString(ACCOUNT_SERVER)+"|"+(string)AccountInfoInteger(ACCOUNT_LOGIN); }
uint Hash(const string s)
  {
   uint h=2166136261;
   for(int i=0;i<StringLen(s);i++) { h^=(uint)StringGetCharacter(s,i); h*=16777619; }
   return h;
  }
bool PutText(const int h,const string s)
  {
   int n=StringLen(s);
   return FileWriteInteger(h,n)==4 && FileWriteString(h,s,n)==(uint)(n*2);
  }
bool GetText(const int h,string &s)
  {
   if(FileTell(h)+4>FileSize(h)) return false;
   int n=FileReadInteger(h);
   if(n<0 || n>2048 || FileTell(h)+(ulong)(n*2)>FileSize(h)) return false;
   s=FileReadString(h,n); return StringLen(s)==n;
  }
bool Acquire(const string kind,const string detail)
  {
   g_scope=Context()+"|"+kind+"|"+detail;
   g_base="ShahrukhDiagnostics\\"+kind+"_"+StringFormat("%08X",Hash(g_scope));
   ResetLastError();
   g_lock=FileOpen(g_base+".lock",FILE_BIN|FILE_READ|FILE_WRITE);
   if(g_lock==INVALID_HANDLE)
     { Note("LOCK_ERROR","Another instance may own this scope, or Files is not writable. Error="+(string)GetLastError()); return false; }
   return true;
  }
bool OpenLog(const string filename)
  {
   ResetLastError();
   g_csv=FileOpen(filename,FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_READ|FILE_UNICODE,',');
   if(g_csv==INVALID_HANDLE) { g_last_error="CSV open failed: "+(string)GetLastError(); Note("IO_ERROR",g_last_error); return false; }
   if(FileSize(g_csv)==0 && FileWrite(g_csv,"observed_local_time","event","symbol","reference","field","before","after","note")==0)
     { g_last_error="CSV header write failed"; return false; }
   return FileSeek(g_csv,0,SEEK_END);
  }
bool Event(const string event,const string symbol,const string reference,const string field,
           const string before,const string after,const string note="")
  {
   Note(event,symbol+" | "+reference+" | "+field+" | "+before+" -> "+after+" | "+note);
   if(g_csv==INVALID_HANDLE) return false;
   ResetLastError();
   uint written=FileWrite(g_csv,TimeToString(TimeLocal(),TIME_DATE|TIME_SECONDS),event,symbol,reference,field,before,after,note);
   FileFlush(g_csv);
   if(written==0 || GetLastError()!=0) { g_last_error="CSV write/flush failed"; Note("IO_ERROR",g_last_error); return false; }
   return true;
  }
int StateWriter(const string tag)
  {
   int h=FileOpen(g_base+".tmp",FILE_BIN|FILE_WRITE);
   if(h==INVALID_HANDLE) return h;
   if(!PutText(h,tag) || !PutText(h,g_scope)) { FileClose(h); return INVALID_HANDLE; }
   return h;
  }
int StateReader(const string tag)
  {
   int h=FileOpen(g_base+".bin",FILE_BIN|FILE_READ);
   if(h==INVALID_HANDLE) return h;
   string t,s;
   if(!GetText(h,t) || !GetText(h,s) || t!=tag || s!=g_scope)
     { FileClose(h); Note("STATE_ERROR","Header or scope mismatch. Saved baseline retained."); return INVALID_HANDLE; }
   return h;
  }
bool Commit(const int h,const bool ok)
  {
   ResetLastError(); FileFlush(h); int err=GetLastError(); FileClose(h);
   if(!ok || err!=0 || !FileMove(g_base+".tmp",0,g_base+".bin",FILE_REWRITE))
     { g_last_error="Baseline save failed; previous file retained if replacement failed"; Note("STATE_ERROR",g_last_error); return false; }
   return true;
  }
void Release()
  {
   if(g_csv!=INVALID_HANDLE) { FileClose(g_csv); g_csv=INVALID_HANDLE; }
   if(g_lock!=INVALID_HANDLE) { FileClose(g_lock); g_lock=INVALID_HANDLE; }
  }

input int InpPanelX=16;       // Panel left offset (pixels)
input int InpPanelY=24;       // Panel top offset (pixels)
input int InpFontSize=10;     // Font size, 8 to 18
string g_prefix="";
bool PanelInit(const string title,const int rows)
  {
   if(InpPanelX<0 || InpPanelY<0 || InpFontSize<8 || InpFontSize>18) return false;
   g_prefix="SD_"+(string)ChartID()+"_"+(string)GetMicrosecondCount()+"_";
   if(!ObjectCreate(0,g_prefix+"bg",OBJ_RECTANGLE_LABEL,0,0,0)) return false;
   ObjectSetInteger(0,g_prefix+"bg",OBJPROP_XDISTANCE,InpPanelX);
   ObjectSetInteger(0,g_prefix+"bg",OBJPROP_YDISTANCE,InpPanelY);
   ObjectSetInteger(0,g_prefix+"bg",OBJPROP_XSIZE,85*InpFontSize);
   ObjectSetInteger(0,g_prefix+"bg",OBJPROP_YSIZE,(rows+1)*(InpFontSize+9)+22);
   ObjectSetInteger(0,g_prefix+"bg",OBJPROP_BGCOLOR,C'18,25,36');
   ObjectSetInteger(0,g_prefix+"bg",OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,g_prefix+"bg",OBJPROP_COLOR,C'50,67,86');
   ObjectSetInteger(0,g_prefix+"bg",OBJPROP_SELECTABLE,false);
   for(int i=0;i<=rows;i++)
     {
      string n=g_prefix+(string)i;
      if(!ObjectCreate(0,n,OBJ_LABEL,0,0,0)) return false;
      ObjectSetInteger(0,n,OBJPROP_XDISTANCE,InpPanelX+12);
      ObjectSetInteger(0,n,OBJPROP_YDISTANCE,InpPanelY+10+i*(InpFontSize+9));
      ObjectSetInteger(0,n,OBJPROP_FONTSIZE,InpFontSize);
      ObjectSetInteger(0,n,OBJPROP_COLOR,i==0?clrDeepSkyBlue:clrGainsboro);
      ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
      ObjectSetString(0,n,OBJPROP_FONT,"Consolas");
     }
   ObjectSetString(0,g_prefix+"0",OBJPROP_TEXT,title);
   return true;
  }
void Row(const int i,const string text,const color c=clrGainsboro)
  {
   string n=g_prefix+(string)i;
   if(ObjectGetString(0,n,OBJPROP_TEXT)!=text) ObjectSetString(0,n,OBJPROP_TEXT,text);
   ObjectSetInteger(0,n,OBJPROP_COLOR,c);
  }
void PanelClose()
  { if(g_prefix!="") ObjectsDeleteAll(0,g_prefix); ChartRedraw(); }
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],const double &high[],const double &low[],const double &close[],
                const long &tick_volume[],const long &volume[],const int &spread[])
  { return rates_total; }

input int InpPollSeconds=10;       // Poll interval, 1 to 3600 seconds
input bool InpResetBaseline=false; // Explicitly replace saved baseline on this attachment
input bool InpPopupAlerts=false;   // One popup per detected batch of changes
#define FIELDS 18
string names[FIELDS]={"digits","point","tick_size","contract_size","volume_min","volume_max",
 "volume_step","volume_limit","stops_level","freeze_level","trade_mode","execution_mode",
 "filling_flags","order_flags","swap_mode","swap_long","swap_short","triple_swap_day"};
struct ContractState { double value[FIELDS]; };
ContractState g_old;
bool g_ready=false;
long g_changes=0;
string g_context="",g_latest="No changes observed in this run.";
bool ReadContract(ContractState &s)
  {
   if(!SymbolIsSynchronized(_Symbol)) return false;
   ENUM_SYMBOL_INFO_INTEGER ip[9]={SYMBOL_DIGITS,SYMBOL_TRADE_STOPS_LEVEL,SYMBOL_TRADE_FREEZE_LEVEL,
      SYMBOL_TRADE_MODE,SYMBOL_TRADE_EXEMODE,SYMBOL_FILLING_MODE,SYMBOL_ORDER_MODE,SYMBOL_SWAP_MODE,SYMBOL_SWAP_ROLLOVER3DAYS};
   int ix[9]={0,8,9,10,11,12,13,14,17};
   for(int i=0;i<9;i++) { long v; if(!SymbolInfoInteger(_Symbol,ip[i],v)) return false; s.value[ix[i]]=(double)v; }
   ENUM_SYMBOL_INFO_DOUBLE dp[9]={SYMBOL_POINT,SYMBOL_TRADE_TICK_SIZE,SYMBOL_TRADE_CONTRACT_SIZE,
      SYMBOL_VOLUME_MIN,SYMBOL_VOLUME_MAX,SYMBOL_VOLUME_STEP,SYMBOL_VOLUME_LIMIT,SYMBOL_SWAP_LONG,SYMBOL_SWAP_SHORT};
   int dx[9]={1,2,3,4,5,6,7,15,16};
   for(int i=0;i<9;i++) if(!SymbolInfoDouble(_Symbol,dp[i],s.value[dx[i]]) || !MathIsValidNumber(s.value[dx[i]])) return false;
   return s.value[1]>0 && s.value[2]>0 && s.value[3]>0 && s.value[4]>0 && s.value[5]>=s.value[4] && s.value[6]>0;
  }
bool SaveContract(const ContractState &s)
  {
   int h=StateWriter("CONTRACT_1"); if(h==INVALID_HANDLE) { g_last_error="Cannot create baseline file"; return false; }
   bool ok=FileWriteStruct(h,s)==sizeof(ContractState); return Commit(h,ok);
  }
bool LoadContract()
  {
   int h=StateReader("CONTRACT_1"); if(h==INVALID_HANDLE) return false;
   bool ok=FileTell(h)+sizeof(ContractState)==FileSize(h) && FileReadStruct(h,g_old)==sizeof(ContractState);
   FileClose(h);
   for(int i=0;i<FIELDS;i++) if(!MathIsValidNumber(g_old.value[i])) ok=false;
   return ok && g_old.value[1]>0 && g_old.value[2]>0 && g_old.value[3]>0 && g_old.value[4]>0 && g_old.value[6]>0;
  }
string Num(const double v) { return StringFormat("%.12g",v); }
void OnTimer()
  {
   if(Context()!=g_context) { Row(1,"ACCOUNT CHANGED: remove and reattach this indicator.",clrOrange); return; }
   if(!TerminalInfoInteger(TERMINAL_CONNECTED)) { Row(1,"DISCONNECTED: baseline preserved.",clrOrange); return; }
   ContractState now;
   if(!ReadContract(now)) { Row(1,"WAITING: symbol properties unavailable or not synchronized.",clrOrange); return; }
   int changes=0;
   if(g_ready)
      for(int i=0;i<FIELDS;i++)
        {
         double scale=MathMax(MathAbs(g_old.value[i]),MathAbs(now.value[i]));
         if(MathAbs(g_old.value[i]-now.value[i])<=MathMax(1e-12,scale*1e-12)) continue;
         changes++;
         g_latest=names[i]+": "+Num(g_old.value[i])+" -> "+Num(now.value[i]);
         Event("PROPERTY_CHANGED",_Symbol,"contract",names[i],Num(g_old.value[i]),Num(now.value[i]),"Observed broker property change; cause not inferred.");
        }
   if(!g_ready || changes>0)
     {
      if(!SaveContract(now)) { Row(1,"SAVE FAILED: baseline not advanced; see Experts log.",clrOrangeRed); return; }
      g_old=now; g_ready=true; g_changes+=changes;
      if(changes>0 && InpPopupAlerts) Alert("Contract Watch: ",_Symbol," / ",changes," property changes. ",g_latest);
     }
   Row(1,_Symbol+" | 18 contract properties | "+TimeToString(TimeLocal(),TIME_SECONDS),clrPaleGreen);
   Row(2,"Changes in this run: "+(string)g_changes+" | Saved baseline survives restart.");
   Row(3,"Latest: "+g_latest);
   Row(4,"Volume min / step / max: "+Num(now.value[4])+" / "+Num(now.value[6])+" / "+Num(now.value[5]));
   Row(5,"Stops / freeze (points): "+Num(now.value[8])+" / "+Num(now.value[9]));
   Row(6,"Swap long / short: "+Num(now.value[15])+" / "+Num(now.value[16])+" | mode "+Num(now.value[14]));
   Row(7,"CSV and baseline: MQL5\\Files\\ShahrukhDiagnostics");
   Row(8,g_last_error==""?"Read-only. Spread and currency-converted tick value are excluded.":g_last_error,g_last_error==""?clrSilver:clrOrangeRed);
   ChartRedraw();
  }
int OnInit()
  {
   if(InpPollSeconds<1 || InpPollSeconds>3600) return INIT_PARAMETERS_INCORRECT;
   g_context=Context();
   if(!Acquire("Contract",_Symbol) || !OpenLog(g_base+".csv") || !PanelInit("BROKER CONTRACT CHANGE WATCH",8)) return INIT_FAILED;
   if(!InpResetBaseline && FileIsExist(g_base+".bin"))
     { if(!LoadContract()) { Note("STATE_ERROR","Invalid baseline. Inspect saved file; use explicit reset to replace it."); return INIT_FAILED; } g_ready=true; }
   IndicatorSetString(INDICATOR_SHORTNAME,"Contract Change Watch");
   if(!EventSetTimer(InpPollSeconds)) return INIT_FAILED;
   OnTimer(); return INIT_SUCCEEDED;
  }
void OnDeinit(const int reason) { EventKillTimer(); Release(); PanelClose(); }
