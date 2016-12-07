//
//  TabBarViewController.swift
//  UpRight-1
//
//  Created by Khalid Mohamed on 12/5/16.
//  Copyright © 2016 Khalid Mohamed. All rights reserved.
//

import UIKit
import ResearchKit
import CareKit

class TabBarViewController: UITabBarController {
  
    fileprivate let carePlanStoreManager = CarePlanStoreManager.sharedCarePlanStoreManager
    fileprivate let carePlanData: CarePlanData
    fileprivate var pedometerTrackerViewController: OCKSymptomTrackerViewController? = nil
    
    required init?(coder aDecoder: NSCoder){
        carePlanData = CarePlanData(carePlanStore: carePlanStoreManager.store)
        super.init(coder:aDecoder)
        let careCardStack = createCareCardStack()
        let symptomTrackerStack = createSymptomTrackerStack()
        let insightsStack = createInsightsStack()
        let connectStack = createConnectStack()
        
        self.viewControllers = [careCardStack,
                                symptomTrackerStack,
                                insightsStack,
                                connectStack]
      
        
        tabBar.tintColor = UIColor.darkOrange()
        tabBar.barTintColor = UIColor.lightGreen()
    }

    fileprivate func createCareCardStack() -> UINavigationController {
        let viewController = OCKCareCardViewController(carePlanStore: carePlanStoreManager.store)
        viewController.maskImage = UIImage(named: "heart")
        viewController.smallMaskImage = UIImage(named: "small-heart")
         viewController.maskImageTintColor = UIColor.darkGreen()
        return UINavigationController(rootViewController: viewController)
    }
    fileprivate func createSymptomTrackerStack() -> UINavigationController {
    let viewController = OCKSymptomTrackerViewController(carePlanStore: carePlanStoreManager.store)
        viewController.delegate = self
        viewController.progressRingTintColor = UIColor.darkGreen()
        
        
        viewController.tabBarItem = UITabBarItem(title: "Symptom Tracker", image: UIImage(named: "symptoms"), selectedImage: UIImage.init(named: "symptoms-filled"))
        viewController.title = "Symptom Tracker"
   return UINavigationController(rootViewController: viewController)
        
 }
   fileprivate func createInsightsStack() -> UINavigationController {
     let viewController = UIViewController()
    
    return UINavigationController(rootViewController: viewController)
    }
    fileprivate func createConnectStack() -> UINavigationController {
       let viewController = UIViewController()
        
    return UINavigationController(rootViewController: viewController)
    }
  }
// MARK: - OCKSymptomTrackerViewControllerDelegate
extension TabBarViewController: OCKSymptomTrackerViewControllerDelegate {
    func symptomTrackerViewController(_ viewController: OCKSymptomTrackerViewController,
                                      didSelectRowWithAssessmentEvent assessmentEvent: OCKCarePlanEvent) {
        guard let userInfo = assessmentEvent.activity.userInfo,
            let task: ORKTask = userInfo["ORKTask"] as? ORKTask else { return }
        
        let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
        taskViewController.delegate = self
        
        present(taskViewController, animated: true, completion: nil)
    }
}
// MARK: - ORKTaskViewControllerDelegate
extension TabBarViewController: ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith
        reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        
        guard let symptomTrackerViewController = createSymptomTrackerStack().viewControllers.first as? OCKSymptomTrackerViewController else {
            fatalError("Unable to create OCKSymptomTrackerViewController ")
        }
        
        
        guard reason == .completed else { return }
      
        let event = symptomTrackerViewController.lastSelectedAssessmentEvent
        let carePlanResult = carePlanStoreManager.buildCarePlanResultFrom(taskResult: taskViewController.result)
        carePlanStoreManager.store.update(event!, with: carePlanResult, state: .completed) {
            success, _, error in
            if !success {
                print(error?.localizedDescription)
            }
        }
    }
}
  
