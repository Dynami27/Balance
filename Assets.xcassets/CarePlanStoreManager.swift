//
//  CarePlanStoreManager.swift
//  UpRight-1
//
//  Created by Khalid Mohamed on 12/5/16.
//  Copyright © 2016 Khalid Mohamed. All rights reserved.
//

import CareKit
import ResearchKit

class CarePlanStoreManager: NSObject {
    var store: OCKCarePlanStore
    
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
    }
    func buildCarePlanResultFrom(taskResult: ORKTaskResult) -> OCKCarePlanEventResult {
        // 1
        guard let firstResult = taskResult.firstResult as? ORKStepResult,
            let stepResult = firstResult.results?.first else {
                fatalError("Unexepected task results")
        }
        
        // 2
        if let numericResult = stepResult as? ORKNumericQuestionResult,
            let answer = numericResult.numericAnswer {
            return OCKCarePlanEventResult(valueString: answer.stringValue, unitString: numericResult.unit, userInfo: nil)
        }
        
        // 3
        fatalError("Unexpected task result type")
    }
}


