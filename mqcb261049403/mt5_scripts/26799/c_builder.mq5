/*********************************************************************
                                                           MQL5 Script
                                                Copyright 2019, dmipec
                                                      792112@gmail.com

Classic Builder Programming Pattern
   This pattern was published in the "Design Patterns: Elements of
   Reusable Object-Oriented Software", 1st Edition, by Erich Gamma
   (Author), Richard Helm (Author), Ralph Johnson (Author), John
   Vlissides (Author), Grady Booch (Foreword). These authors are
   collectively known as Gang of Four (GoF).

Structure is shown on a diagram

Intent
   Separate the construction of a complex object from its
   representation so that the same construction process can create
   different representations.

Applicability
 * the algorithm for creating a complex object should be independent
   of the parts that make up the object and how they're assembled.
 * the construction process must allow different representations for
   the object that's constructed.

Participants
   Builder
    * specifies an interface for creating parts of a Product object.
   Concrete Builder
    * constructs and assembles parts of the product by implementing
      the Builder interface.
    * defines and keeps track of the representation it creates.
    * provides an interface for retrieving the product.
   Director
    * constructs an object using the Builder interface;
   Product
    * represents the complex object under construction. Concrete
      Builder builds the product's internal representation and defines
      the process by which it's assembled.
    * includes classes that define the constituent parts, including
      interfaces for assembling the parts into the final result.

Collaborations (diagram)
 * The client creates the Director object and configures it with the
   desired Builder object.
   Director notifies the builder whenever a part of the product should
   be built.
 * Builder handles requests from the director and adds parts to the
   product.
 * The client retrieves the product from the builder.

Consequences
   It lets you vary a product's internal representation.
      The Builder object provides the director with an abstract
      interface for constructing the product. The interface lets the
      builder hide the representation and internal structure of the
      product. It also hides how the product gets assembled. Because
      the product is constructed through an abstract interface, all
      you have to do to change the product's internal representation
      is define a new kind of builder.
   It isolates code for construction and representation.
      The Builder pattern improves modularity by encapsulating the way
      a complex object is constructed and represented. Clients needn't
      know anything about the classes that define the product's
      internal structure; such classes don't appear in Builder's
      interface. Each Builder contains all the code to create and
      assemble a particular kind of product. The code is written once;
      then different Directors can reuse it to build Product variants
      from the same set of parts.
   It gives you finer control over the construction process.
      Unlike creational patterns that construct products in one shot,
      the Builder pattern constructs the product step by step under
      the director's control. Only when the product is finished does
      the director retrieve it from the builder. Hence the Builder
      interface reflects the process of constructing the product more
      than other creational patterns. This gives you finer control
      over the construction process and consequently the internal
      structure of the resulting product.

Implementation
 * Typically there's an abstract Builder class that defines an
   operation for each component that a director may ask it to create.
   The operations do nothing by default. A ConcreteBuilder class
   overrides operations for components it's interested in creating.
 * Here are other implementation issues to consider:
      Assembly and construction interface.
         Builders construct their products in step-by-step fashion.
         Therefore the Builder class interface must be general enough
         to allow the construction of products for all kinds of
         concrete builders. A key design issue concerns the model for
         the construction and assembly process. A model where the
         results of construction requests are simply appended to the
         product is usually sufficient. But sometimes you might need
         access to parts of the product constructed earlier. In that
         case, the builder would return child nodes to the director,
         which then would pass them back to the builder to build the
         parent nodes.
      Why no abstract class for products?
         In the common case, the products produced by the concrete
         builders differ so greatly in their representation that there
         is little to gain from giving different products a common
         parent class. Because the client usually configures the
         director with the proper concrete builder, the client is in
         a position to know which concrete subclass of Builder is in
         use and can handle its products accordingly.
      Empty methods as default in Builder.
         In C++, the build methods are intentionally not declared pure
         virtual member functions. They're defined as empty methods
         instead, letting clients override only the operations they're
         interested in.

Code output
   Construction in progress...
      Part A built
      Part B built
      Part C built
   Delivering finished 'Real Product'
   This 'Real Product' is made of:
      Part A
      Part B
      Part C
 */
/* import generic object array from the standard MQL library */
#include <Generic\ArrayList.mqh>
/*********************************************************************
   Interface for building blocks-objects of a complex abstract product
 */
interface I_Part {
   string Id();
};
/*********************************************************************
   Part A
 */
class C_PartA: public I_Part {
public:
   string            Id();
};
/*********************************************************************
   Part B
 */
class C_PartB: public I_Part {
public:
   string            Id();
};
/*********************************************************************
   Part C
 */
class C_PartC: public I_Part {
public:
   string            Id();
};
/*********************************************************************
   Abstract Product (Interface)
    * includes common tools for handling the product's parts container
    */
class A_Product {
protected:
   CArrayList<I_Part*>  m_parts;
public:
                    ~A_Product();
   virtual string    Id() = 0;
   void              Display();
   void              Add(I_Part *part);
protected:
   void              Clear(CArrayList<I_Part*>&list);
};
/*********************************************************************
   Product
    * represents the complex object under construction. Concrete
      Builder builds the product's internal representation and defines
      the process by which it's assembled.
    * includes classes that define the constituent parts, including
      interfaces for assembling the parts into the final result.
    */
class C_Product: public A_Product {
public:
   string            Id();
};
/*********************************************************************
   Builder
    * specifies an interface for creating parts of a Product object.
    */
interface I_Builder {
   void BuildPartA();
   void BuildPartB();
   void BuildPartC();
   A_Product *GetResult();
};
/*********************************************************************
   Concrete Builder
    * constructs and assembles parts of the product by implementing
      the Builder interface.
    * defines and keeps track of the representation it creates.
    * provides an interface for retrieving the product.
    */
class C_Builder: public I_Builder {
protected:
   A_Product         *m_product;
public:
                     C_Builder();
   void              BuildPartA();
   void              BuildPartB();
   void              BuildPartC();
   A_Product         *GetResult();
};
/*********************************************************************
   Director
    * constructs an object using the Builder interface;
    */
class C_Director {
protected:
   I_Builder         *m_builder;
public:
                     C_Director(I_Builder *builder);
   void              Construct();
};
/*********************************************************************
 * Client:
 */
void OnStart()
{
   /* The client creates the Director object and configures it with
      the desired Builder object. */
   C_Builder *builder = new C_Builder;
   C_Director director(builder);

   /* Director notifies the builder whenever a part of the product
      should be built.
    * Builder handles requests from the director and adds parts to
      the product. */
   director.Construct();

   /* The client retrieves the product from the builder. */
   C_Product *product = builder.GetResult();
   product.Display();

   delete product;
   delete builder;
}

/*********************************************************************
   Class methods section
 */
/**********************************************************************/
void C_Director::C_Director(I_Builder *builder)
{
   m_builder = builder;
}
/**********************************************************************/
void C_Director::Construct()
{
   Print("Construction in progress...");
   m_builder.BuildPartA();
   m_builder.BuildPartB();
   m_builder.BuildPartC();
}
/**********************************************************************/
void C_Builder::C_Builder(void)
{
   m_product = new C_Product;
}
/**********************************************************************/
void C_Builder::BuildPartA()
{
   m_product.Add(new C_PartA);
   Print("  Part A built");
}
/**********************************************************************/
void C_Builder::BuildPartB()
{
   m_product.Add(new C_PartB);
   Print("  Part B built");
}
/**********************************************************************/
void C_Builder::BuildPartC()
{
   m_product.Add(new C_PartC);
   Print("  Part C built");
}
/**********************************************************************/
A_Product *C_Builder::GetResult()
{
   PrintFormat("Delivering finished '%s'", m_product.Id());
   return m_product;
}
/**********************************************************************/
void A_Product::~A_Product(void)
{
   Clear(m_parts);
}
/**********************************************************************/
void A_Product::Add(I_Part *part)
{
   if(!m_parts.Contains(part)) {
      m_parts.Add(part);
   }
}
/**********************************************************************/
void A_Product::Display()
{
   PrintFormat("This '%s' is made of:", Id());
   I_Part *e;
   int total = m_parts.Count();
   for(int i = 0; i < total; i++) {
      m_parts.TryGetValue(i, e);
      PrintFormat("  %s", e.Id());
   }
}
/**********************************************************************/
void A_Product::Clear(CArrayList<I_Part*>&list)
{
   I_Part *e;
   int total = list.Count();
   for(int i = 0; i < total; i++) {
      list.TryGetValue(i, e);
      if(CheckPointer(e) == POINTER_DYNAMIC) delete e;
   }
   list.Clear();
}
/**********************************************************************/
string C_Product::Id(void)
{
   return "Real Product";
}
/**********************************************************************/
string C_PartA::Id()
{
   return "Part A";
}
/**********************************************************************/
string C_PartB::Id()
{
   return "Part B";
}
/**********************************************************************/
string C_PartC::Id()
{
   return "Part C";
}

/*********************************************************************
 * The code file was formatted with Stroustrup C++ style (MetaEditor >
   Tools > Options > Styler). Use Alt-G/M/Arrows to navigate.
 */
