//
//  NSObject+KCProperty.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import "NSObject+KCProperty.h"
#import "KCBaseDefine.h"

@implementation NSObject (KCProperty)

#pragma mark -
- (NSMutableDictionary *)kc_propertiesForClass:(Class)aClass
{
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    KCAutorelease(results);
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(aClass, &outCount);
    for(i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        
        NSString *pname = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        NSString *pattrs = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        
        pattrs = [[pattrs componentsSeparatedByString:@","] objectAtIndex:0];
        pattrs = [pattrs substringFromIndex:1];
        
        [results setObject:pattrs forKey:pname];
    }
    free(properties);
    
    if ([aClass superclass] != [NSObject class])
    {
        [results addEntriesFromDictionary:[self kc_propertiesForClass:[aClass superclass]]];
    }
    
    return results;
}

- (NSDictionary *)kc_propertyTypeDic
{
    return [self kc_propertiesForClass:[self class]];
}



@end

@implementation NSObject (KCAddProperty)


#pragma mark Add Property

- (void)kc_setProperty:(id)aProperty forKey:(char const * const)aKey withPolicy:(KCAssociantionPolicy)aPolicy
{
    // validate input
    NSAssert(aProperty,@"PROPERTY must not be nil.");
    NSAssert(aKey,@"KEY must not be nil.");
    NSAssert(aPolicy!=0, @"POLICY must not be null.");
    NSAssert([self kc_isValidPolicy:aPolicy],@"POLICY must be valid.");
    
    // associate object
    objc_setAssociatedObject(self, aKey, aProperty, (objc_AssociationPolicy)aPolicy);
}

- (id)kc_getPropertyForKey:(char const * const)aKey
{
    // validate input
    NSAssert(aKey,@"KEY must not be nil.");
    NSAssert(objc_getAssociatedObject(self, aKey)!=nil,@"there is no object for the given KEY.");
    
    // return object
    return objc_getAssociatedObject(self, aKey);
}

- (BOOL)kc_hasPropertyForKey:(char const * const)aKey
{
    // validate input
    NSAssert(aKey,@"KEY must not be nil.");
    
    // return logical result
    return objc_getAssociatedObject(self, aKey) ? YES : NO;
}

/**
 checks if a given policy is valid
 
 @param policy - the memory management policy
 @return logical result indicating if policy is valid
 */

- (BOOL)kc_isValidPolicy:(KCAssociantionPolicy)policy
{
    switch ( policy )
    {
        case EPolicy_Assign:
        case EPolicy_Retain_Nonatomic:
        case EPolicy_Copy_Nonatomic:
        case EPolicy_Retain:
        case EPolicy_Copy:
            return YES;
        default:
            return NO;
    }
}

@end



#pragma mark KCProperties


@implementation NSObject (KCProperties)

+ (BOOL)kc_isPropertyReadOnly:(NSString*)aName
{
    const char * type = property_getAttributes(class_getProperty(self, [aName UTF8String]));
    NSString * typeString = [NSString stringWithUTF8String:type];
    NSArray * attributes = [typeString componentsSeparatedByString:@","];
    NSString * typeAttribute = [attributes objectAtIndex:1];
    
    return [typeAttribute rangeOfString:@"R"].length > 0;
}

+ (BOOL) kc_hasProperties
{
	unsigned int count = 0;
	objc_property_t * properties = class_copyPropertyList( self, &count );
	if ( properties != NULL )
		free( properties );
	
	return ( count != 0 );
}

+ (BOOL) kc_hasPropertyNamed: (NSString*) aName
{
	return ( class_getProperty(self, [aName UTF8String]) != NULL );
}

+ (BOOL) kc_hasPropertyNamed: (NSString*) aName ofType: (const char*) aType
{
	objc_property_t property = class_getProperty( self, [aName UTF8String] );
	if ( property == NULL )
		return ( NO );
    
	const char * value = kc_property_getTypeString( property );
	if ( strcmp(aType, value) == 0 )
		return ( YES );
	
	return ( NO );
}

+ (BOOL) kc_hasPropertyForKVCKey: (NSString*) aKey
{
    if ( [self kc_hasPropertyNamed: aKey] )
        return ( YES );
    
    return ( [self kc_hasPropertyNamed: [self kc_propertyStyleString:aKey]] );
}


+ (const char *) kc_typeOfPropertyNamed: (NSString*) aName
{
	objc_property_t property = class_getProperty( self, [aName UTF8String] );
	if ( property == NULL )
		return ( NULL );
	
	return ( kc_property_getTypeString(property) );
}

+ (Class)kc_classOfPropertyNamed:(NSString*)aPropertyName
{
    if (![self kc_hasPropertyNamed:aPropertyName]) {
        NSLog(@"Error: class %@ has no property named %@", NSStringFromClass([self class]), aPropertyName);
        return nil;
    }
    
    objc_property_t prop = class_getProperty(self, [aPropertyName UTF8String]);
    const char *cAttrs = property_getAttributes(prop);
    NSString *attrs = [NSString stringWithUTF8String:cAttrs];
    
    //right now type is something like T@"NSString", so we need to get the proper string
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"T@\"(.*?)\"" options:0 error:nil];
    NSRange classNameRange = [[regex firstMatchInString:attrs options:0 range:NSMakeRange(0, attrs.length)] rangeAtIndex:1];
    NSString *className = [attrs substringWithRange:classNameRange];
    
    if (!NSClassFromString(className))
        NSLog(@"nil class for className: %@, attrs: %@", className, attrs);
    
    return NSClassFromString(className);
}

+ (SEL) kc_getterForPropertyNamed: (NSString*) aName
{
	objc_property_t property = class_getProperty( self, [aName UTF8String] );
	if ( property == NULL )
		return ( NULL );
	
	SEL result = kc_property_getGetter( property );
	if ( result != NULL )
		return ( NULL );
	
	if ( [self instancesRespondToSelector: NSSelectorFromString(aName)] == NO )
		[NSException raise: NSInternalInconsistencyException
					format: @"%@ has property '%@' with no custom getter, but does not respond to the default getter",
		 self, aName];
	
	return ( NSSelectorFromString(aName) );
}

+ (SEL) kc_setterForPropertyNamed: (NSString*) aName
{
	objc_property_t property = class_getProperty( self, [aName UTF8String] );
	if ( property == NULL )
		return ( NULL );
	
	SEL result = kc_property_getSetter( property );
	if ( result != NULL )
		return ( result );
	
	// build a setter name
	NSMutableString * str = [NSMutableString stringWithString: @"set"];
	[str appendString: [[aName substringToIndex: 1] uppercaseString]];
	if ( [aName length] > 1 )
		[str appendString: [aName substringFromIndex: 1]];
	
	if ( [self instancesRespondToSelector: NSSelectorFromString(str)] == NO )
		[NSException raise: NSInternalInconsistencyException
					format: @"%@ has property '%@' with no custom setter, but does not respond to the default setter",
		 self, str];
	
	return ( NSSelectorFromString(str) );
}

+ (NSString *) kc_retentionMethodOfPropertyNamed: (NSString*) aName
{
	objc_property_t property = class_getProperty( self, [aName UTF8String] );
	if ( property == NULL )
		return ( nil );
	
	const char * str = kc_property_getRetentionMethod( property );
	if ( str == NULL )
		return ( nil );
	
	NSString * result = [NSString stringWithUTF8String: str];
	free( (void *)str );
	
	return ( result );
}

+ (NSArray *) kc_propertyNames
{
    return [self kc_propertyNamesWithClass:self];
}

+ (NSArray *)kc_propertyNamesWithClass:(Class)aCls
{
    unsigned int i, count = 0;
	objc_property_t * properties = class_copyPropertyList( aCls, &count );
	
	if ( count == 0 )
	{
		free( properties );
		return nil;
	}
	
	NSMutableArray * list = [NSMutableArray array];
	
	for ( i = 0; i < count; i++ )
    {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
		[list addObject: [NSString stringWithUTF8String: name]];
    }
	
    free(properties);
    
//    NSArray* arr = [self propertyNamesWithClass:class_getSuperclass(aClass)];
//    [list addObjectsFromArray:arr];
    
	return list;
}

+ (NSArray*) kc_namesForPropertiesOfClass:(Class)aCls
{
    NSArray *propNames = [self kc_propertyNames];
    NSMutableArray *ret = [NSMutableArray array];
    
    for (NSString *name in propNames)
    {
        Class curClass = [self kc_classOfPropertyNamed:name];
        if ([curClass isSubclassOfClass:aCls])
            [ret addObject:name];
    }
    return ret;
}


- (NSString*)kc_propertyStyleString:(NSString*)aString
{
    
    NSString * result = [[aString substringToIndex: 1] lowercaseString];
    if ( [aString length] == 1 )
        return ( result );
    
    return ( [result stringByAppendingString: [aString substringFromIndex: 1]] );
}

- (BOOL)kc_isPropertyReadOnly:(NSString*)aName
{
    return ( [[self class] kc_isPropertyReadOnly:aName] );
}

- (BOOL) kc_hasProperties
{
	return ( [[self class] kc_hasProperties] );
}

- (BOOL) kc_hasPropertyNamed: (NSString*) aName
{
	return ( [[self class] kc_hasPropertyNamed: aName] );
}

- (BOOL) kc_hasPropertyNamed: (NSString*) aName ofType: (const char *) aType
{
	return ( [[self class] kc_hasPropertyNamed: aName ofType: aType] );
}

- (BOOL) kc_hasPropertyForKVCKey: (NSString*) key
{
    return ( [[self class] kc_hasPropertyForKVCKey: key] );
}

- (const char *) kc_typeOfPropertyNamed: (NSString*) aName
{
	return ( [[self class] kc_typeOfPropertyNamed: aName] );
}

- (Class)kc_classOfPropertyNamed:(NSString*)aPropertyName
{
    return [[self class] kc_classOfPropertyNamed:aPropertyName];
}

- (SEL) kc_getterForPropertyNamed: (NSString*) aName
{
	return ( [[self class] kc_getterForPropertyNamed: aName] );
}

- (SEL) kc_setterForPropertyNamed: (NSString*) aName
{
	return ( [[self class] kc_setterForPropertyNamed: aName] );
}

- (NSString *) kc_retentionMethodOfPropertyNamed: (NSString*) aName
{
	return ( [[self class] kc_retentionMethodOfPropertyNamed: aName] );
}

- (NSArray *) kc_propertyNames
{
	return ( [[self class] kc_propertyNames] );
}

- (NSArray *) kc_namesForPropertiesOfClass:(Class)aCls
{
    return [[self class] kc_namesForPropertiesOfClass:aCls];
}

@end




#pragma mark -
@implementation NSObject (KCPropertiesUseCache)
static NSMutableDictionary *s_mapProperty;
static NSMutableDictionary *s_mapPropertyClassOfProperty;

+ (NSArray *)kc_propertyNamesAllClass:(Class)aCls
{
    if (aCls == [NSObject class] /*[KCObject class]*/)
    {
        return [NSArray array];
    }
	if (!s_mapProperty)
    {
        s_mapProperty = [[NSMutableDictionary alloc] init];
    }
	
	NSString *className = NSStringFromClass(aCls);
	NSArray *value = [s_mapProperty objectForKey:className];
	
	if (value)
    {
		return value;
	}
	
	NSMutableArray *propertyNamesArray =(NSMutableArray*) [self kc_propertyNamesWithClass:aCls];
	
    if (className && propertyNamesArray)
    {
        [s_mapProperty setObject:propertyNamesArray forKey:className];
        NSArray* arr = [self kc_propertyNamesAllClass:class_getSuperclass(aCls)];
        [propertyNamesArray addObjectsFromArray:arr];
    }
    
    return propertyNamesArray;
}

+ (Class)kc_propertyClassAllForPropertyName:(NSString *)propertyName ofClass:(Class)aCls
{
	if (!s_mapPropertyClassOfProperty)
    {
        s_mapPropertyClassOfProperty = [[NSMutableDictionary alloc] init];
    }
	
	NSString *key = [NSString stringWithFormat:@"%@:%@", NSStringFromClass(aCls), propertyName];
	NSString *value = [s_mapPropertyClassOfProperty objectForKey:key];
	
	if (value)
    {
		return NSClassFromString(value);
	}
	
	unsigned int propertyCount = 0;
	objc_property_t *properties = class_copyPropertyList(aCls, &propertyCount);
	
	const char * cPropertyName = [propertyName UTF8String];
	
	for (unsigned int i = 0; i < propertyCount; ++i)
    {
		objc_property_t property = properties[i];
		const char * name = property_getName(property);
		if (strcmp(cPropertyName, name) == 0)
        {
			free(properties);
			NSString *className = [NSString stringWithUTF8String:kc_property_getTypeString(property)];
			[s_mapPropertyClassOfProperty setObject:className forKey:key];
            //we found the property - we need to free
			return NSClassFromString(className);
		}
	}
    free(properties);
    //this will support traversing the inheritance chain
	return [self kc_propertyClassAllForPropertyName:propertyName ofClass:class_getSuperclass(aCls)];
}

@end

#pragma mark -

const char *kc_property_getTypeName(objc_property_t aProperty)
{
	const char *attributes = property_getAttributes(aProperty);
	char buffer[1 + strlen(attributes)];
	strcpy(buffer, attributes);
	char *state = buffer, *attribute;
	while ((attribute = strsep(&state, ",")) != NULL)
    {
		if (attribute[0] == 'T')
        {
			size_t len = strlen(attribute);
			attribute[len - 1] = '\0';
			return (const char *)[[NSData dataWithBytes:(attribute + 3) length:len - 2] bytes];
		}
	}
	return "@";
}

const char * kc_property_getTypeString( objc_property_t aProperty )
{
	const char * attrs = property_getAttributes( aProperty );
	if ( attrs == NULL )
		return ( NULL );
	
	static char buffer[256];
	const char * e = strchr( attrs, ',' );
	if ( e == NULL )
		return ( NULL );
	
	int len = (int)(e - attrs);
	memcpy( buffer, attrs, len );
	buffer[len] = '\0';
	
	return ( buffer );
}

SEL kc_property_getGetter( objc_property_t aProperty )
{
	const char * attrs = property_getAttributes( aProperty );
	if ( attrs == NULL )
		return ( NULL );
	
	const char * p = strstr( attrs, ",G" );
	if ( p == NULL )
		return ( NULL );
	
	p += 2;
	const char * e = strchr( p, ',' );
	if ( e == NULL )
		return ( sel_getUid(p) );
	if ( e == p )
		return ( NULL );
	
	int len = (int)(e - p);
	char * selPtr = malloc( len + 1 );
	memcpy( selPtr, p, len );
	selPtr[len] = '\0';
	SEL result = sel_getUid( selPtr );
	free( selPtr );
	
	return ( result );
}

SEL kc_property_getSetter( objc_property_t aProperty )
{
	const char * attrs = property_getAttributes( aProperty );
	if ( attrs == NULL )
		return ( NULL );
	
	const char * p = strstr( attrs, ",S" );
	if ( p == NULL )
		return ( NULL );
	
	p += 2;
	const char * e = strchr( p, ',' );
	if ( e == NULL )
		return ( sel_getUid(p) );
	if ( e == p )
		return ( NULL );
	
	int len = (int)(e - p);
	char * selPtr = malloc( len + 1 );
	memcpy( selPtr, p, len );
	selPtr[len] = '\0';
	SEL result = sel_getUid( selPtr );
	free( selPtr );
	
	return ( result );
}

const char * kc_property_getRetentionMethod( objc_property_t aProperty )
{
	const char * attrs = property_getAttributes( aProperty );
	if ( attrs == NULL )
		return ( NULL );
	
	const char * p = attrs;
	do
	{
		if ( p == NULL )
			break;
		
		if ( p[0] == '\0' )
			break;
		
		if ( p[1] == '&' )
			return ( "retain" );
		
		if ( p[1] == 'C' )
			return ( "copy" );
		
		p = strchr( p, ',' );
		
	} while (1);
	
	// this is the default, and thus has no specifier character in the attr string
	return ( "assign" );
}
