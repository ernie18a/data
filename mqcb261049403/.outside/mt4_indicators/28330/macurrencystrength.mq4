//+------------------------------------------------------------------+
//|                                           MACurrencyStrength.mq4 |
//+------------------------------------------------------------------+

/*
 To access this indicator via iCustom, include this function within your EA, Indicator
 or script:
 
   bool GetCSBuffer(int tf, int bar, string currency, int &numBulls, int &numBears)
   {
      string name = "MACurrencyStrength";
      string Cs[] = { "USD", "EUR", "GBP", "CHF", "AUD", "CAD", "JPY", "NZD" };
      int numCs = ArraySize(Cs);
      for (int i=0; i<numCs; i++)
      {
         if (Cs[i]==currency)
         {
            numBulls = int(iCustom(Symbol(),tf,name,i*3,bar)) - (numCs-i-1)*numCs;
            numBears = int(iCustom(Symbol(),tf,name,(i*3)+1,bar)) - (numCs-i-1)*numCs;
            numBulls = numBulls - numBears;
            return (true);
         }
      }
      return (false);
   }

 Then, you can use this function this way:

   int bar = 1;
   string c = "USD";
   int numBulls, numBears;
   if (GetCSBuffer(Period(),bar,c,numBulls,numBears))
      Print ("Bulls = ", numBulls, ", Bears = ", numBears);
*/
 
#property strict
#include <stdlib.mqh>

#define PRINTERROR(INFO) Print ("Error in "+__FUNCTION__+" : ("+string(_LastError)+") "+ErrorDescription(GetLastError())+" ["+INFO+"]")
#define HEIGHT 8

//--- indicator input parameters (Alt-255 for indentation)
input ENUM_APPLIED_PRICE MAPrice       = PRICE_CLOSE;  // Price type of MA
input ENUM_MA_METHOD     MAMethod      = MODE_EMA;     // Method of MA
input int                MAPeriod      = 10;           // Period of MA
input int                MAShift       = 0;            // Shift of MA
input int                MaxBars       = 100;          // Max Bars to Compute
input bool               SkipBar0      = true;         // Skip Bar 0 - Will Run Faster
input color              ColorOfBulls  = clrAqua;      // Color of Bulls
input color              ColorOfBears  = clrOrangeRed; // Color of Bears
input color              ColorOfGaps   = clrBlack;     // Color of Gaps
input color              ColorOfLabels = clrGray;      // Color of Labels
input double             TextSize      = 75;           // Text size (% of row height)
input string             EURUSDName    = "EURUSD";     // Full Symbol Name of EURUSD

#property indicator_separate_window
#property indicator_minimum -1
#property indicator_maximum 72
#property indicator_buffers 24
#property indicator_plots   24
//--- indicator buffers
double USDBullBuffer[], USDBearBuffer[], USDGapBuffer[];
double EURBullBuffer[], EURBearBuffer[], EURGapBuffer[];
double GBPBullBuffer[], GBPBearBuffer[], GBPGapBuffer[];
double CHFBullBuffer[], CHFBearBuffer[], CHFGapBuffer[];
double AUDBullBuffer[], AUDBearBuffer[], AUDGapBuffer[];
double CADBullBuffer[], CADBearBuffer[], CADGapBuffer[];
double JPYBullBuffer[], JPYBearBuffer[], JPYGapBuffer[];
double NZDBullBuffer[], NZDBearBuffer[], NZDGapBuffer[];

class IndBuffers
{
private:
   int m_prevBarPixelWidth, m_prevPixelHeight;
   void AddBull(int bar, string c);
   void AddBear(int bar, string c);
public:
   IndBuffers() { m_prevBarPixelWidth = 0; m_prevPixelHeight = 0; };
   ~IndBuffers() {};
   bool SetBuffers();
   void InitBuffers();
   void InitBar(int bar);
   void FillBar(int bar, int symbIdx, int trend);
   int GetBarPixelWidth();
   bool ZoomChanged();
} indBuffers;

string Cs[] = { "USD","EUR","GBP","CHF","AUD","CAD","JPY","NZD" };
string RawCPs[] = { "AUDCAD", "AUDCHF", "AUDJPY", "AUDNZD", "AUDUSD",
                    "CADCHF", "CADJPY", "CHFJPY", "EURAUD", "EURCAD",
                    "EURCHF", "EURGBP", "EURJPY", "EURNZD", "EURUSD",
                    "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD",
                    "GBPUSD", "NZDCAD", "NZDCHF", "NZDJPY", "NZDUSD",
                    "USDCAD", "USDCHF", "USDJPY" };
string ActualCPs[];
string prefix, infix, postfix;

int wid;
long cid;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{  
   if (!InitializeSymbols())
      return (INIT_FAILED);

   indBuffers.SetBuffers();
   
   string strShortName = WindowExpertName()+"("+string(MAPeriod)+")";
   IndicatorShortName(strShortName);
   wid = WindowFind(strShortName);
   cid = ChartID();

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if (ChartWindowFind()==wid)
   {
      for (int i=0; i<ArraySize(Cs); i++)
      {
         string objName = WindowExpertName()+Cs[i];
         ObjectDelete(objName);
      }
   }
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
   int limit = MathMin(rates_total-1, rates_total-prev_calculated);
   
   if (prev_calculated==0 || indBuffers.ZoomChanged())
   {
      indBuffers.InitBuffers();
      limit = rates_total-1;
   }
   
   int firstBar = 0;
   if (SkipBar0)
      firstBar = 1;
   
   for (int i=MathMin(limit,MaxBars); i>=firstBar; i--)
   {
      indBuffers.InitBar(i);
      for (int j=0; j<ArraySize(RawCPs); j++)
         indBuffers.FillBar(i, j, GetTrend(i, j));

      if (i==1 && ChartWindowFind()==wid)
      {
         for (int c=0; c<ArraySize(Cs); c++)
         {
            string objName = WindowExpertName()+Cs[c];
            int halfHeight = HEIGHT/2;
            datetime nameXPos = time[0]+_Period*2*60;
            double nameYPos = indicator_maximum-((c+1)*HEIGHT)-halfHeight;
            if (ObjectFind(objName)!=wid)
            {
               ObjectCreate(cid,objName,OBJ_TEXT,wid,nameXPos,nameYPos);
               ObjectSetInteger(cid,objName,OBJPROP_COLOR,ColorOfLabels);
               ObjectSetInteger(cid,objName,OBJPROP_ANCHOR,ANCHOR_LEFT);
               ObjectSetInteger(cid,objName,OBJPROP_SELECTABLE,false);
               ObjectSetInteger(cid,objName,OBJPROP_HIDDEN,true);
            }
            else
            {
               ObjectSetInteger(cid,objName,OBJPROP_TIME1,nameXPos);
               ObjectSetDouble(cid,objName,OBJPROP_PRICE1,nameYPos);
            }
            
            int fontSize = int(ChartGetInteger(cid,CHART_HEIGHT_IN_PIXELS,wid)*(TextSize/100))/9;
            ObjectSetText(objName,Cs[c],fontSize);
         }
      }
   }
   
   return(rates_total);
}

bool InitializeSymbols()
{
   if (!SymbolSelect(EURUSDName,true))
   {
      PRINTERROR("Symbol "+EURUSDName+" does not exist! Please check input parameters.");
      return (false);
   }
   
   const int upperCase = 1, lowerCase = 0;
   int cases[6];
   ArrayInitialize(cases, -1);
   string tmpEURUSD = EURUSDName;
   StringToLower(tmpEURUSD);
   int pos1 = StringFind(tmpEURUSD,"eur");
   int pos2 = StringFind(tmpEURUSD,"usd");
   if (pos1<0 || pos2<0)
   {
      PRINTERROR("Symbol "+EURUSDName+" is not EURUSD! Please check input parameters.");
      return (false);
   }
   
   for (int i=pos1; i<pos1+3; i++)
   {
      if (EURUSDName[i]>=65 && EURUSDName[i]<=90)
         cases[i-pos1] = upperCase;
      else
         cases[i-pos1] = lowerCase;
   }
   for (int i=pos2; i<pos2+3; i++)
   {
      if (EURUSDName[i]>=65 && EURUSDName[i]<=90)
         cases[i-pos2] = upperCase;
      else
         cases[i-pos2] = lowerCase;
   }
   
   prefix = pos1>0?StringSubstr(EURUSDName,0,pos1):"";
   infix = (pos2-(pos1+3))>0?StringSubstr(EURUSDName,pos1,pos2-(pos1+3)):"";
   postfix = StringSubstr(EURUSDName,pos2+3);
   
   int numCPs = ArraySize(RawCPs);
   ArrayResize(ActualCPs,numCPs);
   for (int i=0; i<numCPs; i++)
   {
      string cp = RawCPs[i];
      for (int j=0; j<6; j++)
      {
         ushort ch = StringGetChar(cp, j);
         if (ch>=65 && ch<=90 && cases[j]==lowerCase)
            cp = StringSetChar(cp, j, ushort(ch+32));
         if (ch>=97 && ch<=122 && cases[j]==upperCase)
            cp = StringSetChar(cp, j, ushort(ch-32));
      }
      ActualCPs[i] = cp;
      if (prefix!="" || infix!="" || postfix!="")
      {
         string c1 = StringSubstr(cp,0,3);
         string c2 = StringSubstr(cp,3,3);
         ActualCPs[i] = prefix+c1+infix+c2+postfix;
      }
      
      if (!SymbolSelect(ActualCPs[i],true))
      {
         PRINTERROR("Symbol "+ActualCPs[i]+" is not available!");
         return (false);
      }
   }
   
   return (true);
}

int GetTrend(int bar, int symbIdx)
{
   string symb = ActualCPs[symbIdx];
   
   if (!SymbolSelect(symb,true))
   {
      PRINTERROR(symb+" not found.");
      return (0);
   }
      
   double ema10 = iMA(symb,_Period,MAPeriod,MAShift,MAMethod,MAPrice,bar);
   double close = iClose(symb,_Period,bar);
   
   if (close>ema10)
      return (1);
   
   if (close<ema10)
      return (-1);
   
   return (0);
}

#define SETBUFFER(BUFFER,LABEL) if (!SetIndexBuffer(++idx, BUFFER)) { PRINTERROR(LABEL); return (false); } SetIndexLabel(idx,LABEL);
bool IndBuffers::SetBuffers()
{
   int idx = -1;
   
   SETBUFFER(USDBullBuffer,"USDBull"); SETBUFFER(USDBearBuffer,"USDBear"); SETBUFFER(USDGapBuffer,"USDGap");
   SETBUFFER(EURBullBuffer,"EURBull"); SETBUFFER(EURBearBuffer,"EURBear"); SETBUFFER(EURGapBuffer,"EURGap");
   SETBUFFER(GBPBullBuffer,"GBPBull"); SETBUFFER(GBPBearBuffer,"GBPBear"); SETBUFFER(GBPGapBuffer,"GBPGap");
   SETBUFFER(CHFBullBuffer,"CHFBull"); SETBUFFER(CHFBearBuffer,"CHFBear"); SETBUFFER(CHFGapBuffer,"CHFGap");
   SETBUFFER(AUDBullBuffer,"AUDBull"); SETBUFFER(AUDBearBuffer,"AUDBear"); SETBUFFER(AUDGapBuffer,"AUDGap");
   SETBUFFER(CADBullBuffer,"CADBull"); SETBUFFER(CADBearBuffer,"CADBear"); SETBUFFER(CADGapBuffer,"CADGap");
   SETBUFFER(JPYBullBuffer,"JPYBull"); SETBUFFER(JPYBearBuffer,"JPYBear"); SETBUFFER(JPYGapBuffer,"JPYGap");
   SETBUFFER(NZDBullBuffer,"NZDBull"); SETBUFFER(NZDBearBuffer,"NZDBear"); SETBUFFER(NZDGapBuffer,"NZDGap");

   return (true);
}

#define INITBUFFER SetIndexDrawBegin(idx, Bars-MaxBars); SetIndexEmptyValue(idx, 0);
#define INITBULLBUFFER(BUFFER) SetIndexStyle(++idx, DRAW_HISTOGRAM, STYLE_SOLID, w, ColorOfBulls); INITBUFFER;
#define INITBEARBUFFER(BUFFER) SetIndexStyle(++idx, DRAW_HISTOGRAM, STYLE_SOLID, w, ColorOfBears); INITBUFFER;
#define INITGAPBUFFER(BUFFER) SetIndexStyle(++idx, DRAW_HISTOGRAM, STYLE_SOLID, w, ColorOfGaps); INITBUFFER;
void IndBuffers::InitBuffers()
{
   int idx = -1;
   int w = GetBarPixelWidth();
   
   INITBULLBUFFER(USDBullBuffer); INITBEARBUFFER(USDBearBuffer); INITGAPBUFFER(USDGapBuffer);
   INITBULLBUFFER(EURBullBuffer); INITBEARBUFFER(EURBearBuffer); INITGAPBUFFER(EURGapBuffer);
   INITBULLBUFFER(GBPBullBuffer); INITBEARBUFFER(GBPBearBuffer); INITGAPBUFFER(GBPGapBuffer);
   INITBULLBUFFER(CHFBullBuffer); INITBEARBUFFER(CHFBearBuffer); INITGAPBUFFER(CHFGapBuffer);
   INITBULLBUFFER(AUDBullBuffer); INITBEARBUFFER(AUDBearBuffer); INITGAPBUFFER(AUDGapBuffer);
   INITBULLBUFFER(CADBullBuffer); INITBEARBUFFER(CADBearBuffer); INITGAPBUFFER(CADGapBuffer);
   INITBULLBUFFER(JPYBullBuffer); INITBEARBUFFER(JPYBearBuffer); INITGAPBUFFER(JPYGapBuffer);
   INITBULLBUFFER(NZDBullBuffer); INITBEARBUFFER(NZDBearBuffer); INITGAPBUFFER(NZDGapBuffer);

   m_prevBarPixelWidth = w;
}

#define INITBAR(BUFFER) BUFFER[bar] = ini;
void IndBuffers::InitBar(int bar)
{
   int ini = indicator_maximum-2*HEIGHT;
   
                INITBAR(USDBullBuffer); INITBAR(USDBearBuffer); INITBAR(USDGapBuffer);
   ini-=HEIGHT; INITBAR(EURBullBuffer); INITBAR(EURBearBuffer); INITBAR(EURGapBuffer);
   ini-=HEIGHT; INITBAR(GBPBullBuffer); INITBAR(GBPBearBuffer); INITBAR(GBPGapBuffer);
   ini-=HEIGHT; INITBAR(CHFBullBuffer); INITBAR(CHFBearBuffer); INITBAR(CHFGapBuffer);
   ini-=HEIGHT; INITBAR(AUDBullBuffer); INITBAR(AUDBearBuffer); INITBAR(AUDGapBuffer);
   ini-=HEIGHT; INITBAR(CADBullBuffer); INITBAR(CADBearBuffer); INITBAR(CADGapBuffer);
   ini-=HEIGHT; INITBAR(JPYBullBuffer); INITBAR(JPYBearBuffer); INITBAR(JPYGapBuffer);
   ini-=HEIGHT; INITBAR(NZDBullBuffer); INITBAR(NZDBearBuffer); INITBAR(NZDGapBuffer);
}

void IndBuffers::FillBar(int bar, int symbIdx, int trend)
{
   if (trend==0)
      return;
   
   string symb = RawCPs[symbIdx];
   string c1 = StringSubstr(symb,(trend>0)?0:3,3);
   string c2 = StringSubstr(symb,(trend>0)?3:0,3);
   
   AddBull(bar, c1);
   AddBear(bar, c2);
}

void IndBuffers::AddBull(int bar, string c)
{
   if (c==Cs[0]) USDBullBuffer[bar] += 1;
   if (c==Cs[1]) EURBullBuffer[bar] += 1;
   if (c==Cs[2]) GBPBullBuffer[bar] += 1;
   if (c==Cs[3]) CHFBullBuffer[bar] += 1;
   if (c==Cs[4]) AUDBullBuffer[bar] += 1;
   if (c==Cs[5]) CADBullBuffer[bar] += 1;
   if (c==Cs[6]) JPYBullBuffer[bar] += 1;
   if (c==Cs[7]) NZDBullBuffer[bar] += 1;
}

void IndBuffers::AddBear(int bar, string c)
{
   if (c==Cs[0]) USDBearBuffer[bar] += 1;
   if (c==Cs[1]) EURBearBuffer[bar] += 1;
   if (c==Cs[2]) GBPBearBuffer[bar] += 1;
   if (c==Cs[3]) CHFBearBuffer[bar] += 1;
   if (c==Cs[4]) AUDBearBuffer[bar] += 1;
   if (c==Cs[5]) CADBearBuffer[bar] += 1;
   if (c==Cs[6]) JPYBearBuffer[bar] += 1;
   if (c==Cs[7]) NZDBearBuffer[bar] += 1;
   AddBull(bar, c);
}

int IndBuffers::GetBarPixelWidth()
{
   int numVisibleBars = WindowBarsPerChart();
   int numVisiblePixels = int(ChartGetInteger(ChartID(),CHART_WIDTH_IN_PIXELS));
   return (int(numVisiblePixels/numVisibleBars));
}

bool IndBuffers::ZoomChanged()
{
   bool changed = false;
   
   int currBarPixelWidth = GetBarPixelWidth();
   if (currBarPixelWidth!=m_prevBarPixelWidth)
      changed = true;
   m_prevBarPixelWidth = currBarPixelWidth;

   int currPixelHeight = int(ChartGetInteger(cid,CHART_HEIGHT_IN_PIXELS,wid));
   if (currPixelHeight!=m_prevPixelHeight)
      changed = true;
   m_prevPixelHeight = currPixelHeight;

   return (changed);
}