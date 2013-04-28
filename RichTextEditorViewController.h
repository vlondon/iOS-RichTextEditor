//
//  RichTextEditorViewController.h
//  RichTextEditor
//
//  Created by Vladimirs Matusevics on 28/04/2013.
//  Copyright (c) 2013 Vladimirs Matusevic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTEGestureRecognizer.h"

@interface RichTextEditorViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate> {
    NSTimer *timer;
    BOOL currentBoldStatus;
    BOOL currentItalicStatus;
    BOOL currentUnderlineStatus;
    int currentFontSize;
    NSString *currentForeColor;    
    NSString *currentFontName;
    BOOL currentUndoStatus;
    BOOL currentRedoStatus;
    UIPopoverController *imagePickerPopover;
    CGPoint initialPointOfImage;
    
    BOOL actionButtons; // Inactive buttons when we don't see keyboard
    UIBarButtonItem *undo;
    UIBarButtonItem *redo;
    UIBarButtonItem *btnFontNav;
    UIBarButtonItem *fontColorPicker;
    UIBarButtonItem *bold;
    UIBarButtonItem *italic;
    UIBarButtonItem *underline;
}
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSTimer *timer;
- (void)checkSelection:(id)sender;
@end
