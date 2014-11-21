#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C"{
#endif
    
/**
 *	@brief	用于替换1个类内的2个方法.其中selector分为2段,并且使用C方法尽量减少被查风险
 *
 *	@param 	orgClassStr 	需要被替换的目标类名
 *	@param 	orgSelector 	旧方法名字
 *	@param 	newSelector 	新方法名字
 *
 *	@return	替换是否成功
 */
bool OBJC_EXCHANGE_METHOD_SAFE(const char* orgClassStr,
                               const char* orgSelector1,const char* orgSelector2,
                               const char* newSelector1,const char* newSelector2);
	
bool OBJC_EXCHANGE_STATIC_METHOD_SAFE(const char* orgClassStr,
									   const char* orgSelector1,const char* orgSelector2,
									   const char* newSelector1,const char* newSelector2);


/**
 *	@brief	用于替换2个不同类的方法.其中selector分为2段,用于减少被查风险
 *	@param 	orgClassStr 	需要被替换的目标类名
 *	@param 	orgSelector 	需要被替换的目标类的方法名
 *	@param 	newClass 	包含用于替换已有类的方法的类名
 *	@param 	newSelector 	用于替换已有类的方法名
 *	@param 	method 	objc的Dynamic Method的表达式,若为NULL,则不会添加新方法
 *
 *	@return	替换是否成功
 */
bool OBJC_EXCHANGE_NEWCLASS_METHOD_SAFE(const char* orgClassStr,const char* orgSelector1,const char* orgSelector2,
                                        const char* newClassStr,const char* newSelector1,const char* newSelector2,
                                        const char* methodStr);

bool OBJC_EXCHANGE_NEWCLASS_METHOD(const char* orgClassStr,const char* orgSelector,
                                        const char* newClassStr,const char* newSelector,
                                        const char* methodStr);
    

//下面2个函数用于替换静态方法
bool OBJC_EXCHANGE_NEWCLASS_STATIC_METHOD_SAFE(const char* orgClassStr,const char* orgSelector1,const char* orgSelector2,
                                            const char* newClassStr,const char* newSelector1,const char* newSelector2,
                                            const char* methodStr);
    
bool OBJC_EXCHANGE_NEWCLASS_STATIC_METHOD(const char* orgClassStr,const char* orgSelector,
                                       const char* newClassStr,const char* newSelector,
                                       const char* methodStr);


#ifdef __cplusplus
}
#endif
