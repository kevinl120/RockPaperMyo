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
    // Triangle in the background
    CCSprite *_triangle;
    
    // Used for changing hue
    NSInteger _count;
}

- (void) didLoadFromCCB {
    // Set the hue
    _count = -179;
    
    // Change the hue 20 times every second
    [self schedule:@selector(updateTriangleHue) interval:0.05];
}

- (void) startGame {
    // Load gameplay when play button is pressed
    CCScene *gameplayScene = [CCBReader loadAsScene: @"Gameplay"];
    CCTransition *transition = [CCTransition transitionCrossFadeWithDuration:1.0f];
    [[CCDirector sharedDirector] replaceScene:gameplayScene withTransition:transition];
}

- (void) updateTriangleHue {
    
    // Set the hue to the count previously set
    CCEffectHue *hueEffect = [CCEffectHue effectWithHue:_count];
    
    // Increase the hue
    _count += 10;
    
    // Set the hue back to the lowest number if the hue is greater than the highest number
    if (_count >= 179) {
        _count = -179;
    }
    
    // Set the triangle's hue to hueEffect
    _triangle.effect = hueEffect;
}

- (void)connect {
    // Note that when the settings view controller is presented to the user, it must be in a UINavigationController.
    TLHMViewController* thalmicController = [[TLHMViewController alloc] initWithNibName:@"TLHMViewController" bundle:nil];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:thalmicController];
    
    // Present the settings view controller modally.
    [[CCDirector sharedDirector] presentViewController:controller animated:YES completion:nil];
}

@end
