//
//  Gameplay.m
//  ychacksproject
//
//  Created by Kevin Li on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"

#import "TLHMViewController.h"

#import <MyoKit/MyoKit.h>


#import "Rock.h"
#import "Paper.h"
#import "Scissors.h"

#import "Heart.h"

#import "Recap.h"

@interface Gameplay ()

@property (strong, nonatomic) TLMPose *currentPose;

@end



@implementation Gameplay {
    CCNode *_timer;
    float _timeCount;
    
    CCSprite *_picture;
    
    CCLabelTTF *_scoreLabel;
    
    Rock *_rock;
    Paper *_paper;
    Scissors *_scissors;
    
    BOOL _previousRock;
    BOOL _previousPaper;
    BOOL _previousScissors;
    
    CCLayoutBox *_livesBox;
    
    Heart *_heart1;
    Heart *_heart2;
    Heart *_heart3;
}

// -----------------------------------------------------------------------
#pragma mark - Setup Game
// -----------------------------------------------------------------------

- (void) didLoadFromCCB {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePoseChange:)
                                                 name:TLMMyoDidReceivePoseChangedNotification
                                               object:nil];
    
    
    _rock = (Rock*)[CCBReader load:@"Rock"];
    _paper = (Paper*)[CCBReader load:@"Paper"];
    _scissors = (Scissors*)[CCBReader load:@"Scissors"];
    
    _rock.positionInPoints = ccp(160, 284);
    _paper.positionInPoints = ccp(160, 284);
    _scissors.positionInPoints = ccp(160, 284);
    
    _score = 0;
    
    _timeCount = 0.5;
    _timer.scaleX = _timeCount;
    [self schedule:@selector(timerUpdate) interval:1];
    
    [self changePicture];
}

// -----------------------------------------------------------------------
#pragma mark - Receive Interaction from Myo
// -----------------------------------------------------------------------

- (void)didReceivePoseChange:(NSNotification *)notification {
    // Retrieve the pose from the NSNotification's userInfo with the kTLMKeyPose key.
    TLMPose *pose = notification.userInfo[kTLMKeyPose];
    self.currentPose = pose;
    
    // Handle the cases of the TLMPoseType enumeration, and change the color of helloLabel based on the pose we receive.
    switch (pose.type) {
        case TLMPoseTypeNone:
            break;
        case TLMPoseTypeFist:
            [self rockSelected];
            break;
        case TLMPoseTypeWaveIn:
            [self scissorsSelected];
            break;
        case TLMPoseTypeWaveOut:
            break;
        case TLMPoseTypeFingersSpread:
            [self paperSelected];
            break;
        case TLMPoseTypeTwistIn:
            break;
    }
}

// -----------------------------------------------------------------------
#pragma mark - Core Gameplay
// -----------------------------------------------------------------------

- (void) changePicture {
    NSInteger randomInt;
    
    if (_previousRock) {
        randomInt = (arc4random() % 2) + 1;
    } else if (_previousPaper) {
        randomInt = (arc4random() % 2);
        if (randomInt == 1) {
            randomInt++;
        }
    } else if (_previousScissors) {
        randomInt = arc4random() % 2;
    } else {
        randomInt = arc4random() % 3;
    }
    
    if ([[self children] containsObject:_rock]) {
        [self removeChild:_rock];
    }
    if ([[self children] containsObject:_paper]) {
        [self removeChild:_paper];
    }
    if ([[self children] containsObject:_scissors]) {
        [self removeChild:_scissors];
    }
    
    
    switch (randomInt) {
        case 0:
            [self addChild:_rock z:1];
            _previousRock = true;
            _previousPaper = false;
            _previousScissors = false;
            break;
            
        case 1:
            [self addChild:_paper z:1];
            _previousPaper = true;
            _previousRock = false;
            _previousScissors = false;
            break;
            
        case 2:
            [self addChild:_scissors z:1];
            _previousScissors = true;
            _previousRock = false;
            _previousPaper = false;
            break;
            
        default:
            break;
    }
}

// -----------------------------------------------------------------------
#pragma mark - Buttons/Myo Interaction
// -----------------------------------------------------------------------

- (void) rockSelected {
    if ([[self children] containsObject:_scissors]) {
        [self subtractLives];
    } else if ([[self children] containsObject:_paper]) {
        [self gotCorrect];
    }
}

- (void) paperSelected {
    if ([[self children] containsObject:_rock]) {
        [self subtractLives];
    } else if ([[self children] containsObject:_scissors]) {
        [self gotCorrect];
    }
}

- (void) scissorsSelected {
    if ([[self children] containsObject:_paper]) {
        [self subtractLives];
    } else if ([[self children] containsObject:_rock]) {
        [self gotCorrect];
    }
}

// -----------------------------------------------------------------------
#pragma mark - Gameplay Mechanics
// -----------------------------------------------------------------------

- (void) timerUpdate {
    _timeCount -= 0.1;
    _timer.scaleX = _timeCount;
    if (_timeCount < 0.01) {
        [self gameOver];
    }
}

- (void) gameOver {
    CCScene *scene = [CCBReader loadAsScene:@"Recap"];
    //        CCTransition *transition = [CCTransition transitionFadeWithDuration:1.0f];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    NSUserDefaults *_highscoreDefaults = [NSUserDefaults standardUserDefaults];
    if (_score > [_highscoreDefaults integerForKey:@"highscore"]) {
        [_highscoreDefaults setInteger:_score forKey:@"highscore"];
    }
    
    Recap *recapScreen = (Recap *)scene.children[0];
    recapScreen.positionType = CCPositionTypeNormalized;
    recapScreen.position = ccp(0, 0);
    [[CCDirector sharedDirector] replaceScene:scene];
    recapScreen.finalScoreLabel.string = [NSString stringWithFormat:@"%d", _score];
    recapScreen.highScoreLabel.string = [NSString stringWithFormat:@"%d", [_highscoreDefaults integerForKey:@"highscore"]];
}

- (void) subtractLives {
    if ([[_livesBox children] containsObject:_heart3]) {
        [_livesBox removeChild:_heart3];
    } else if ([[_livesBox children] containsObject:_heart2]) {
        [_livesBox removeChild:_heart2];
    } else if ([[_livesBox children] containsObject:_heart1]) {
        [self gameOver];
    }
}

- (void) gotCorrect {
    _score++;
    _timeCount += 0.15;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _score];
    
    [self changePicture];
}

@end
