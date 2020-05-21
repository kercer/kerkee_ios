
#import <UIKit/UIKit.h>
#import "KCButton.h"

@interface UIAlertView (KCBlocks)

-(id)initWithTitle:(NSString*)aTitle message:(NSString *)aMessage cancelButton:(KCButton *)aCancelButton otherButtons:(KCButton*)inOtherButtons, ... NS_REQUIRES_NIL_TERMINATION;

- (NSInteger)addButton:(KCButton *)aButton;

@end
