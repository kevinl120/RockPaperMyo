//
//  Recap.m
//  ychacksproject
//
//  Created by Kevin Li on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Recap.h"

#import "Gameplay.h"

@implementation Recap {
    
}

- (void) retry {
    CCScene *gameplayScene = [CCBReader loadAsScene: @"Gameplay"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:1.0f];
    [[CCDirector sharedDirector] replaceScene:gameplayScene withTransition:transition];
}

@end
