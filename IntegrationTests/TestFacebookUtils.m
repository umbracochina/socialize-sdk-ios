//
//  TestSZFacebookUtils.m
//  SocializeSDK
//
//  Created by Nathaniel Griswold on 6/7/12.
//  Copyright (c) 2012 Socialize, Inc. All rights reserved.
//

#import "TestFacebookUtils.h"
#import "SZTestHelper.h"
#import "SZUserUtils.h"
#import <OCMock/NSObject+ClassMock.h>

@implementation TestFacebookUtils

- (void)linkToFacebookIfNeeded {
    if (![SZFacebookUtils isLinked]) {
        NSString *accessToken = [[SZTestHelper sharedTestHelper] facebookAccessToken];
        
        //set to date 30 days in future (preferred for FB access token)
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:30];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *newDate = [calendar dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];

        [self prepare];
        [SZFacebookUtils linkWithAccessToken:accessToken expirationDate:newDate success:^(id<SZFullUser> fullUser) {
            [self notify:kGHUnitWaitStatusSuccess];
        } failure:^(NSError *error) {
            [self notify:kGHUnitWaitStatusFailure];        
        }];
        [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10];
    }
}

- (void)testLink {
    [SZFacebookUtils unlink];
    [self linkToFacebookIfNeeded];
}

- (void)testLinkAndSaveUserSettings {
    [SZFacebookUtils unlink];
    if (![SZFacebookUtils isLinked]) {
        NSString *accessToken = [[SZTestHelper sharedTestHelper] facebookAccessToken];
        
        //set to date 30 days in future (preferred for FB access token)
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:30];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *newDate = [calendar dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
        
        [self prepare];
        [SZFacebookUtils linkWithAccessToken:accessToken
                              expirationDate:newDate
                                     success:^(id<SZFullUser> fullUser) {
                                         SZUserSettings *settings = [SZUserUtils currentUserSettings];
                                         UIImage *newImage = nil;
                                         settings.profileImage = newImage;
                                         settings.bio = @"I love this app!";
                                         settings.firstName = @"firstName";
                                         settings.lastName = @"lastName";
                                        
                                         [SZUserUtils saveUserSettings:settings
                                                               success:^(SZUserSettings *settings, id<SocializeFullUser> updatedUser) {
                                                                   [self notify:kGHUnitWaitStatusSuccess];
                                                               }
                                                               failure:^(NSError *error) {
                                                                   [self notify:kGHUnitWaitStatusFailure];
                                                               }];
            
                                     }
                                     failure:^(NSError *error) {
                                         [self notify:kGHUnitWaitStatusFailure];
                                     }];
        
        [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10];
    }
}

//- (void)testGraphGetWhenNotAuthed {
//    [SZFacebookUtils unlink];
//
//    __block BOOL didAuth = NO;
//    [[SZTestHelper sharedTestHelper] startMockingSucceedingFacebookAuthWithDidAuth:^(NSString *token, NSDate *date) {
//        didAuth = YES;
//        [self linkToFacebookIfNeeded];
//    }];
//    
//    [self prepare];
//    [SZFacebookUtils postWithGraphPath:@"me/feed" params:nil success:^(id result) {
//        [self notify:kGHUnitWaitStatusSuccess];
//    } failure:^(NSError *error) {
//        [self notify:kGHUnitWaitStatusFailure];
//    }];
//    [self waitForStatus:kGHUnitWaitStatusSuccess];
//    
//    GHAssertTrue(didAuth, @"Should have authed");
//    [[SZTestHelper sharedTestHelper] stopMockingSucceedingFacebookAuth];
//}
//
//- (void)testGraphGetWhenAuthed {
//    [self linkToFacebookIfNeeded];
//
//    [[SZTestHelper sharedTestHelper] startMockingSucceededFacebookAuth];
//    
//    [self prepare];
//    [[SZFacebookUtils origClass] postWithGraphPath:@"me/feed" params:nil success:^(id result) {
//        [self notify:kGHUnitWaitStatusSuccess];
//    } failure:^(NSError *error) {
//        [self notify:kGHUnitWaitStatusFailure];
//    }];
//    [self waitForStatus:kGHUnitWaitStatusSuccess];
//    
//    [[SZTestHelper sharedTestHelper] stopMockingSucceededFacebookAuth];
//}


//- (void)testGraphPosting {
//    [self linkToFacebookIfNeeded];
//    
//    NSDictionary *postData = [NSDictionary dictionaryWithObjectsAndKeys:
//                              @"message", @"message",
//                              @"caption", @"caption",
//                              @"http://www.getsocialize.com", @"link",
//                              @"A link", @"name",
//                              @"description", @"description",
//                              nil];
//    
//    __block NSDictionary *postInfo = nil;
//    
//    // POST the post and grab id
//    [self prepare];
//    [SZFacebookUtils postWithGraphPath:@"me/feed" params:postData success:^(id info) {
//        postInfo = [info retain];
//        [self notify:kGHUnitWaitStatusSuccess];
//    } failure:^(NSError *error) {
//        [self notify:kGHUnitWaitStatusFailure];
//    }];
//    [self waitForStatus:kGHUnitWaitStatusSuccess];
//    NSString *postID = [postInfo objectForKey:@"id"];
//    
//    // GET the post and verify id
//    [self prepare];
//    [SZFacebookUtils getWithGraphPath:postID params:nil success:^(id info) {
//        GHAssertEqualStrings([info objectForKey:@"id"], postID, @"Not the post");
//        [self notify:kGHUnitWaitStatusSuccess];
//    } failure:^(NSError *error) {
//        [self notify:kGHUnitWaitStatusFailure];
//    }];
//    [self waitForStatus:kGHUnitWaitStatusSuccess];
//
//    // DELETE the post
//    [self prepare];
//    [SZFacebookUtils deleteWithGraphPath:postID params:nil success:^(id info) {
//        [self notify:kGHUnitWaitStatusSuccess];
//    } failure:^(NSError *error) {
//        [self notify:kGHUnitWaitStatusFailure];
//    }];
//    [self waitForStatus:kGHUnitWaitStatusSuccess];
//
//    [postInfo release];
//}

@end
