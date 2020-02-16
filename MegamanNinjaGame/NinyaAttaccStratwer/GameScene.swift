/// Copyright (c) 2018 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SpriteKit


struct PhysicsCategory {
  static let none      : UInt32 = 0
  static let all       : UInt32 = UInt32.max
  static let monster   : UInt32 = 0b1       // 1
  static let projectile: UInt32 = 0b10      // 2
  static let ally      : UInt32 = 0b11      // 3
}


func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
  func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
  }
#endif

extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
}


class GameScene: SKScene {
  // 1
  let player = SKSpriteNode(imageNamed: "Megaman")
  var monstersDestroyed = 0
  var monstersSpawned = 0;
    
  override func didMove(to view: SKView) {
    // 2
    backgroundColor = SKColor.white
    // 3
    player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
    // 4
    addChild(player)
    
    physicsWorld.gravity = .zero
    physicsWorld.contactDelegate = self
    
    run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.run(addMonster),
        SKAction.wait(forDuration: 0.8)
        ])
    ))
    
    let backgroundMusic = SKAudioNode(fileNamed: "11 Dr. Wily's Castle.mp3")
    backgroundMusic.autoplayLooped = true
    addChild(backgroundMusic)
  }
  
  
  
  
  func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
  }

  func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
  }

  func addMonster() {
    
    if(monstersSpawned < 30){
      
      let ran = random(min: 0.0, max: 8.0);
      
      if(ran < 7.0){
      
        monstersSpawned+=1;
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "SniperJoe")
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        // Add the monster to the scene
        addChild(monster)
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(5.0), max: CGFloat(6.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY),
                                       duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.run() { [weak self] in
          guard let `self` = self else { return }
          self.run(SKAction.playSoundFileNamed("08 - MegamanDefeat.wav", waitForCompletion: false))
          let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
          let gameOverScene = GameOverScene(size: self.size, won: false)
          self.view?.presentScene(gameOverScene, transition: reveal)
        }
        monster.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        
      }else{
        // Create sprite
        let ally = SKSpriteNode(imageNamed: "Protoman")
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: ally.size.height/2, max: size.height - ally.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        ally.position = CGPoint(x: size.width + ally.size.width/2, y: actualY)
        
        // Add the monster to the scene
        addChild(ally)
        
        ally.physicsBody = SKPhysicsBody(rectangleOf: ally.size) // 1
        ally.physicsBody?.isDynamic = true // 2
        ally.physicsBody?.categoryBitMask = PhysicsCategory.ally // 3
        ally.physicsBody?.contactTestBitMask = PhysicsCategory.projectile // 4
        ally.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(5.0), max: CGFloat(6.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: -ally.size.width/2, y: actualY),
                                       duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        ally.run(SKAction.sequence([actionMove, actionMoveDone]))
      }
    }
  }
  
  
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    // 1 - Choose one of the touches to work with
    guard let touch = touches.first else {
      run(SKAction.playSoundFileNamed("05 - MegaBuster.wav", waitForCompletion: false))
      return
    }
    let touchLocation = touch.location(in: self)
    
    // 2 - Set up initial location of projectile
    let projectile = SKSpriteNode(imageNamed: "projectile")
    projectile.position = player.position
    
    
    projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
    projectile.physicsBody?.isDynamic = true
    projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
    projectile.physicsBody?.contactTestBitMask = PhysicsCategory.monster
    projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
    projectile.physicsBody?.usesPreciseCollisionDetection = true
    
    
    // 3 - Determine offset of location to projectile
    let offset = touchLocation - projectile.position
    
    // 4 - Bail out if you are shooting down or backwards
    if offset.x < 0 { return }
    
    // 5 - OK to add now - you've double checked position
    addChild(projectile)
    
    // 6 - Get the direction of where to shoot
    let direction = offset.normalized()
    
    // 7 - Make it shoot far enough to be guaranteed off screen
    let shootAmount = direction * 1000
    
    // 8 - Add the shoot amount to the current position
    let realDest = shootAmount + projectile.position
    
    // 9 - Create the actions
    let actionMove = SKAction.move(to: realDest, duration: 1.0)
    let actionMoveDone = SKAction.removeFromParent()
    projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
  }
  
  func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
    print("Sniper Joe Hit")
    run(SKAction.playSoundFileNamed("09 - EnemyDamage.wav", waitForCompletion: false))
    projectile.removeFromParent()
    monster.removeFromParent()
    
    monstersDestroyed += 1
    if monstersDestroyed == 30 {
      run(SKAction.playSoundFileNamed("Victory.mp3", waitForCompletion: false))
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      let gameOverScene = GameOverScene(size: self.size, won: true)
      view?.presentScene(gameOverScene, transition: reveal)
    }
  }
  
  func projectileDidCollideWithAlly(projectile: SKSpriteNode, ally: SKSpriteNode) {
    print("Protoman Hit")
    run(SKAction.playSoundFileNamed("08 - MegamanDefeat.wav", waitForCompletion: false))
    projectile.removeFromParent()
    ally.removeFromParent()
    
    let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
    let gameOverScene = GameOverScene(size: self.size, won: false)
    view?.presentScene(gameOverScene, transition: reveal)
  }
  
}

extension GameScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {
    // 1
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
   
    // 2
    if ((firstBody.categoryBitMask & PhysicsCategory.monster != 0) &&
        (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
      if let monster = firstBody.node as? SKSpriteNode,
        let projectile = secondBody.node as? SKSpriteNode {
        projectileDidCollideWithMonster(projectile: projectile, monster: monster)
      }
      //3
    }else if ((firstBody.categoryBitMask & PhysicsCategory.ally != 0) &&
        (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
      if let ally = firstBody.node as? SKSpriteNode,
        let projectile = secondBody.node as? SKSpriteNode {
        projectileDidCollideWithAlly(projectile: projectile, ally: ally)
      }
    }
  }
}
