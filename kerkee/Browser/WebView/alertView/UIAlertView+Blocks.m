
#import "UIAlertView+Blocks.h"
#import <objc/runtime.h>

static NSString *KC_BUTTON_ASS_KEY = @"com.kercer.BUTTONS";

@implementation UIAlertView (KCBlocks)

-(id)initWithTitle:(NSString*)aTitle message:(NSString *)aMessage cancelButton:(KCButton *)aCancelButton otherButtons:(KCButton*)inOtherButtons, ...
{
    if((self = [self initWithTitle:aTitle message:aMessage delegate:self cancelButtonTitle:aCancelButton.label otherButtonTitles:nil]))
    {
        NSMutableArray *buttonsArray = [self buttonItems];
        
        KCButton *eachItem;
        va_list argumentList;
        if (inOtherButtons)
        {
            [buttonsArray addObject: inOtherButtons];
            va_start(argumentList, inOtherButtons);
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
        
        if(aCancelButton)
            [buttonsArray insertObject:aCancelButton atIndex:0];
        
        [self setDelegate:self];
    }
    return self;
}

- (NSInteger)addButton:(KCButton*)aButton
{
    NSInteger buttonIndex = [self addButtonWithTitle:aButton.label];
    [[self buttonItems] addObject:aButton];
    
    if (![self delegate])
    {
        [self setDelegate:self];
    }
    
    return buttonIndex;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // If the button index is -1 it means we were dismissed with no selection
    if (buttonIndex >= 0)
    {
        NSArray *buttonsArray = objc_getAssociatedObject(self, (__bridge const void *)KC_BUTTON_ASS_KEY);
        KCButton *item = [buttonsArray objectAtIndex:buttonIndex];
        if(item.action)
            item.action();
    }
    
    objc_setAssociatedObject(self, (__bridge const void *)KC_BUTTON_ASS_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)buttonItems
{
    NSMutableArray *buttonItems = objc_getAssociatedObject(self, (__bridge const void *)KC_BUTTON_ASS_KEY);
    if (!buttonItems)
    {
        buttonItems = [NSMutableArray array];
        objc_setAssociatedObject(self, (__bridge const void *)KC_BUTTON_ASS_KEY, buttonItems, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return buttonItems;
}

@end
