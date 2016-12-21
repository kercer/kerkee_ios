

#import <UIKit/UIKit.h>
#import "KCButton.h"

@interface UIActionSheet (KCBlocks) <UIActionSheetDelegate>

-(id)initWithTitle:(NSString *)aTitle cancelButton:(KCButton *)aCancelButton destructiveButton:(KCButton*)aDestructive otherButtons:(KCButton *)inOtherButtons, ... NS_REQUIRES_NIL_TERMINATION;

- (NSInteger)addButton:(KCButton*)aButton;

/** This block is called when the action sheet is dismssed for any reason.
 */
@property (copy, nonatomic) void(^dismissalAction)();

@end
