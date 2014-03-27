//
//  SocializeShareService.m
//  SocializeSDK
//
//  Created by Fawad Haider on 7/1/11.
//  Copyright 2011 Socialize, Inc. All rights reserved.
//

#import "SocializeShareService.h"
#import "SocializeShare.h"
#import "_Socialize.h"

@interface SocializeShareService()
@end


#define SHARE_METHOD @"share/"

@implementation SocializeShareService

-(Protocol *)ProtocolType
{
    return  @protocol(SocializeShare);
}

- (void)createShare:(id<SocializeShare>)share {
    [self createShare:share success:nil failure:nil];
}

- (void)createShare:(id<SocializeShare>)share
            success:(void(^)(id<SZShare> share))success
            failure:(void(^)(NSError *error))failure {
    __block SocializeActivity *activityObj = (SocializeActivity *)share;
    __block id<SocializeEntity>entityObj = activityObj.entity;
    NSString *entityKey = entityObj.key;
    BOOL keyIsURL = [entityObj keyIsURL];

    //derive a Loopy shortlink from URL
    if(keyIsURL) {
        [self getLoopyShortlink:entityKey success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *responseDict = (NSDictionary *)responseObject;
            NSString *shortlink = (NSString *)[responseDict objectForKey:@"shortlink"];
            [entityObj setKey:shortlink];
            [self executeShare:share success:success failure:failure];            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //currently does nothing and imply "passes thru" the share
            //TODO is this right??
            [self executeShare:share success:success failure:failure];
        }];
    }
    else {
        [self executeShare:share success:success failure:failure];
    }
}

//second half of createShare; called with Loopy shortlink, if applicable
- (void)executeShare:(id<SocializeShare>)share
             success:(void(^)(id<SZShare> share))success
             failure:(void(^)(NSError *error))failure {
    NSDictionary *params = [_objectCreator createDictionaryRepresentationOfObject:share];
    SocializeRequest *request = [SocializeRequest requestWithHttpMethod:@"POST"
                                                           resourcePath:SHARE_METHOD
                                                     expectedJSONFormat:SocializeDictionaryWithListAndErrors
                                                                 params:[NSArray arrayWithObject:params]];
    request.successBlock = ^(NSArray *shares) {
        BLOCK_CALL_1(success, [shares objectAtIndex:0]);
        //report to Loopy -- either as straight share or sharelink
        NSString *shareText = (NSString *)[params objectForKey:@"text"];
        NSString *medium = (NSString *)[params objectForKey:@"medium"];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *mediumNbr = [formatter numberFromString:medium];
        int mediumInt = [mediumNbr intValue];
        [self reportShareToLoopyWithText:shareText
                                 channel:[self getNetworksForLoopy:mediumInt]
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     //currently does nothing
                                 }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     //currently does nothing
                                 }];
    };
    request.failureBlock = failure;
    
    [self executeRequest:request];
}

//Loopy analytics reporting
- (void)reportShareToLoopyWithText:(NSString *)shareText
                           channel:(NSString *)channel
                           success:(void(^)(AFHTTPRequestOperation *, id))success
                           failure:(void(^)(AFHTTPRequestOperation *, NSError *))failure {
    STAPIClient *loopyAPIClient = (STAPIClient *)[Socialize sharedLoopyAPIClient];
    NSDictionary *shareDict = [loopyAPIClient reportShareDictionary:shareText channel:channel];
    [loopyAPIClient reportShare:shareDict
                        success:success
                        failure:failure];
}

//Loopy analytics reporting
- (void)getLoopyShortlink:(NSString *)urlStr
                  success:(void(^)(AFHTTPRequestOperation *, id))success
                  failure:(void(^)(AFHTTPRequestOperation *, NSError *))failure {
    STAPIClient *loopyAPIClient = (STAPIClient *)[Socialize sharedLoopyAPIClient];
    NSDictionary *shortlinkDict = [loopyAPIClient shortlinkDictionary:urlStr title:nil meta:nil tags:nil];
    [loopyAPIClient shortlink:shortlinkDict success:success failure:failure];
}

//for now, simply text-ify networks being shared
- (NSString *)getNetworksForLoopy:(int)networks {
    NSString *channel = @"";
    switch (networks) {
        case SocializeShareMediumTwitter:
            channel = @"twitter";
            break;
            
        case SocializeShareMediumFacebook:
            channel = @"facebook";
            break;
            
        case SocializeShareMediumEmail:
            channel = @"email";
            break;
            
        case SocializeShareMediumSMS:
            channel = @"sms";
            break;
            
        case SocializeShareMediumPinterest:
            channel = @"pinterest";
            break;
            
        case SocializeShareMediumOther:
            channel = @"facebook,twitter";
            break;
            
        default:
            break;
    }
    
    return channel;
}

-(void)createShareForEntity:(id<SocializeEntity>)entity medium:(SocializeShareMedium)medium  text:(NSString*)text{
    [self createShareForEntityKey:[entity key] medium:medium text:text];
}

-(void)createShareForEntityKey:(NSString*)key medium:(SocializeShareMedium)medium  text:(NSString*)text{
    
    if (key && [key length]){   
        NSDictionary* entityParam = [NSDictionary dictionaryWithObjectsAndKeys:key, @"entity_key", text, @"text", [NSNumber numberWithInt:medium], @"medium" , nil];
        NSArray *params = [NSArray arrayWithObjects:entityParam, 
                           nil];
        [self executeRequest:
         [SocializeRequest requestWithHttpMethod:@"POST"
                                    resourcePath:SHARE_METHOD
                              expectedJSONFormat:SocializeDictionaryWithListAndErrors
                                          params:params]
         ];
    }
}

-(void)getSharesWithIds:(NSArray*)shareIds success:(void(^)(NSArray *shares))success failure:(void(^)(NSError *error))failure {
    
    NSMutableDictionary*  params = [[[NSMutableDictionary alloc] init] autorelease]; 
    [params setObject:shareIds forKey:@"id"];
    SocializeRequest *request = [SocializeRequest requestWithHttpMethod:@"GET"
                                                           resourcePath:SHARE_METHOD
                                                     expectedJSONFormat:SocializeDictionaryWithListAndErrors
                                                                 params:params];

    request.successBlock = success;
    request.failureBlock = failure;
    [self executeRequest:request];
}

-(void)getShareWithId:(NSNumber*)shareId success:(void(^)(id<SZShare> share))success failure:(void(^)(NSError *error))failure {
    [self getSharesWithIds:[NSArray arrayWithObject:shareId]
                   success:^(NSArray *shares) {
                       BLOCK_CALL_1(success, [shares objectAtIndex:0]);
                   } failure:failure];
}

- (void)getSharesForEntityKey:(NSString*)key
                        first:(NSNumber*)first
                         last:(NSNumber*)last
                      success:(void(^)(NSArray *shares))success
                      failure:(void(^)(NSError *error))failure {
    
    NSMutableDictionary* params = [[[NSMutableDictionary alloc] init] autorelease]; 
    if (key)
        [params setObject:key forKey:@"entity_key"];
    if (first && last){
        [params setObject:first forKey:@"first"];
        [params setObject:last forKey:@"last"];
    }
    SocializeRequest *request = [SocializeRequest requestWithHttpMethod:@"GET"
                                                           resourcePath:SHARE_METHOD
                                                     expectedJSONFormat:SocializeDictionaryWithListAndErrors
                                                                 params:params];
    request.successBlock = success;
    request.failureBlock = failure;
    
    [self executeRequest:request];
}

- (void)getSharesWithFirst:(NSNumber*)first
                      last:(NSNumber*)last
                   success:(void(^)(NSArray *shares))success
                   failure:(void(^)(NSError *error))failure {
    [self callListingGetEndpointWithPath:SHARE_METHOD params:nil first:first last:last success:success failure:failure];
}


@end
