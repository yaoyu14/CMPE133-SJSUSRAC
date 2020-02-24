//
//  MacawChartView.swift
//  SJSUSRAC
//
//  Created by Daniel Lee on 10/28/19.
//  Copyright © 2019 Daniel Lee. All rights reserved.
//

import Foundation
import Macaw

class MacawChartView: MacawView {
    
    static let lastFiveHours = createDummydata()
    static let maxValue = 500
    static let maxValueLineHeight = 180
    static let lineWidth: Double = 687
    
    static let dataDivisor = Double(maxValue/maxValueLineHeight)
    static let adjustedData: [Double] = lastFiveHours.map({ $0.numberOfVisitors/dataDivisor})
    static var animations: [Animation] = []
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(node: MacawChartView.createChart(), coder: aDecoder)
        backgroundColor = .clear
    }
    
    private static func createChart() -> Group {
        var items: [Node] = addYAxisItems() + addXAxisItems()
        items.append(createBars())
        return Group(contents: items, place: .identity)
    }
    
    private static func addYAxisItems() -> [Node] {
        let maxLines = 6
        let lineInterval = Int(maxValue/maxLines)
        let yAxisHeight: Double = 200
        let lineSpacing: Double = 30
        
        var newNodes: [Node] = []
        for i in 1...maxLines {
            let y = yAxisHeight - (Double(i) * lineSpacing)
            let valueLine = Line(x1: -5, y1: y, x2: lineWidth, y2: y).stroke(fill: Color.black.with(a: 0.10))
            let valueText = Text(text: "\(i * lineInterval)", align: .max, baseline: .mid, place: .move(dx: -10,dy: y))
            valueText.fill = Color.black
            
            //newNodes.append(valueLine)
           // newNodes.append(valueText)
        }
        let yAxis = Line(x1: 0, y1: 0, x2: 0, y2: yAxisHeight).stroke(fill: Color.black.with(a: 0.25))
        //newNodes.append(yAxis)
        return newNodes
    }
    
    private static func addXAxisItems() -> [Node] {
        let chartBaseY: Double = 200
        
        var newNodes: [Node] = []
        
        for i in 1...adjustedData.count {
            let x = (Double(i) * 35)
            let valueText = Text(text: lastFiveHours[i-1].hours, align: .max, baseline: .mid, place: .move(dx: x, dy: chartBaseY+15))
            valueText.fill = Color.black
            newNodes.append(valueText)
            
        }
        let xAxis = Line(x1: 0, y1: chartBaseY, x2: lineWidth, y2: chartBaseY).stroke(fill: Color.black.with(a: 0.25))
        newNodes.append(xAxis)
        return newNodes
    }
    
    private static func createBars() -> Group {
        let fill = LinearGradient(degree: 90, from: Color(val: 0x00b1e1), to: Color(val: 0x00b1e1).with(a: 0.55))
        let items = adjustedData.map {_ in Group()}

        animations = items.enumerated().map { (i: Int, item: Group) in
            item.contentsVar.animation(delay: Double(i) * 0.1) { t in
                let height = adjustedData[i] * t
                let rect = Rect(x: Double(i) * 35 + 12, y: 200 - height, w: 30, h: height)
                return [rect.fill(with: fill)]
            }
        }
        
        
        return items.group()
    }
    
    static func playAnimation() {
        animations.combine().play()
    }
    
    
    private static func createDummydata() -> [BusyHours] {
        let one = BusyHours(hours: "6", numberOfVisitors: 50)
        let two = BusyHours(hours: "7", numberOfVisitors: 75)
        let three = BusyHours(hours: "8", numberOfVisitors: 110)
        let four = BusyHours(hours: "9", numberOfVisitors: 150)
        let five = BusyHours(hours: "10", numberOfVisitors: 160)
        let six = BusyHours(hours: "11", numberOfVisitors: 180)
        let seven = BusyHours(hours: "12", numberOfVisitors: 180)
             let eight = BusyHours(hours: "13", numberOfVisitors: 160)
           let nine = BusyHours(hours: "14", numberOfVisitors: 150)
                let ten = BusyHours(hours: "15", numberOfVisitors: 120)
        let eleven = BusyHours(hours: "16", numberOfVisitors: 200)
        let twelve = BusyHours(hours: "17", numberOfVisitors: 300)
        let thirteen = BusyHours(hours: "18", numberOfVisitors: 400)
        let fourteen = BusyHours(hours: "19", numberOfVisitors: 400)
        let fifteen = BusyHours(hours: "20", numberOfVisitors: 500)
        let sixteen = BusyHours(hours: "21", numberOfVisitors: 350)
             let seventeen = BusyHours(hours: "22", numberOfVisitors: 300)
           let eighteen = BusyHours(hours: "23", numberOfVisitors: 100)
          let nineteen = BusyHours(hours: "24", numberOfVisitors: 50)
        return [one, two, three, four, five, six, seven, eight, nine, ten, eleven, twelve, thirteen, fourteen, fifteen, sixteen, seventeen, eighteen, nineteen]
    }
}
