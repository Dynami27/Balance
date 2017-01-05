//
//  AssessmentFactory.swift
//  UpRight-1
//
//  Created by Khalid Mohamed on 12/5/16.
//  Copyright © 2016 Khalid Mohamed. All rights reserved.
//

import ResearchKit
import CoreMotion

struct AssessmentFactory {
    
 static func stepCountAssessment() -> ORKTask {
let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
    
let unit = HKUnit(from: "count")
    let answerFormat = ORKHealthKitQuantityTypeAnswerFormat(quantityType: quantityType, unit: unit, style: .integer)
    
    //Create a question.
let title = "Estimate your fall Risk"
let text = "This assessment measure how fast you walk to estimate your fall risk. Start from a sitting position stand walk 10 feet turn around and walk back to sitting position. Do this assessment with whatever assistance device you normally walk with. IMPORTANT NOTE: IF YOU ARE UNSTEADY OR FEEL THAT YOU ARE UNSTEADT DO NOT PERFORM THIS ASSESSEMENT. MAKE SURE YOU ARE ABSOLUTELY SAFE WHEN PERFORM THIS ASSESSMENT"
let questionStep = ORKQuestionStep(identifier: "Timed Get up and Go", title: title, text: text, answer: answerFormat)
questionStep.isOptional = false
    
    //Create an ordered task with a single question
return ORKOrderedTask(identifier: "Step Count", steps: [questionStep])
    }
    
  static func timedWalkAssessment() -> ORKTask {
       return ORKOrderedTask.shortWalk(withIdentifier: "Short Walk Assessment", intendedUseDescription: "Estimate your fall Risk", numberOfStepsPerLeg: 20, restDuration: 60, options: .excludeHeartRate)
    }
   }
