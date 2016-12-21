
#import <Foundation/Foundation.h>

typedef void (^KCButtonBlock)();

@interface KCButton : NSObject

@property (retain, nonatomic) NSString* label;
@property (copy, nonatomic) KCButtonBlock action;

+(id)button;
+(id)buttonWithLabel:(NSString*)aLabel;
+(id)buttonWithLabel:(NSString*)aLabel action:(KCButtonBlock)aAction;
@end

