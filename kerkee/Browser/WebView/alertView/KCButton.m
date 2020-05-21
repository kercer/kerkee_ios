
#import "KCButton.h"

@interface KCButton()
{
    NSString* label;
    void (^action)(void);
}
@end

@implementation KCButton
@synthesize label;
@synthesize action;

+(id)button
{
    return [self new];
}

+(id)buttonWithLabel:(NSString *)aLabel
{
    KCButton *newItem = [self button];
    [newItem setLabel:aLabel];
    return newItem;
}

+(id)buttonWithLabel:(NSString *)aLabel action:(KCButtonBlock)aAction
{
  KCButton *newItem = [self buttonWithLabel:aLabel];
  [newItem setAction:aAction];
  return newItem;
}

@end

