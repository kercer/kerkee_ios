//
//  KCObject.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import "KCObject.h"
#import "KCBaseDefine.h"
#import "NSObject+KCProperty.h"


@implementation KCObject


@synthesize objectId;
static NSString *idPropertyName = @"id";
static NSString *idPropertyNameOnObject = @"objectId";

Class nsDictionaryClass;
Class nsArrayClass;

+ (id)objectFromDictionary:(NSDictionary*)dictionary
{
    id item = [[self alloc] initWithDictionary:dictionary];
    KCAutorelease(item);
    return item;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	if (!nsDictionaryClass) nsDictionaryClass = [NSDictionary class];
	if (!nsArrayClass) nsArrayClass = [NSArray class];
	
	if ((self = [super init]))
    {
		for (NSString *key in [KCPropertiesUseCache kc_propertyNamesAllClass:[self class]])
        {
			
			id value = [dictionary valueForKey:[[self map] valueForKey:key]];
			
			if (value == [NSNull null] || value == nil)
            {
                continue;
            }
            
            if ([self kc_isPropertyReadOnly:key])
            {
                continue;
            }
			
			// handle dictionary
			if ([value isKindOfClass:nsDictionaryClass])
            {
				Class klass = [KCPropertiesUseCache kc_propertyClassAllForPropertyName:key ofClass:[self class]];
				value = [[klass alloc] initWithDictionary:value];
                KCAutorelease(value);
			}
			// handle array
			else if ([value isKindOfClass:nsArrayClass])
            {
				
				NSMutableArray *childObjects = [NSMutableArray arrayWithCapacity:[(NSArray*)value count]];
                
                // suppress the warnings
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
				
				for (id child in value)
                {
                    if ([[child class] isSubclassOfClass:nsDictionaryClass])
                    {
                        Class arrayItemType = [[self class] performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@_class", key])];
                        if ([arrayItemType isSubclassOfClass:[NSDictionary class]])
                        {
                            [childObjects addObject:child];
                        }
                        else if ([arrayItemType isSubclassOfClass:[KCObject class]])
                        {
                            KCObject *childDTO = [[arrayItemType alloc] initWithDictionary:child];
                            KCAutorelease(childDTO);
                            [childObjects addObject:childDTO];
                        }
					}
                    else
                    {
						[childObjects addObject:child];
					}
				}
                
                #pragma clang diagnostic pop
                
				
				value = childObjects;
			}
			// handle all others
			[self setValue:value forKey:key];
		}
		
		id objectIdValue;
		if ((objectIdValue = [dictionary objectForKey:idPropertyName]) && objectIdValue != [NSNull null])
        {
			if (![objectIdValue isKindOfClass:[NSString class]])
            {
				objectIdValue = [NSString stringWithFormat:@"%@", objectIdValue];
			}
			[self setValue:objectIdValue forKey:idPropertyNameOnObject];
		}
	}
	return self;
}

- (void)dealloc
{
	self.objectId = nil;
	
    //	for (NSString *key in [JastorRuntimeHelper propertyNames:[self class]]) {
    //		//[self setValue:nil forKey:key];
    //	}
	
    KCDealloc(super);
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
	[encoder encodeObject:self.objectId forKey:idPropertyNameOnObject];
	for (NSString *key in [KCPropertiesUseCache kc_propertyNamesAllClass:[self class]])
    {
		[encoder encodeObject:[self valueForKey:key] forKey:key];
	}
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super init]))
    {
		[self setValue:[decoder decodeObjectForKey:idPropertyNameOnObject] forKey:idPropertyNameOnObject];
		
		for (NSString *key in [KCPropertiesUseCache kc_propertyNamesAllClass:[self class]])
        {
            if ([self kc_isPropertyReadOnly:key])
            {
                continue;
            }
			id value = [decoder decodeObjectForKey:key];
			if (value != [NSNull null] && value != nil)
            {
				[self setValue:value forKey:key];
			}
		}
	}
	return self;
}

- (NSMutableDictionary *)toDictionary
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.objectId)
    {
        [dic setObject:self.objectId forKey:idPropertyName];
    }
	
	for (NSString *key in [KCPropertiesUseCache kc_propertyNamesAllClass:[self class]])
    {
		id value = [self valueForKey:key];
        if (value && [value isKindOfClass:[KCObject class]])
        {
			[dic setObject:[value toDictionary] forKey:[[self map] valueForKey:key]];
        }
        else if (value && [value isKindOfClass:[NSArray class]] && ((NSArray*)value).count > 0)
        {
            id internalValue = [value objectAtIndex:0];
            if (internalValue && [internalValue isKindOfClass:[KCObject class]])
            {
                NSMutableArray *internalItems = [NSMutableArray array];
                for (id item in value)
                {
                    [internalItems addObject:[item toDictionary]];
                }
				[dic setObject:internalItems forKey:[[self map] valueForKey:key]];
            }
            else
            {
				[dic setObject:value forKey:[[self map] valueForKey:key]];
            }
        }
        else if (value != nil)
        {
			[dic setObject:value forKey:[[self map] valueForKey:key]];
        }
	}
    return dic;
}


- (NSString*)toString
{
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[self toDictionary] options:0 error:nil] encoding:NSUTF8StringEncoding];
    KCRelease(json);
    return json;
}

- (NSDictionary *)map
{
	NSArray *properties = [KCPropertiesUseCache kc_propertyNamesAllClass:[self class]];
	NSMutableDictionary *mapDictionary = [[NSMutableDictionary alloc] initWithCapacity:properties.count];
    KCAutorelease(mapDictionary);
	for (NSString *property in properties)
    {
		[mapDictionary setObject:property forKey:property];
	}
	return [NSDictionary dictionaryWithDictionary:mapDictionary];
}

- (NSString *)description
{
    NSMutableDictionary *dic = [self toDictionary];
	
	return [NSString stringWithFormat:@"#<%@: id = %@ \n%@>", [self class], self.objectId, [dic description]];
}

- (BOOL)isEqual:(id)object
{
	if (object == nil || ![object isKindOfClass:[KCObject class]]) return NO;
	
	KCObject *model = (KCObject *)object;
	
	return [self.objectId isEqualToString:model.objectId];
}


@end
