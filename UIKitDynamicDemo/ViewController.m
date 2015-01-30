//
//  ViewController.m
//  UKDDemo3
//
//  Created by Sebastiao Gazolla Costa Junior on 25/01/15.
//  Copyright (c) 2015 Sebastiao Gazolla Costa Junior. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()
@property (nonatomic, strong) UIView *square;
@property (nonatomic, strong) UIView *block;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, strong) UICollisionBehavior *collision;
@property (nonatomic, strong) UIDynamicItemBehavior *blockBehavior;

@property (nonatomic, strong) NSOperationQueue *motionQueue;
@property (nonatomic, strong) CMMotionManager *motionManager;
@end

@implementation ViewController

/*
 * Cria um objeto da classe UIView, pinta de azul e adiciona na view deste ViewController
 */
-(UIView *) square{
    if (!_square) {
        _square = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 40, 40)];
        [_square setBackgroundColor:[UIColor blueColor]];
        [self.view addSubview:_square];
    }
    return _square;
}

/*
 * Cria um objeto da classe UIView, pinta de cinza. Esta será nossa View com a densidade grande.
 */
-(UIView *) block{
    if (!_block) {
        _block = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 150, 150)];
        [_block setBackgroundColor:[UIColor grayColor]];
        [self.view addSubview:_block];
    }
    return _block;
}

/*
 * Instancia um objeto UIDymanicAnimator e define a view de referência
 * como a View  deste UIViewController
 */
-(UIDynamicAnimator *)animator{
    if (!_animator) {
        _animator= [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    }
    return _animator;
}

/*
 * Instancia um comportamento de gravidade
 */
-(UIGravityBehavior *)gravity{
    if (!_gravity) {
        _gravity= UIGravityBehavior.alloc.init;
        [self.animator addBehavior:_gravity];
    }
    return _gravity;
}

/*
 * Instancia um comportamento configurável e defini a
 * densidade (teoricamente quantidade de massa por unidade de volume) com 1000 unidade
 * o padrão (default) é 1 unidade.
 */
-(UIDynamicItemBehavior *) blockBehavior{
    if (!_blockBehavior) {
        _blockBehavior= UIDynamicItemBehavior.alloc.init;
        _blockBehavior.density = 1000;
        [self.animator addBehavior:_blockBehavior];
    }
    return _blockBehavior;
}

/*
 * Instancia um comportamento de colisão e define
 * as bordas da view do controlador como barreiras.
 */
-(UICollisionBehavior *)collision{
    if (!_collision) {
        _collision = UICollisionBehavior.alloc.init;
        _collision.translatesReferenceBoundsIntoBoundary = YES;
        [self.animator addBehavior:_collision];
    }
    return _collision;
}

/*
 * Instancia um objeto de NSOperationQueue.
 */
-(NSOperationQueue *)motionQueue{
    if (!_motionQueue) {
        _motionQueue = NSOperationQueue.alloc.init;
    }
    return _motionQueue;
}

/*
 * Instancia um objeto de CMMotionManager.
 */
-(CMMotionManager *)motionManager{
    if (!_motionManager) {
        _motionManager = CMMotionManager.alloc.init;
    }
    return _motionManager;
}


/*
 * Inicia todos os objetos pela chamada do 'addItem' dos comportamentos de gravidade e colisão.
 * Depois inicia a captura dos movimentos do iPhone numa operation queue  (motionQueue)
 * e usando um bloco para manipular os dados.
 */
- (void)startGravity {
    
    [self.collision addItem:self.block];
    [self.blockBehavior addItem:self.block]; // <== comente esse para ver um evento bem interessante.
    //   [self.gravity addItem:self.block];  <== Para ver o pequeno bloco azul ser esmagado pelo cinza descomente essa linha
    
    [self.gravity addItem:self.square];
    [self.collision addItem:self.square];
    
    [self.motionManager startDeviceMotionUpdatesToQueue:self.motionQueue withHandler:^(CMDeviceMotion *motion, NSError *error) {
        // captura os movimentos gerados pelo acelerômetro.
        CMAcceleration gravity = motion.gravity;
        // Cria um bloco assincrono para atualizar a thread principal (que manipula a interface gráfica)
        dispatch_async(dispatch_get_main_queue(), ^{
            //Atualiza o nosso comportamento de gravidade a partir dos dados gerados pelo acelerômetro.
            self.gravity.gravityDirection = CGVectorMake(gravity.x, -gravity.y);
        });
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startGravity];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
