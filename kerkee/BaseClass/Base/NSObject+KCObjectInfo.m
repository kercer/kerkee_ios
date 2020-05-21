//
//  NSObject+KCObjectInfo.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "NSObject+KCObjectInfo.h"
#import "KCBaseDefine.h"


@implementation NSObject (KCObjectInfo)

#pragma mark - Superclasses

+ (NSArray *) kc_superclasses
{
    if ([self isEqual:[NSObject class]]) return @[self];
    
    Class theClass = self;
    NSMutableArray *results = [NSMutableArray arrayWithObject:theClass];
    
    do
    {
        theClass = [theClass superclass];
        [results addObject:theClass];
    }
    while (![theClass isEqual:[NSObject class]]) ;
    
    return results;
}

// Return an array of an object's superclasses
- (NSArray *) kc_superclasses
{
    return [[self class] kc_superclasses];
}


// A work in progress
+ (NSString *) kc_typeForString: (const char *) aTypeName
{
    NSString *typeNameString = @(aTypeName);
    if ([typeNameString hasPrefix:@"@\""])
    {
        NSRange r = NSMakeRange(2, typeNameString.length - 3);
        NSString *format = [NSString stringWithFormat:@"(%@ *)", [typeNameString substringWithRange:r]];
        return format;
    }
    
    if ([typeNameString isEqualToString:@"v"])
        return @"(void)";
    
    if ([typeNameString isEqualToString:@"@"])
        return @"(id)";
    
    if ([typeNameString isEqualToString:@"^v"])
        return @"(void *)";
    
    if ([typeNameString isEqualToString:@"c"])
        return @"(BOOL)";
    
    if ([typeNameString isEqualToString:@"i"])
        return @"(int)";
    
    if ([typeNameString isEqualToString:@"s"])
        return @"(short)";
    
    if ([typeNameString isEqualToString:@"l"])
        return @"(long)";
    
    if ([typeNameString isEqualToString:@"q"])
        return @"(long long)";
    
    if ([typeNameString isEqualToString:@"I"])
        return @"(unsigned int)";
    
    if ([typeNameString isEqualToString:@"L"])
        return @"(unsigned long)";
    
    if ([typeNameString isEqualToString:@"Q"])
        return @"(unsigned long long)";
    
    if ([typeNameString isEqualToString:@"f"])
        return @"(float)";
    
    if ([typeNameString isEqualToString:@"d"])
        return @"(double)";
    
    if ([typeNameString isEqualToString:@"B"])
        return @"(bool)";
    
    if ([typeNameString isEqualToString:@"*"])
        return @"(char *)";
    
    if ([typeNameString isEqualToString:@"#"])
        return @"(Class)";
    
    if ([typeNameString isEqualToString:@":"])
        return @"(SEL)";
    
    if ([typeNameString isEqualToString:@(@encode(CGPoint))])
        return @"(CGPoint)";
    
    if ([typeNameString isEqualToString:@(@encode(CGSize))])
        return @"(CGSize)";
    
    if ([typeNameString isEqualToString:@(@encode(CGRect))])
        return @"(CGRect)";
    
    if ([typeNameString isEqualToString:@(@encode(CGAffineTransform))])
        return @"(CGAffineTransform)";
    
    if ([typeNameString isEqualToString:@(@encode(UIEdgeInsets))])
        return @"(UIEdgeInsets)";
    
    if ([typeNameString isEqualToString:@(@encode(NSRange))])
        return @"(NSRange)";
    
    if ([typeNameString isEqualToString:@(@encode(CFStringRef))])
        return @"(CFStringRef)";
    
    if ([typeNameString isEqualToString:@(@encode(NSZone *))])
        return @"(NSZone *)";
    
    //    if ([typeNameString isEqualToString:@(@encode(CGAffineTransform))])
    //        return @"(CGAffineTransform)";
    
    
    /*
     [array type]     An array
     {name=type...}     A structure
     (name=type...)     A union
     bnum     A bit field of num bits
     ^type     A pointer to type
     ?     An unknown type (among other things, this code is used for function pointers)
     */
    
    return [NSString stringWithFormat:@"(%@)", typeNameString];
}

+ (NSString *) kc_dump
{
    NSMutableString *dump = [NSMutableString string];
    
    [dump appendFormat:@"%@ ", [[self.kc_superclasses valueForKey:@"description"] componentsJoinedByString:@" : "]];
    
    NSDictionary *protocols = [self kc_protocols];
    NSMutableSet *protocolSet = [NSMutableSet set];
    for (NSString *key in protocols.allKeys)
        [protocolSet addObjectsFromArray:protocols[key]];
    [dump appendFormat:@"<%@>\n", [protocolSet.allObjects componentsJoinedByString:@", "]];
    
    [dump appendString:@"{\n"];
	unsigned int num;
	Ivar *ivars = class_copyIvarList(self, &num);
	for (int i = 0; i < num; i++)
    {
        const char *ivname = ivar_getName(ivars[i]);
        const char *typename = ivar_getTypeEncoding(ivars[i]);
        [dump appendFormat:@"    %@ %s\n", [self kc_typeForString:typename], ivname];
    }
	free(ivars);
    [dump appendString:@"}\n\n"];
    
    BOOL hasProperty = NO;
    NSArray *properties = [self kc_getPropertyListForClass];
    for (NSString *property in properties)
    {
        hasProperty = YES;
        objc_property_t prop = class_getProperty(self, property.UTF8String);
        
        [dump appendString:@"    @property "];
        
        char *nonatomic = property_copyAttributeValue(prop, "N");
        char *readonly = property_copyAttributeValue(prop, "R");
        char *copyAt = property_copyAttributeValue(prop, "C");
        char *strong = property_copyAttributeValue(prop, "&");
        NSMutableArray *attributes = [NSMutableArray array];
        if (nonatomic) [attributes addObject:@"nonatomic"];
        [attributes addObject:strong ? @"strong" : @"assign"];
        [attributes addObject:readonly ? @"readonly" : @"readwrite"];
        if (copyAt) [attributes addObject:@"copy"];
        [dump appendFormat:@"(%@) ", [attributes componentsJoinedByString:@", "]];
        free(nonatomic);
        free(readonly);
        free(copyAt);
        free(strong);
        
        char *typeName = property_copyAttributeValue(prop, "T");
        [dump appendFormat:@"%@ ", [self kc_typeForString:typeName]];
        free(typeName);
        
        char *setterName = property_copyAttributeValue(prop, "S");
        char *getterName = property_copyAttributeValue(prop, "G");
        if (setterName || getterName)
            [dump appendFormat:@"(setter=%s, getter=%s)", setterName, getterName];
        [dump appendFormat:@" %@\n", property];
        free(setterName);
        free(getterName);
    }
    if (hasProperty) [dump appendString:@"\n"];
    
    
	Method *clMethods = class_copyMethodList(objc_getMetaClass(self.description.UTF8String), &num);
	for (int i = 0; i < num; i++)
    {
        char returnType[1024];
        method_getReturnType(clMethods[i], returnType, 1024);
        NSString *rType = [self kc_typeForString:returnType];
        [dump appendFormat:@"+ %@ ", rType];
        
        NSString *selectorString = NSStringFromSelector(method_getName(clMethods[i]));
        NSArray *components = [selectorString componentsSeparatedByString:@":"];
        int argCount = method_getNumberOfArguments(clMethods[i]) - 2;
        if (argCount > 0)
        {
            for (unsigned int j = 0; j < argCount; j++)
            {
                NSString *arg = @"argument";
                char argType[1024];
                method_getArgumentType(clMethods[i], j + 2, argType, 1024);
                NSString *typeStr = [self kc_typeForString:argType];
                [dump appendFormat:@"%@:%@%@ ", components[j], typeStr, arg];
            }
            [dump appendString:@"\n"];
        }
        else
        {
            [dump appendFormat:@"%@\n", selectorString];
        }
    }
	free(clMethods);
    
    [dump appendString:@"\n"];
	Method *methods = class_copyMethodList(self, &num);
	for (int i = 0; i < num; i++)
    {
        char returnType[1024];
        method_getReturnType(methods[i], returnType, 1024);
        NSString *rType = [self kc_typeForString:returnType];
        [dump appendFormat:@"- %@ ", rType];
        
        NSString *selectorString = NSStringFromSelector(method_getName(methods[i]));
        NSArray *components = [selectorString componentsSeparatedByString:@":"];
        int argCount = method_getNumberOfArguments(methods[i]) - 2;
        if (argCount > 0)
        {
            for (unsigned int j = 0; j < argCount; j++)
            {
                NSString *arg = @"argument";
                char argType[1024];
                method_getArgumentType(methods[i], j + 2, argType, 1024);
                NSString *typeStr = [self kc_typeForString:argType];
                [dump appendFormat:@"%@:%@%@ ", components[j], typeStr, arg];
            }
            [dump appendString:@"\n"];
        }
        else
        {
            [dump appendFormat:@"%@\n", selectorString];
        }
    }
	free(methods);
    
    return dump;
}

- (NSString *) kc_dump
{
    return [[self class] kc_dump];
}



#pragma mark - Class Bits

+ (NSArray *) kc_getMetaSelectorListForClass
{
    NSMutableArray *selectors = [NSMutableArray array];
    unsigned int num;
    Class clz = objc_getMetaClass(self.description.UTF8String);
    Method *methods = class_copyMethodList(clz, &num);
    for (int i = 0; i < num; i++)
        [selectors addObject:NSStringFromSelector(method_getName(methods[i]))];
    free(methods);
    return selectors;
}


// Return an array of all an object's selectors
+ (NSArray *) kc_getSelectorListForClass
{
	NSMutableArray *selectors = [NSMutableArray array];
	unsigned int num;
	Method *methods = class_copyMethodList(self, &num);
	for (int i = 0; i < num; i++)
		[selectors addObject:NSStringFromSelector(method_getName(methods[i]))];
	free(methods);
	return selectors;
}

// Return a dictionary with class/selectors entries, all the way up to NSObject
- (NSDictionary *) kc_selectors
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[[self class] kc_getSelectorListForClass] forKey:NSStringFromClass([self class])];
	for (Class cl in [self kc_superclasses])
		[dict setObject:[cl kc_getSelectorListForClass] forKey:NSStringFromClass(cl)];
	return dict;
}

// Return an array of all an object's properties
+ (NSArray *) kc_getPropertyListForClass
{
	NSMutableArray *propertyNames = [NSMutableArray array];
	unsigned int num;
	objc_property_t *properties = class_copyPropertyList(self, &num);
	for (int i = 0; i < num; i++)
		[propertyNames addObject:[NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding]];
	free(properties);
	return propertyNames;
}

// Return a dictionary with class/selectors entries, all the way up to NSObject
- (NSDictionary *) kc_properties
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[[self class] kc_getPropertyListForClass] forKey:NSStringFromClass([self class])];
	for (Class cl in [self kc_superclasses])
		[dict setObject:[cl kc_getPropertyListForClass] forKey:NSStringFromClass(cl)];
	return dict;
}


// Return an array of all an object's properties
+ (NSArray *) kc_getIvarListForClass
{
	NSMutableArray *ivarNames = [NSMutableArray array];
	unsigned int num;
	Ivar *ivars = class_copyIvarList(self, &num);
	for (int i = 0; i < num; i++)
		[ivarNames addObject:[NSString stringWithCString:ivar_getName(ivars[i]) encoding:NSUTF8StringEncoding]];
	free(ivars);
	return ivarNames;
}

// Return a dictionary with class/selectors entries, all the way up to NSObject
- (NSDictionary *) kc_ivars
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[[self class] kc_getIvarListForClass] forKey:NSStringFromClass([self class])];
	for (Class cl in [self kc_superclasses])
		[dict setObject:[cl kc_getIvarListForClass] forKey:NSStringFromClass(cl)];
	return dict;
}

// Return an array of all an object's properties
+ (NSArray *) kc_getProtocolListForClass
{
	NSMutableArray *protocolNames = [NSMutableArray array];
	unsigned int num;
	Protocol *const *protocols = class_copyProtocolList(self, &num);
	for (int i = 0; i < num; i++)
		[protocolNames addObject:[NSString stringWithCString:protocol_getName(protocols[i]) encoding:NSUTF8StringEncoding]];
	free((void *)protocols);
	return protocolNames;
}

// Return a dictionary with class/selectors entries, all the way up to NSObject
- (NSDictionary *) kc_protocols
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[[self class] kc_getProtocolListForClass] forKey:NSStringFromClass([self class])];
	for (Class cl in [self kc_superclasses])
		[dict setObject:[cl kc_getProtocolListForClass] forKey:NSStringFromClass(cl)];
	return dict;
}


// Runtime checks of properties, etc.
- (BOOL) kc_hasProperty: (NSString *) aPropertyName
{
	NSMutableSet *set = [NSMutableSet set];
	NSDictionary *dict = self.kc_properties;
	for (NSArray *properties in [dict allValues])
		[set addObjectsFromArray:properties];
	return [set containsObject:aPropertyName];
}

// Tests whether ivar exists
- (BOOL) kc_hasIvar: (NSString *) aIvarName
{
	NSMutableSet *set = [NSMutableSet set];
	NSDictionary *dict = self.kc_ivars;
	for (NSArray *ivars in [dict allValues])
		[set addObjectsFromArray:ivars];
	return [set containsObject:aIvarName];
}

// Tests class
+ (BOOL) kc_classExists: (NSString *) aClassName
{
	return (NSClassFromString(aClassName) != nil);
}

// Return instance from class
+ (id) kc_instanceOfClassNamed: (NSString *) aClassName
{
    id obj = nil;
	if (NSClassFromString(aClassName) != nil)
    {
        obj = [[NSClassFromString(aClassName) alloc] init];
        KCAutorelease(obj);
        return obj;
    }
	else
		return nil;
}

+ (void)kc_swizzleMethod:(SEL)aOrigSel withMethod:(SEL)aAltSel
{
    Method orig_method = class_getInstanceMethod(self, aOrigSel);
    Method alt_method = class_getInstanceMethod(self, aAltSel);
    
    if (orig_method == nil || alt_method == nil) {
        NSLog(@"method not exists.");
        return;
    }
    
    class_addMethod(self,
                    aOrigSel,
                    class_getMethodImplementation(self, aOrigSel),
                    method_getTypeEncoding(orig_method));
    
    class_addMethod(self,
                    aAltSel,
                    class_getMethodImplementation(self, aAltSel),
                    method_getTypeEncoding(alt_method));
    
    method_exchangeImplementations(class_getInstanceMethod(self, aOrigSel), class_getInstanceMethod(self, aAltSel));
}

+ (BOOL)kc_swizzle:(SEL)aOriginal with:(IMP)aReplacement store:(IMPPointer)aStore
{
    return class_swizzleMethodAndStore(self, aOriginal, aReplacement, aStore);
}


+ (void)kc_exchangeMethond:(SEL)aSel1 :(SEL)aSel2
{
    Method m1 = class_getInstanceMethod([self class], aSel1);
    Method m2 = class_getInstanceMethod([self class], aSel2);
    method_exchangeImplementations(m1, m2);
}
+(IMP)kc_replaceMethod :(SEL)aOldMethond :(IMP)aNewIMP
{
    IMP orginIMP = [[self class] instanceMethodForSelector:aOldMethond];
    class_replaceMethod([self class],aOldMethond,aNewIMP,NULL);
    return orginIMP;
}

@end

BOOL class_swizzleMethodAndStore(Class aClass, SEL aOriginal, IMP aReplacement, IMPPointer aStore)
{
    IMP imp = NULL;
    Method method = class_getInstanceMethod(aClass, aOriginal);
    if (method)
    {
        const char *type = method_getTypeEncoding(method);
        imp = class_replaceMethod(aClass, aOriginal, aReplacement, type);
        if (!imp)
        {
            imp = method_getImplementation(method);
        }
    }
    if (imp && aStore) { *aStore = imp; }
    return (imp != NULL);
}


void KCSwapClassMethods(Class cls, SEL original, SEL replacement)
{
    Method originalMethod = class_getClassMethod(cls, original);
    IMP originalImplementation = method_getImplementation(originalMethod);
    const char *originalArgTypes = method_getTypeEncoding(originalMethod);
    
    Method replacementMethod = class_getClassMethod(cls, replacement);
    IMP replacementImplementation = method_getImplementation(replacementMethod);
    const char *replacementArgTypes = method_getTypeEncoding(replacementMethod);
    
    if (class_addMethod(cls, original, replacementImplementation, replacementArgTypes)) {
        class_replaceMethod(cls, replacement, originalImplementation, originalArgTypes);
    } else {
        method_exchangeImplementations(originalMethod, replacementMethod);
    }
}

void KCSwapInstanceMethods(Class cls, SEL original, SEL replacement)
{
    Method originalMethod = class_getInstanceMethod(cls, original);
    IMP originalImplementation = method_getImplementation(originalMethod);
    const char *originalArgTypes = method_getTypeEncoding(originalMethod);
    
    Method replacementMethod = class_getInstanceMethod(cls, replacement);
    IMP replacementImplementation = method_getImplementation(replacementMethod);
    const char *replacementArgTypes = method_getTypeEncoding(replacementMethod);
    
    if (class_addMethod(cls, original, replacementImplementation, replacementArgTypes)) {
        class_replaceMethod(cls, replacement, originalImplementation, originalArgTypes);
    } else {
        method_exchangeImplementations(originalMethod, replacementMethod);
    }
}

BOOL KCClassOverridesClassMethod(Class cls, SEL selector)
{
    return KCClassOverridesInstanceMethod(object_getClass(cls), selector);
}

BOOL KCClassOverridesInstanceMethod(Class cls, SEL selector)
{
    unsigned int numberOfMethods;
    Method *methods = class_copyMethodList(cls, &numberOfMethods);
    for (unsigned int i = 0; i < numberOfMethods; i++) {
        if (method_getName(methods[i]) == selector) {
            free(methods);
            return YES;
        }
    }
    free(methods);
    return NO;
}

