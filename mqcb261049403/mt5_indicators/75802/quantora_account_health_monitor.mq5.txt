#property copyright "Copyright 2026 Quantora"
#property link      "https://www.mql5.com/en/users/quantora/seller"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0

input group "========== HEALTH SCORE SETTINGS =========="
input double InpGoodMarginLevel=500.0;
input double InpWarningMarginLevel=200.0;
input double InpCriticalMarginLevel=100.0;
input double InpLowDrawdownPct=2.0;
input double InpModerateDrawdownPct=5.0;
input double InpHighDrawdownPct=10.0;
input double InpLowExposureLots=0.50;
input double InpModerateExposureLots=1.00;
input double InpHighExposureLots=2.00;

input group "========== DASHBOARD =========="
input bool InpShowPanel=true;
input ENUM_BASE_CORNER InpPanelCorner=CORNER_LEFT_UPPER;
input int InpPanelX=15;
input int InpPanelY=145;
input int InpTimerSeconds=1;

#define Q_BG C'8,23,38'
#define Q_GOLD C'212,175,55'
#define Q_WHITE C'245,245,245'
#define Q_GRAY C'169,176,184'
#define Q_GREEN C'0,200,83'
#define Q_YELLOW C'255,193,7'
#define Q_ORANGE C'255,152,0'
#define Q_RED C'255,82,82'
#define Q_BORDER C'62,76,89'
#define Q_DARK C'5,14,24'

string p="QAHM5_", cur="", health="UNKNOWN", mrisk="UNKNOWN", drisk="UNKNOWN", erisk="UNKNOWN", trade="UNKNOWN";
double bal,eq,free_margin,used_margin,margin_level,margin_usage,floatpl,dd,total_lots,spread_pts,score;
int open_positions;
long leverage;

color RiskColor(string s){
   if(s=="LOW"||s=="EXCELLENT"||s=="GOOD"||s=="ALLOWED") return Q_GREEN;
   if(s=="MODERATE"||s=="WARNING") return Q_YELLOW;
   if(s=="HIGH") return Q_ORANGE;
   if(s=="CRITICAL"||s=="BLOCKED") return Q_RED;
   return Q_GRAY;
}

void Exposure(){
   open_positions=0; total_lots=0.0;
   for(int i=0;i<PositionsTotal();i++){
      ulong t=PositionGetTicket(i);
      if(t==0 || !PositionSelectByTicket(t)) continue;
      open_positions++;
      total_lots+=PositionGetDouble(POSITION_VOLUME);
   }
}

void Classify(){
   if(margin_level<=0.0 || margin_level>=InpGoodMarginLevel) mrisk="LOW";
   else if(margin_level>=InpWarningMarginLevel) mrisk="MODERATE";
   else if(margin_level>=InpCriticalMarginLevel) mrisk="HIGH";
   else mrisk="CRITICAL";

   if(dd<=InpLowDrawdownPct) drisk="LOW";
   else if(dd<=InpModerateDrawdownPct) drisk="MODERATE";
   else if(dd<=InpHighDrawdownPct) drisk="HIGH";
   else drisk="CRITICAL";

   if(total_lots<=InpLowExposureLots) erisk="LOW";
   else if(total_lots<=InpModerateExposureLots) erisk="MODERATE";
   else if(total_lots<=InpHighExposureLots) erisk="HIGH";
   else erisk="CRITICAL";
}

double Penalty(string s){
   if(s=="MODERATE") return 10.0;
   if(s=="HIGH") return 20.0;
   if(s=="CRITICAL") return 35.0;
   return 0.0;
}

void CalcScore(){
   score=100.0-Penalty(mrisk)-Penalty(drisk)-Penalty(erisk);
   if(margin_usage>50.0) score-=10.0;
   else if(margin_usage>30.0) score-=5.0;
   if(floatpl<0.0 && bal>0.0) score-=MathMin(10.0,100.0*MathAbs(floatpl)/bal);
   score=MathMax(0.0,MathMin(100.0,score));
   if(score>=85.0) health="EXCELLENT";
   else if(score>=70.0) health="GOOD";
   else if(score>=50.0) health="WARNING";
   else health="CRITICAL";
}

void UpdateData(){
   cur=AccountInfoString(ACCOUNT_CURRENCY);
   bal=AccountInfoDouble(ACCOUNT_BALANCE);
   eq=AccountInfoDouble(ACCOUNT_EQUITY);
   free_margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   used_margin=AccountInfoDouble(ACCOUNT_MARGIN);
   margin_level=AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   floatpl=AccountInfoDouble(ACCOUNT_PROFIT);
   leverage=AccountInfoInteger(ACCOUNT_LEVERAGE);
   margin_usage=(eq>0.0?100.0*used_margin/eq:0.0);
   dd=(bal>0.0 && eq<bal?100.0*(bal-eq)/bal:0.0);
   Exposure();
   double pt=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   MqlTick tk;
   spread_pts=(pt>0.0 && SymbolInfoTick(_Symbol,tk)?(tk.ask-tk.bid)/pt:0.0);
   trade=(bool)TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)?"ALLOWED":"BLOCKED";
   Classify(); CalcScore();
}

bool Rect(string n,int x,int y,int w,int h,color bg,color br){
   if(!ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0)) return false;
   ObjectSetInteger(0,n,OBJPROP_CORNER,InpPanelCorner); ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,n,OBJPROP_XSIZE,w); ObjectSetInteger(0,n,OBJPROP_YSIZE,h); ObjectSetInteger(0,n,OBJPROP_BGCOLOR,bg); ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,br);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false); ObjectSetInteger(0,n,OBJPROP_HIDDEN,true); return true;
}
bool Label(string n,string t,int x,int y,int sz,color c,bool b=false){
   if(!ObjectCreate(0,n,OBJ_LABEL,0,0,0)) return false;
   ObjectSetInteger(0,n,OBJPROP_CORNER,InpPanelCorner); ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,n,OBJPROP_COLOR,c); ObjectSetInteger(0,n,OBJPROP_FONTSIZE,sz); ObjectSetString(0,n,OBJPROP_FONT,b?"Arial Bold":"Arial");
   ObjectSetString(0,n,OBJPROP_TEXT,t); ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false); ObjectSetInteger(0,n,OBJPROP_HIDDEN,true); return true;
}
void DeletePanel(){ for(int i=ObjectsTotal(0)-1;i>=0;i--){ string n=ObjectName(0,i); if(StringFind(n,p)==0) ObjectDelete(0,n); } }

void BuildPanel(){
   if(!InpShowPanel) return;
   DeletePanel(); int x=InpPanelX,y=InpPanelY;
   Rect(p+"BG",x,y,580,575,Q_BG,Q_GOLD);
   Label(p+"TITLE","QUANTORA",x+18,y+14,14,Q_GOLD,true); Label(p+"SUB","ACCOUNT HEALTH MONITOR",x+18,y+38,11,Q_WHITE,true); Label(p+"VER","MT5 v1.00",x+490,y+18,9,Q_GRAY);
   Label(p+"HEALTH","ACCOUNT HEALTH: UNKNOWN",x+18,y+78,13,Q_GREEN,true); Label(p+"SCORE","SCORE: 0 / 100",x+350,y+78,12,Q_GOLD,true);
   Rect(p+"SBG",x+18,y+112,544,22,Q_DARK,Q_BORDER); Rect(p+"SF",x+20,y+114,1,18,Q_GREEN,Q_GREEN);
   Label(p+"BAL","BALANCE: 0",x+18,y+158,10,Q_WHITE); Label(p+"EQ","EQUITY: 0",x+310,y+158,10,Q_WHITE);
   Label(p+"FM","FREE MARGIN: 0",x+18,y+194,10,Q_WHITE); Label(p+"UM","USED MARGIN: 0",x+310,y+194,10,Q_WHITE);
   Label(p+"ML","MARGIN LEVEL: 0%",x+18,y+230,10,Q_GOLD,true); Label(p+"MU","MARGIN USAGE: 0%",x+310,y+230,10,Q_WHITE);
   Label(p+"FLOAT","FLOATING P/L: 0",x+18,y+266,10,Q_WHITE); Label(p+"DD","EQUITY DD: 0%",x+310,y+266,10,Q_WHITE);
   Rect(p+"SEP1",x+18,y+302,544,2,Q_BORDER,Q_BORDER);
   Label(p+"POS","OPEN POSITIONS: 0",x+18,y+324,10,Q_WHITE); Label(p+"LOTS","TOTAL EXPOSURE: 0.00 LOT",x+310,y+324,10,Q_WHITE);
   Label(p+"LEV","LEVERAGE: 1:0",x+18,y+360,10,Q_GRAY); Label(p+"SPR","SPREAD: 0 pts",x+310,y+360,10,Q_GRAY);
   Rect(p+"SEP2",x+18,y+396,544,2,Q_BORDER,Q_BORDER);
   Label(p+"MR","MARGIN RISK: UNKNOWN",x+18,y+420,10,Q_GREEN,true); Label(p+"DR","DRAWDOWN RISK: UNKNOWN",x+310,y+420,10,Q_GREEN,true);
   Label(p+"ER","EXPOSURE RISK: UNKNOWN",x+18,y+456,10,Q_GREEN,true); Label(p+"TR","TRADE STATUS: UNKNOWN",x+310,y+456,10,Q_GREEN,true);
   Label(p+"TIME","SERVER TIME: --",x+18,y+500,10,Q_GRAY); Label(p+"FOOT","mql5.com/en/users/quantora/seller",x+310,y+500,9,Q_GOLD);
   Label(p+"INFO","Health Score combines margin, drawdown and exposure risk.",x+18,y+536,9,Q_GRAY); ChartRedraw();
}

void UpdatePanel(){
   if(!InpShowPanel) return;
   color hc=RiskColor(health);
   ObjectSetString(0,p+"HEALTH",OBJPROP_TEXT,"ACCOUNT HEALTH: "+health); ObjectSetInteger(0,p+"HEALTH",OBJPROP_COLOR,hc);
   ObjectSetString(0,p+"SCORE",OBJPROP_TEXT,"SCORE: "+DoubleToString(score,0)+" / 100");
   int fill=(int)MathRound(540.0*score/100.0); fill=MathMax(1,MathMin(540,fill));
   ObjectSetInteger(0,p+"SF",OBJPROP_XSIZE,fill); ObjectSetInteger(0,p+"SF",OBJPROP_BGCOLOR,hc); ObjectSetInteger(0,p+"SF",OBJPROP_BORDER_COLOR,hc);
   ObjectSetString(0,p+"BAL",OBJPROP_TEXT,"BALANCE: "+DoubleToString(bal,2)+" "+cur); ObjectSetString(0,p+"EQ",OBJPROP_TEXT,"EQUITY: "+DoubleToString(eq,2)+" "+cur);
   ObjectSetString(0,p+"FM",OBJPROP_TEXT,"FREE MARGIN: "+DoubleToString(free_margin,2)+" "+cur); ObjectSetString(0,p+"UM",OBJPROP_TEXT,"USED MARGIN: "+DoubleToString(used_margin,2)+" "+cur);
   ObjectSetString(0,p+"ML",OBJPROP_TEXT,"MARGIN LEVEL: "+DoubleToString(margin_level,1)+" %"); ObjectSetString(0,p+"MU",OBJPROP_TEXT,"MARGIN USAGE: "+DoubleToString(margin_usage,1)+" %");
   ObjectSetString(0,p+"FLOAT",OBJPROP_TEXT,"FLOATING P/L: "+DoubleToString(floatpl,2)+" "+cur); ObjectSetInteger(0,p+"FLOAT",OBJPROP_COLOR,floatpl>0?Q_GREEN:floatpl<0?Q_RED:Q_GRAY);
   ObjectSetString(0,p+"DD",OBJPROP_TEXT,"EQUITY DD: "+DoubleToString(dd,2)+" %");
   ObjectSetString(0,p+"POS",OBJPROP_TEXT,"OPEN POSITIONS: "+IntegerToString(open_positions)); ObjectSetString(0,p+"LOTS",OBJPROP_TEXT,"TOTAL EXPOSURE: "+DoubleToString(total_lots,2)+" LOT");
   ObjectSetString(0,p+"LEV",OBJPROP_TEXT,"LEVERAGE: 1:"+IntegerToString((int)leverage)); ObjectSetString(0,p+"SPR",OBJPROP_TEXT,"SPREAD: "+DoubleToString(spread_pts,1)+" pts");
   ObjectSetString(0,p+"MR",OBJPROP_TEXT,"MARGIN RISK: "+mrisk); ObjectSetInteger(0,p+"MR",OBJPROP_COLOR,RiskColor(mrisk));
   ObjectSetString(0,p+"DR",OBJPROP_TEXT,"DRAWDOWN RISK: "+drisk); ObjectSetInteger(0,p+"DR",OBJPROP_COLOR,RiskColor(drisk));
   ObjectSetString(0,p+"ER",OBJPROP_TEXT,"EXPOSURE RISK: "+erisk); ObjectSetInteger(0,p+"ER",OBJPROP_COLOR,RiskColor(erisk));
   ObjectSetString(0,p+"TR",OBJPROP_TEXT,"TRADE STATUS: "+trade); ObjectSetInteger(0,p+"TR",OBJPROP_COLOR,RiskColor(trade));
   ObjectSetString(0,p+"TIME",OBJPROP_TEXT,"SERVER TIME: "+TimeToString(TimeCurrent(),TIME_SECONDS)); ChartRedraw();
}

int OnInit(){
   if(InpTimerSeconds<1 || InpWarningMarginLevel<InpCriticalMarginLevel || InpGoodMarginLevel<InpWarningMarginLevel ||
      InpModerateDrawdownPct<InpLowDrawdownPct || InpHighDrawdownPct<InpModerateDrawdownPct ||
      InpModerateExposureLots<InpLowExposureLots || InpHighExposureLots<InpModerateExposureLots)
      return INIT_PARAMETERS_INCORRECT;

   IndicatorSetString(INDICATOR_SHORTNAME,"Quantora Account Health Monitor MT5 v1.00");
   BuildPanel(); UpdateData(); UpdatePanel();
   if(!EventSetTimer(InpTimerSeconds)) return INIT_FAILED;
   return INIT_SUCCEEDED;
}
void OnDeinit(const int reason){ EventKillTimer(); DeletePanel(); }
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[]){ return rates_total; }
void OnTimer(){ UpdateData(); UpdatePanel(); }

// Developed by Quantora
// https://www.mql5.com/en/users/quantora/seller
