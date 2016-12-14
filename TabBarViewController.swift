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
import CoreMotion

class TabBarViewController: UITabBarController {
  
    fileprivate let carePlanStoreManager = CarePlanStoreManager.sharedCarePlanStoreManager
    fileprivate let carePlanData: CarePlanData
    fileprivate var symptomTrackerViewController: OCKSymptomTrackerViewController? = nil
    fileprivate var insightsViewController: OCKInsightsViewController? = nil
    fileprivate var connectViewController:OCKConnectViewController? = nil
    fileprivate var insightChart: OCKBarChart? = nil
    
    required init?(coder aDecoder: NSCoder){
        carePlanData = CarePlanData(carePlanStore: carePlanStoreManager.store)
        super.init(coder:aDecoder)
        
        carePlanStoreManager.delegate = self
        carePlanStoreManager.updateInsights()
        
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
        viewController.maskImageTintColor = UIColor.red
        viewController.tabBarItem = UITabBarItem(title: "UpRight Training", image: UIImage(named: "StandingMan"), selectedImage: UIImage(named: "StandingMan"))
        viewController.title = "UpRight Training"
        viewController.view.backgroundColor = UIColor.darkYellow()
        return UINavigationController(rootViewController: viewController)
    }
    
    
    fileprivate func createSymptomTrackerStack() -> UINavigationController {
    let viewController = OCKSymptomTrackerViewController(carePlanStore: carePlanStoreManager.store)
        viewController.delegate = self
        viewController.progressRingTintColor = UIColor.darkGreen()
        
        symptomTrackerViewController = viewController
        viewController.tabBarItem = UITabBarItem(title: "Balance Assessment", image: UIImage(named: "barbell"), selectedImage: UIImage.init(named: "barbell.png"))
        viewController.title = "Balance Assessment"
   return UINavigationController(rootViewController: viewController)
        
 }
   fileprivate func createInsightsStack() -> UINavigationController {
    let viewController = OCKInsightsViewController(insightItems: [OCKInsightItem.emptyInsightsMessage()],
    headerTitle: "UpRight Progress", headerSubtitle: "")
    insightsViewController = viewController
    
    viewController.tabBarItem = UITabBarItem(title: "Insights", image: UIImage(named: "LineChart"), selectedImage: UIImage.init(named: "Line Chart"))
    viewController.title = "Insights"
    return UINavigationController(rootViewController: viewController)
    }
    
    fileprivate func createConnectStack() -> UINavigationController {
     let viewController = OCKConnectViewController(contacts: carePlanData.contacts)
        viewController.delegate = self
        viewController.tabBarItem = UITabBarItem(title: "Show off", image: UIImage(named: "LikeIt"), selectedImage: UIImage.init(named: "LikeIt"))
        viewController.title = "Show off"
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
        
       guard reason == .completed else { return }
       guard let symptomTrackerViewController = symptomTrackerViewController,
        let event = symptomTrackerViewController.lastSelectedAssessmentEvent else { return }
       
        let carePlanResult = carePlanStoreManager.buildCarePlanResultFrom(taskResult: taskViewController.result)
        carePlanStoreManager.store.update(event,with:carePlanResult,state:.completed) {
            success, _, error in
            if !success {
                print(error?.localizedDescription)
            }
        }
    }
}
// MARK: - CarePlanStoreManagerDelegate
extension TabBarViewController: CarePlanStoreManagerDelegate {
    func carePlanStore(_ store: OCKCarePlanStore, didUpdateInsights insights: [OCKInsightItem]) {
        if let trainingPlan = (insights.filter { $0.title == "UpRight Training Plan" }.first) {
            insightChart = trainingPlan as? OCKBarChart
        }
        
        insightsViewController?.items = insights
    }
}
// MARK: - OCKConnectViewControllerDelegate
extension TabBarViewController: OCKConnectViewControllerDelegate {
    
    func connectViewController(_ connectViewController: OCKConnectViewController,
                               didSelectShareButtonFor contact: OCKContact,
                               presentationSourceView sourceView: UIView?) {
        let document = carePlanData.generateDocumentWith(chart: insightChart)
        let activityViewController = UIActivityViewController(activityItems: [document.htmlContent],
                                                              applicationActivities: nil)
        
        present(activityViewController, animated: true, completion: nil)
    }
}
