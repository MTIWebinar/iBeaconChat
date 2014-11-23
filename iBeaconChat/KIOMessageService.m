//
//  KIOMessageService.m
//  iBeaconChat
//
//  Created by Kirill Osipov on 20.11.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

#import "KIOMessageService.h"

static NSString *const kBonjourServiceType = @"chatservice"; // 15 max


@interface KIOMessageService () <MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate>
@property (strong, nonatomic) MCPeerID *peerID;
@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCNearbyServiceAdvertiser *serviceAdvertiser;
@property (strong, nonatomic) MCNearbyServiceBrowser *serviceBrowser;
@end


@implementation KIOMessageService

- (instancetype)init {
    if ([super init]) {
        self.peerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];

        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(startServices) name:UIApplicationWillEnterForegroundNotification object:nil];
        [nc addObserver:self selector:@selector(stopServices) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [self startServices];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.session.delegate = nil;
    self.serviceAdvertiser.delegate = nil;
    self.serviceBrowser.delegate = nil;
}


#pragma mark - KIOMessageService State

- (void)startServices {
    [self setupSession];
    [self.serviceAdvertiser startAdvertisingPeer];
    [self.serviceBrowser startBrowsingForPeers];
}

- (void)stopServices {
    [self.serviceBrowser stopBrowsingForPeers];
    [self.serviceAdvertiser stopAdvertisingPeer];
    [self.session disconnect];
}

- (void)setupSession {
    self.session = [[MCSession alloc] initWithPeer:self.peerID];
    self.session.delegate = self;
    
    self.serviceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID discoveryInfo:nil serviceType:kBonjourServiceType];
    self.serviceAdvertiser.delegate = self;
    
    self.serviceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID serviceType:kBonjourServiceType];
    self.serviceBrowser.delegate = self;
}


#pragma mark - Action

- (void)sendString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
}


#pragma mark - MCNearbyServiceBrowserDelegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    NSLog(@"foundPeer: %@", peerID.displayName);
    
    [browser invitePeer:peerID toSession:self.session withContext:nil timeout:30.0f];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    NSLog(@"lostPeer: %@", peerID.displayName);
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    NSLog(@"didNotStartBrowsingForPeers: %@", error.localizedDescription);
}


#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID
       withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler {
    NSLog(@"didReceiveInvitationFromPeer: %@ and invit him", peerID.displayName);
    invitationHandler(YES, self.session);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    NSLog(@"didNotStartAdvertisingPeer: %@", error.localizedDescription);
}


#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {

    // TODO: kKIOServiceMessagePeerStateChangeNotification
    // NSDictionary *dict = @{@"peerID": peerID, @"state": @(state)]};
    
    switch (state) {
        case MCSessionStateNotConnected:
            NSLog(@"Not Connected: %@", peerID.displayName);
            break;
        case MCSessionStateConnecting:
            NSLog(@"Connecting: %@", peerID.displayName);
            break;
        case MCSessionStateConnected:
            NSLog(@"Connected: %@", peerID.displayName);
            break;
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    // TODO: kKIOServiceMessagePeerReceiveDataNotification
    // NSDictionary *dict = @{@"peerID": peerID, @"message": message};

    NSLog(@"didReceiveData: %@ from %@", message, peerID.displayName);
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream
       withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    NSLog(@"didReceiveStreamWithName: %@", streamName);
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    NSLog(@"didStartReceivingResourceWithName: %@", resourceName);
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    NSLog(@"didFinishReceivingResourceWithName: %@", resourceName);
}

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate
       fromPeer:(MCPeerID *)peerID certificateHandler:(void(^)(BOOL accept))certificateHandler {
    NSLog(@"didReceiveCertificate: %@", peerID.displayName);
    certificateHandler(YES);
}


@end

NSString *const kKIOServiceMessagePeerStateChangeNotification = @"ru.kirillosipov.kKIOServiceMessagePeerStateChangeNotification";
NSString *const kKIOServiceMessagePeerReceiveDataNotification = @"ru.kirillosipov.kKIOServiceMessagePeerReceiveDataNotification";