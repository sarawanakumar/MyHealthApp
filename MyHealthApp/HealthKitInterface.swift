//
//  HealthKitInterface.swift
//  MyHealthApp
//
//  Created by Sarawanak on 9/25/18.
//  Copyright © 2018 ThoughtWorks. All rights reserved.
//

import HealthKit

class HealthKitInterface {
    let healthKitDataStore: HKHealthStore?

    let genderChar = HKCharacteristicType.characteristicType(forIdentifier: .biologicalSex)

    var readableCharTypes: Set<HKCharacteristicType>?

    static let shared = HealthKitInterface()

    private init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthKitDataStore = HKHealthStore()
        } else {
            print("Device doesn't support healthkit")
            healthKitDataStore = nil
        }
    }

    func requestReadAuthorization(for charTypes: Set<HKObjectType>, completion: @escaping (String?) -> ()) {
        healthKitDataStore?.requestAuthorization(toShare: nil, read: charTypes, completion: { (success, error) in
            if let error = error {
                completion(error.localizedDescription)
            } else {
                completion(nil)
            }
        })
    }

    func requestWriteAuth(for types: Set<HKSampleType>, completion: @escaping (String?) -> ()) {
        healthKitDataStore?.requestAuthorization(toShare: types, read: nil, completion: { (success, error) in
            if let error = error {
                completion(error.localizedDescription)
            } else {
                completion(nil)
            }
        })
    }


    func writeHeartRate(values: [(Int
        , Date)]) {
        let heartCountUnit = HKUnit.count()
        var objects = [HKObject]()
        for val in values {
            let bpm = HKQuantity(unit: heartCountUnit.unitDivided(by: HKUnit.minute()), doubleValue: Double(val.0))
            let bpmType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
            let heartSample = HKQuantitySample(type: bpmType, quantity: bpm, start: val.1, end: val.1)
            objects.append(heartSample)
        }


        healthKitDataStore?.save(objects, withCompletion: { (success, message) in
            if success {
                print("WRITE SUCESS: Heart Rate")
            } else {
                print("Unable to write")
            }
        })
    }

    func readGenderType() -> String {
        do {
            let genderType = try healthKitDataStore?.biologicalSex()
            let gender = genderType?.biologicalSex
            if gender == .female {
                print("Gender is female")
                return "Female"
            } else if gender == .male {
                print("Gender is male")
                return "Male"
            } else if gender == .notSet {
                print("Gender is not available")
                return "Not Set"
            } else if gender == HKBiologicalSex.other {
                return "Other"
            }
        } catch let e {
            print(e.localizedDescription)
            return "Not Available"
        }
        return "Not Available"
    }

    func readDob() -> String {
        do {
            let dob = try healthKitDataStore?.dateOfBirthComponents()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MMM-yyyy"
            return dateFormatter.string(from: dob!.date!)
        } catch let e {
            print(e.localizedDescription)
        }
        return "Not Available"
    }

    func readBloodType() -> String {
        do {
            let bloodType = try healthKitDataStore?.bloodType()
            let type = bloodType?.bloodType
            return type?.typeString ?? "Not Available"
        } catch let e {
            print(e.localizedDescription)
        }
        return "Not Available"
    }

    func readHeartRate() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)

        let query = HKAnchoredObjectQuery(type: heartRateType!, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error) in
            if let samples = samples {
                for s in samples {
                    print("\(s)")
                }
            }
        }

        healthKitDataStore?.execute(query)
    }

    func readSamples(of type: HKQuantityType, completion: @escaping ([HKQuantitySample]?, Error?) -> ()) {
        let query = HKAnchoredObjectQuery(type: type, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error) in
            if let samples = samples {
                completion(samples as? [HKQuantitySample], nil)
            } else if let error = error {
                completion(nil, error)
            }
        }

        healthKitDataStore?.execute(query)
    }

    func readSamples(of type: Set<HKQuantityType>, completion: @escaping ([HKQuantitySample]?, Error?) -> ()) {
//        let query = HKAnchoredObjectQuery(type: type, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error) in
//            if let samples = samples {
//                completion(samples as? [HKQuantitySample], nil)
//            } else if let error = error {
//                completion(nil, error)
//            }
//        }
//
//        healthKitDataStore?.execute(query)
//        
    }
}

enum HealthCharacteristic {
    case gender
    case dateOfBirth
    case bloodType
    case heartRate
    case bp
    case bloodGlucose
    case cycling
    case steps

    var type: Set<HKObjectType> {
        switch self {
        case .gender:
            return [.characteristicType(forIdentifier: .biologicalSex)!]
        case .dateOfBirth:
            return [.characteristicType(forIdentifier: .dateOfBirth)!]
        case .bloodType:
            return [.characteristicType(forIdentifier: .bloodType)!]
        case .heartRate:
            return [.quantityType(forIdentifier: .heartRate)!]
        case .bp:
            return [.quantityType(forIdentifier: .bloodPressureSystolic)!, .quantityType(forIdentifier: .bloodPressureDiastolic)!]
        case .bloodGlucose:
            return [.quantityType(forIdentifier: .bloodGlucose)!]
        case .cycling:
            return [.quantityType(forIdentifier: .distanceCycling)!]
        case .steps:
            return [.quantityType(forIdentifier: .stepCount)!]
        }
    }

    static var allReadableTypes: Set<HKObjectType> {
        var types = Set<HKObjectType>()
        types = types.union(HealthCharacteristic.gender.type)
        types = types.union(HealthCharacteristic.dateOfBirth.type)
        types = types.union(HealthCharacteristic.bloodType.type)
        types = types.union(HealthCharacteristic.heartRate.type)
        types = types.union(HealthCharacteristic.bp.type)
        types = types.union(HealthCharacteristic.bloodGlucose.type)

        return types
    }
}

extension HKBloodType {
    var typeString: String {
        switch self {
        case .notSet:
            return "Not set"
        case .aPositive:
            return "A+"
        case .aNegative:
            return "A-"
        case .bPositive:
            return "B+"
        case .bNegative:
            return "B-"
        case .abPositive:
            return "AB+"
        case .abNegative:
            return "AB-"
        case .oPositive:
            return "O+"
        case .oNegative:
            return "O-"
        }
    }
}
