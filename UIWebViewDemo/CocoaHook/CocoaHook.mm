#import "CocoaHook.h"

#ifndef OBJC_ADD_METHOD
#import <objc/runtime.h>
#endif//OBJC_ADD_METHOD


bool OBJC_EXCHANGE_METHOD_SAFE(const char* orgClassStr,
                               const char* orgSelector1,const char* orgSelector2,
                               const char* newSelector1,const char* newSelector2)
{
    
    Class orgClass = objc_getClass(orgClassStr);
    
    if(!orgClass)
    {
        return false;
    }
        
    /*使用动态生成的方法名, 尝试降低被查出的风险*/
    char* orgMethodName = (char* )malloc((strlen(orgSelector1) + strlen(orgSelector2) + 1)*sizeof(char));
    char* newMethodName = (char* )malloc((strlen(newSelector1) + strlen(newSelector2) + 1)*sizeof(char));
    sprintf(orgMethodName, "%s%s",orgSelector1,orgSelector2);
    sprintf(newMethodName, "%s%s",newSelector1,newSelector2);
    SEL orgMethod = sel_registerName(orgMethodName);
    SEL newMethod = sel_registerName(newMethodName);
    free(orgMethodName);
    free(newMethodName);
    
    Method newMethodIns = class_getInstanceMethod(orgClass, newMethod);
    Method orgMethodIns = class_getInstanceMethod(orgClass, orgMethod);
    
    
    /*防止方法不存在*/
    if(!orgMethodIns || !newMethodIns)
    {
        return false;
    }
    
    method_exchangeImplementations(orgMethodIns, newMethodIns);
    
    
    return true;
}

bool OBJC_EXCHANGE_STATIC_METHOD_SAFE(const char* orgClassStr,
									  const char* orgSelector1,const char* orgSelector2,
									  const char* newSelector1,const char* newSelector2)
{
	Class orgClass = objc_getClass(orgClassStr);
    
    if(!orgClass)
    {
        return false;
    }
	
    /*使用动态生成的方法名, 尝试降低被查出的风险*/
    char* orgMethodName = (char* )malloc((strlen(orgSelector1) + strlen(orgSelector2) + 1)*sizeof(char));
    char* newMethodName = (char* )malloc((strlen(newSelector1) + strlen(newSelector2) + 1)*sizeof(char));
    sprintf(orgMethodName, "%s%s",orgSelector1,orgSelector2);
    sprintf(newMethodName, "%s%s",newSelector1,newSelector2);
    SEL orgMethod = sel_registerName(orgMethodName);
    SEL newMethod = sel_registerName(newMethodName);
    free(orgMethodName);
    free(newMethodName);
    
    Method newMethodIns = class_getClassMethod(orgClass, newMethod);
    Method orgMethodIns = class_getClassMethod(orgClass, orgMethod);
    
    
    /*防止方法不存在*/
    if(!orgMethodIns || !newMethodIns)
    {
        return false;
    }
    
    method_exchangeImplementations(orgMethodIns, newMethodIns);
    
    
    return true;
}


typedef Method getClassMethodPointer(Class cls, SEL name);

template <getClassMethodPointer function>
bool OBJC_EXCHANGE_NEWCLASS_METHOD_TEMPLATE(const char* orgClassStr,const char* orgSelector,
                                        const char* newClassStr,const char* newSelector,
                                        const char* methodStr)
{
    Class orgClass = objc_getClass(orgClassStr);
    Class newClass = objc_getClass(newClassStr);
    
    if(!orgClass || !newClass)
    {
        return false;
    }
    
    SEL orgMethod = sel_registerName(orgSelector);
    SEL newMethod = sel_registerName(newSelector);
    
    
    Method newMethodIns = function(newClass, newMethod);
    
    /*在旧的类添加类新方法后,那么只需要交换原有的方法即可*/
    Method orgMethodIns = function(orgClass, orgMethod);
    
    /*防止方法不存在*/
    if(!orgMethodIns || !newMethodIns)
    {
        return false;
    }
    
    /*在已有类添加新方法*/
    if(methodStr)
    {
        IMP newMethodIMP = method_getImplementation(newMethodIns);
        const char *newMethodStr = method_getTypeEncoding(newMethodIns);
        class_addMethod(orgClass, newMethod, newMethodIMP, newMethodStr);
        newMethodIns = class_getInstanceMethod(orgClass, newMethod);
    }
    
    method_exchangeImplementations(orgMethodIns, newMethodIns);
    
    
    return true;
}

template <getClassMethodPointer function>
bool OBJC_EXCHANGE_NEWCLASS_METHOD_SAFE_TEMPLATE(const char* orgClassStr,const char* orgSelector1,const char* orgSelector2,
                                        const char* newClassStr,const char* newSelector1,const char* newSelector2,
                                        const char* methodStr)
{
    
    
    char* orgMethodName = (char* )malloc((strlen(orgSelector1) + strlen(orgSelector2) + 1)*sizeof(char));
    char* newMethodName = (char* )malloc((strlen(newSelector1) + strlen(newSelector2) + 1)*sizeof(char));
    sprintf(orgMethodName, "%s%s",orgSelector1,orgSelector2);
    sprintf(newMethodName, "%s%s",newSelector1,newSelector2);
    
    
    bool result = OBJC_EXCHANGE_NEWCLASS_METHOD_TEMPLATE<function>(orgClassStr,orgMethodName , newClassStr ,newMethodName , methodStr);
    
    free(orgMethodName);
    free(newMethodName);
    
    return result;
}

///之所以使用以下方式,纯粹是为了兼容 C 的方法而已,其实可以用 typdef 去掉
bool OBJC_EXCHANGE_NEWCLASS_METHOD_SAFE(const char* orgClassStr,const char* orgSelector1,const char* orgSelector2,
                                                 const char* newClassStr,const char* newSelector1,const char* newSelector2,
                                                 const char* methodStr)
{
    return OBJC_EXCHANGE_NEWCLASS_METHOD_SAFE_TEMPLATE<class_getInstanceMethod>(orgClassStr,orgSelector1,orgSelector2,
                                                                                newClassStr,newSelector1,newSelector2,
                                                                                methodStr);
}

bool OBJC_EXCHANGE_NEWCLASS_METHOD(const char* orgClassStr,const char* orgSelector,
                                   const char* newClassStr,const char* newSelector,
                                   const char* methodStr)
{
    return OBJC_EXCHANGE_NEWCLASS_METHOD_TEMPLATE<class_getInstanceMethod>(orgClassStr,orgSelector , newClassStr ,newSelector , methodStr);
}


bool OBJC_EXCHANGE_NEWCLASS_STATIC_METHOD_SAFE(const char* orgClassStr,const char* orgSelector1,const char* orgSelector2,
                                               const char* newClassStr,const char* newSelector1,const char* newSelector2,
                                               const char* methodStr)
{
    return OBJC_EXCHANGE_NEWCLASS_METHOD_SAFE_TEMPLATE<class_getClassMethod>(orgClassStr,orgSelector1,orgSelector2,
                                                                                newClassStr,newSelector1,newSelector2,
                                                                                methodStr);
}

bool OBJC_EXCHANGE_NEWCLASS_STATIC_METHOD(const char* orgClassStr,const char* orgSelector,
                                          const char* newClassStr,const char* newSelector,
                                          const char* methodStr)
{
    return OBJC_EXCHANGE_NEWCLASS_METHOD_TEMPLATE<class_getClassMethod>(orgClassStr,orgSelector , newClassStr ,newSelector , methodStr);
}
