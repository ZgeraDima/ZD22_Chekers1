//
//  ViewController.m
//  DZ 22 - Obj_Skut_Touch
//
//  Created by mac on 11.11.17.
//  Copyright © 2017 Dima Zgera. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) UIView* draggingChecker;
@property (assign, nonatomic) CGPoint touchOffset;
@property (assign, nonatomic) CGPoint startPosition;
@property (assign, nonatomic) CGFloat scaleCheckers;
@property (strong, nonatomic) NSMutableArray* possibleCells;

@end

@implementation ViewController

# pragma mark - Loading

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scaleCheckers = 1.8f;
    self.possibleCells = [NSMutableArray array];
    
    [self alignBoard:self.cellsLayer onMainView:self.mainView];
    [self alignBoard:self.checkersLayer onMainView:self.mainView];
    [self setScale:self.scaleCheckers toCheckers:self.checkers];
    [self alignCheckers:self.checkers toCellsLayer:self.cellsLayer];
}

- (void) alignBoard:(UIView*) board onMainView: (UIView*) mainView {
    CGFloat minDim = MIN(mainView.bounds.size.height, mainView.bounds.size.width);
    [board setFrame:CGRectMake(0, 0, minDim, minDim)];
    board.center = mainView.center;
}

- (void) setScale:(CGFloat)scale  toCheckers:(NSArray*) checkers {
    for (UIView* checker in checkers) {
        checker.transform = CGAffineTransformMakeScale(scale, scale);
        checker.layer.cornerRadius = MIN(CGRectGetWidth(checker.bounds), CGRectGetHeight(checker.bounds))/2;
    }
}

- (void) alignCheckers:(NSArray*) checkers toCellsLayer: (UIView*) cellsLayer {
    for (UIView* checker in checkers) {
        UIView* cell = [self cellByPoint:checker.center];
        if (cell != nil){
            checker.center = cell.center;
        }
    }
}

- (UIInterfaceOrientationMask)  supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

# pragma mark - Touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint pointOnCheckersLayer = [touch locationInView:self.checkersLayer];
    UIView* checker = [self.checkersLayer hitTest:pointOnCheckersLayer withEvent:event];
    
    if (![checker isEqual:self.checkersLayer]) {
        self.draggingChecker = checker;
        self.startPosition = checker.center;
        [self.checkersLayer bringSubviewToFront:checker];
        
        CGPoint touchPoint = [touch locationInView:checker];
        self.touchOffset = CGPointMake(CGRectGetMidX(checker.bounds) - touchPoint.x, CGRectGetMidY(checker.bounds) - touchPoint.y);
        [self.draggingChecker.layer removeAllAnimations];
        
        [self findPossibleMovesForPoint:self.startPosition secondCalling:NO];
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             CGFloat scale = self.scaleCheckers * 1.2;
                             checker.transform = CGAffineTransformMakeScale(scale, scale);
                             checker.alpha = 0.9;
                         }];
        
        [UIView animateWithDuration:1.0
                              delay:0
                            options: UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                         animations:^{
                             [self setColorToPossibleMoves:[UIColor grayColor]];
                         }
                         completion:nil ];
        
    } else {
        self.draggingChecker = nil;
        self.touchOffset = CGPointMake(0, 0);
    }
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.draggingChecker != nil) {
        UITouch* touch = [touches anyObject];
        CGPoint pointOnCheckersLayer = [touch locationInView:self.checkersLayer];
        CGPoint correction = CGPointMake(pointOnCheckersLayer.x + self.touchOffset.x,
                                         pointOnCheckersLayer.y + self.touchOffset.y);
        self.draggingChecker.center = correction;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self onTouchesEnded:touches];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self onTouchesEnded:touches];
}

- (void) onTouchesEnded:(NSSet<UITouch *> *)touches {
    
    UITouch* touch = [touches anyObject];
    CGPoint pointOnCellsLayer = [touch locationInView:self.cellsLayer];
    CGPoint endPosition = [self blackCellCenterNearCGPoint:pointOnCellsLayer];
    CGPoint newPosition = [self endPositionIsLegal:endPosition] ? endPosition : self.startPosition;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGFloat scale = self.scaleCheckers;
                         self.draggingChecker.transform = CGAffineTransformMakeScale(scale, scale);
                         self.draggingChecker.alpha = 1.0;
                         self.draggingChecker.center = newPosition;
                     }];
    
    [self.cellsLayer.layer removeAllAnimations];
    [self setColorToPossibleMoves:[UIColor blackColor]];
    [self.possibleCells removeAllObjects];
    self.draggingChecker = nil;
    self.touchOffset = CGPointMake(0, 0);
    self.startPosition = CGPointMake(0, 0);
}

# pragma mark - Calculation

- (CGPoint) blackCellCenterNearCGPoint:(CGPoint) currentPoint {
    
    CGFloat minDistance = MAX(CGRectGetHeight(self.view.bounds), CGRectGetHeight(self.view.bounds));
    __weak UIView* nearestblackCell;
    
    for (UIView* blackCell in self.blackCells) {
        
        CGFloat distance = sqrt(pow(blackCell.center.x - currentPoint.x, 2) + pow(blackCell.center.y - currentPoint.y, 2));
        
        if (distance < minDistance) {
            minDistance = distance;
            nearestblackCell = blackCell;
        }
    }
    
    return nearestblackCell.center;
}

- (Boolean) blackCellIsClearByPoint:(CGPoint) point {
    return [self checkerByPoint:point] == nil;
}

- (UIView*) checkerByPoint:(CGPoint) point {
    
    [self.checkersLayer sendSubviewToBack:self.draggingChecker];
    
    UIView* checker = [self.checkersLayer hitTest:point withEvent:nil];
    UIView* resultChecker = checker;
    
    if ([checker isEqual:self.checkersLayer] || [checker isEqual:self.draggingChecker]) {
        resultChecker = nil;
    }
    
    [self.checkersLayer bringSubviewToFront:self.draggingChecker];
    return resultChecker;
    
}

- (Boolean) checkerIsWhite:(UIView*) checker {
    return (checker.tag == 1);
}

- (Boolean) checkerIsBlack:(UIView*) checker {
    return (checker.tag == 0);
}

- (void) findPossibleMovesForPoint:(CGPoint) point secondCalling:(Boolean) secondCalling{
    
    CGFloat deltaX = CGRectGetWidth([self cellByPoint:point].frame);
    CGFloat deltaY = CGRectGetHeight([self cellByPoint:point].frame);
    
    CGFloat sign = [self checkerIsWhite:self.draggingChecker] ? 1 : -1;
    CGPoint leftPoint = CGPointMake(point.x - deltaX * sign, point.y - deltaY * sign);
    CGPoint rightPoint = CGPointMake(point.x + deltaX * sign, point.y - deltaY * sign);
    CGPoint nextLeftPoint = CGPointMake(point.x - 2 * deltaX * sign, point.y - 2 * deltaY * sign);
    CGPoint nextRightPoint = CGPointMake(point.x + 2 * deltaX * sign, point.y - 2 * deltaY * sign);
    
    [self checkCellByPoint:leftPoint andNextPoint:nextLeftPoint secondCalling:secondCalling];
    [self checkCellByPoint:rightPoint andNextPoint:nextRightPoint secondCalling:secondCalling];
}

- (void) checkCellByPoint:(CGPoint) point andNextPoint:(CGPoint) nextPoint secondCalling:(Boolean) secondCalling{
    
    if ([self cellByPoint:point] == nil) {
        
    } else if ([self blackCellIsClearByPoint:point] && !secondCalling) {
        
        [self.possibleCells addObject:[self cellByPoint:point]];
        
    } else if ((![self blackCellIsClearByPoint:point]) &&
               ([self checkerByPoint:point].tag != self.draggingChecker.tag) &&
               ([self cellByPoint:nextPoint] != nil) &&
               ([self blackCellIsClearByPoint:nextPoint]) ){
        
        [self.possibleCells addObject:[self cellByPoint:nextPoint]];
        
        [self findPossibleMovesForPoint:nextPoint secondCalling:YES];
    }
}

- (UIView*) cellByPoint:(CGPoint) point {
    UIView* cell = [self.cellsLayer hitTest:point withEvent:nil];
    return [cell isEqual:self.cellsLayer] ? nil : cell;
}

- (void) setColorToPossibleMoves:(UIColor*) color {
    for (UIView* cell in self.possibleCells) {
        cell.backgroundColor = color;
    }
}

- (Boolean) endPositionIsLegal:(CGPoint) endPosition {
    UIView* endCell = [self cellByPoint: endPosition];
    Boolean result = NO;
    for (UIView* cell in self.possibleCells) {
        if ([endCell isEqual:cell]) {
            result = YES;
        }
    }
    return result;
}

@end
