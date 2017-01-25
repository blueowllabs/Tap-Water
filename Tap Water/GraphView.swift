//
//  GraphView.swift
//  WaterUp
//
//  Created by Stephen Kyles on 8/16/15.
//  Copyright (c) 2015 Blue Owl Labs. All rights reserved.
//

import UIKit

@IBDesignable class GraphView: UIView {
    var graphPoints:[Int] = [0,0,0,0,0,0,0]
    var datePoints: NSMutableArray = []
    var labelPoints: NSMutableArray = []
    
    override func draw(_ rect: CGRect) {
        let width = rect.width
        let height = rect.height
        
        graphPoints = getPastSevenDays(Date()) as! [Int]
        graphPoints[graphPoints.count-1] = GetCurrentDay().totalGlassesDrank
        
        //calculate the x point
        let margin:CGFloat = 20.0
        let columnXPoint = { (column:Int) -> CGFloat in
            //Calculate gap between points
            let spacer = (width - margin*2 - 4) /
                CGFloat((self.graphPoints.count - 1))
            var x:CGFloat = CGFloat(column) * spacer
            x += margin + 2
            return x
        }
        
        // calculate the y point
        let topBorder:CGFloat = 50
        let bottomBorder:CGFloat = 50
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = graphPoints.max()!
        let columnYPoint = { (graphPoint:Int) -> CGFloat in
            if CGFloat(graphPoint) == 0 {
                return graphHeight + topBorder/2
            }
            var y:CGFloat = CGFloat(graphPoint) /
                CGFloat(maxValue) * graphHeight
            y = graphHeight + topBorder - y // Flip the graph
            return y
        }

        // draw the line graph
        UIColor.black.setFill()
        UIColor.black.setStroke()
        
        //set up the points line
        let graphPath = UIBezierPath()
        
        //go to start of line
        graphPath.move(to: CGPoint(x:columnXPoint(0),
            y:columnYPoint(graphPoints[0])))
        
        //add points for each item in the graphPoints array
        //at the correct (x, y) for the point
        for i in 0..<graphPoints.count {
            let nextPoint = CGPoint(x:columnXPoint(i),
                y:columnYPoint(graphPoints[i]))
            graphPath.addLine(to: nextPoint)
            datePoints.add(nextPoint.x)
            labelPoints.add(nextPoint.y)
        }
        
        //draw the line on top of the clipped gradient
        graphPath.lineWidth = 2.0
        graphPath.stroke()
        
        //Draw the circles on top of graph stroke
        for i in 0..<graphPoints.count {
            var point = CGPoint(x:columnXPoint(i), y:columnYPoint(graphPoints[i]))
            point.x -= 5.0/2
            point.y -= 5.0/2
            
            let circle = UIBezierPath(ovalIn:
                CGRect(origin: point,
                    size: CGSize(width: 5.0, height: 5.0)))
            circle.fill()
        }
        
        setupGraphDisplay()
    }
    
    func setupGraphDisplay() {
        self.setNeedsDisplay()
        
        //4 - get today's day number
        let calendar = Calendar.current
        let componentOptions:NSCalendar.Unit = .weekday
        let components = (calendar as NSCalendar).components(componentOptions,
            from: Date())
        var weekday = components.weekday
        
        let days = ["Sa", "Su", "M", "Tu", "W", "Th", "F"]
        
        //5 - set up the day name labels with correct day
        for i in Array((1...days.count).reversed()) {
            if let labelView = self.viewWithTag(i) as? UILabel {
                labelView.center = CGPoint(x: datePoints[i-1] as! CGFloat, y: self.frame.height - 10)
                                
                if weekday == 7 {
                    weekday = 0
                }
                labelView.text = days[(weekday!-1)]
                if weekday! < 0 {
                    weekday = days.count - 1
                }
            }
        }
        
        for i in Array((1...graphPoints.count).reversed()) {
            if let labelView = self.viewWithTag(i + 100) as? UILabel {
                labelView.center = CGPoint(x: datePoints[i-1] as! CGFloat, y: (labelPoints[i-1] as! CGFloat) - 30)
                labelView.text = NSString(format: "%i", graphPoints[i-1]) as String
            }
        }
    }
}
