//
//  AppDelegate.swift
//
//  Copyright © 2017-2022 Doug Russell. All rights reserved.
//

@preconcurrency import Cocoa
import AX
import ScreenReader

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private lazy var screenReader: ScreenReader = {
        ScreenReader(dependencies: makeDependencies())
    }()
    private func makeDependencies() -> Dependencies {
        .init(
            screenReaderDependenciesFactory: {
                .init(
                    isTrusted: { AX.isTrusted(promptIfNeeded:$0) },
                    runningApplicationsFactory: {
                        await WorkspaceRunningApplications()
                    }
                )
            },
            serverProviderDependenciesFactory: {
                .init(
                    inclusionListFactory: {
                        [
                            //"com.apple.finder",
                        ]
                    },
                    exclusionListFactory: {
                        [
                            "com.apple.voiceover",
                            "com.apple.webkit.databases",
                            "com.apple.webkit.networking",
                            "com.google.Keystone.Agent",
                        ]
                    }
                )
            }
        )
    }
    func applicationDidFinishLaunching(_ notification: Notification) {
        let screenReader = self.screenReader
        Task.detached {
            _ = await MainActor.run {
                NSApplication.shared.setActivationPolicy(.prohibited)
            }
            do {
                await screenReader.confirmTrust()
                try await screenReader.start()
            } catch {
                exit(1)
            }
        }
    }
}
