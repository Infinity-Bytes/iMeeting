//
//  main.m
//  iMeeting
//
//  Created by Jesus Cagide on 10/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"


/**
 Ref:
 - http://qrcode.kaywa.com/
 - http://borkware.com/quickies/one?topic=NSString
 - http://www.raywenderlich.com/6015/beginning-icloud-in-ios-5-tutorial-part-1
 - http://www.techotopia.com/index.php/Managing_iPhone_Files_using_the_iOS_5_UIDocument_Class
 - http://www.ios-developer.net/iphone-ipad-programmer/development/file-saving-and-loading/using-the-document-directory-to-store-files
 
 - https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/nsfilemanager_Class/Reference/Reference.html
 - https://developer.apple.com/library/IOs/#documentation/DataManagement/Conceptual/DocumentBasedAppPGiOS/CreateCustomDocument/CreateCustomDocument.html
 - https://developer.apple.com/library/ios/#documentation/uikit/reference/UIDocument_Class/UIDocument/UIDocument.html
 - https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSDistributedNotificationCenter_Class/Reference/Reference.html
 - https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/nsnotificationcenter_Class/Reference/Reference.html
 - https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSDate_Class/Reference/Reference.html
 - https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html
 - https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSURL_Class/Reference/Reference.html
 
 - http://stackoverflow.com/questions/2184372/how-do-i-save-an-nsstring-as-a-txt-file-on-my-apps-local-documents-directory
 - http://stackoverflow.com/questions/1110278/iphone-sdk-getting-device-id-or-mac-address
 - http://stackoverflow.com/questions/5303411/append-nsstring-to-nsurl
 - http://stackoverflow.com/questions/2492236/replace-occurences-of-nsstring-iphone
 */
int main(int argc, char *argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
