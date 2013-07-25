//
//  main.m
//  CRMultiRowSelector
//
//  Created by Christian Roman Mendoza on 6/17/12.
//  Copyright (c) 2012 chroman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UI7Kit/UI7Kit.h>
#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {

        [UI7Kit patchIfNeeded]; // in main.m, before UIApplicationMain()
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
