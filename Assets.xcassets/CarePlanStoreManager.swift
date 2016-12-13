//
//  CarePlanStoreManager.swift
//  UpRight-1
//
//  Created by Khalid Mohamed on 12/5/16.
//  Copyright © 2016 Khalid Mohamed. All rights reserved.
//

import CareKit
import ResearchKit

protocol CarePlanStoreManagerDelegate: class {
    func carePlanStore(_: OCKCarePlanStore, didUpdateInsights insights: [OCKInsightItem])
}
class CarePlanStoreManager: NSObject {
    var store: OCKCarePlanStore
    weak var delegate: CarePlanStoreManagerDelegate?
    static let sharedCarePlanStoreManager = CarePlanStoreManager()
    
    override init() {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last else {
            fatalError("Failed to obtain Documents directory!")
        }
        
        
        
        let storeURL = documentDirectory.appendingPathComponent("CarePlanStore")
        
        if !fileManager.fileExists(atPath: storeURL.path) {
            try! fileManager.createDirectory(at: storeURL, withIntermediateDirectories: true, attributes: nil)
        }
    
        store = OCKCarePlanStore(persistenceDirectoryURL: storeURL)
        super.init()
        store.delegate = self
    }
    func buildCarePlanResultFrom(taskResult: ORKTaskResult) -> OCKCarePlanEventResult {
        guard let firstResult = taskResult.firstResult as? ORKStepResult,
            let stepResult = firstResult.results?.first else {
                fatalError("Unexepected task results")
        }
        if let numericResult = stepResult as? ORKNumericQuestionResult,
            let answer = numericResult.numericAnswer {
            return OCKCarePlanEventResult(valueString: answer.stringValue, unitString: numericResult.unit, userInfo: nil)
        }
        fatalError("Unexpected task result type")
    }
    

func updateInsights() {
    InsightsDataManager().updateInsights { (success, insightItems) in
        guard let insightItems = insightItems, success else { return }
        self.delegate?.carePlanStore(self.store, didUpdateInsights: insightItems)
    }
}
}
extension CarePlanStoreManager: OCKCarePlanStoreDelegate {
    func carePlanStore(_ store: OCKCarePlanStore, didReceiveUpdateOf event: OCKCarePlanEvent) {
        updateInsights()
    }
}
