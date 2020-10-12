// Copyright © 2020 Danil Gontovnik. All rights reserved.

import UIKit

import Experiments

private final class AnalyticsTracker: ExperimentAnalyticsTracking {
    func log(event: String, parameters: [AnyHashable : Any]?) {
        print("[AnalyticsTracker] log: ", event, parameters ?? [:])
    }
    
    func setUserProperties(_ userProperties: [AnyHashable : Any]) {
        print("[AnalyticsTracker] setUserProperties: ", userProperties)
    }
}

private struct ButtonColorExperiment: Experiment {
    typealias Group = ButtonColorExperimentGroup

    static let key = "button_color_experiment"
}

private enum ButtonColorExperimentGroup: String, ExperimentGroup {
    case red,
    blue,
    green
}

extension ButtonColorExperimentGroup {
    func toColor() -> UIColor {
        switch self {
        case .red:
            return .red
        case .green:
            return .green
        case .blue:
            return .blue
        }
    }
}

final class ViewController: UIViewController {

    // MARK: - Vars

    private let experimentService = ExperimentService(userDefaults: .standard, analyticsTracker: AnalyticsTracker())

    private let button = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        experimentService.registerExperiment(ButtonColorExperiment.self)

        button.addTarget(self, action: #selector(ViewController.showExperimentsDebug), for: .touchUpInside)
        button.setTitle("Open Experiment Service Debug", for: .normal)
        button.tintColor = experimentService.allocatedGroup(for: ButtonColorExperiment.self).toColor()
        button.frame = view.bounds
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(button)
    }

    // MARK: -

    @objc
    private func showExperimentsDebug() {
        let viewModel = ExperimentsDebugViewModel(experimentService: experimentService)
        let viewController = ExperimentsDebugViewController(viewModel: viewModel)
        viewController.title = "Experiments Debug"
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ViewController.dismissExperimentsDebug))
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true, completion: nil)
    }

    @objc
    private func dismissExperimentsDebug() {
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
}

