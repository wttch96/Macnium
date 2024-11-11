//
//  AccessibilityApplication.swift
//  Macnium
//
//  Created by Wttch on 2024/11/10.
//
import AppKit

/// 具有指定运行应用程序的辅助功能对象
struct AccessibilityApplication {
    /// 元素根节点
    let root: AccessibilityElement

    /// 使用具有指定进程 ID 的应用程序创建顶级辅助功能对象
    /// - Parameter
    ///    - pid: 应用程序的进程 ID
    init(pid: pid_t) {
        let element = AXUIElementCreateApplication(pid)
        self.root = AccessibilityElement(element)
    }
}

extension AccessibilityApplication {
    /// 使用具有指定运行应用程序的辅助功能对象创建顶级辅助功能对象
    init(application: NSRunningApplication) {
        self.init(pid: application.processIdentifier)
    }

    /// 使用具有指定 bundle identifier 的应用程序创建顶级辅助功能对象
    init?(withBundleIdentifier: String) {
        guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: withBundleIdentifier).first else {
            return nil
        }

        self.init(pid: app.processIdentifier)
    }
}

extension AccessibilityApplication {
    func findElement(matching predicate: (AccessibilityElement) -> Bool) -> AccessibilityElement? {
        return root.find { predicate($0) }
    }

    func visit(_ element: AccessibilityElement, _ deep: Int, _ block: (AccessibilityElement, Int) throws -> Void) throws {
        try block(element, deep)
        if try element.role == .button {
            element.perform(.press)
            // wait 1s
            usleep(1000000)
            print("Children", element.children)
        }
        for element in element.children {
            try visit(element, deep + 1, block)
        }
    }
}
