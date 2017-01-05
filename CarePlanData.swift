//
//  CarePlanData.swift
//  UpRight-1
//
//  Created by Khalid Mohamed on 12/5/16.
//  Copyright © 2016 Khalid Mohamed. All rights reserved.
//


import CareKit



enum ActivityIdentifer : String {
  case exerciseOne = "Stand on one foot"
  case exerciseTwo = "Heel to toe walk"
  case exerciseThree = "Balance Walk"
  case TaiChi = "Tai Chi"
  case timedWalk
  case timedWalkTest
   
    
    }

class CarePlanData: NSObject {
    let carePlanStore: OCKCarePlanStore
    let contacts =
        [OCKContact(contactType: .personal,
                    name: "Dorton",
                    relation: "Son",
                    tintColor: nil,
                    phoneNumber: CNPhoneNumber(stringValue: "888-555-5512"),
                    messageNumber: CNPhoneNumber(stringValue: "888-555-5512"),
                    emailAddress: "thebrisketguy@example.com",
                    monogram: "",
                    image: UIImage(named: "Dorton.jpg")),
         OCKContact(contactType: .careTeam,
                    name: "Fredrick Ohen",
                    relation: " Physical Therapist",
                    tintColor: nil,
                    phoneNumber: CNPhoneNumber(stringValue: "888-555-5235"),
                    messageNumber: CNPhoneNumber(stringValue: "888-555-5235"),
                    emailAddress: "freddieOH@example.com",
                    monogram: "FO",
                    image: UIImage(named: "FreddieOh.jpg")),
         OCKContact(contactType: .careTeam,
                    name: "Dr William Garner",
                    relation: "Primary Care Physician",
                    tintColor: nil,
                    phoneNumber: CNPhoneNumber(stringValue: "888-555-2351"),
                    messageNumber: CNPhoneNumber(stringValue: "888-555-2351"),
                    emailAddress: "Dr.Garner@example.com",
                    monogram: "WG",
                    image: UIImage(named: "willgarner.jpeg"))]
    
    class func dailyScheduleRepeating(occurencesPerDay: UInt) -> OCKCareSchedule {
        return OCKCareSchedule.dailySchedule(withStartDate: DateComponents.firstDateOfCurrentWeek,
                                             occurrencesPerDay: occurencesPerDay)
        
       
    }
    
    
    init(carePlanStore: OCKCarePlanStore) {
        self.carePlanStore = carePlanStore
    
        let exerciseone = Bundle.main.path(forResource: "standup", ofType:"png")
        let firstExercise = URL(fileURLWithPath: exerciseone!)
       // let videoone = Bundle.main.path(forResource:"StandonOneFoot",ofType:"mp4")
       // let firstVideo = URL(fileURLWithPath: videoone!)
       
       let exercisetwo = Bundle.main.path(forResource: "heeltotoewalk", ofType: "jpg")
        let secondExercise = URL(fileURLWithPath: exercisetwo!)
        
        let exercisethree = Bundle.main.path(forResource: "balancewalk" , ofType:"jpg")
        let exerciseURL = URL(fileURLWithPath: exercisethree!)
        
        let exerciseOne = OCKCarePlanActivity(identifier: ActivityIdentifer.exerciseOne.rawValue, groupIdentifier:nil, type: .intervention, title:"Stand on one Foot", text: "10-15 reps", tintColor:UIColor.darkOrange(), instructions:"1. Stand on one foot behind a sturdy chair, holding on for balance 2.Hold for 10 seconds 3.Repeat 10-15 times.",imageURL: firstExercise as URL,schedule:CarePlanData.dailyScheduleRepeating(occurencesPerDay: 3), resultResettable: true, userInfo: nil)
      
        
      let exerciseTwo = OCKCarePlanActivity(
        identifier: ActivityIdentifer.exerciseTwo.rawValue,
        groupIdentifier: nil,
        type: .intervention,
        title: "Heel to toe walk",
        text: " Repeat for 20 steps",
        tintColor: UIColor.darkGreen(),
        instructions: "Having good balance is important for everyday activites such as going up and downstairs 1.Position the heel of one foot just in front of the toes of the other foot. Your heel and toes should touch or almost touch. 2.Choose a spot ahead of you and focus on it to keep you steady as you walk. 3. Take a step. Put your heel just in front of the toe of your other foot. 4.Repeat for 20 steps",
        imageURL: secondExercise as URL ,
        schedule:CarePlanData.dailyScheduleRepeating(occurencesPerDay: 3),
        resultResettable: true,
        userInfo: nil)
        
        
        let exerciseThree = OCKCarePlanActivity(
            identifier: ActivityIdentifer.exerciseThree.rawValue,
            groupIdentifier: nil,
            type: .intervention,
            title: "Balance Walk",
            text: " Repeat for 20 steps, Alternating feet",
            tintColor: UIColor.red,
            instructions: "1.Raise arms to sides, shoulder height. 2.Choose a spot ahead of you and focus on it to keep you steady as you walk 3.Walk in a straight line with one foot in front of the other. 4. As you walk, lift your back leg. Pause for 1 second before stepping forward 5. Repeat for 20 steps, alternating legs.",
            imageURL: exerciseURL as URL ,
            schedule:CarePlanData.dailyScheduleRepeating(occurencesPerDay: 3),
            resultResettable: true,
            userInfo: nil)
        let taiChi = OCKCarePlanActivity(identifier: ActivityIdentifer.TaiChi.rawValue, groupIdentifier: nil, type: .intervention, title: "Tai Chi", text: "Excellent to improve balance", tintColor: UIColor.green, instructions: "Research shows Tai Chi improves balance and prevents Falls", imageURL: nil, schedule: CarePlanData.dailyScheduleRepeating(occurencesPerDay: 1), resultResettable: true, userInfo: nil)
       
        let timedwalkActivity = OCKCarePlanActivity
        .assessment(withIdentifier: ActivityIdentifer.timedWalk.rawValue,
                      groupIdentifier: nil,
                      title: " Timed Walk",
                      text: "Timed Walk assessment",
                       tintColor: UIColor.blue,
                        resultResettable: true,
                       schedule: CarePlanData.dailyScheduleRepeating(occurencesPerDay: 1),
                       userInfo: ["ORKTask": AssessmentFactory.stepCountAssessment()])
       
        let timedWalkTest = OCKCarePlanActivity
            .assessment(withIdentifier: ActivityIdentifer.timedWalkTest.rawValue, groupIdentifier: nil, title: "Timed Walk Test", text: "Balance Assessment", tintColor: UIColor.red, resultResettable: true, schedule: CarePlanData.dailyScheduleRepeating(occurencesPerDay: 1), userInfo: ["ORKTask":AssessmentFactory.timedWalkAssessment()])
        
        
        
        super.init()
        
        for activity in [exerciseOne, exerciseTwo, exerciseThree,taiChi, timedwalkActivity,timedWalkTest] {
            add(activity: activity)
        }
    }
    
        func add(activity: OCKCarePlanActivity) {
            carePlanStore.activity(forIdentifier: activity.identifier) {
                [weak self] (success, fetchedActivity, error) in
                guard success else { return }
                guard let strongSelf = self else { return }
                if let _ = fetchedActivity { return }
                strongSelf.carePlanStore.add(activity, completion: { _ in })
            }
    }
}
        extension CarePlanData {
            func generateDocumentWith(chart: OCKChart?) -> OCKDocument {
                let intro = OCKDocumentElementParagraph(content: "I've been tracking my balance exercise to prevent falls.")
                
                var documentElements: [OCKDocumentElement] = [intro]
                if let chart = chart {
                    documentElements.append(OCKDocumentElementChart(chart: chart))
                }
                
                let document = OCKDocument(title: "Re: Your Progress", elements: documentElements)
                document.pageHeader = "UpRight: Weekly Report"
                
                return document
            }
}




