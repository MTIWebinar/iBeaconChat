//
//  KIOChatViewController.m
//  iBeaconChat
//
//  Created by Kirill Osipov on 26.05.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

@import MultipeerConnectivity;

#import "KIOChatViewController.h"

static NSString *const kBonjourServiceType = @"iBeaconChat";


@interface KIOChatViewController () <UITextFieldDelegate, MCBrowserViewControllerDelegate, MCSessionDelegate>

@property (nonatomic, weak) IBOutlet UITextView *textOutputBox;
@property (nonatomic, weak) IBOutlet UITextField *textInputBox;

@property (nonatomic, strong) MCBrowserViewController *mcBrowserViewController;
@property (nonatomic, strong) MCAdvertiserAssistant *mcAdvertiserAssistant;
@property (nonatomic, strong) MCSession *mcSession;
@property (nonatomic, strong) MCPeerID *mcPeerID;

@end

@implementation KIOChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.textOutputBox.text = nil;
    self.textInputBox.delegate = self;
    
    self.mcPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    
    self.mcSession = [[MCSession alloc] initWithPeer:self.mcPeerID];
    self.mcSession.delegate = self;
    
    self.mcBrowserViewController = [[MCBrowserViewController alloc] initWithServiceType:kBonjourServiceType session:self.mcSession];
    self.mcBrowserViewController.delegate = self;
    
    self.mcAdvertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:kBonjourServiceType discoveryInfo:nil session:self.mcSession];
    [self.mcAdvertiserAssistant start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (IBAction)showMCBrowserViewController:(id)sender
{
    [self presentViewController:self.mcBrowserViewController animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendText];

    [textField resignFirstResponder];
    self.textInputBox.text = nil;
    return YES;
}

- (void)receiveMessage:(NSString *)message fromPeer:(MCPeerID *)peer
{
    NSString *finalText;
    if (peer == self.mcPeerID) {
        finalText = [NSString stringWithFormat:@"\nme: %@\n", message];
    }
    else {
        finalText = [NSString stringWithFormat:@"\n%@: %@\n", peer.displayName, message];
    }
    
    self.textOutputBox.text = [self.textOutputBox.text stringByAppendingString:finalText];
}

- (void)sendText
{
    NSString *message = self.textInputBox.text;
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.mcSession sendData:data toPeers:[self.mcSession connectedPeers] withMode:MCSessionSendDataUnreliable error:nil];
    [self receiveMessage:message fromPeer:self.mcPeerID];
}

#pragma mark - MCBrowserViewControllerDelegate

// Notifies the delegate, when the user taps the done button
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [self.mcBrowserViewController dismissViewControllerAnimated:YES completion:nil];
}

// Notifies delegate that the user taps the cancel button.
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [self.mcBrowserViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MCSessionDelegate

// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    
}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    dispatch_async(dispatch_get_main_queue(),^{
        [self receiveMessage:message fromPeer:peerID];
    });
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
