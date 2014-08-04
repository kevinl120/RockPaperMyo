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
    
    CCSprite *_background;
    
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
    
    CCButton *_rockButton;
    CCButton *_paperButton;
    CCButton *_scissorsButton;
    
    CCSprite *_triangle;
    
    NSInteger _count;
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
    
    
    _rock.positionType = CCPositionTypeNormalized;
    _rock.position = ccp(0.5, 0.475);
    _paper.positionType = CCPositionTypeNormalized;
    _paper.position = ccp(0.5, 0.475);
    _scissors.positionType = CCPositionTypeNormalized;
    _scissors.position = ccp(0.5, 0.475);
    
    
    _score = 0;
    _count = -179;
    
    _timeCount = 1;
    _timer.scaleX = _timeCount/2;
    [self schedule:@selector(timerUpdate) interval:0.01];
    [self schedule:@selector(triangleUpdate) interval:0.05];
    
    [self changePicture];
}

// -----------------------------------------------------------------------q
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
    
    randomInt = (arc4random() % 3);
    
   // CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:0.2f];
    
    if ([[self children] containsObject:_rock]) {
        //[_rock runAction:fadeOut];
        [_rock removeFromParent];
    }
    if ([[self children] containsObject:_paper]) {
        //[_paper runAction:fadeOut];
        [_paper removeFromParent];
    }
    if ([[self children] containsObject:_scissors]) {
        //[_scissors runAction:fadeOut];
        [_scissors removeFromParent];
    }
    
    CCEffectBrightness *brightnessEffect = [CCEffectBrightness effectWithBrightness: sin(45)];
    
    
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
        [self gotWrong];
    } else if ([[self children] containsObject:_paper]) {
        [self gotCorrect];
    }
}

- (void) paperSelected {
    if ([[self children] containsObject:_rock]) {
        [self gotWrong];
    } else if ([[self children] containsObject:_scissors]) {
        [self gotCorrect];
    }
}

- (void) scissorsSelected {
    if ([[self children] containsObject:_paper]) {
        [self gotWrong];
    } else if ([[self children] containsObject:_rock]) {
        [self gotCorrect];
    }
}

// -----------------------------------------------------------------------
#pragma mark - Gameplay Mechanics
// -----------------------------------------------------------------------

- (void) timerUpdate {
    _timeCount -= 0.001;
    _timer.scaleX = _timeCount/2;
    if (_timeCount < 0.00001) {
        [self gameOver];
    }
}

-(void) triangleUpdate {
//    NSInteger randomInteger;
//    
//    randomInteger = (arc4random() % 358) - 179;

    CCEffectHue *hueEffect = [CCEffectHue effectWithHue:_count];
    _count += 10;
    if (_count >= 179) {
        _count = -179;
    }
    _triangle.effect = hueEffect;
}

- (void) gameOver {
    CCScene *scene = [CCBReader loadAsScene:@"Recap"];
    
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

- (void) gotWrong {
    
    CCActionBlink *blink = [CCActionBlink actionWithDuration:0.3f blinks:2];
    
    if ([[self children] containsObject:_rock]) {
        [_rock runAction:blink];
    }
    if ([[self children] containsObject:_paper]) {
        [_paper runAction:blink];
    }
    if ([[self children] containsObject:_scissors]) {
        [_scissors runAction:blink];
    }
    
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
    if (_timeCount < 1.9) {
        if (_score <= 20) {
            _timeCount += 0.1;
        } else if (_score > 20 && _score <= 40) {
            _timeCount += 0.09;
        } else if (_score > 40 && _score <= 60) {
            _timeCount += 0.08;
        } else if (_score > 60 && _score <= 80) {
            _timeCount += 0.07;
        } else if (_score > 80 && _score <= 100) {
            _timeCount += 0.06;
        } else if (_score > 100) {
            _timeCount += 0.05;
        }
        
    } else if (_timeCount > 1.9 && _timeCount < 2.0) {
        _timeCount = 2.0;
    }
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _score];
    
    [self changePicture];
}


//Hi :)


@end
