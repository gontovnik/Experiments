// Copyright © 2020 Danil Gontovnik. All rights reserved.

import Foundation

public class ExperimentService: ExperimentServiceProtocol, ExperimentServiceDebugProtocol {

    // MARK: - Vars

    private let storage: KeyValueStoring
    private let analyticsTracker: ExperimentAnalyticsTracking

    // MARK: - Init

    public init(storage: KeyValueStoring, analyticsTracker: ExperimentAnalyticsTracking) {
        self.storage = storage
        self.analyticsTracker = analyticsTracker
    }

    // MARK: -

    public func registerExperiment<E: Experiment>(_ experiment: E.Type) {
        allocateGroupIfNeeded(for: experiment)
        registeredExperiments.append(RegisteredExperimentDebug(experiment: experiment))
    }

    public func allocatedGroup<E: Experiment>(for experiment: E.Type) -> E.Group {
        return allocateGroupIfNeeded(for: experiment)
    }

    // MARK: -

    @discardableResult func allocateGroupIfNeeded<E: Experiment>(for experiment: E.Type) -> E.Group {
        if let groupRaw = allocatedGroupRawForExperiment(withKey: experiment.key), let group = E.Group(rawValue: groupRaw) {
            return group
        }
        return allocateGroup(for: experiment)
    }

    @discardableResult func allocateGroup<E: Experiment>(for experiment: E.Type) -> E.Group {
        let group = E.Group.random()
        allocateGroup(experimentKey: experiment.key, groupRaw: group.rawValue)
        return group
    }

    // MARK: - ExperimentServiceDebugProtocol

    var registeredExperiments = [RegisteredExperimentDebug]()

    func allocatedGroupRawForExperiment(withKey key: String) -> String? {
        return storage.string(forKey: key)
    }

    func allocateGroup(experimentKey: String, groupRaw: String) {
        storage.set(groupRaw, forKey: experimentKey)

        analyticsTracker.setUserProperties([
            experimentKey: groupRaw
        ])
        analyticsTracker.log(event: "\(experimentKey)_registered", parameters: nil)
    }
}
