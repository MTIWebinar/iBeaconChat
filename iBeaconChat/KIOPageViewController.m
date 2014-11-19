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


@interface KIOPageViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>
@property (strong, nonatomic) NSArray *pageData;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@end


@implementation KIOPageViewController

- (NSArray *)pageData {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    return [[dateFormatter monthSymbols] copy];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageViewController =
    [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                    navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                  options:nil];
    self.pageViewController.delegate = self;
    
    KIOBeaconViewController *startingViewController = [self viewControllerAtIndex:0 storyboard:self.storyboard];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO completion:nil];
    
    self.pageViewController.dataSource = self;
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (KIOBeaconViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    if (([self.pageData count] == 0) || (index >= [self.pageData count])) {
        return nil;
    }
    
    KIOBeaconViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([KIOBeaconViewController class])];
    dataViewController.dataObject = self.pageData[index];
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(KIOBeaconViewController *)viewController {
    return [self.pageData indexOfObject:viewController.dataObject];
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
    
    KIOBeaconViewController *currentViewController = self.pageViewController.viewControllers[0];
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
    NSUInteger index = [self indexOfViewController:(id)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:(id)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageData count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}


@end
