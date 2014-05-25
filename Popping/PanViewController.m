//
//  PanViewController.m
//  Popping
//
//  Created by André Schneider on 11.05.14.
//  Copyright (c) 2014 André Schneider. All rights reserved.
//

#import "PanViewController.h"
#import <POP/POP.h>
#import "UIColor+CustomColors.h"

@interface PanViewController()
- (void)addPanView;
- (void)touchDown:(UIControl *)sender;
- (void)touchUpInside:(UIControl *)sender;
- (void)handlePan:(UIPanGestureRecognizer *)recognizer;

- (void)scaleDownView:(UIView *)view;
- (void)scaleUpView:(UIView *)view;
@end

@implementation PanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self addPanView];
}

#pragma mark - Private Instance methods

- (void)addPanView
{
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handlePan:)];

    CGFloat width = CGRectGetWidth(self.view.bounds) - 20.f;
    CGFloat height = roundf(width*0.75f);
    UIControl *panView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    panView.center = self.view.center;
    panView.layer.cornerRadius = 5.f;
    panView.layer.masksToBounds = YES;
    panView.backgroundColor = [UIColor customGreenColor];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:panView.bounds];
    [imageView setImage:[UIImage imageNamed:@"boat.jpg"]];
    [panView addSubview:imageView];

    [panView addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [panView addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [panView addGestureRecognizer:recognizer];

    [self.view addSubview:panView];
    [self scaleDownView:panView];
}

- (void)touchDown:(UIControl *)sender {
    [sender.layer pop_removeAllAnimations];
}

- (void)touchUpInside:(UIControl *)sender {
    if (sender.layer.affineTransform.a == 1) {
        [self scaleDownView:sender];
        return;
    }
    [self scaleUpView:sender];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    [self scaleDownView:recognizer.view];
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];

    if(recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self.view];

        POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
        positionAnimation.velocity = [NSValue valueWithCGPoint:velocity];
        positionAnimation.dynamicsTension = 10.f;
        positionAnimation.dynamicsFriction = 1.0f;
        positionAnimation.springBounciness = 12.0f;
        [recognizer.view.layer pop_addAnimation:positionAnimation forKey:@"layerPositionAnimation"];
    }
}

-(void)scaleUpView:(UIView *)view
{
    POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    positionAnimation.toValue = [NSValue valueWithCGPoint:self.view.center];
    [view.layer pop_addAnimation:positionAnimation forKey:@"layerPositionAnimation"];

    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
    [view.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
}

- (void)scaleDownView:(UIView *)view
{
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(0.5, 0.5)];
    [view.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
}

@end
