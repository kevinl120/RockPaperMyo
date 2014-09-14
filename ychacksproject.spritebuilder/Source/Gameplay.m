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
    // The timer and the time
    CCNode *_timer;
    float _timeCount;
    
    // The background image
    CCSprite *_background;
    
    // The label for the score
    CCLabelTTF *_scoreLabel;
    
    // The three images: Rock, Paper, and Scissors
    Rock *_rock;
    Paper *_paper;
    Scissors *_scissors;
    
    // If the previous image was rock, paper, or scissors
    BOOL _previousRock;
    BOOL _previousPaper;
    BOOL _previousScissors;
    
    // The layout box for the lives
    CCLayoutBox *_livesBox;
    
    // The three lives (images)
    Heart *_heart1;
    Heart *_heart2;
    Heart *_heart3;
    
    // The buttons for rock, paper, and scissors
    CCButton *_rockButton;
    CCButton *_paperButton;
    CCButton *_scissorsButton;
    
    // The triangle in the background
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
    
    // Load the three images/ccb-s: Rock, Paper, and Scissors
    _rock = (Rock*)[CCBReader load:@"Rock"];
    _paper = (Paper*)[CCBReader load:@"Paper"];
    _scissors = (Scissors*)[CCBReader load:@"Scissors"];
    
    // Set the position of the three images
    _rock.positionType = CCPositionTypeNormalized;
    _rock.position = ccp(0.5, 0.475);
    _paper.positionType = CCPositionTypeNormalized;
    _paper.position = ccp(0.5, 0.475);
    _scissors.positionType = CCPositionTypeNormalized;
    _scissors.position = ccp(0.5, 0.475);
    
    // Set the score to 0
    _score = 0;
    
    // Set the hue
    _count = -179;
    
    // Set the triangle to be behind everything
    [self removeChild:_triangle];
    [self addChild:_triangle z:-1];
    
    // Set the time left to 10 seconds
    _timeCount = 1;
    // Set the scale of the time bar according to the time left
    _timer.scaleX = _timeCount/2;
    
    // Update the time
    [self schedule:@selector(timerUpdate) interval:0.01];
    // Update the hue of the triangle in the background
    [self schedule:@selector(updateTriangleHue) interval:0.05];
    
    // Set the first picture
    [self changePicture];
}

// -----------------------------------------------------------------------q
#pragma mark - Receive Interaction from Myo
// -----------------------------------------------------------------------

- (void)didReceivePoseChange:(NSNotification *)notification {
    // Retrieve the pose from the NSNotification's userInfo with the kTLMKeyPose key.
    TLMPose *pose = notification.userInfo[kTLMKeyPose];
    self.currentPose = pose;
    
    // Handle the cases of the TLMPoseType enumeration, and change the input based on the pose we receive.
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
    // A random integer to find the next icon
    NSInteger randomInt = (arc4random() % 3);
    
    // Remove the icon that is currently shown
    if ([[self children] containsObject:_rock]) {
        [_rock removeFromParent];
    }
    if ([[self children] containsObject:_paper]) {
        [_paper removeFromParent];
    }
    if ([[self children] containsObject:_scissors]) {
        [_scissors removeFromParent];
    }
    
    // Add the icon based on the random number
    switch (randomInt) {
        case 0:
            [self addChild:_rock z:1];
            break;
            
        case 1:
            [self addChild:_paper z:1];
            break;
            
        case 2:
            [self addChild:_scissors z:1];
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
    // Subtract 0.1 seconds from the time
    _timeCount -= 0.001;
    // Set the scale of the time bar based on the time
    _timer.scaleX = _timeCount/2;
    
    // Game over if time is less than 0
    if (_timeCount < 0.00001) {
        [self gameOver];
    }
}

-(void) updateTriangleHue {
    // Declare the hue
    CCEffectHue *hueEffect = [CCEffectHue effectWithHue:_count];
    
    // Add 10 to the hue
    _count += 10;
    
    // Set the hue back to the lowest if it exceeds the highest
    if (_count >= 179) {
        _count = -179;
    }
    // Set the hue of the background triangle
    _triangle.effect = hueEffect;
}

- (void) gotWrong {
    // Remove a life if there is more than 1 life, otherwise game is over
    if ([[_livesBox children] containsObject:_heart3]) {
        [_livesBox removeChild:_heart3];
    } else if ([[_livesBox children] containsObject:_heart2]) {
        [_livesBox removeChild:_heart2];
    } else if ([[_livesBox children] containsObject:_heart1]) {
        [self gameOver];
    }
    
    // Blink
    CCActionBlink *blink = [CCActionBlink actionWithDuration:0.3f blinks:2];
    
    // Blink the icon
    if ([[self children] containsObject:_rock]) {
        [_rock runAction:blink];
    }
    if ([[self children] containsObject:_paper]) {
        [_paper runAction:blink];
    }
    if ([[self children] containsObject:_scissors]) {
        [_scissors runAction:blink];
    }
}

- (void) gotCorrect {
    // Increase the score
    _score++;
    
    // Add a different amount of time based on how far the user is into the game
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
    
    // Set the score label
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _score];
    
    // Change the picture
    [self changePicture];
}

- (void) gameOver {
    // Recap screen
    CCScene *scene = [CCBReader loadAsScene:@"Recap"];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    // Set the high score
    NSUserDefaults *_highscoreDefaults = [NSUserDefaults standardUserDefaults];
    if (_score > [_highscoreDefaults integerForKey:@"highscore"]) {
        [_highscoreDefaults setInteger:_score forKey:@"highscore"];
    }
    
    // Load the recap screen with the score and highscore
    Recap *recapScreen = (Recap *)scene.children[0];
    recapScreen.positionType = CCPositionTypeNormalized;
    recapScreen.position = ccp(0, 0);
    [[CCDirector sharedDirector] replaceScene:scene];
    recapScreen.finalScoreLabel.string = [NSString stringWithFormat:@"%d", _score];
    recapScreen.highScoreLabel.string = [NSString stringWithFormat:@"%ld", (long)[_highscoreDefaults integerForKey:@"highscore"]];
}



@end
