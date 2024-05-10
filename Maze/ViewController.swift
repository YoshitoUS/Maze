//
//  ViewController.swift
//  Maze
//
//  Created by Yoshito Usui on 2024/05/09.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    var playerView: UIView!
    var playerMotionManager: CMMotionManager!
    var speedx: Double = 0.0
    var speedy: Double = 0.0
    
    let screenSize = UIScreen.main.bounds.size
    
    var wallRectArray = [CGRect]()
    
    let maze = [
        [1,0,0,0,1,0],
        [1,0,1,0,1,0],
        [3,0,0,0,1,0],
        [1,1,1,0,0,0],
        [1,0,0,1,0,0],
        [0,0,1,0,0,0],
        [0,1,1,0,1,0],
        [0,0,0,0,0,1],
        [0,1,1,0,0,0],
        [0,0,1,1,1,2],
    ]
    
    var startView: UIView!
    var goalView: UIView!
    
    func createView(x:Int, y:Int, width:CGFloat, height:CGFloat, offsetX:CGFloat, offsetY:CGFloat) -> UIView{
        let rect = CGRect(x:0, y:0, width: width, height: height)
        let view = UIView(frame: rect)
        
        let center = CGPoint(x: offsetX + width * CGFloat(x), y: offsetY + height * CGFloat(y))
        
        view.center = center
        
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellWidth = screenSize.width/CGFloat(maze[0].count)
        let cellHeight = screenSize.height/CGFloat(maze.count)
        
        let cellOffsetX = cellWidth/2
        let cellOffsetY = cellHeight/2
        
        view.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.94, alpha: 1.0)
        
        for y in 0..<maze.count{
            for x in 0 ..< maze[y].count{
                switch maze[y][x]{
                case 1:
                    let wallView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY:  cellOffsetY)
                    let wallImageView = UIImageView(image: UIImage(named: "wall2"))
                    wallImageView.frame = wallView.frame
                    view.addSubview(wallImageView)
                    wallRectArray.append(wallView.frame)
                case 2:
                    startView = createView(x:x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    startView.backgroundColor = UIColor.green
                    view.addSubview(startView)
                case 3:
                    goalView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    goalView.backgroundColor = UIColor.red
                    view.addSubview(goalView)
                default:
                    break
                }
            }
        }
        playerView = UIView(frame: CGRect(x: 0, y: 0, width: cellWidth/6, height: cellWidth/6))
        playerView.center = startView.center
        playerView.backgroundColor = UIColor.black
        view.addSubview(playerView)
        
        playerMotionManager = CMMotionManager()
        playerMotionManager.accelerometerUpdateInterval = 0.02
        
        startAccelerometer()
        
    }
    
    func startAccelerometer(){
        let handler: CMAccelerometerHandler = { (CMAccelerometerData: CMAccelerometerData?, error: Error?) -> Void in
            self.speedx += CMAccelerometerData!.acceleration.x
            self.speedy += CMAccelerometerData!.acceleration.y
            
            var posX = self.playerView.center.x + (CGFloat(self.speedx)/3)
            var posY = self.playerView.center.y + (CGFloat(self.speedy)/3)
            
            if posX <= self.playerView.frame.width / 2{
                self.speedx = 0
                posX = self.playerView.frame.width / 2
            }
            if posY <= self.playerView.frame.height / 2{
                self.speedy = 0
                posY = self.playerView.frame.height / 2
            }
            if posX >= self.screenSize.width - (self.playerView.frame.width/2){
                self.speedx = 0
                posX = self.screenSize.width - (self.playerView.frame.width/2)
            }
            if posY >= self.screenSize.height - (self.playerView.frame.height/2){
                self.speedy = 0
                posY = self.screenSize.height - (self.playerView.frame.height/2)
            }
            for wallRect in self.wallRectArray{
                if wallRect.intersects(self.playerView.frame){
                    self.gameCheck(result: "gameover", message: "壁に当たりました")
                    return
                }
            }
            
            if self.goalView.frame.intersects(self.playerView.frame){
                self.gameCheck(result: "clear", message: "クリアしました！")
                return
            }
            self.playerView.center = CGPoint(x: posX, y: posY)
    }
        
        
        
        playerMotionManager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: handler)
 }
    func gameCheck(result: String, message: String){
        if playerMotionManager.isAccelerometerActive{
            playerMotionManager.stopAccelerometerUpdates()
        }
        
        let gameCheckAlert: UIAlertController = UIAlertController(title: result, message: message, preferredStyle: .alert)
        
        let retryAction = UIAlertAction(title: "もう一度", style: .default, handler: {(action: UIAlertAction!) -> Void in
            self.retry()
        })
        
        gameCheckAlert.addAction(retryAction)
        
        self.present(gameCheckAlert, animated: true, completion: nil)
    }
    
    func retry(){
        playerView.center = startView.center
        if !playerMotionManager.isAccelerometerActive{
            startAccelerometer()
        }
        
        speedx = 0.0
        speedy = 0.0
    }
   


}

