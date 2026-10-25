//+---------------------------------------------------------------------+
//|                                       MultiThreadedObjectWorker.mqh |
//|                                       Copyright (c) 2020, Marketeer |
//|                             https://www.mql5.com/en/users/marketeer |
//|            Asynchronous Multithreaded Calculations in Chart Objects |
//| based on . . . . . . . . . .  https://www.mql5.com/ru/articles/5337 |
//+---------------------------------------------------------------------+

input string MultiThreadedScriptPath = "Experts\\MultiThreadedObjectWorker.ex5";

// the input above is used for 2 purposes:
// - script path in a client MQL program
// - resource path in a helper script running inside automatic chart objects

#include <fxsaber\ResourceData.mqh>
#include <fxsaber\Expert.mqh>


#define PREFIX "MCS"
#define LEADSIZE (sizeof(int)*5)
#define FAILED(T) Print(#T, " failed: ", GetLastError());
#define PRT(T) Print(#T, " ", T);


#define MessageBroadcast 101

#define MSG_DONE     3
#define MSG_ERROR    4
#define MSG_ITERATE  5

#define MSG(x) (x - MessageBroadcast - CHARTEVENT_CUSTOM)
#define TO_MSG(X) ((ushort)(MessageBroadcast + X))

class ResourceMediator
{
  private:
    const RESOURCEDATA<uchar> *resource;
    
    union lead
    {
      struct _l
      {
        int m; // method/function
        int u; // url/parameters(stringified)
        int h; // headers/options(not used)
        int t; // timeout
        int b; // body/parameters(serialized)
      }
      lengths;
      
      uchar sizes[LEADSIZE];
      
      int total()
      {
        return lengths.m + lengths.u + lengths.h + lengths.t + lengths.b;
      }
    }
    metadata;
  
    union _s
    {
      int x;
      uchar b[sizeof(int)];
    }
    int2chars;
    
    
  public:
    ResourceMediator(const RESOURCEDATA<uchar> *r): resource(r)
    {
    }
    
    void packRequest(const string method, const string url, const string headers, const int timeout, const uchar &body[])
    {
      metadata.lengths.m = StringLen(method) + 1;
      metadata.lengths.u = StringLen(url) + 1;
      metadata.lengths.h = StringLen(headers) + 1;
      metadata.lengths.t = sizeof(int);
      metadata.lengths.b = ArraySize(body);
      
      uchar data[];
      ArrayResize(data, LEADSIZE + metadata.total());
      
      ArrayCopy(data, metadata.sizes);
      
      int cursor = LEADSIZE;
      uchar temp[];
      StringToCharArray(method, temp);
      ArrayCopy(data, temp, cursor);
      ArrayResize(temp, 0);
      cursor += metadata.lengths.m;
      
      StringToCharArray(url, temp);
      ArrayCopy(data, temp, cursor);
      ArrayResize(temp, 0);
      cursor += metadata.lengths.u;
      
      StringToCharArray(headers, temp);
      ArrayCopy(data, temp, cursor);
      ArrayResize(temp, 0);
      cursor += metadata.lengths.h;
      
      int2chars.x = timeout;
      ArrayCopy(data, int2chars.b, cursor);
      cursor += metadata.lengths.t;
      
      ArrayCopy(data, body, cursor);
      
      int fraction = ArraySize(data) % sizeof(uint);
      if(fraction > 0)
      {
        uchar append[];
        ArrayResize(append, sizeof(uint) - fraction);
        ArrayInitialize(append, 0);
        cursor += metadata.lengths.b;
        ArrayCopy(data, append, cursor);
      }

      Print(ChartID(), ": Saved ", ArraySize(data), " bytes in request");
      
      resource = data;
    }
    
    void unpackRequest(string &method, string &url, string &headers, int &timeout, uchar &body[])
    {
      uchar array[];  
      int n = resource.Get(array);
      Print(ChartID(), ": Got ", n, " bytes in request");
      
      ArrayCopy(metadata.sizes, array, 0, 0, LEADSIZE);
      int cursor = LEADSIZE;
      
      method = CharArrayToString(array, cursor, metadata.lengths.m);
      cursor += metadata.lengths.m;
      url = CharArrayToString(array, cursor, metadata.lengths.u);
      cursor += metadata.lengths.u;
      headers = CharArrayToString(array, cursor, metadata.lengths.h);
      cursor += metadata.lengths.h;
      
      ArrayCopy(int2chars.b, array, 0, cursor, metadata.lengths.t);
      timeout = int2chars.x;
      cursor += metadata.lengths.t;
      if(metadata.lengths.b > 0)
      {
        ArrayCopy(body, array, 0, cursor, metadata.lengths.b);
      }
    }
    
    void packResponse(const string source, const uchar &result[], const string &result_headers)
    {
      uchar src[];
      uchar meta[];
      uchar data[];
      
      int c = StringToCharArray(source, src);
      int m = StringToCharArray(result_headers, meta);
      int n = ArraySize(result);
      ArrayResize(data, c + m + n + 3 * sizeof(int2chars));

      int2chars.x = c;
      ArrayCopy(data, int2chars.b);
      int2chars.x = m;
      ArrayCopy(data, int2chars.b, sizeof(int2chars));
      int2chars.x = n;
      ArrayCopy(data, int2chars.b, 2 * sizeof(int2chars));
      
      ArrayCopy(data, src, 3 * sizeof(int2chars));
      ArrayCopy(data, meta, 3 * sizeof(int2chars) + c);
      ArrayCopy(data, result, 3 * sizeof(int2chars) + c + m);

      int fraction = ArraySize(data) % sizeof(uint);
      if(fraction > 0)
      {
        uchar append[];
        ArrayResize(append, sizeof(uint) - fraction);
        ArrayInitialize(append, 0);
        ArrayCopy(data, append, 3 * sizeof(int2chars) + c + m + n);
      }
      
      Print(ChartID(), ": Packed ", ArraySize(data), " bytes in response for ", source);
      
      resource = data;
    }
    
    void unpackResponse(uchar &initiator[], uchar &headers[], uchar &text[])
    {
      uchar array[];
      const int n = resource.Get(array);
    
      ArrayCopy(int2chars.b, array, 0, 0, sizeof(int2chars));
      const int c = int2chars.x; // original resource name
      Print(ChartID(), ": Got ", n, " bytes in response, payload: ", c);
      ArrayCopy(int2chars.b, array, 0, sizeof(int2chars), sizeof(int2chars));
      const int h = int2chars.x; // headers
      ArrayCopy(int2chars.b, array, 0, 2 * sizeof(int2chars), sizeof(int2chars));
      const int d = int2chars.x; // document
      ArrayCopy(initiator, array, 0, 3 * sizeof(int2chars), c);
      ArrayCopy(headers, array, 0, 3 * sizeof(int2chars) + c, h);
      ArrayCopy(text, array, 0, 3 * sizeof(int2chars) + c + h, d);
    }
};

class CalcWorkerScript
{
  protected:
    const RESOURCEDATA<uchar> *resource;
    const string prefix;
    const long chartID; // host
    string name;        // chart object
    string fullname;    // resource
    long requestID;     // unique number (incremented via numerator)
    long workerChartID;
    
    static long requestIDnumerator;
    
    string _method;
    string _url;
    
    const RESOURCEDATA<uchar> *allocate()
    {
      release();
      resource = new RESOURCEDATA<uchar>(prefix + (string)chartID);
      fullname = StringSubstr(MQLInfoString(MQL_PROGRAM_PATH), StringLen(TerminalInfoString(TERMINAL_DATA_PATH)) + 5) + prefix + (string)chartID;
      return resource;
    }

  public:
    CalcWorkerScript(const long id): prefix("::" + PREFIX + "_" + (string)(requestIDnumerator) + "_"), chartID(id), requestID(requestIDnumerator)
    {
      requestIDnumerator++;
      fullname = NULL;
      name = NULL;
    }
    
    ~CalcWorkerScript()
    {
      release();
    }

    long getWorkerChartID() const
    {
      return workerChartID;
    }

    string getFullName() const
    {
      return fullname;
    }

    string getMethod() const
    {
      return _method;
    }

    string getURL() const
    {
      return _url;
    }

    virtual void release()
    {
      if(CheckPointer(resource) == POINTER_DYNAMIC) delete resource;
      resource = NULL;
      fullname = NULL;
      if(name != NULL) ObjectDelete(0, name);
      name = NULL;
      workerChartID = 0;
    }
  
    bool CalculateAsync(const string method, const string url, const string headers, const int timeout, const uchar &data[])
    {
      _method = method;
      _url = url;

      ResourceMediator mediator(allocate());
      mediator.packRequest(method, url, headers, timeout, data);
    
      name = PREFIX + (string)requestID;
      if(!ObjectCreate(0, name, OBJ_CHART, 0, 0, 0))
      {
        FAILED(ObjectCreate);
        return false;
      }
      
      ObjectSetInteger(0, name, OBJPROP_XSIZE, 200); // dummy sizes
      ObjectSetInteger(0, name, OBJPROP_YSIZE, 200);
      
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, -1000); // move out of view
      
      long chart = ObjectGetInteger(0, name, OBJPROP_CHART_ID);
      int failures = 0;
      while(chart == 0 && GetLastError() == ERR_CHART_NO_REPLY)
      {
        Sleep(100);
        failures++;
        chart = ObjectGetInteger(0, name, OBJPROP_CHART_ID);
        if(failures > 10)
        {
          FAILED(OBJPROP_CHART_ID);
          return false;
        }
      }

      // for the case ObjectSetInteger calls above didn't work
      ChartSetInteger(chart, CHART_SHOW, false);
      
      MqlParam Params[2];
      
      Params[0].string_value = MultiThreadedScriptPath;
      
      Params[1].type = TYPE_STRING;
      Params[1].string_value = fullname;
      EXPERT::AddInputName(Params[1], "MultiThreadedScriptPath");
      
      Print(ChartID(), ": Starting chart object ", name, " ", chart);
      workerChartID = chart;
    
      return EXPERT::Run(chart, Params);
    }

    static void receiveResult(const string resname, uchar &initiator[], uchar &headers[], uchar &text[])
    {
      Print(ChartID(), ": Reading result ", resname);
      const RESOURCEDATA<uchar> resource(resname);
      ResourceMediator mediator(&resource);
      mediator.unpackResponse(initiator, headers, text);
    }
    
    static long getChartIDFromResource(const string resname)
    {
      string parts[];
      long returnChartID = 0;
      int p = StringSplit(resname, '_', parts);
      if(p > 1) returnChartID = StringToInteger(parts[p - 1]);
      return returnChartID;
    }
};

class CalcWorkerClient: public CalcWorkerScript
{
  public:
    CalcWorkerClient(const long id): CalcWorkerScript(id)
    {
    }
    
    virtual void onResult(const long code, const uchar &headers[], const uchar &text[]) = 0;
    virtual void onError(const long code) = 0;
};

template<typename T>
class CalcWorkerScriptPool
{
  protected:
    T *workers[];
    
  public:
    ~CalcWorkerScriptPool()
    {
      for(int i = 0; i < ArraySize(workers); i++)
      {
        if(CheckPointer(workers[i]) == POINTER_DYNAMIC) delete workers[i];
      }
    }

    T *findWorker(const string resname) const
    {
      for(int i = 0; i < ArraySize(workers); i++)
      {
        if(workers[i] != NULL)
        {
          if(workers[i].getFullName() == resname)
          {
            return workers[i];
          }
        }
      }
      return NULL;
    }

    T *findWorker(const long id) const
    {
      for(int i = 0; i < ArraySize(workers); i++)
      {
        if(workers[i] != NULL)
        {
          if(workers[i].getWorkerChartID() == id)
          {
            return workers[i];
          }
        }
      }
      return NULL;
    }
    
    /*
    void operator<<(T *worker)
    {
      const int n = ArraySize(workers);
      for(int i = 0; i < n; i++)
      {
        if(workers[i] == NULL)
        {
          workers[i] = worker;
          return;
        }
      }
      
      ArrayResize(workers, n + 1);
      workers[n] = worker;
    }
    */
    
    int findEmptySlot() const
    {
      const int n = ArraySize(workers);
      for(int i = 0; i < n; i++)
      {
        if(workers[i] == NULL)
        {
          return i;
        }
      }
      return -1;
    }

    bool revoke(const T *that)
    {
      if(that == NULL) return false;
      for(int i = 0; i < ArraySize(workers); i++)
      {
        if(workers[i] == that)
        {
          Print("Revoking ", workers[i].getFullName());
          workers[i].release();
          if(CheckPointer(workers[i]) == POINTER_DYNAMIC) delete workers[i];
          workers[i] = NULL;
          return true;
        }
      }
      return false;
    }
    
};

template<typename T>
class ClientCalcWorkersPool: public CalcWorkerScriptPool<T>
{
  protected:
    const T *WAIT;
    long hostChartID;
    bool looping;

    void set(const int i, T *worker)
    {
      workers[i] = worker;
    }
    
  public:
    ClientCalcWorkersPool(const long id): hostChartID(id), WAIT(new T(0)), looping(true)
    {
    }
    
    ~ClientCalcWorkersPool()
    {
      delete WAIT;
    }
    
    void allocate(const int n)
    {
      const int m = ArraySize(workers);
      if(n > m)
      {
        ArrayResize(workers, n);
        for(int i = m; i < n; i++) workers[i] = NULL;
      }
    }
    
    bool isWait(const T *ptr) const
    {
      return ptr == WAIT;
    }
    
    void advance() const
    {
      EventChartCustom(ChartID(), TO_MSG(MSG_ITERATE), 0, 0, NULL);
    }
    
    T *CalculateAsync(const string method, const string url, const string headers, const int timeout, const uchar &data[])
    {
      if(ArraySize(workers) == 0) allocate(1);

      int i = findEmptySlot();
      if(i == -1) return (T *)WAIT; // can retry later

      T *worker = new T(hostChartID);
      if(worker != NULL)
      {
        set(i, worker);
        if(worker.CalculateAsync(method, url, headers, timeout, data))
        {
          return worker; // promise
        }
        revoke(worker);
      }
      return NULL; // can't proceed
    }
    
    void onChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
    {
      if(MSG(id) == MSG_DONE) // async request is completed with result or error
      {
        Print(ChartID(), ": Result code ", (long)dparam);
    
        if(sparam != NULL)
        {
          // read data from the resource with name in sparam
          uchar initiator[], headers[], text[];
          CalcWorkerScript::receiveResult(sparam, initiator, headers, text);
          string resname = CharArrayToString(initiator);
          
          T *worker = findWorker(resname);
          if(worker != NULL)
          {
            worker.onResult((long)dparam, headers, text);
            revoke(worker);
          }
          else
          {
            Print("No worker found for '", resname, "', ChartID: ", lparam);
            worker = findWorker(lparam);
            if(worker != NULL)
            {
              worker.onError(ERR_USER_ERROR_FIRST);
              revoke(worker);
            }
          }
          
          if(looping) advance();
        }
        else
        {
          Print("MSG_DONE sparam is NULL"); // abnormal
        }
      }
      else
      if(MSG(id) == MSG_ERROR) // some error happens other than request processing
      {
        if(sparam != NULL)
        {
          T *worker = findWorker(sparam);
          if(worker != NULL)
          {
            worker.onError(lparam);
            revoke(worker);
          }
          else
          {
            Print("No worker found for '", sparam, "', error: ", lparam);
          }
        }
        else
        {
          Print("MSG_ERROR sparam is NULL"); // abnormal
        }
      }
      else
      if(MSG(id) == MSG_ITERATE)
      {
        looping = T::iterate();
      }
    }

};

static long CalcWorkerScript::requestIDnumerator = 0;

class CalcWorkerServer: public CalcWorkerScript
{
  public:
    CalcWorkerServer(const long id): CalcWorkerScript(id)
    {
    }

    void receive(const string source, const uchar &result[], const string &result_headers)
    {
      ResourceMediator mediator(allocate());
      mediator.packResponse(source, result, result_headers);
    }
    
    // actual calculations go here
    virtual int execute(
      const string method, // an optional name to perform different tasks
      const string url,    // stringified parameters, empty by default, may be used in arbitrary way, if necessary
      const string header, // stringified parameters, empty by default, may be used in arbitrary way, if necessary
      const int timeout,   // msec, 0 by default, should be controlled by calculator
      const uchar &body[], // optional parameters, packed in "binary" form
      uchar &result[],     // packed result in "binary" form, optional
      string &result_headers // stringified result, optional
      ) = 0;
    
    void startCalculation(const string resname)
    {
      Print(ChartID(), ": Reading request ", resname);
      
      long returnChartID = CalcWorkerScript::getChartIDFromResource(resname);
      
      if(returnChartID == 0)
      {
        Print("Wrong sender ID: ", resname);
        return;
      }
      
      const RESOURCEDATA<uchar> _resource(resname);
      ResourceMediator mediator(&_resource);
    
      string method, url, headers;
      int timeout;
      uchar body[];
    
      mediator.unpackRequest(method, url, headers, timeout, body);
      
      Print(ChartID(), ": ", method, " ", url, " ", headers, " ", timeout, " ", CharArrayToString(body));
    
      uint startTime = GetTickCount();
      
      this.release();
      
      uchar result[]; // packed results of calculations
      string result_headers; // stringified results (option)
      
      // NB: timeout can be supported only by calculations in a loop
      
      int code = execute(method, url, headers, timeout, body, result, result_headers);
      
      if(code != -1)
      {
        // create resource with results to pass back to the client via custom event
        this.receive(resname, result, result_headers);
        EventChartCustom(returnChartID, TO_MSG(MSG_DONE), ChartID(), (double)code, this.getFullName());
        Print(ChartID(), ": ", "Done in ", (GetTickCount() - startTime), "ms");
      }
      else
      {
        EventChartCustom(returnChartID, TO_MSG(MSG_ERROR), GetLastError(), 0.0, resname);
        Print(ChartID(), ": ", "Failed with code ", GetLastError());
      }
      
      // expert keeps running until client reads results and closes the object
    }
    
};
