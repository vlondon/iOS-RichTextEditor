//
//  RichTextEditorViewController.m
//  RichTextEditor
//
//  Created by Vladimirs Matusevics on 28/04/2013.
//  Copyright (c) 2013 Vladimirs Matusevic. All rights reserved.
//

#import "RichTextEditorViewController.h"

@implementation RichTextEditorViewController
@synthesize webView;
@synthesize timer;

#pragma mark - Additions

- (UIColor *)colorFromRGBValue:(NSString *)rgb { // General format is 'rgb(red, green, blue)'
    if ([rgb rangeOfString:@"rgb"].location == NSNotFound)
        return nil;
    
    NSMutableString *mutableCopy = [rgb mutableCopy];
    [mutableCopy replaceCharactersInRange:NSMakeRange(0, 4) withString:@""];
    [mutableCopy replaceCharactersInRange:NSMakeRange(mutableCopy.length-1, 1) withString:@""];
    
    NSArray *components = [mutableCopy componentsSeparatedByString:@","];
    int red = [[components objectAtIndex:0] intValue];
    int green = [[components objectAtIndex:1] intValue];
    int blue = [[components objectAtIndex:2] intValue];
    
    UIColor *retVal = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
    return retVal;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Load in the index file
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *indexFileURL = [bundle URLForResource:@"indextext" withExtension:@"html"];
    [webView loadRequest:[NSURLRequest requestWithURL:indexFileURL]];
    
    // Add ourselves as observer for the keyboard will show notification so we can remove the toolbar
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    // Set up navbar items now
    [self checkSelection:self];
    
    // Add the highlight menu item to the menu controller
    UIMenuItem *highlightMenuItem = [[UIMenuItem alloc] initWithTitle:@"Highlight" action:@selector(highlight)];
    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObject:highlightMenuItem]];
}


- (void)checkSelection:(id)sender {
    // Setup navigation bar
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonSystemItemCancel target:self action:@selector(done:)];
    [items addObject:doneButton];
    self.navigationItem.rightBarButtonItems = items;
    [items removeAllObjects];
    
    // Highlight
    NSString *currentColor = [webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('backColor')"];
    BOOL isYellow = [currentColor isEqualToString:@"rgb(255, 255, 0)"];
    UIMenuItem *highlightMenuItem = [[UIMenuItem alloc] initWithTitle:(isYellow) ? @"De-Highlight" : @"Highlight" action:@selector(highlight)];
    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObject:highlightMenuItem]];
    
    // Bold
    UIButton *btnBold = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *butBoldImage = [[UIImage imageNamed:@"btn_bold.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [btnBold setBackgroundImage:butBoldImage forState:UIControlStateNormal];
    [btnBold addTarget:self action:@selector(bold:) forControlEvents:UIControlEventTouchUpInside];
    btnBold.frame = CGRectMake(0, 0, 48, 30);
    bold = [[UIBarButtonItem alloc] initWithCustomView:btnBold];
    
    // Italic
    UIButton *btnItalic = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *butItalicImage = [[UIImage imageNamed:@"btn_italic.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [btnItalic setBackgroundImage:butItalicImage forState:UIControlStateNormal];
    [btnItalic addTarget:self action:@selector(italic:) forControlEvents:UIControlEventTouchUpInside];
    btnItalic.frame = CGRectMake(0, 0, 48, 30);
    italic = [[UIBarButtonItem alloc] initWithCustomView:btnItalic];
    
    // Underline
    UIButton *btnUnderline = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *butUnderlineImage = [[UIImage imageNamed:@"btn_underline.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [btnUnderline setBackgroundImage:butUnderlineImage forState:UIControlStateNormal];
    [btnUnderline addTarget:self action:@selector(underline:) forControlEvents:UIControlEventTouchUpInside];
    btnUnderline.frame = CGRectMake(0, 0, 48, 30);
    underline = [[UIBarButtonItem alloc] initWithCustomView:btnUnderline];
    
    // Font Picker
    UIButton *btnFont = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnFontImage = [[UIImage imageNamed:@"btn_font.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [btnFont setBackgroundImage:btnFontImage forState:UIControlStateNormal];
    [btnFont addTarget:self action:@selector(displayFontPicker:) forControlEvents:UIControlEventTouchUpInside];
    btnFont.frame = CGRectMake(0, 0, 48, 30);
    btnFontNav = [[UIBarButtonItem alloc] initWithCustomView:btnFont];
    NSString *fontName = [webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontName')"];
    
    //TODO:
    // Font size
    int size = [[webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontSize')"] intValue];
    /*
    UIBarButtonItem *plusFontSize = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStyleBordered target:self action:@selector(fontSizeUp)];
    UIBarButtonItem *minusFontSize = [[UIBarButtonItem alloc] initWithTitle:@"-" style:UIBarButtonItemStyleBordered target:self action:@selector(fontSizeDown)];
    
    int size = [[webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontSize')"] intValue];
    if (size == 7)
        plusFontSize.enabled = NO;
    else if (size == 1)
        minusFontSize.enabled = NO;
    
    [items addObject:plusFontSize];
    [items addObject:minusFontSize];
    */
    
    
    // Font Color Picker
    UIButton *btnFontColor = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnFontColorImage = [[UIImage imageNamed:@"btn_font_color.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [btnFontColor setBackgroundImage:btnFontColorImage forState:UIControlStateNormal];
    [btnFontColor addTarget:self action:@selector(displayFontColorPicker:) forControlEvents:UIControlEventTouchUpInside];
    btnFontColor.frame = CGRectMake(0, 0, 48, 30);
    fontColorPicker = [[UIBarButtonItem alloc] initWithCustomView:btnFontColor];
    NSString *foreColor = [webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('foreColor')"];
    UIColor *color = [self colorFromRGBValue:foreColor]; //
    if (color) [fontColorPicker setTintColor:color]; //
    
    // Text position - Left
    UIButton *btnTxtPosLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnTxtPosLeftImage = [[UIImage imageNamed:@"btn_text_left.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [btnTxtPosLeft setBackgroundImage:btnTxtPosLeftImage forState:UIControlStateNormal];
    [btnTxtPosLeft addTarget:self action:@selector(textJustifyLeft:) forControlEvents:UIControlEventTouchUpInside];
    btnTxtPosLeft.frame = CGRectMake(0, 0, 48, 30);
    UIBarButtonItem *btnTxtPosLeftNav = [[UIBarButtonItem alloc] initWithCustomView:btnTxtPosLeft];
    
    // Text position - Center
    UIButton *btnTxtPosCenter = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnTxtPosCenterImage = [[UIImage imageNamed:@"btn_text_center.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [btnTxtPosCenter setBackgroundImage:btnTxtPosCenterImage forState:UIControlStateNormal];
    [btnTxtPosCenter addTarget:self action:@selector(textJustifyCenter:) forControlEvents:UIControlEventTouchUpInside];
    btnTxtPosCenter.frame = CGRectMake(0, 0, 48, 30);
    UIBarButtonItem *btnTxtPosCenterNav = [[UIBarButtonItem alloc] initWithCustomView:btnTxtPosCenter];
    
    // Text position - Right
    UIButton *btnTxtPosRight = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnTxtPosRightImage = [[UIImage imageNamed:@"btn_text_right.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [btnTxtPosRight setBackgroundImage:btnTxtPosRightImage forState:UIControlStateNormal];
    [btnTxtPosRight addTarget:self action:@selector(textJustifyRight:) forControlEvents:UIControlEventTouchUpInside];
    btnTxtPosRight.frame = CGRectMake(0, 0, 48, 30);
    UIBarButtonItem *btnTxtPosRightNav = [[UIBarButtonItem alloc] initWithCustomView:btnTxtPosRight];
    
    // Text position - Full
    /*
    UIButton *btnTxtPosFull = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnTxtPosFullImage = [[UIImage imageNamed:@"btn_text_full.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [btnTxtPosFull setBackgroundImage:btnTxtPosFullImage forState:UIControlStateNormal];
    [btnTxtPosFull addTarget:self action:@selector(textJustifyFull:) forControlEvents:UIControlEventTouchUpInside];
    btnTxtPosFull.frame = CGRectMake(0, 0, 48, 30);
    UIBarButtonItem *btnTxtPosFullNav = [[UIBarButtonItem alloc] initWithCustomView:btnTxtPosFull];
    */
    
    // Text position - Indent
    UIButton *btnTxtPosIndent = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnTxtPosIndentImage = [[UIImage imageNamed:@"btn_text_dent_in.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [btnTxtPosIndent setBackgroundImage:btnTxtPosIndentImage forState:UIControlStateNormal];
    [btnTxtPosIndent addTarget:self action:@selector(textJustifyIndent:) forControlEvents:UIControlEventTouchUpInside];
    btnTxtPosIndent.frame = CGRectMake(0, 0, 48, 30);
    UIBarButtonItem *btnTxtPosIndentNav = [[UIBarButtonItem alloc] initWithCustomView:btnTxtPosIndent];
    
    // Text position - Outdent
    UIButton *btnTxtPosOutdent = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnTxtPosOutdentImage = [[UIImage imageNamed:@"btn_text_dent_out.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [btnTxtPosOutdent setBackgroundImage:btnTxtPosOutdentImage forState:UIControlStateNormal];
    [btnTxtPosOutdent addTarget:self action:@selector(textJustifyOutdent:) forControlEvents:UIControlEventTouchUpInside];
    btnTxtPosOutdent.frame = CGRectMake(0, 0, 48, 30);
    UIBarButtonItem *btnTxtPosOutdentNav = [[UIBarButtonItem alloc] initWithCustomView:btnTxtPosOutdent];
    
    // Undo
    UIButton *btnUndo = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *butUndoImage = [[UIImage imageNamed:@"btn_do_undo.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [btnUndo setBackgroundImage:butUndoImage forState:UIControlStateNormal];
    [btnUndo addTarget:self action:@selector(undo:) forControlEvents:UIControlEventTouchUpInside];
    btnUndo.frame = CGRectMake(0, 0, 48, 30);
    undo = [[UIBarButtonItem alloc] initWithCustomView:btnUndo];
    
    BOOL undoAvailable = [[webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandEnabled('undo')"] boolValue];
    if (!undoAvailable) [undo setEnabled:NO];
    
    // Redo
    UIButton *btnRedo = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *butRedoImage = [[UIImage imageNamed:@"btn_do_redo.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [btnRedo setBackgroundImage:butRedoImage forState:UIControlStateNormal];
    [btnRedo addTarget:self action:@selector(redo:) forControlEvents:UIControlEventTouchUpInside];
    btnRedo.frame = CGRectMake(0, 0, 48, 30);
    redo = [[UIBarButtonItem alloc] initWithCustomView:btnRedo];
    
    BOOL redoAvailable = [[webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandEnabled('redo')"] boolValue];
    if (!redoAvailable) [redo setEnabled:NO];
    
    
    // Set new values
    currentFontSize = size;
    currentForeColor = foreColor;
    currentFontName = fontName;
    currentUndoStatus = undoAvailable;
    currentRedoStatus = redoAvailable;
    
    // Add all items to navigation bar
    [items addObject:btnFontNav];
    [items addObject:bold];
    [items addObject:italic];
    [items addObject:underline];
    [items addObject:fontColorPicker];
    [items addObject:btnTxtPosLeftNav];
    [items addObject:btnTxtPosCenterNav];
    [items addObject:btnTxtPosRightNav];
    [items addObject:btnTxtPosFullNav];
    [items addObject:btnTxtPosIndentNav];
    [items addObject:btnTxtPosOutdentNav];
    [items addObject:undo];
    [items addObject:redo];
    self.navigationItem.leftBarButtonItems = items;
    
    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('content').focus()"];
    
}

- (void)done:(id)sender {
    NSLog(@"Done clicked");
    NSString *yourHTMLSourceCodeString = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    NSLog(@"HTML code:\n %@", yourHTMLSourceCodeString);
    [self dismissModalViewControllerAnimated:YES];
    //[self.parentViewController dismissModalViewControllerAnimated: YES];
    //[self.parentViewController.parentViewController dismissModalViewControllerAnimated: YES];
}




#pragma mark Removing toolbar

- (void)keyboardWillShow:(NSNotification *)note {
    NSLog(@"keyboardWillShow");
    actionButtons = TRUE;
    [self performSelector:@selector(removeBar) withObject:nil afterDelay:0];
    [self checkSelection:self];
}

- (void)removeBar {
    // Locate non-UIWindow.
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if (![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    // Locate UIWebFormView.
    for (UIView *possibleFormView in [keyboardWindow subviews]) {       
        // iOS 5 sticks the UIWebFormView inside a UIPeripheralHostView.
        if ([[possibleFormView description] rangeOfString:@"UIPeripheralHostView"].location != NSNotFound) {
            for (UIView *subviewWhichIsPossibleFormView in [possibleFormView subviews]) {
                if ([[subviewWhichIsPossibleFormView description] rangeOfString:@"UIWebFormAccessory"].location != NSNotFound) {
                    [subviewWhichIsPossibleFormView removeFromSuperview];
                }
            }
        }
    }
}

#pragma mark Inserting photos

- (void)insertPhoto:(id)sender {    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; 
    imagePicker.delegate = self; 
    
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
    [popover presentPopoverFromBarButtonItem:(UIBarButtonItem *)sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    imagePickerPopover = popover;
    
}

static int i = 0;

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // Obtain the path to save to
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"photo%i.png", i]];
    
    // Extract image from the picker and save it
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];   
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *data = UIImagePNGRepresentation(image);
        [data writeToFile:imagePath atomically:YES];
    }
    
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('insertImage', false, '%@')", imagePath]];
    [imagePickerPopover dismissPopoverAnimated:YES];
    i++;
}

#pragma mark Undo/Redo

- (void)undo:(id)sender {
    [webView stringByEvaluatingJavaScriptFromString:@"document.execCommand('undo')"];
    [self checkSelection:self];
}

- (void)redo:(id)sender {
    [webView stringByEvaluatingJavaScriptFromString:@"document.execCommand('redo')"];
    [self checkSelection:self];
}

#pragma mark Fonts

- (void)displayFontColorPicker:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select a font color" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Blue", @"Yellow", @"Green", @"Red", @"Orange", nil];
    [actionSheet showFromBarButtonItem:(UIBarButtonItem *)fontColorPicker animated:YES];
}

- (void)displayFontPicker:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select a font" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Helvetica", @"Courier", @"Arial", @"Zapfino", @"Verdana", nil];
    [actionSheet showFromBarButtonItem:(UIBarButtonItem *)btnFontNav animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *selectedButtonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    selectedButtonTitle = [selectedButtonTitle lowercaseString];
    
    if ([actionSheet.title isEqualToString:@"Select a font"])
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('fontName', false, '%@')", selectedButtonTitle]];
    else
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('foreColor', false, '%@')", selectedButtonTitle]];
}

- (void)fontSizeUp {
    //[timer invalidate]; // Stop it while we work
    
    int size = [[webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontSize')"] intValue] + 1;
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('fontSize', false, '%i')", size]];

    currentFontSize = size;
    [self checkSelection:self];
    //timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkSelection:) userInfo:nil repeats:YES];
}

- (void)fontSizeDown {
    //[timer invalidate]; // Stop it while we work
    
    int size = [[webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontSize')"] intValue] - 1;    
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('fontSize', false, '%i')", size]];
    
    currentFontSize = size;
    [self checkSelection:self];
    //timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkSelection:) userInfo:nil repeats:YES];
}

#pragma mark B/I/U

- (void)bold:(id)sender {
    [webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Bold\")"];
    currentBoldStatus = !currentBoldStatus;
    [self checkSelection:self];
}
- (void)italic:(id)sender {
    [webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Italic\")"];
    currentItalicStatus = !currentItalicStatus;
    [self checkSelection:self];
}
- (void)underline:(id)sender {
    //asd
    [webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Underline\")"];
    currentUnderlineStatus = !currentUnderlineStatus;
    [self checkSelection:self];
}

#pragma mark Justify

- (void)textJustifyLeft:(id)sender {
    [webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"JustifyLeft\")"];
    [self checkSelection:self];
}
- (void)textJustifyCenter:(id)sender {
    [webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"JustifyCenter\")"];
    [self checkSelection:self];
}
- (void)textJustifyRight:(id)sender {
    [webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"JustifyRight\")"];
    [self checkSelection:self];
}
- (void)textJustifyFull:(id)sender {
    [webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"JustifyFull\")"];
    [self checkSelection:self];
}

- (void)textJustifyIndent:(id)sender {
    [webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Indent\")"];
    [self checkSelection:self];
}

- (void)textJustifyOutdent:(id)sender {
    [webView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Outdent\")"];
    [self checkSelection:self];
}


#pragma Highlights

- (void)highlight {
    NSString *currentColor = [webView stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('backColor')"];
    if ([currentColor isEqualToString:@"rgb(255, 255, 0)"]) {
        [webView stringByEvaluatingJavaScriptFromString:@"document.execCommand('backColor', false, 'white')"];
    } else {
        [webView stringByEvaluatingJavaScriptFromString:@"document.execCommand('backColor', false, 'yellow')"];
    }
    [self checkSelection:self];
}

@end
