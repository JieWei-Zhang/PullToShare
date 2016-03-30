//
//  ViewController.m
//  PullToShare
//
//  Created by Vinhome on 16/3/24.
//  Copyright © 2016年 Vinhome. All rights reserved.
//

#import "ViewController.h"
#import "Masonry/Masonry/Masonry.h"
#define  Screen  [UIScreen  mainScreen].bounds.size
#define circleSize 60
@interface ViewController ()
{
    UIView *view;
    
    
    CGPoint currentPoint;
    CGFloat leftOffset;
    CGFloat rightOffset;
    CGPoint leftPoint;
    CGPoint topPoint;
    CGPoint rightPoint;
    CGPoint bottomPoint;
    
    NSMutableArray * Icons;
    
    CGFloat  threshold ;
    
    
    CGFloat contentOffsetY;
    
    int iconSelectedIndex ;
    
    
    BOOL  isAnimating;
    
}
@property(nonatomic,strong)UIView *containerView;
@property(nonatomic,strong)CAShapeLayer *circleSelectionColor;

@property(nonatomic,strong)CAShapeLayer *circleLayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    leftOffset=0;
    
    threshold =30;
    
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
    view=[[UIView  alloc]initWithFrame:CGRectMake(0, 0,Screen.width ,300)];
    view.backgroundColor=[UIColor  yellowColor];
    
    view.layer.masksToBounds = true;
    [self.tableView  addSubview:view];
    
    Icons =[[NSMutableArray  alloc]init];
    
   // CGRectMake(((Screen.width-4*50)/5+50)*i+(Screen.width-4*50)/5, 75, 50, 50);
    CGFloat btnwidth=Screen.width/4;
    for (int i=0; i<4; i++) {
        UIButton *btn =[UIButton  buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(i*btnwidth, 300-60, btnwidth, 48);
        
        [btn setImage:[UIImage  imageNamed:[NSString  stringWithFormat:@"%d",i]] forState:UIControlStateNormal];
        [view addSubview:btn];
        
        [Icons addObject:btn];
        
        
    }
    
    self.tableView.alwaysBounceVertical = true;
    
    self.tableView.contentInset=UIEdgeInsetsMake(-300, 0, 0, 0);
    
    _circleLayer=[CAShapeLayer layer];
    _circleLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _circleLayer.frame = CGRectMake(0, 0, 60, 60);
    
    _circleLayer.path = [self circleCurrentPath].CGPath;
    _circleLayer.fillColor =[UIColor  redColor].CGColor;
    _circleLayer.zPosition = -1;
    [view.layer addSublayer:_circleLayer];
    
    
    
    
    
    
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//    [self.tableView setUserInteractionEnabled:YES];
//    [self.tableView addGestureRecognizer:pan];

}
- (void) handlePan: (UIPanGestureRecognizer *)gesture{
    NSLog(@"xxoo---xxoo---xxoo");
    
}
-(UIBezierPath*)circleCurrentPath
{
    
    leftPoint = CGPointMake( leftOffset, circleSize/2);
    rightPoint = CGPointMake(circleSize+rightOffset,  circleSize/2);
    //direction left right
    if (leftOffset>rightOffset){
        topPoint = CGPointMake( circleSize/2 + rightOffset, 0);
        bottomPoint = CGPointMake( circleSize/2 + rightOffset,  circleSize);
    }else{
        topPoint = CGPointMake( circleSize/2 + leftOffset,  0);
        bottomPoint = CGPointMake( circleSize/2 + leftOffset,  circleSize);
    }
    
    //control point
    CGFloat  controlPointLeft = topPoint.x - leftPoint.x;
    CGFloat controlPointRight = rightPoint.x - topPoint.x;
    
    UIBezierPath * path = [[UIBezierPath alloc]init];
    
    [path  moveToPoint:leftPoint];
    //top
    [path addCurveToPoint:topPoint controlPoint1:CGPointMake(leftPoint.x, leftPoint.y  - (controlPointLeft/2)) controlPoint2:CGPointMake(topPoint.x- (controlPointLeft/2), topPoint.y )];
    
   
    
    
    //right
    [path addCurveToPoint:rightPoint controlPoint1:CGPointMake(topPoint.x + (controlPointRight/2), topPoint.y ) controlPoint2:CGPointMake(rightPoint.x,  rightPoint.y - (controlPointRight/2))];
    
    //bottom
    [path addCurveToPoint:bottomPoint controlPoint1:CGPointMake(rightPoint.x ,  rightPoint.y + (controlPointRight/2) ) controlPoint2:CGPointMake(bottomPoint.x + (controlPointRight/2),  bottomPoint.y)];
    
    //left
    [path addCurveToPoint:leftPoint controlPoint1:CGPointMake(bottomPoint.x - (controlPointLeft/2) ,  bottomPoint.y ) controlPoint2:CGPointMake(leftPoint.x, leftPoint.y + (controlPointLeft/2))];
    
    [path  closePath];
    
    return path;
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    CGPoint location = [self.tableView.panGestureRecognizer  locationInView:self.tableView];
    CGPoint translation = [self.tableView.panGestureRecognizer  translationInView:self.tableView];
    
    CGFloat offsetY =[change[NSKeyValueChangeNewKey] CGPointValue].y+self.tableView.contentInset.top;
    
//    [view mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view.mas_top).offset(-(200+offsetY));
//        make.left.equalTo(self.view.mas_left);
//        make.right.equalTo(self.view.mas_right);
//        make.height.equalTo(@220);
//        
//    }];
    
    if (self.tableView.panGestureRecognizer.state == UIGestureRecognizerStateBegan || self.tableView.panGestureRecognizer.state==UIGestureRecognizerStateChanged) {
        
    
    if (offsetY<=-60) {
        
        CGFloat index =0;
        int  newIndex=-1;
        
        for (UIButton  *btn  in Icons) {

            if (CGRectContainsPoint(btn.frame, CGPointMake(location.x, btn.frame.origin.y))) {
                newIndex = index;
                
               // NSLog(@"===================");
            }
            index++;
           
        }
        
      
        if ( iconSelectedIndex ==-1 && newIndex !=-1) {
            
            UIButton * btn =Icons[newIndex];
            _circleLayer.position = CGPointMake( (btn.center.x), btn.center.y);
            iconSelectedIndex = newIndex;
            
           
        }
        
        [self  circleAppear];
        if (!isAnimating  &&  iconSelectedIndex != -1)  {
            
            leftOffset =MIN((translation.x+30)/2, 0);
            leftOffset = MAX(leftOffset, -threshold);
            
            rightOffset = MAX((translation.x-30)/2,0);
            rightOffset = MIN(rightOffset, threshold);
            
            _circleLayer.path = [self  circleCurrentPath].CGPath;
            
            UIButton * btn =Icons[iconSelectedIndex];
            _circleLayer.position = CGPointMake( (btn.center.x) + leftOffset/5 + rightOffset/5, _circleLayer.position.y);
            
        }
        
       // NSLog(@"___________%f______%f_________%f",rightOffset,threshold,leftOffset);
        
        if (!isAnimating  && (rightOffset>= threshold || leftOffset <= -threshold) ){
            
            
            
            if ( newIndex != iconSelectedIndex) {
                isAnimating=YES;
                
                [self.tableView.panGestureRecognizer  setTranslation:CGPointMake(0, translation.y) inView:self.view];
                
                iconSelectedIndex=newIndex;
                
                [self  animateToIndex];
                
            }
        }
        
    }
    else
    {
      CGPoint translation=  [self.tableView.panGestureRecognizer translationInView:self.tableView];
        [self.tableView.panGestureRecognizer setTranslation:CGPointMake(0, translation.y) inView:self.tableView];
        
        
        iconSelectedIndex = -1;
        _circleLayer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0);
        _circleLayer.opacity = 0.0;
        
        
    }

    }
    
    //NSLog(@"===============%ld",(long)self.tableView.panGestureRecognizer.state);
    if (self.tableView.panGestureRecognizer.state == UIGestureRecognizerStateEnded || self.tableView.panGestureRecognizer.state == UIGestureRecognizerStateCancelled||self.tableView.panGestureRecognizer.state == UIGestureRecognizerStatePossible) {

        if (offsetY<0) {
            
            CATransform3D transform = _circleLayer.transform;
            
            
            _circleLayer.transform = CATransform3DScale(transform, 10.0, 10.0, 0.0);
            
//            if (iconSelectedIndex != -1 && buttonSelectedCallback != nil)
//            {
//                
//                buttonSelectedCallback!( icons[iconSelectedIndex], WAPullToShareButtonType(rawValue: icons[iconSelectedIndex].tag)!)
//            }
            
        }else{
            iconSelectedIndex = -1;
            _circleLayer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0);
            _circleLayer.opacity = 0.0;
        }
    }
    
    
}

-(void)animateToIndex
{
    isAnimating = YES;
    rightOffset = 0;
    leftOffset = 0;
    UIButton * btn =Icons[iconSelectedIndex];
    
    CABasicAnimation * layerAnimation =[CABasicAnimation animationWithKeyPath:@"position"];
    
    layerAnimation.fromValue =[NSValue  valueWithCGPoint:_circleLayer.position];
    layerAnimation.toValue = [NSValue  valueWithCGPoint:btn.center];
    
    _circleLayer.position = CGPointMake(btn.center.x, btn.center.y);
    
    CABasicAnimation * pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    
    pathAnimation.fromValue = (__bridge id _Nullable)(_circleLayer.path);
    pathAnimation.toValue = (__bridge id _Nullable)([self circleCurrentPath].CGPath);
    _circleLayer.path = [self circleCurrentPath].CGPath;
    
    CAAnimationGroup * groupAnimation = [CAAnimationGroup animation];
    groupAnimation.duration = 0.3;
    groupAnimation.animations = @[layerAnimation, pathAnimation];
    groupAnimation.delegate = self;
    groupAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [_circleLayer addAnimation:groupAnimation forKey:@"selectedIndex"];
}
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    rightOffset=0;
    leftOffset=0;
    isAnimating=NO;
    CGPoint  translation = [self.tableView.panGestureRecognizer translationInView:self.tableView];
    [self.tableView.panGestureRecognizer setTranslation:CGPointMake(0, translation.y) inView:self.tableView];
    
}
-(void)circleAppear
{
    _circleLayer.transform = CATransform3DMakeScale(1.0, 1.0, 0.0);
    _circleLayer.opacity = 1.0;
}
-(void)circleDisappear
{
    _circleLayer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0);
    _circleLayer.opacity = 0.0;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
