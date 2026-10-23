//+------------------------------------------------------------------+
//|                                              BufferInspector.mq5 |
//|                                     Buffer Inspector Kb, MQL5    |
//|                                                                  |
//| Shows what every buffer of an indicator holds - arrows, a line   |
//| or a colour index - and marks the last arrows of each arrow      |
//| buffer on the chart with its number. Drop the script on a chart  |
//| that already has the indicator, or enter the indicator's name.   |
//+------------------------------------------------------------------+
#property copyright   "Bohdan Klok"
#property link        "https://www.mql5.com/en/users/kbposht"
#property version     "1.00"
#property description "Which buffer holds the arrows? Drop this script on a chart with your indicator:"
#property description "it lists every buffer (arrows, line or colour index) and labels the arrows on"
#property description "the chart with their buffer numbers. Works with any indicator, including"
#property description "compiled ones without source code."
#property script_show_inputs

input string InpIndicator="";       // Indicator name inside MQL5\Indicators (empty = the ones on this chart)
input string InpParams="";          // Its inputs, comma separated (empty = defaults)
input int    InpBars=500;           // Closed bars to inspect
input int    InpMarks=20;           // Arrows to label on the chart per buffer (0 = none)
input bool   InpClear=false;        // Only remove the labels of a previous run

#define PREFIX "BufInspector_"

color g_palette[]={clrDodgerBlue,clrOrangeRed,clrLimeGreen,clrGold,clrMagenta,clrAqua,clrWhite,clrTomato};

//+------------------------------------------------------------------+
//| Arrow buffers mark "no arrow" with EMPTY_VALUE or 0              |
//+------------------------------------------------------------------+
bool HasArrow(const double v)
  {
   return(v!=EMPTY_VALUE && v!=0.0 && MathIsValidNumber(v));
  }

bool IsDefined(const double v)
  {
   return(v!=EMPTY_VALUE && MathIsValidNumber(v));
  }

//+------------------------------------------------------------------+
//| Indicator inputs from "14,0,1.5,true,text": numbers, bools and   |
//| strings, in the order of the indicator's own inputs window       |
//+------------------------------------------------------------------+
int CreateByName(const string name,const string params)
  {
   MqlParam p[];
   ArrayResize(p,1);
   p[0].type=TYPE_STRING;
   p[0].string_value=name;
   if(StringLen(params)>0)
     {
      string parts[];
      const int n=StringSplit(params,',',parts);
      ArrayResize(p,n+1);
      for(int i=0; i<n; i++)
        {
         string s=parts[i];
         StringTrimLeft(s);
         StringTrimRight(s);
         if(s=="true" || s=="false")
           {
            p[i+1].type=TYPE_BOOL;
            p[i+1].integer_value=(s=="true");
           }
         else
            if(StringLen(s)>0 && (StringFind(s,".")>=0) && MathIsValidNumber(StringToDouble(s)) && StringToDouble(s)!=0.0)
              {
               p[i+1].type=TYPE_DOUBLE;
               p[i+1].double_value=StringToDouble(s);
              }
            else
               if(s=="0" || (StringLen(s)>0 && StringToInteger(s)!=0))
                 {
                  p[i+1].type=TYPE_INT;
                  p[i+1].integer_value=StringToInteger(s);
                 }
               else
                 {
                  p[i+1].type=TYPE_STRING;
                  p[i+1].string_value=s;
                 }
        }
     }
   return(IndicatorCreate(_Symbol,_Period,IND_CUSTOM,ArraySize(p),p));
  }

//+------------------------------------------------------------------+
//| Wait until the indicator has calculated (a few seconds at most)  |
//+------------------------------------------------------------------+
bool WaitCalculated(const int handle)
  {
   for(int i=0; i<50 && !IsStopped(); i++)
     {
      if(BarsCalculated(handle)>0)
         return(true);
      Sleep(100);
     }
   return(BarsCalculated(handle)>0);
  }

//+------------------------------------------------------------------+
//| Label the last arrows of one buffer: "B1" at the arrow's price   |
//+------------------------------------------------------------------+
int MarkArrows(const string tag,const int buffer,const double &v[],const int n,const color clr)
  {
   int marked=0;
   for(int i=n-1; i>=0 && marked<InpMarks; i--)
     {
      if(!HasArrow(v[i]))
         continue;
      const int shift=n-i;                   // v[] starts at shift n (oldest) and ends at shift 1
      const datetime t=iTime(_Symbol,_Period,shift);
      const string obj=StringFormat("%s%s_%d_%d",PREFIX,tag,buffer,shift);
      if(ObjectCreate(0,obj,OBJ_TEXT,0,t,v[i]))
        {
         ObjectSetString(0,obj,OBJPROP_TEXT,"B"+IntegerToString(buffer));
         ObjectSetInteger(0,obj,OBJPROP_COLOR,clr);
         ObjectSetInteger(0,obj,OBJPROP_FONTSIZE,9);
         ObjectSetString(0,obj,OBJPROP_FONT,"Arial Bold");
         ObjectSetInteger(0,obj,OBJPROP_ANCHOR,ANCHOR_LOWER);
         ObjectSetInteger(0,obj,OBJPROP_SELECTABLE,false);
         ObjectSetString(0,obj,OBJPROP_TOOLTIP,StringFormat("buffer %d = %s",buffer,DoubleToString(v[i],_Digits)));
         marked++;
        }
     }
   return(marked);
  }

//+------------------------------------------------------------------+
//| One indicator: a line of text per buffer                         |
//+------------------------------------------------------------------+
string Inspect(const int handle,const string title,const string tag,const bool onMainChart)
  {
   string out=title+"\n";
   if(!WaitCalculated(handle))
      return(out+"   the indicator has not calculated yet - open the chart for a while and run the script again\n");
   const int bars=MathMin(InpBars,BarsCalculated(handle)-1);
   int arrowBuffers=0;
   string code="";
   for(int b=0; b<64; b++)
     {
      double v[];
      const int n=CopyBuffer(handle,b,1,bars,v);      // v[0] = the oldest closed bar
      if(n<=0)
         break;
      int valid=0,arrows=0,ints=0,last=-1;
      double lo=DBL_MAX,hi=-DBL_MAX;
      for(int i=0; i<n; i++)
        {
         if(!IsDefined(v[i]))
            continue;
         valid++;
         lo=MathMin(lo,v[i]);
         hi=MathMax(hi,v[i]);
         if(HasArrow(v[i]))
           {
            arrows++;
            last=i;
           }
         if(MathAbs(v[i]-MathRound(v[i]))<1e-9 && MathAbs(v[i])<64)
            ints++;
        }
      string kind;
      if(valid==0 || (arrows==0 && hi==0.0 && lo==0.0))
         kind="empty on these bars";
      else
         if(arrows>0 && arrows<=n*0.3)
           {
            kind=StringFormat("ARROWS: %d, the latest on %s at %s",arrows,
                              TimeToString(iTime(_Symbol,_Period,n-last),TIME_DATE|TIME_MINUTES),
                              DoubleToString(v[last],_Digits));
            arrowBuffers++;
            if(InpMarks>0 && onMainChart)
              {
               const int k=MarkArrows(tag,b,v,n,g_palette[b%ArraySize(g_palette)]);
               kind+=StringFormat(" (labelled B%d on the chart: %d)",b,k);
              }
            if(code=="")
               code=StringFormat("   arrow: CopyBuffer(handle,%d,1,1,v); a signal when v[0]!=EMPTY_VALUE && v[0]!=0\n",b);
           }
         else
            if(ints==valid && hi-lo<=16)
               kind=StringFormat("colour index: values %.0f to %.0f, now %s",lo,hi,
                                 IsDefined(v[n-1]) ? DoubleToString(v[n-1],0) : "empty");
            else
               kind=StringFormat("line: now %s, from %s to %s",
                                 IsDefined(v[n-1]) ? DoubleToString(v[n-1],_Digits) : "empty",
                                 DoubleToString(lo,_Digits),DoubleToString(hi,_Digits));
      out+=StringFormat("   buffer %d - %s\n",b,kind);
     }
   if(StringFind(out,"buffer 0")<0)
      out+="   no buffers could be read\n";
   else
      if(arrowBuffers==0)
         out+="   no arrow buffer: if you see arrows on the chart, the indicator probably draws them as objects,\n"
              "   which a program cannot read through iCustom/CopyBuffer\n";
   if(code!="")
      out+="   In an Expert Advisor:\n"+code;
   return(out);
  }

//+------------------------------------------------------------------+
//| Number of indicators in all windows of the chart                 |
//+------------------------------------------------------------------+
int TotalOnChart()
  {
   int n=0;
   const int windows=(int)ChartGetInteger(0,CHART_WINDOWS_TOTAL);
   for(int w=0; w<windows; w++)
      n+=ChartIndicatorsTotal(0,w);
   return(n);
  }
//+------------------------------------------------------------------+
void OnStart()
  {
   ObjectsDeleteAll(0,PREFIX);
   if(InpClear)
     {
      Comment("");
      ChartRedraw();
      return;
     }
   string report=StringFormat("Buffer Inspector Kb - %s %s, last %d closed bars\n\n",_Symbol,
                              StringSubstr(EnumToString(_Period),7),InpBars);
   int found=0;
   if(InpIndicator!="")
     {
      const int h=CreateByName(InpIndicator,InpParams);
      if(h==INVALID_HANDLE)
         report+=StringFormat("Cannot load '%s' (error %d). The name is the path inside MQL5\\Indicators without .ex5,\n"
                              "for example Examples\\Fractals or Market\\Name of the indicator.\n",InpIndicator,GetLastError());
      else
        {
         report+=Inspect(h,InpIndicator+(InpParams!="" ? " ("+InpParams+")" : ""),"n",true);
         IndicatorRelease(h);
         found++;
        }
     }
   else
     {
      //--- a chart that has just been opened may get its indicators a moment later
      for(int t=0; t<50 && !IsStopped() && TotalOnChart()==0; t++)
         Sleep(100);
      const int windows=(int)ChartGetInteger(0,CHART_WINDOWS_TOTAL);
      for(int w=0; w<windows; w++)
         for(int i=0; i<ChartIndicatorsTotal(0,w); i++)
           {
            const string name=ChartIndicatorName(0,w,i);
            const int h=ChartIndicatorGet(0,w,name);
            if(h==INVALID_HANDLE)
               continue;
            report+=Inspect(h,name+(w==0 ? " (main chart)" : StringFormat(" (subwindow %d)",w)),
                            IntegerToString(w)+"_"+IntegerToString(i),w==0)+"\n";
            IndicatorRelease(h);
            found++;
           }
      if(found==0)
         report+="No indicator on this chart. Attach your indicator first, or enter its name in the script's inputs.\n";
     }
   report+="\nRun again with 'Only remove the labels' = true to clear the chart.";
   Comment(report);
   string lines[];
   const int n=StringSplit(report,'\n',lines);
   for(int i=0; i<n; i++)
      if(lines[i]!="")
         Print(lines[i]);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
