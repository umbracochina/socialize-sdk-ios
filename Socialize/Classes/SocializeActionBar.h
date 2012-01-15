/*
 * SocializeActionBar.h
 * SocializeSDK
 *
 * Created on 10/5/11.
 * 
 * Copyright (c) 2011 Socialize, Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <UIKit/UIKit.h>
#import "SocializeBaseViewController.h"
#import "SocializeActionView.h"

@class SocializeCommentsTableViewController;
@protocol SocializeView;
@protocol SocializeEntity;
@protocol SocializeLike;
@class MFMailComposeViewController;
@protocol SocializeActionBarDelegate;

/**
 The Socialize Action Bar

 */
@interface SocializeActionBar : SocializeBaseViewController<SocializeActionViewDelegate>

@property (nonatomic, assign) id<SocializeActionBarDelegate> delegate;
@property (nonatomic, assign) UIViewController* presentModalInViewController;
@property (nonatomic, retain) id<SocializeEntity> entity;
@property (nonatomic, retain) UIViewController *commentsNavController;

@property (nonatomic, assign) BOOL ignoreNextView;
@property (nonatomic, retain) UIActionSheet *shareActionSheet;
@property (nonatomic, retain) MFMailComposeViewController *shareComposer;
@property (nonatomic, assign) BOOL noAutoLayout;
@property (nonatomic, assign, readonly) BOOL initialized;
@property (nonatomic, retain) UIAlertView *unconfiguredEmailAlert;

/** @name Initialization */

/**
 Class helper method to create an Action Bar
 
 @param url The URL for the Entity Key
 @param presentModalInController Modal dialogs and UIActionSheet popups will be presented in this controller and its view
 
 @warning Deprecated. Use actionbarWithKey:presentModalInController: instead
 */
+(SocializeActionBar*)actionBarWithUrl:(NSString*)url presentModalInController:(UIViewController*)controller;


/**
 Class helper method to create an Action Bar
 
 @param key The Entity Key
 @param presentModalInController Modal dialogs and UIActionSheet popups will be presented in this controller and its view
 */
+(SocializeActionBar*)actionBarWithKey:(NSString*)key presentModalInController:(UIViewController*)controller;


/**
 Action Bar Init
 
 @param url The URL for the Entity Key
 @param presentModalInController Modal dialogs and UIActionSheet popups will be presented in this controller and its view
 */
-(id)initWithEntityUrl:(NSString*)url presentModalInController:(UIViewController*)controller;

/**
 Action Bar Init
 
 @param key The Entity Key
 @param presentModalInController Modal dialogs and UIActionSheet popups will be presented in this controller and its view
 */
-(id)initWithEntityKey:(NSString*)key presentModalInController:(UIViewController*)controller;

/**
 Action Bar Init
 
 @param url The URL for the Entity Key
 @param presentModalInController Modal dialogs and UIActionSheet popups will be presented in this controller and its view
 */
-(id)initWithEntity:(id<SocializeEntity>)socEntity presentModalInController:(UIViewController*)controller;
@end

@protocol SocializeActionBarDelegate <NSObject>

@optional
- (void)actionBar:(SocializeActionBar*)actionBar wantsDisplayActionSheet:(UIActionSheet*)actionSheet;

@end
