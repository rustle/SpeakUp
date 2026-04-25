//
//  AppDelegate.swift
//
//  Copyright © 2017-2026 Doug Russell. All rights reserved.
//

import AppKit
import AX
import ScreenReader

@MainActor
@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private lazy var screenReader: ScreenReader = {
        ScreenReader(dependencies: makeDependencies())
    }()

    private func makeDependencies() -> Dependencies {
        .init(
            screenReaderDependenciesFactory: {
                .init(
                    isTrusted: AX.isTrusted(promptIfNeeded:),
                    runningApplicationsFactory: {
                        WorkspaceRunningApplications()
                    },
                    focusedRunningApplicationFactory: {
                        WorkspaceFocusedRunningApplication()
                    },
                    outputContextsFactory: {
                        [
                            SpeechInProcess(),
                            Text(),
                        ]
                    },
                    commandSourcesFactory: {
                        [
                            try KeyboardCommandSource(
                                capsLock: .init(),
                                bindings: defaultKeyboardBindings
                            )
                        ]
                    }
                )
            },
            serverProviderDependenciesFactory: {
                .init(
                    inclusionListFactory: {
                        [
                            //"com.apple.finder",
                            //"org.mozilla.firefox",
                            //"com.apple.mobilesms",
                        ]
                    },
                    exclusionListFactory: {
                        [
                            "com.apple.voiceover",
                            "com.apple.webkit.databases",
                            "com.apple.webkit.networking",
                            "com.google.Keystone.Agent",
                            "com.apple.webkit.gpu",
                            "com.google.Keystone.Agent",
                            "com.apple.accessibility.axvisualsupportagent",
                            "com.apple.authenticationservicescore.authenticationservicesagent",
                            "com.apple.windowmanager",
                            "com.apple.speech.speechsynthesisserverxpc",
                            "com.apple.authenticationservicescore.authenticationservicesagent",
                        ]
                    }
                )
            }
        )
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let screenReader = self.screenReader
        Task { @MainActor in
            NSApplication.shared.setActivationPolicy(.prohibited)
            do {
                await screenReader.confirmTrust()
                try await screenReader.start()
            } catch {
                exit(1)
            }
        }
    }
}
