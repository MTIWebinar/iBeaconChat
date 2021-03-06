//
//  RootViewController.m
//  iBeaconChat
//
//  Created by Kirill Osipov on 19.11.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

#import "KIOPageViewController.h"

#import "KIOChatViewController.h"
#import "KIOBeaconViewController.h"
#import "KIOSettingsViewController.h"
#import "KIOErrorViewController.h"

#import "KIOBluetoothService.h"
#import "KIOMessageService.h"
#import "KIOBeaconService.h"


@interface KIOPageViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>
@property (strong, nonatomic) UIPageViewController *pageViewController;
@end


@implementation KIOPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self listenNotification];
    
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:self.pageStoryboardIdentifiers.firstObject];
    self.pageViewController = [self setupPageViewControllerWithController:viewController];
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    CGRect pageViewRect = self.view.bounds;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        pageViewRect = CGRectInset(pageViewRect, 40.0, 40.0);
    }
    self.pageViewController.view.frame = pageViewRect;
    [self.pageViewController didMoveToParentViewController:self];

    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // !!!: remove or not listenNotification for kKIOServiceBluetoothStateNotification
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIPageViewController *)setupPageViewControllerWithController:(UIViewController *)viewController {
    UIPageViewController *pageViewController =
    [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                    navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                  options:nil];
    pageViewController.delegate = self;
    pageViewController.dataSource = self;
    
    [pageViewController setViewControllers:@[viewController]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO completion:nil];
    
    return pageViewController;
}


#pragma mark - Privat

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (([self.pageStoryboardIdentifiers count] == 0) || (index >= [self.pageStoryboardIdentifiers count])) {
        return nil;
    }
    return [self.storyboard instantiateViewControllerWithIdentifier:self.pageStoryboardIdentifiers[index]];
}

- (NSUInteger)indexOfViewController:(UIViewController *)viewController {
    return [self.pageStoryboardIdentifiers indexOfObject:NSStringFromClass([viewController class])];
}


#pragma mark - NSNotification

- (void)listenNotification {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(notificationBlutooth:) name:kKIOServiceBluetoothStateNotification object:nil];
    [nc addObserver:self selector:@selector(notificationMessage:) name:kKIOServiceMessagePeerReceiveDataNotification object:nil];
}

- (void)notificationBlutooth:(NSNotification *)notification {
    BOOL blutoothON = [notification.userInfo[kKIOServiceBluetoothStateNotification] boolValue];

    self.pageStoryboardIdentifiers =
    blutoothON ?    @[NSStringFromClass([KIOBeaconViewController class]), NSStringFromClass([KIOChatViewController class])] :
                    @[NSStringFromClass([KIOErrorViewController class])];
    
    KIOBeaconService *locator = [KIOBeaconService sharedInstance];
    blutoothON ? [locator startMonitoring] : [locator stopMonitoring];
    
    [self walkToPageStoryboardIdentifier:self.pageStoryboardIdentifiers.firstObject];
}

- (void)notificationMessage:(NSNotification *)notification {
    // TODO: notificationMessage with Action walkToPageStoryboardIdentifier:
}


#pragma mark - Action

- (void)walkToPageStoryboardIdentifier:(NSString *)pageStoryboardIdentifier {
    NSUInteger index =  [self.pageStoryboardIdentifiers indexOfObject:pageStoryboardIdentifier] != NSNotFound ?
                        [self.pageStoryboardIdentifiers indexOfObject:pageStoryboardIdentifier] : 0;
    UIViewController *startingViewController = [self viewControllerAtIndex:index];
    [self.pageViewController setViewControllers:@[startingViewController]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:NO completion:nil];
}


#pragma mark - UIPageViewControllerDelegate

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsPortrait(orientation) || ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) {
        
        UIViewController *currentViewController = self.pageViewController.viewControllers[0];
        NSArray *viewControllers = @[currentViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        
        self.pageViewController.doubleSided = NO;
        return UIPageViewControllerSpineLocationMin;
    }
    
    UIViewController *currentViewController = self.pageViewController.viewControllers.firstObject;
    NSArray *viewControllers = nil;
    
    NSUInteger indexOfCurrentViewController = [self indexOfViewController:currentViewController];
    if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) {
        UIViewController *nextViewController = [self pageViewController:self.pageViewController viewControllerAfterViewController:currentViewController];
        viewControllers = @[currentViewController, nextViewController];
    } else {
        UIViewController *previousViewController = [self pageViewController:self.pageViewController viewControllerBeforeViewController:currentViewController];
        viewControllers = @[previousViewController, currentViewController];
    }
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    return UIPageViewControllerSpineLocationMid;
}


#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageStoryboardIdentifiers count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}


@end
