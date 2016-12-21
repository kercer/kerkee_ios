
#import "UIActionSheet+Blocks.h"
#import <objc/runtime.h>

static NSString *KC_BUTTON_ASS_KEY = @"com.kercer.BUTTONS";
static NSString *KC_DISMISSAL_ACTION_KEY = @"com.kercer.DISMISSAL_ACTION";

@implementation UIActionSheet (KCBlocks)

-(id)initWithTitle:(NSString *)aTitle cancelButton:(KCButton *)aCancelButton destructiveButton:(KCButton*)aDestructive otherButtons:(KCButton *)aOtherButtons, ...
{
    if((self = [self initWithTitle:aTitle delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil]))
    {
        NSMutableArray *buttonsArray = [NSMutableArray array];
        
        KCButton *eachItem;
        va_list argumentList;
        if (aOtherButtons)
        {
            [buttonsArray addObject: aOtherButtons];
            va_start(argumentList, aOtherButtons);
            while((eachItem = va_arg(argumentList, KCButton *)))
            {
                [buttonsArray addObject: eachItem];
            }
            va_end(argumentList);
        }
        
        for(KCButton *item in buttonsArray)
        {
            [self addButtonWithTitle:item.label];
        }
        
        if(aDestructive)
        {
            [buttonsArray addObject:aDestructive];
            NSInteger destIndex = [self addButtonWithTitle:aDestructive.label];
            [self setDestructiveButtonIndex:destIndex];
        }
        if(aCancelButton)
        {
            [buttonsArray addObject:aCancelButton];
            NSInteger cancelIndex = [self addButtonWithTitle:aCancelButton.label];
            [self setCancelButtonIndex:cancelIndex];
        }
        
        objc_setAssociatedObject(self, (__bridge const void *)KC_BUTTON_ASS_KEY, buttonsArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
    }
    return self;
}

- (NSInteger)addButton:(KCButton *)aButton
{	
    NSMutableArray *buttonsArray = objc_getAssociatedObject(self, (__bridge const void *)KC_BUTTON_ASS_KEY);
	
	NSInteger buttonIndex = [self addButtonWithTitle:aButton.label];
	[buttonsArray addObject:aButton];
	
	return buttonIndex;
}

- (void)setDismissalAction:(void(^)())dismissalAction
{
    objc_setAssociatedObject(self, (__bridge const void *)KC_DISMISSAL_ACTION_KEY, nil, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(self, (__bridge const void *)KC_DISMISSAL_ACTION_KEY, dismissalAction, OBJC_ASSOCIATION_COPY);
}

- (void(^)())dismissalAction
{
    return objc_getAssociatedObject(self, (__bridge const void *)KC_DISMISSAL_ACTION_KEY);
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // Action sheets pass back -1 when they're cleared for some reason other than a button being 
    // pressed.
    if (buttonIndex >= 0)
    {
        NSArray *buttonsArray = objc_getAssociatedObject(self, (__bridge const void *)KC_BUTTON_ASS_KEY);
        KCButton *item = [buttonsArray objectAtIndex:buttonIndex];
        if(item.action)
            item.action();
    }
    
    if (self.dismissalAction) self.dismissalAction();
    
    objc_setAssociatedObject(self, (__bridge const void *)KC_BUTTON_ASS_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, (__bridge const void *)KC_DISMISSAL_ACTION_KEY, nil, OBJC_ASSOCIATION_COPY);
}

@end

