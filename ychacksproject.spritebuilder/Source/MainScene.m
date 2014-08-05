//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

#import "TLHMViewController.h"

#import <MyoKit/MyoKit.h>

@interface MainScene ()

@property (strong, nonatomic) TLMPose *currentPose;

@end

@implementation MainScene {
    CCSprite *_triangle;
    
    NSInteger _count;
}

- (void) didLoadFromCCB {
    _count = -179;
    
    [self schedule:@selector(triangleUpdate) interval:0.05];
}

- (void) startGame {
    CCScene *gameplayScene = [CCBReader loadAsScene: @"Gameplay"];
    CCTransition *transition = [CCTransition transitionCrossFadeWithDuration:0.1f];
    [[CCDirector sharedDirector] replaceScene:gameplayScene withTransition:transition];
}

- (void)connect {
    // Note that when the settings view controller is presented to the user, it must be in a UINavigationController.
    TLHMViewController* thalmicController = [[TLHMViewController alloc] initWithNibName:@"TLHMViewController" bundle:nil];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:thalmicController];
    
    // Present the settings view controller modally.
    [[CCDirector sharedDirector] presentViewController:controller animated:YES completion:nil];
}


- (void) triangleUpdate {
    CCEffectHue *hueEffect = [CCEffectHue effectWithHue:_count];
    _count += 10;
    if (_count >= 179) {
        _count = -179;
    }
    _triangle.effect = hueEffect;
}


@end
