//+------------------------------------------------------------------+
//| A B S T R A C T  F A C T O R Y               C R E A T I O N A L |
//|                                                                  |
//| Provides an interface for creating families of related or        |
//| dependent objects without specifying their concrete class.       |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| P R O D U C T  A                               I N T E R F A C E |
//+------------------------------------------------------------------+
interface I_ProductA { void Act(); };
//+------------------------------------------------------------------+
//| P R O D U C T  B                               I N T E R F A C E |
//+------------------------------------------------------------------+
interface I_ProductB { void Act(); };
//+------------------------------------------------------------------+
//| F A C T O R Y                                  I N T E R F A C E |
//+------------------------------------------------------------------+
interface I_Factory
  {
   I_ProductA *MakeProductA();
   I_ProductB *MakeProductB();
  };
//+------------------------------------------------------------------+
//| P R O D U C T  A 1                                     C L A S S |
//+------------------------------------------------------------------+
class C_ProductA1 : public I_ProductA
  {
public:
                     C_ProductA1() { Print(" • Product A1 constructed"); }
                    ~C_ProductA1() { Print(" • Product A1 destructed"); }
   void Act() { Print("    • Doing A1 operation"); }
  };
//+------------------------------------------------------------------+
//| P R O D U C T  A 2                                     C L A S S |
//+------------------------------------------------------------------+
class C_ProductA2 : public I_ProductA
  {
public:
                     C_ProductA2() { Print(" • Product A2 constructed"); }
                    ~C_ProductA2() { Print(" • Product A2 destructed"); }
   void Act() { Print("    • Doing A2 operation"); }
  };
//+------------------------------------------------------------------+
//| P R O D U C T  B 1                                     C L A S S |
//+------------------------------------------------------------------+
class C_ProductB1 : public I_ProductB
  {
public:
                     C_ProductB1() { Print(" • Product B1 constructed"); }
                    ~C_ProductB1() { Print(" • Product B1 destructed"); }
   void Act() { Print("    • Doing B1 operation"); }
  };
//+------------------------------------------------------------------+
//| P R O D U C T  B 2                                     C L A S S |
//+------------------------------------------------------------------+
class C_ProductB2 : public I_ProductB
  {
public:
                     C_ProductB2() { Print(" • Product B2 constructed"); }
                    ~C_ProductB2() { Print(" • Product B2 destructed"); }
   void Act() { Print("    • Doing B2 operation"); }
  };
//+------------------------------------------------------------------+
//| F A C T O R Y  1                                       C L A S S |
//+------------------------------------------------------------------+
class C_Factory1 : public I_Factory
  {
public:
                     C_Factory1() { Print("Factory 1 constructed"); }
                    ~C_Factory1() { Print("Factory 1 destructed"); }
   I_ProductA* MakeProductA() { return new C_ProductA1; }
   I_ProductB* MakeProductB() { return new C_ProductB1; }
  };
//+------------------------------------------------------------------+
//| F A C T O R Y  2                                       C L A S S |
//+------------------------------------------------------------------+
class C_Factory2 : public I_Factory
  {
public:
                     C_Factory2() { Print("Factory 2 constructed"); }
                    ~C_Factory2() { Print("Factory 2 destructed"); }
   I_ProductA *MakeProductA() { return new C_ProductA2; }
   I_ProductB *MakeProductB() { return new C_ProductB2; }
  };
//+------------------------------------------------------------------+
//| C L I E N T                                            C L A S S |
//+------------------------------------------------------------------+
class C_Client
  {
public:
                     C_Client(I_Factory *factory)
     {
      m_factory=factory;
      m_product_a=m_factory.MakeProductA();
      m_product_b=m_factory.MakeProductB();
     }
                    ~C_Client()
     {
      if(CheckPointer(m_product_a)==POINTER_DYNAMIC) delete m_product_a;
      if(CheckPointer(m_product_b)==POINTER_DYNAMIC) delete m_product_b;
      if(CheckPointer(m_factory)==POINTER_DYNAMIC) delete m_factory;
     }
   //---
   void Act() { m_product_a.Act(); m_product_b.Act(); }

protected:
   I_Factory        *m_factory;
   I_ProductA       *m_product_a;
   I_ProductB       *m_product_b;
  };
//+------------------------------------------------------------------+
//|                                                      S C R I P T |
//+------------------------------------------------------------------+
void OnStart()
  {
   C_Client *client;
//---
   client=new C_Client(new C_Factory1);
   client.Act();
   delete client;
//---
   client=new C_Client(new C_Factory2);
   client.Act();
   delete client;
  }
//--- OUTPUT
/*
   Factory 1 constructed
    • Product A1 constructed
    • Product B1 constructed
       • Doing A1 operation
       • Doing B1 operation
    • Product A1 destructed
    • Product B1 destructed
   Factory 1 destructed
   Factory 2 constructed
    • Product A2 constructed
    • Product B2 constructed
       • Doing A2 operation
       • Doing B2 operation
    • Product A2 destructed
    • Product B2 destructed
   Factory 2 destructed
*/
//+------------------------------------------------------------------+
