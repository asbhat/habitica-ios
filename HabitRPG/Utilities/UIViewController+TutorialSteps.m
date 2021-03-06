//
//  UIViewController+TutorialSteps.m
//  Habitica
//
//  Created by Phillip Thelen on 11/10/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "UIViewController+TutorialSteps.h"
#import "Amplitude.h"
#import "Habitica-Swift.h"

@implementation UIViewController (TutorialSteps)

@dynamic displayedTutorialStep;
@dynamic tutorialIdentifier;
@dynamic coachMarks;
@dynamic activeTutorialView;

- (void)displayTutorialStep {
    if (self.activeTutorialView) {
        if (self.activeTutorialView.hintView) {
            [self.activeTutorialView.hintView continueAnimating];
        }
        return;
    }
    if (self.tutorialIdentifier && !self.displayedTutorialStep) {
        if ([UserManager.shared shouldDisplayTutorialStepWithKey:self.tutorialIdentifier]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *defaultsKey =
                [NSString stringWithFormat:@"tutorial%@", self.tutorialIdentifier];
            NSDate *nextAppearance = [defaults valueForKey:defaultsKey];
            if (!([nextAppearance compare:[NSDate date]] == NSOrderedDescending)) {
                self.displayedTutorialStep = YES;
                [self displayExlanationView:self.tutorialIdentifier
                           highlightingArea:CGRectZero
                               withDefaults:defaults
                              inDefaultsKey:defaultsKey
                           withTutorialType:@"common"];
            }
        }
    }

    if (self.coachMarks && !self.displayedTutorialStep) {
        for (NSString *coachMark in self.coachMarks) {
            if ([UserManager.shared shouldDisplayTutorialStepWithKey:self.tutorialIdentifier]) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *defaultsKey = [NSString stringWithFormat:@"tutorial%@", coachMark];
                NSDate *nextAppearance = [defaults valueForKey:defaultsKey];
                if ([nextAppearance compare:[NSDate date]] == NSOrderedDescending) {
                    continue;
                }
                if ([self respondsToSelector:@selector(getFrameForCoachmark:)]) {
                    CGRect frame = [self getFrameForCoachmark:coachMark];
                    if (!CGRectEqualToRect(frame, CGRectZero)) {
                        self.displayedTutorialStep = YES;
                        [self displayExlanationView:coachMark
                                   highlightingArea:frame
                                       withDefaults:defaults
                                      inDefaultsKey:defaultsKey
                                   withTutorialType:@"ios"];
                    }
                }
                break;
            }
        }
    }
}

- (void)displayExlanationView:(NSString *)identifier
             highlightingArea:(CGRect)frame
                 withDefaults:(NSUserDefaults *)defaults
                inDefaultsKey:(NSString *)defaultsKey
             withTutorialType:(NSString *)type {

    NSDictionary *tutorialDefinition = [self getDefinitonForTutorial:identifier];
    TutorialStepView *tutorialStepView = [[TutorialStepView alloc] init];
    self.activeTutorialView = tutorialStepView;
    if (tutorialDefinition[@"textList"]) {
        [tutorialStepView setTextsWithList:tutorialDefinition[@"textList"]];
    } else {
        [tutorialStepView setText:tutorialDefinition[@"text"]];
    }
    if (!CGRectIsEmpty(frame)) {
        tutorialStepView.highlightedFrame = frame;
        [tutorialStepView displayHintOnView:self.parentViewController.view displayView:self.parentViewController.parentViewController.view animated:YES];
    } else {
        [tutorialStepView displayOnView:self.parentViewController.parentViewController.view animated:YES];
    }

    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    [eventProperties setValue:@"tutorial" forKey:@"eventAction"];
    [eventProperties setValue:@"behaviour" forKey:@"eventCategory"];
    [eventProperties setValue:@"event" forKey:@"event"];
    [eventProperties setValue:[identifier stringByAppendingString:@"-iOS"]
                       forKey:@"eventLabel"];
    [eventProperties setValue:identifier forKey:@"eventValue"];
    [eventProperties setValue:@NO forKey:@"complete"];
    [[Amplitude instance] logEvent:@"tutorial" withEventProperties:eventProperties];

    tutorialStepView.dismissAction = ^() {
        self.activeTutorialView = nil;
        
        NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
        [eventProperties setValue:@"tutorial" forKey:@"eventAction"];
        [eventProperties setValue:@"behaviour" forKey:@"eventCategory"];
        [eventProperties setValue:@"event" forKey:@"event"];
        [eventProperties setValue:[identifier stringByAppendingString:@"-iOS"]
                           forKey:@"eventLabel"];
        [eventProperties setValue:identifier forKey:@"eventValue"];
        [eventProperties setValue:@YES forKey:@"complete"];
        [[Amplitude instance] logEvent:@"tutorial" withEventProperties:eventProperties];
        [UserManager.shared markTutorialAsSeenWithType:type key:identifier];
    };
}

- (void)removeActiveView {
    if (self.activeTutorialView) {
        [self.activeTutorialView removeFromSuperview];
        self.activeTutorialView = nil;
    }
}

@end
